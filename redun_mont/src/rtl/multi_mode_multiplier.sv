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
 This does 3 modes of multiplication, one hot encoded:
 i_ctl[0] for square
 i_ctl[1] for multiply to get lower products
 i_ctl[2] for multiply to get higher products

 i_add_term allows for an addition term to be added to the output products (needed for last stage)

 We calculate (NUM_ELEMENTS_OUT-NUM_ELEMENTS) words past the boundary so that any overflow can be detected when only multiplying
 lower or upper products.

 Use log3 adder trees to try minimize critical path.
 */

module multi_mode_multiplier #(
  parameter int NUM_ELEMENTS     = 33,
  parameter int DSP_BIT_LEN      = 17,
  parameter int WORD_LEN         = 16,
  parameter int NUM_ELEMENTS_OUT = NUM_ELEMENTS*2
)(
  input                          i_clk,
  input                          i_rst,
  input        [2:0]             i_ctl,
  input        [DSP_BIT_LEN-1:0] i_dat_a[NUM_ELEMENTS],
  input        [DSP_BIT_LEN-1:0] i_dat_b[NUM_ELEMENTS],
  input        [DSP_BIT_LEN-1:0] i_add_term[NUM_ELEMENTS],
  output logic [DSP_BIT_LEN-1:0] o_dat[NUM_ELEMENTS*2]
);

localparam int OUT_BIT_LEN = (2*DSP_BIT_LEN - WORD_LEN) + $clog2(2*NUM_ELEMENTS+1);

logic [OUT_BIT_LEN-1:0]   res[NUM_ELEMENTS*2];
logic [DSP_BIT_LEN-1:0]   res_int[NUM_ELEMENTS*2];

logic [OUT_BIT_LEN-1:0]   add[NUM_ELEMENTS];
logic [DSP_BIT_LEN*2-1:0] mul_result[NUM_ELEMENTS][NUM_ELEMENTS];
logic [OUT_BIT_LEN-1:0]   grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];


always_comb begin
  for (int i = 0; i < NUM_ELEMENTS; i++) begin
    add[NUM_ELEMENTS-i-1] = i_add_term[i];
  end
end

// Instantiate the multiplier array and input mux
genvar gi, gj;
generate
  for (gi = 0; gi < NUM_ELEMENTS; gi++) begin : GEN_MULA
    for (gj = 0; gj < NUM_ELEMENTS; gj++) begin : GEN_MULB
      if (gi + gj < NUM_ELEMENTS_OUT) begin
        logic [DSP_BIT_LEN-1:0] mul_a, mul_b;

        always_comb begin
          mul_a = i_dat_a[gi];
          mul_b = i_dat_b[gj];
          unique case (1'b1)
            i_ctl[0]: begin
              // Square - elements in upper diagonal are reflected horizontally
              if (gi > gj) begin
                mul_a = i_dat_a[gi];
                mul_b = i_dat_b[NUM_ELEMENTS-gj-1];
              end else begin
                mul_a = i_dat_a[gi];
                mul_b = i_dat_b[gj];
              end
            end
            i_ctl[1]: begin
              // Multiply lower half
              mul_a = i_dat_a[gi];
              mul_b = i_dat_b[gj];
            end
            i_ctl[2]: begin
              // Multiply upper half, input terms are swapped
              mul_a = i_dat_a[NUM_ELEMENTS-gi-1];
              mul_b = i_dat_b[NUM_ELEMENTS-gj-1];
            end
          endcase
        end

        async_mult #(
          .BITS(DSP_BIT_LEN)
        )
        async_mult (
          .i_dat_a ( mul_a              ),
          .i_dat_b ( mul_b              ),
          .o_dat   ( mul_result[gi][gj] )
        );

      end else begin
        always_comb mul_result[gi][gj] = 0;
      end
    end
  end
endgenerate

