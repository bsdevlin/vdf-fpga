/*******************************************************************************
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
 This does 3 modes of multiplication:
 - i_ctl = 0 for multiply to get lower products
 - i_ctl = 1 for multiply to get higher products
 - i_ctl = 2 for square

 - i_add_term allows for an addition term to be added to the output products
 */
module multi_mode_multiplier
   #(
     parameter int NUM_ELEMENTS    = 33,
     parameter int DSP_BIT_LEN     = 17,
     parameter int WORD_LEN        = 16,
     parameter int NUM_ELEMENTS_OUT = NUM_ELEMENTS*2
    )
   (
    input  logic                       i_clk,
    input  logic [1:0]                 i_ctl,
    input  logic [DSP_BIT_LEN-1:0]     i_dat_a[NUM_ELEMENTS],
    input  logic [DSP_BIT_LEN-1:0]     i_dat_b[NUM_ELEMENTS],
    input  logic [DSP_BIT_LEN-1:0]     i_add_term[NUM_ELEMENTS],
    output logic [DSP_BIT_LEN-1:0]     o_dat[NUM_ELEMENTS*2]
   );

   localparam int OUT_BIT_LEN = (2*DSP_BIT_LEN - WORD_LEN) + $clog2(2*NUM_ELEMENTS+1);

   logic [OUT_BIT_LEN-1:0]   res[NUM_ELEMENTS*2];
   logic [DSP_BIT_LEN-1:0]   res_int[NUM_ELEMENTS*2];

   logic [OUT_BIT_LEN-1:0]   add_r[NUM_ELEMENTS];
   logic [DSP_BIT_LEN*2-1:0] mul_result[NUM_ELEMENTS*NUM_ELEMENTS];
   logic [OUT_BIT_LEN-1:0]   grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];

   logic [1:0] ctl_r;

   always_ff @ (posedge i_clk) begin
     ctl_r <= i_ctl;
     for (int i = 0; i < NUM_ELEMENTS; i++) begin
       if (i_ctl == 0) begin
         add_r[i] <= 0;
         add_r[i] <= i_add_term[i];
       end else if (i_ctl == 1) begin
         add_r[NUM_ELEMENTS-i-1] <= 0;
         add_r[NUM_ELEMENTS-i-1] <= i_add_term[i] + (i == 0 ? 1 : 0);
       end else if (i_ctl == 2) begin
         add_r[i] <= 0;
         add_r[i] <= i_add_term[i];
       end
     end
   end

   // Instantiate half the multipliers
   // Swap order if we only need top half
   // In square mode we need to swap there products go
   genvar i, j;
   generate
      for (i=0; i<NUM_ELEMENTS; i=i+1) begin : mul_A
         for (j=0; j<NUM_ELEMENTS; j=j+1) begin : mul_B
           if (i+j < NUM_ELEMENTS_OUT) begin

              logic [DSP_BIT_LEN-1:0] mul_a, mul_b;
              always_comb begin
                case(i_ctl)
                  0: begin
                    // Multiply lower half
                    mul_a = i_dat_a[i];
                    mul_b = i_dat_b[j];
                  end
                  1: begin
                    // Multiply upper half
                    mul_a = i_dat_a[NUM_ELEMENTS-i-1];
                    mul_b = i_dat_b[NUM_ELEMENTS-j-1];
                  end
                  2: begin
                    // Square - elements in upper diagonal are reflected horizontally (e.g. i > j)
                    if (i > j) begin
                      mul_a = i_dat_a[i];
                      mul_b = i_dat_b[NUM_ELEMENTS-j-1];
                    end else begin
                      mul_a = i_dat_a[i];
                      mul_b = i_dat_b[j];
                    end
                  end
                endcase
              end

              multiplier #(.A_BIT_LEN(DSP_BIT_LEN),
                         .B_BIT_LEN(DSP_BIT_LEN)
                        ) multiplier (
                          .clk(i_clk),
                          .A(mul_a),
                          .B(mul_b),
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
           case(ctl_r)
            0: begin
              grid[(ii+jj)][(2*ii)]       = mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0];
              grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN];
            end
            1: begin
              grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0];
              grid[(ii+jj)][(2*ii)]       = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN];
            end
            2: begin
              // Up to half way is normal
              if (ii+jj < NUM_ELEMENTS_OUT) begin
                if (ii==jj) begin
                  grid[(ii+jj)][(2*ii)]       = mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0];
                  grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN];
                end else begin
                  grid[(ii+jj)][(2*ii)]       = {mul_result[(NUM_ELEMENTS*ii)+jj][WORD_LEN-1 : 0], 1'b0};
                  grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+jj][2*DSP_BIT_LEN-1 : WORD_LEN-1];
                end  
              end // Everything below takes reflected value
                if (ii==jj) begin
                  grid[(ii+jj)][(2*ii)]       = mul_result[(NUM_ELEMENTS*ii)+(NUM_ELEMENTS-jj-1)][WORD_LEN-1 : 0];
                  grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+(NUM_ELEMENTS-jj-1)][2*DSP_BIT_LEN-1 : WORD_LEN];
                end else begin
                  grid[(ii+jj)][(2*ii)]       = {mul_result[(NUM_ELEMENTS*ii)+(NUM_ELEMENTS-jj-1)][WORD_LEN-1 : 0], 1'b0};
                  grid[(ii+jj+1)][((2*ii)+1)] = mul_result[(NUM_ELEMENTS*ii)+(NUM_ELEMENTS-jj-1)][2*DSP_BIT_LEN-1 : WORD_LEN-1];
                end  
              end
            endcase
         end
      end
   end

   // Sum each column using compressor tree
   generate
      // First and last can always come from grid
      always_comb begin
        res[0] = grid[0][0] + add_r[0];
        res[NUM_ELEMENTS*2-1] = grid[NUM_ELEMENTS*2-1][NUM_ELEMENTS*2-1];
      end

      for (i=1; i<NUM_ELEMENTS*2-1; i=i+1) begin : col_sums
         localparam integer CUR_ELEMENTS = (i < NUM_ELEMENTS) ?
                                              ((i*2)+1) :
                                              ((NUM_ELEMENTS*4) - 1 - (i*2));
         localparam integer GRID_INDEX   = (i < NUM_ELEMENTS) ?
                                              0 :
                                              (((i - NUM_ELEMENTS) * 2) + 1);

         localparam integer TOT_ELEMENTS = CUR_ELEMENTS + (i < NUM_ELEMENTS);

         logic [OUT_BIT_LEN-1:0] terms [TOT_ELEMENTS];
         if (i < NUM_ELEMENTS_OUT)
           always_comb begin
             terms = {grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)], add_r[i]};
           end
         else
           always_comb begin
             terms = grid[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)];
           end

// We could really make to branches or accumulators, and sum the outputs, to save on logic
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
     for (int ii = 0; ii < NUM_ELEMENTS*2; ii++)
       if (ctl_r == 0)
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       else if (ctl_r == 1) // Also on the boundary we propigate the carry
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii < NUM_ELEMENTS_OUT-1 ? res[ii+1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       else
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);

   endgenerate

   always_ff @ (posedge i_clk)
     for (int i = 0; i < NUM_ELEMENTS*2; i++) // Also check for bit overflow here (not on square)
       if (i == NUM_ELEMENTS-1 && ctl_r == 1)
         o_dat[i] <= res_int[i] + res_int[NUM_ELEMENTS][WORD_LEN];
       else if (i == NUM_ELEMENTS && ctl_r == 1)
         o_dat[i] <= res_int[i][WORD_LEN-1:0];
       else
         o_dat[i] <= res_int[i];

endmodule
