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
  parameter int BITS = 384,
  parameter [BITS-1:0] MODULUS = 1 << (BITS-1) - 10,
  parameter int A_DSP_W = 26,
  parameter int B_DSP_W = 17,
  parameter int GRID_BIT = 17
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
localparam int MAX_COEF = (2*BITS+GRID_BIT-1)/GRID_BIT;
localparam int ACCUM_BITS = $clog2(NUM_COL+NUM_ROW)+GRID_BIT;
localparam int PIPE = 5;

logic [NUM_COL-1:0][A_DSP_W-1:0]             dat_a;
logic [NUM_ROW-1:0][B_DSP_W-1:0]             dat_b;
logic [A_DSP_W+B_DSP_W-1:0]                  mul_grid [NUM_COL][NUM_ROW];
logic [ACCUM_BITS-1:0]                       accum_grid_o [MAX_COEF];
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

// Now we do the reduction and propigate carries
// Split add across 2 pipelines

logic [ACCUM_BITS*MAX_COEF/2-1:0]  res_h_c, res_l_c, res_h_r, res_l_r;

always_comb begin
  res_l_c = 0;
  for (int i = 0; i < MAX_COEF/2; i++)
    res_l_c += accum_grid_o[i] << (i*GRID_BIT);
    
  res_h_c = 0;
  for (int i = 0; i < MAX_COEF-(MAX_COEF/2); i++)
    res_h_c += accum_grid_o[i+MAX_COEF/2] << (i*GRID_BIT);
end

always_ff @ (posedge i_clk) begin
  res_h_r <= res_h_c;
  res_l_r <= res_l_c;
  o_dat <= res_l_r + (res_h_r << (GRID_BIT*MAX_COEF/2));
end


endmodule