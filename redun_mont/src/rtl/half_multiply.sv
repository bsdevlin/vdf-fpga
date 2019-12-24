/*******************************************************************************
  Copyright 2019 Supranational LLC
  Copyright 2019 Benjamin Devlin

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

/*
   Multiply two arrays element by element
   The products are split into low (L) and high (H) values
   The products in each column are summed using compressor trees
   Leave results in carry/sum format

   Example A*B 4x4 element multiply results in 8 carry/sum values

                                           |----------------------------------|
                                           |   B3   |   B2   |   B1   |   B0  |
                                           |----------------------------------|
                                           |----------------------------------|
                                     x     |   A3   |   A2   |   A1   |   A0  |
                                           |----------------------------------|
      -------------------------------------------------------------------------

ctl == 0
       Col
   Row     7        6        5        4        3        2        1        0
    0                                       A00B03L  A00B02L  A00B01L  A00B00L
    1                              A00B03H  A00B02H  A00B01H  A00B00H
    2                              A01B03L  A01B02L  A01B01L  A01B00L
    3                     A01B03H  A01B02H  A01B01H  A01B00H
    4                     A02B03L  A02B02L  A02B01L  A02B00L
    5            A02B03H  A02B02H  A02B01H  A02B00H
    6            A03B03L  A03B02L  A03B01L  A03B00L
    7 + A03B03H  A03B02H  A03B01H  A03B00H
      -------------------------------------------------------------------------
         C7,S7    C6,S6    C5,S5    C4,S4    C3,S3    C2,S2    C1,S1    C0,S0

*/

module half_multiply
   #(
     parameter int NUM_ELEMENTS    = 33,
     parameter int DSP_BIT_LEN     = 17,
     parameter int WORD_LEN        = 16,
     parameter int NUM_ELEMENTS_OUT = NUM_ELEMENTS*2
    )
   (
    input  logic                       clk,
    input  logic                       ctl, // 0 = lower half, 1 = upper half
    input  logic                       i_sqr, // Sqr mode
    input  logic [DSP_BIT_LEN-1:0]     A[NUM_ELEMENTS],
    input  logic [DSP_BIT_LEN-1:0]     B[NUM_ELEMENTS],
    input  logic [DSP_BIT_LEN-1:0]     ADD_i[NUM_ELEMENTS],
    output logic [DSP_BIT_LEN-1:0]     out[NUM_ELEMENTS_OUT]
   );

   localparam int OUT_BIT_LEN      = (2*DSP_BIT_LEN) + $clog2(2*NUM_ELEMENTS+1);

   logic [OUT_BIT_LEN-1:0]     res[NUM_ELEMENTS_OUT];
   logic [DSP_BIT_LEN-1:0]     res_int[NUM_ELEMENTS_OUT];

   logic [OUT_BIT_LEN-1:0]     ADD_r[NUM_ELEMENTS];
   logic [DSP_BIT_LEN*2-1:0] mul_result[NUM_ELEMENTS*NUM_ELEMENTS];
   logic [OUT_BIT_LEN-1:0]   grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];

   logic ctl_r, sqr_r;

   always_ff @ (posedge clk) begin
     ctl_r <= ctl;
     sqr_r <= i_sqr;
     for (int i = 0; i < NUM_ELEMENTS; i++) begin
       if (ctl == 0) begin
         ADD_r[i] <= 0;
         ADD_r[i] <= ADD_i[i];
       end else begin
         ADD_r[NUM_ELEMENTS-i-1] <= 0;
         ADD_r[NUM_ELEMENTS-i-1] <= ADD_i[i] + (i == 0 ? 1 : 0);
       end
     end
   end

   // Instantiate half the multipliers
   // Swap order if we only need top half
   genvar i, j;
   generate
      for (i=0; i<NUM_ELEMENTS; i=i+1) begin : mul_A
         for (j=0; j<NUM_ELEMENTS; j=j+1) begin : mul_B
           if (i+j < NUM_ELEMENTS_OUT) begin
            multiplier #(.A_BIT_LEN(DSP_BIT_LEN),
                         .B_BIT_LEN(DSP_BIT_LEN)
                        ) multiplier (
                          .clk(clk),
                          .A(ctl == 0 ? A[i] : A[NUM_ELEMENTS-i -1]),
                          .B(ctl == 0 ? B[j] : B[NUM_ELEMENTS-j-1]),
                          .P(mul_result[(NUM_ELEMENTS*i)+j])
                         );
            end else begin
              always_comb mul_result[(NUM_ELEMENTS*i)+j] = 0;
            end
         end
      end
   endgenerate

   int ii, jj;
   always_comb begin
      for (ii=0; ii<NUM_ELEMENTS*2; ii=ii+1) begin
         for (jj=0; jj<NUM_ELEMENTS*2; jj=jj+1) begin
            grid[ii][jj] = 0;
         end
      end

      for (ii=0; ii<NUM_ELEMENTS; ii=ii+1) begin : grid_row
         for (jj=0; jj<NUM_ELEMENTS; jj=jj+1) begin : grid_col

            if (ii+jj < NUM_ELEMENTS_OUT) begin
              if (ctl_r == 0) begin
                grid[(ii+jj)][(2*ii)]       = mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0];
                grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN];
              end else begin
                grid[(ii+jj+1)][((2*ii)+1)]        = mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0];
                grid[(ii+jj)][(2*ii)]              = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN];
              end
            end

         end
      end
   end

   // Sum each column using compressor tree
   generate
      always_comb begin
        res[0] = grid[0][0] + ADD_r[0];
      end

      for (i=1; i<NUM_ELEMENTS_OUT; i=i+1) begin : col_sums
         localparam integer CUR_ELEMENTS = (i < NUM_ELEMENTS) ?
                                              ((i*2)+1) :
                                              ((NUM_ELEMENTS*4) - 1 - (i*2));
         localparam integer GRID_INDEX   = (i < NUM_ELEMENTS) ?
                                              0 :
                                              (((i - NUM_ELEMENTS) * 2) + 1);

         localparam integer TOT_ELEMENTS = CUR_ELEMENTS + (i < NUM_ELEMENTS);

         logic [OUT_BIT_LEN-1:0] terms [TOT_ELEMENTS];
         if (i < NUM_ELEMENTS)
           always_comb terms = {grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)], ADD_r[i]};
         else
           always_comb terms = grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)];

           adder_tree_2_to_1 #(
             .NUM_ELEMENTS(TOT_ELEMENTS),
             .BIT_LEN(OUT_BIT_LEN)
           )
           adder_tree_2_to_1 (
             .terms(terms),
             .S(res[i])
           );
      end

   always_comb
     for (int ii = 0; ii < NUM_ELEMENTS_OUT; ii++)
       if (ctl_r == 0)
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       else // Also on the boundary we propigate the carry
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii < NUM_ELEMENTS_OUT-1 ? res[ii+1][OUT_BIT_LEN-1:WORD_LEN] : 0);

   endgenerate

   always_ff @ (posedge clk)
     for (int i = 0; i < NUM_ELEMENTS_OUT; i++) // Also check for bit overflow here (not on square)
       if (i == NUM_ELEMENTS-1 && sqr_r == 0 && ctl_r == 1)
         out[i] <= res_int[i] + res_int[NUM_ELEMENTS][WORD_LEN];
       else if (i == NUM_ELEMENTS && sqr_r == 0 && ctl_r == 1)
         out[i] <= res_int[i][WORD_LEN-1:0];
       else
         out[i] <= res_int[i];

endmodule
