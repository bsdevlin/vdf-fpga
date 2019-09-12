/*
  This does a BITS multiplication using adder tree and parameterizable
  DSP sizes. A python script generates the accum_gen.sv file.

  Does modulus reduction using RAM tables. Multiplication and reduction has
  latency of 5 clock cycles and a throughput of 1 clock cycle per result.

  TODO: Properly add in flow control
  TODO: final check for modulus

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

module accum_mult_mod #(
  parameter BITS,
  parameter A_DSP_W,
  parameter B_DSP_W,
  parameter GRID_BIT,
  parameter RAM_A_W,
  parameter RAM_D_W 
)(
  input i_clk,
  input i_rst,
  input i_val,
  input i_rdy,
  output logic o_val,
  output logic o_rdy,
  input        [BITS-1:0] i_dat_a,
  input        [BITS-1:0] i_dat_b,
  output logic [BITS-1:0] o_dat,
  input [RAM_D_W-1:0] i_ram_d,
  input               i_ram_we
);

localparam int TOT_DSP_W = A_DSP_W+B_DSP_W;
localparam int NUM_COL = (BITS+A_DSP_W-1)/A_DSP_W;
localparam int NUM_ROW = (BITS+B_DSP_W-1)/B_DSP_W;
localparam int MAX_COEF = (2*BITS+GRID_BIT-1)/GRID_BIT;
localparam int PIPE = 9;

logic [A_DSP_W*NUM_COL-1:0]             dat_a;
logic [B_DSP_W*NUM_ROW-1:0]             dat_b;
(* DONT_TOUCH = "yes" *) logic [A_DSP_W+B_DSP_W-1:0] mul_grid [NUM_COL][NUM_ROW];
logic [2*BITS:0]     res0_c, res0_r, res0_rr, res1_c, tmp;

// Most of the code is generated
`include "accum_mult_mod_generated.sv"

always_comb begin
  tmp = 0;
  for (int i = 0; i < MAX_COEF; i++)
    tmp += accum_grid_o[i] << (i*GRID_BIT);
end

logic [PIPE-1:0]                        val;

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
  if (~val[0] || (val[0] && i_rdy)) begin
    for (int i = 0; i < NUM_COL; i++)
      dat_a <= 0;
      dat_b <= 0;
      dat_a <= i_dat_a;
      dat_b <= i_dat_b;
  end
end


always_ff @ (posedge i_clk) begin
  for (int i = 0; i < NUM_COL; i++)
    for (int j = 0; j < NUM_ROW; j++) begin
      if (~val[1] || (val[1] && i_rdy))
        mul_grid[i][j] <= dat_a[i*A_DSP_W +: A_DSP_W] * dat_b[j*B_DSP_W +: B_DSP_W];
    end
end

// Register lower half accumulator output while we lookup BRAM
always_ff @ (posedge i_clk)
  for (int i = 0; i < MAX_COEF/2; i++) begin
    accum_grid_o_r[i] <= accum_grid_o[i];
  end

always_comb begin
  res0_c = 0;
  for (int i = 0; i < MAX_COEF/2; i++)
    res0_c += accum2_grid_o[i] << (i*GRID_BIT);
end

// We do a second level reduction to get back within MODULUS bits
always_ff @ (posedge i_clk) begin
  res0_r <= res0_c;
  res0_rr <= res0_r;
  o_dat <= res1_c;
end
  
endmodule