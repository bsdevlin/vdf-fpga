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
  parameter BITS = 381,
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

logic [RAM_D_W-1:0] ram_d_r;
logic               ram_we_r;
logic               ram_se_r;

if_axi_stream #(.DAT_BYTS(BITS*2), .CTL_BITS(8)) in_if(i_clk);
if_axi_stream #(.DAT_BYTS(BITS), .CTL_BITS(8)) out_if(i_clk);

always_ff @ (posedge i_clk) begin
  in_if.dat[0+:BITS] <= i_dat_a;
  in_if.dat[BITS+:BITS] <= i_dat_b;
  o_dat <= out_if.dat;
  in_if.val <= i_val;
  o_rdy <= in_if.rdy;
  out_if.rdy <= i_rdy;
  o_val <= out_if.val;
  ram_d_r <= i_ram_d;
  ram_we_r <= i_ram_we;
  ram_se_r <= i_ram_se;
end

accum_mult_mod #(
  .DAT_BITS ( BITS     ),
  .CTL_BITS ( 8        ),
  .MODULUS  ( MODULUS  ),
  .A_DSP_W  ( A_DSP_W  ),
  .B_DSP_W  ( B_DSP_W  ),
  .GRID_BIT ( GRID_BIT ),
  .RAM_A_W  ( RAM_A_W  ),
  .RAM_D_W  ( RAM_D_W  )
)
accum_mult_mod (
  .i_clk ( i_clk ),
  .i_rst ( i_rst ),
  .i_mul ( in_if ),
  .o_mul ( out_if ),
  .i_ram_d  ( ram_d_r  ),
  .i_ram_we ( ram_we_r ),
  .i_ram_se ( ram_se_r )
);

endmodule