// Depending on mode we multiplex where multiplier results end up in the grid to be accumulated
always_comb begin
  for (int i=0; i < NUM_ELEMENTS*2; i++)
    for (int j = 0; j < NUM_ELEMENTS*2; j++)
      grid[i][j] = 0;

  for (int i = 0; i < NUM_ELEMENTS; i++) begin : grid_row
    for (int j = 0; j < NUM_ELEMENTS; j++) begin : grid_col
      unique case (1'b1)
        i_ctl[0]: begin
          if (i <= j) begin
            if (i + j < NUM_ELEMENTS) begin
              if (i == j) begin
                grid[(i+j)][(2*i)]       = mul_result[i][j][WORD_LEN-1 : 0];
                grid[(i+j+1)][((2*i)+1)] = mul_result[i][j][2*DSP_BIT_LEN-1 : WORD_LEN];
              end else begin
                grid[(i+j)][(2*i)]       = {mul_result[i][j][WORD_LEN-2 : 0], 1'b0};
                grid[(i+j+1)][((2*i)+1)] =  mul_result[i][j][2*DSP_BIT_LEN-1 : WORD_LEN-1];
              end
            end else begin
              if (i == j) begin
                grid[(i+j)][(2*i)]       = mul_result[i][NUM_ELEMENTS-j-1][WORD_LEN-1 : 0];
                grid[(i+j+1)][((2*i)+1)] = mul_result[i][NUM_ELEMENTS-j-1][2*DSP_BIT_LEN-1 : WORD_LEN];
              end else begin
                grid[(i+j)][(2*i)]       = {mul_result[i][NUM_ELEMENTS-j-1][WORD_LEN-2 : 0], 1'b0};
                grid[(i+j+1)][((2*i)+1)] =  mul_result[i][NUM_ELEMENTS-j-1][2*DSP_BIT_LEN-1 : WORD_LEN-1];
              end
            end
          end
        end
        i_ctl[1]: begin
          grid[(i+j)][(2*i)]       = mul_result[i][j][WORD_LEN-1 : 0];
          grid[(i+j+1)][((2*i)+1)] = mul_result[i][j][2*DSP_BIT_LEN-1 : WORD_LEN];
        end
        i_ctl[2]: begin
          grid[(i+j+1)][((2*i)+1)] = mul_result[i][j][WORD_LEN-1 : 0];
          grid[(i+j)][(2*i)]       = mul_result[i][j][2*DSP_BIT_LEN-1 : WORD_LEN];
        end
      endcase
    end
  end
end

// Sum each column in the grid using log3 adders
generate
  always_comb begin
    res[0] = grid[0][0] + add[0];
    res[NUM_ELEMENTS*2-1] = grid[NUM_ELEMENTS*2-1][NUM_ELEMENTS*2-1]; // We don't add in square mode so don't need to worry about last element
  end

  for (gi = 1; gi < NUM_ELEMENTS*2-1; gi++) begin : col_sums
    localparam integer CUR_ELEMENTS = (gi < NUM_ELEMENTS) ?
                                     ((gi*2)+1) : (gi < NUM_ELEMENTS_OUT) ?
                                     ((NUM_ELEMENTS*4) - 1 - (gi*2)) :
                                     ((NUM_ELEMENTS*4) - 1 - (gi*2) - (NUM_ELEMENTS*2 - gi - 1)); // Past half way we only need lower half due to squares
    localparam integer GRID_INDEX   = (gi < NUM_ELEMENTS) ?
                                       0 :
                                      (((gi - NUM_ELEMENTS) * 2) + 1);

    localparam integer TOT_ELEMENTS = CUR_ELEMENTS + (gi < NUM_ELEMENTS);

    logic [OUT_BIT_LEN-1:0] terms [TOT_ELEMENTS];
    if (gi < NUM_ELEMENTS)
      always_comb terms = {grid[gi][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)], add[gi]};
    else
      always_comb terms = grid[gi][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)];

      // Log 3 gave the best results
      adder_tree_log_n #(
        .NUM_ELEMENTS ( TOT_ELEMENTS ),
        .BIT_LEN      ( OUT_BIT_LEN  ),
        .N            ( 3            )
      )
      adder_tree_log_n (
        .i_terms ( terms   ),
        .o_s     ( res[gi] )
      );

    end
endgenerate

// Propigate carry on the boundary depending on direction
always_comb
  for (int i = 0; i < NUM_ELEMENTS*2; i++) begin
    res_int[i] = res[i][WORD_LEN-1:0] + (i > 0 ? res[i-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
    unique case (1'b1)
      i_ctl[0]: begin
        res_int[i] = res[i][WORD_LEN-1:0] + (i > 0 ? res[i-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
      end
      i_ctl[1]: begin
        res_int[i] = res[i][WORD_LEN-1:0] + (i > 0 ? res[i-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
      end
      i_ctl[2]: begin
        res_int[i] = res[i][WORD_LEN-1:0] + (i < NUM_ELEMENTS*2-1 ? res[i+1][OUT_BIT_LEN-1:WORD_LEN] : 0);
      end
    endcase
  end

// Output is registered, we propagate one level at the boundary to save cycles calculating overflow
always_ff @ (posedge i_clk or posedge i_rst)
  if (i_rst)
    for (int i = 0; i < NUM_ELEMENTS*2; i++)
      o_dat[i] <= 0;
  else
    for (int i = 0; i < NUM_ELEMENTS*2; i++) begin
      o_dat[i] <= res_int[i];
      unique case (1'b1)
        i_ctl[0]: if (i == NUM_ELEMENTS)
                    o_dat[i] <= res_int[i] + res_int[NUM_ELEMENTS-1][WORD_LEN];
                  else if (i == NUM_ELEMENTS-1)
                    o_dat[i] <= res_int[i][WORD_LEN-1:0];
        i_ctl[1]: if (i == NUM_ELEMENTS)
                    o_dat[i] <= res_int[i] + res_int[NUM_ELEMENTS-1][WORD_LEN];
                  else if (i == NUM_ELEMENTS-1)
                    o_dat[i] <= res_int[i][WORD_LEN-1:0];
        i_ctl[2]: if (i == NUM_ELEMENTS-1)
                    o_dat[i] <= res_int[i] + res_int[NUM_ELEMENTS][WORD_LEN];
                  else if (i == NUM_ELEMENTS)
                    o_dat[i] <= res_int[i][WORD_LEN-1:0];
      endcase
    end

endmodule
