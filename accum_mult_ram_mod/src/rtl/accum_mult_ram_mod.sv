/*

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
 */

module accum_mult_ram_mod #(
  parameter int BITS = 54,
  parameter [BITS-1:0] MODULUS,
  parameter int A_DSP_W = 27,
  parameter int B_DSP_W = 18,
  parameter int GRID_BIT = 9 // Should be some common factor of DSP width
)(
  input i_clk,
  input i_rst,
  input i_val,
  input i_rdy,
  output logic o_val,
  output logic o_rdy,
  input        [BITS-1:0] i_dat_a,
  input        [BITS-1:0] i_dat_b,
  output logic [BITS*2-1:0] o_dat
);

localparam int TOT_DSP_W = A_DSP_W+B_DSP_W;
localparam int NUM_COL = (BITS+A_DSP_W-1)/A_DSP_W;
localparam int NUM_ROW = (BITS+B_DSP_W-1)/B_DSP_W;
localparam int MAX_COEF = (BITS+GRID_BIT-1)/GRID_BIT;
localparam int PIPE = 4;

logic [NUM_COL-1:0][A_DSP_W-1:0]             dat_a;
logic [NUM_ROW-1:0][B_DSP_W-1:0]             dat_b;
logic [A_DSP_W+B_DSP_W-1:0]                  mul_grid [NUM_COL][NUM_ROW];
logic [$clog2(NUM_COL+NUM_ROW)+GRID_BIT-1:0] accum_grid_o [MAX_COEF*2];
logic [BITS*2-1:0]                           res_c;
logic [PIPE-1:0]                             val;

genvar gx, gy;

// Flow control
always_comb begin
  o_rdy = i_rdy;
  o_val = val[PIPE-1];
end

always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
  end else begin
    if (i_rdy) begin
      val <= {val, i_val};
    end
  end
end

// Logic for handling multiple pipelines
always_ff @ (posedge i_clk) begin
  if (i_val && o_rdy) begin
    dat_a <= i_dat_a;
    dat_b <= i_dat_b;
  end
end

// Generate multipliers
generate
  for (gx = 0; gx < NUM_COL; gx++) begin: GEN_MUL_X
    for (gy = 0; gy < NUM_ROW; gy++) begin: GEN_MUL_Y
      always_ff @ (posedge i_clk) begin
        mul_grid[gx][gy] <= dat_a[gx] * dat_b[gy];
      end
    end
  end
endgenerate

`include "accum_gen.sv"

always_comb begin
  res_c = 0;
  for (int i = 0; i < MAX_COEF*2; i++)
    res_c += accum_grid_o[i] << (i*GRID_BIT);
end

always_ff @ (posedge i_clk) begin
   o_dat <= res_c;
end


endmodule