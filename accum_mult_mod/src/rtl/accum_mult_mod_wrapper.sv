/*
  Wrapper for synthesis.

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

module accum_mult_mod_wrapper #(
  parameter BITS = 381 + 1,
  parameter [380:0] MODULUS = 381'h1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab,
  parameter A_DSP_W = 26,
  parameter B_DSP_W = 17,
  parameter GRID_BIT = 32,
  parameter RAM_A_W = 8,
  parameter RAM_D_W = 32
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
  input               i_ram_we,
  input               i_ram_se
);

logic [BITS-1:0] i_dat_a_r;
logic [BITS-1:0] i_dat_b_r;
logic [BITS-1:0] o_dat_r;
logic i_val_r, i_rdy_r, o_val_r, o_rdy_r;
logic [RAM_D_W-1:0] ram_d_r;
logic               ram_we_r;
logic               ram_se_r;

always_ff @ (posedge i_clk) begin
  i_dat_a_r <= i_dat_a;
  i_dat_b_r <= i_dat_b;
  o_dat <= o_dat_r;
  i_val_r <= i_val;
  o_rdy <= o_rdy_r;
  i_rdy_r <= i_rdy;
  o_val <= o_val_r;
  ram_d_r <= i_ram_d;
  ram_we_r <= i_ram_we;
  ram_se_r <= i_ram_se;
end

accum_mult_mod #(
  .BITS     ( BITS     ),
  .A_DSP_W  ( A_DSP_W  ),
  .B_DSP_W  ( B_DSP_W  ),
  .GRID_BIT ( GRID_BIT ),
  .RAM_A_W  ( RAM_A_W  ),
  .RAM_D_W  ( RAM_D_W  )
)
accum_mult_mod (
  .i_clk ( i_clk ),
  .i_rst ( i_rst ),
  .i_val ( i_val_r ),
  .i_rdy ( i_rdy_r ),
  .o_val ( o_val_r ),
  .o_rdy ( o_rdy_r ),
  .i_dat_a ( i_dat_a_r ),
  .i_dat_b ( i_dat_b_r ),
  .o_dat   ( o_dat_r   ),
  .i_ram_d  ( ram_d_r  ),
  .i_ram_we ( ram_we_r ),
  .i_ram_se ( ram_se_r )
);

endmodule