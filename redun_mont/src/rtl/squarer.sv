/*******************************************************************************
  Copyright 2019 Supranational LLC

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

module squarer
   #(
     parameter int NUM_ELEMENTS    = 33,
     parameter int A_BIT_LEN       = 17,
     parameter int B_BIT_LEN       = 17,
     parameter int WORD_LEN        = 16,

     parameter int MUL_OUT_BIT_LEN  = A_BIT_LEN + B_BIT_LEN,
     parameter int COL_BIT_LEN      = MUL_OUT_BIT_LEN - WORD_LEN,

     // Extra bits needed for accumulation depends on bit width
     // If one operand is larger than the other, then only need enough extra
     //  bits based on number of larger operands.
     parameter int EXTRA_TREE_BITS  = (COL_BIT_LEN > WORD_LEN) ?
                                       $clog2(NUM_ELEMENTS)    :
                                       $clog2(NUM_ELEMENTS*2),
     parameter int OUT_BIT_LEN      = COL_BIT_LEN + EXTRA_TREE_BITS
    )
   (
    input  logic                       clk,
    input  logic [A_BIT_LEN-1:0]       A[NUM_ELEMENTS],
    input  logic [B_BIT_LEN-1:0]       B[NUM_ELEMENTS],
    output logic [B_BIT_LEN-1:0]       out[2*NUM_ELEMENTS]
   );


   logic [OUT_BIT_LEN-1:0]     Cout[NUM_ELEMENTS*2];
   logic [OUT_BIT_LEN-1:0]     S[NUM_ELEMENTS*2];
   logic [OUT_BIT_LEN-1:0]     res[NUM_ELEMENTS*2];
   logic [OUT_BIT_LEN-1:0]     res_int[NUM_ELEMENTS*2];

   localparam int GRID_PAD_SHORT   = EXTRA_TREE_BITS;
   localparam int GRID_PAD_LONG    = (COL_BIT_LEN - WORD_LEN) +
                                     EXTRA_TREE_BITS;

   logic [MUL_OUT_BIT_LEN-1:0] mul_result[NUM_ELEMENTS*NUM_ELEMENTS];
   logic [OUT_BIT_LEN-1:0]     grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];

   // Instantiate all the multipliers, requires NUM_ELEMENTS^2 muls
   genvar i, j;
   generate
      for (i=0; i<NUM_ELEMENTS; i=i+1) begin : mul_A
         for (j=i; j<NUM_ELEMENTS; j=j+1) begin : mul_B
            multiplier #(.A_BIT_LEN(A_BIT_LEN),
                         .B_BIT_LEN(B_BIT_LEN)
                        ) multiplier (
                                      .clk(clk),
                                      .A(A[i][A_BIT_LEN-1:0]),
                                      .B(B[j][B_BIT_LEN-1:0]),
                                      .P(mul_result[(NUM_ELEMENTS*i)+j])
                                     );
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
         for (jj=ii; jj<NUM_ELEMENTS; jj=jj+1) begin : grid_col
            if( jj == ii ) begin // diagonal cases are used as is
                grid[(ii+jj)][(2*ii)]       = {{GRID_PAD_LONG{ 1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1       :0       ]};
                grid[(ii+jj+1)][((2*ii)+1)] = {{GRID_PAD_SHORT{1'b0}}, 1'b0, mul_result[(NUM_ELEMENTS*ii)+jj][MUL_OUT_BIT_LEN-1:WORD_LEN]};
            end else begin // all non diagonal cases are doubled
                grid[(ii+jj)][(2*ii)]       = {{GRID_PAD_LONG{ 1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-2       :0         ], 1'b0};
                grid[(ii+jj+1)][((2*ii)+1)] = {{GRID_PAD_SHORT{1'b0}},       mul_result[(NUM_ELEMENTS*ii)+jj][MUL_OUT_BIT_LEN-1:WORD_LEN-1]};
            end
         end
      end
   end

   // Sum each column using compressor tree
   generate
      // The first and last columns have only one entry, return in S
      always_comb begin
         Cout[0][OUT_BIT_LEN-1:0]                  = '0;
         Cout[(NUM_ELEMENTS*2)-1][OUT_BIT_LEN-1:0] = '0;

         S[0][OUT_BIT_LEN-1:0]                     =
            grid[0][0][OUT_BIT_LEN-1:0];

         S[(NUM_ELEMENTS*2)-1][OUT_BIT_LEN-1:0]    =
            grid[(NUM_ELEMENTS*2)-1][(NUM_ELEMENTS*2)-1][OUT_BIT_LEN-1:0];

         res[0] = Cout[0] + S[0];
         res[(NUM_ELEMENTS*2)-1] = Cout[(NUM_ELEMENTS*2)-1] + S[(NUM_ELEMENTS*2)-1];
      end

      // Loop through grid parallelogram
      // The number of elements increases up to the midpoint then decreases
      // Starting grid row is 0 for the first half, decreases by 2 thereafter
      // Instantiate compressor tree per column
      for (i=1; i<(NUM_ELEMENTS*2)-1; i=i+1) begin : col_sums
         localparam integer CUR_ELEMENTS = (i < NUM_ELEMENTS) ?
                                              ((i*2)+1) :
                                              ((NUM_ELEMENTS*4) - 1 - (i*2));
         localparam integer GRID_INDEX   = (i < NUM_ELEMENTS) ?
                                              0 :
                                              (((i - NUM_ELEMENTS) * 2) + 1);

         logic [OUT_BIT_LEN-1:0] Cout_col;
         logic [OUT_BIT_LEN-1:0] S_col;

         adder_tree_2_to_1 #(
           .NUM_ELEMENTS(CUR_ELEMENTS),
           .BIT_LEN(OUT_BIT_LEN)
         )
         adder_tree_2_to_1 (
           .terms(grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)]),
           .S(res[i])
         );

      end
   endgenerate
   
   always_comb
     for (int ii = 0; ii < NUM_ELEMENTS*2; ii++)
       res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);

   // Carry proigate on the boundary as we need MSB bits
   always_ff @ (posedge clk)
     for (int ii = 0; ii < NUM_ELEMENTS*2; ii++)
       if (ii == NUM_ELEMENTS-1)
         out[ii] <= res_int[ii][WORD_LEN-1:0];
       else if (ii == NUM_ELEMENTS)
         out[ii] <= res_int[ii] + res_int[ii-1][WORD_LEN];
       else
         out[ii] <= res_int[ii];

endmodule
