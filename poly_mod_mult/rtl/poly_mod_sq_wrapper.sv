/*
  In this wrapper we check the result is not greater than MODULUS and
  do a correction subtraction if it is, and then convert to integer form.

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
module poly_mod_sq_wrapper #(
  parameter int                       WORD_BITS = 16,
  parameter int                       NUM_WORDS = 64,
  parameter [WORD_BITS*NUM_WORDS-1:0] MODULUS = 1024'd124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331,
  parameter int                       REDUCTION_BITS = 12,
  parameter int                       REDUN_WORD_BITS = 1,
  parameter int                       I_WORD = NUM_WORDS + 1,
  parameter int                       COEF_BITS = WORD_BITS + REDUN_WORD_BITS
) (
  input i_clk,
  input i_rst,
  input i_val,
  input i_reduce_only,
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat,
  output logic [I_WORD-1:0][COEF_BITS-1:0] o_dat,
  output logic                             o_val,
  input                                    i_ram_we,
  input [NUM_WORDS-1:0][WORD_BITS-1:0]     i_ram_d
);

logic                                val_in, val_out, reduce_only, ram_we;
logic [I_WORD-1:0][COEF_BITS-1:0]    dat_in, dat_out;
logic [NUM_WORDS-1:0][WORD_BITS-1:0] ram_d;

// We divide the clock by two, and run some logic at double speed
logic clk_s;

logic cnt;
always_ff @ (posedge i_clk)
  if (i_rst)
    cnt <= 0;
  else
    cnt <= cnt + 1;
    
BUFGCE_DIV # (
  .BUFGCE_DIVIDE ( 1 )
)
BUFGCE_DIV_i (
  .I  ( i_clk ),
  .CLR( i_rst ),
  .CE ( cnt   ),
  .O  ( clk_s )
);

always_ff @ (posedge i_clk) begin
  val_in <= i_val;
  dat_in <= i_dat;
  o_val <= val_out;
  o_dat <= dat_out;
  reduce_only <= i_reduce_only;
  ram_we <= i_ram_we;
  ram_d <= i_ram_d;
end

poly_mod_mult #(
  .SQ_MODE           ( 1'd1            ),
  .WORD_BITS         ( WORD_BITS       ),
  .NUM_WORDS         ( NUM_WORDS       ),
  .MODULUS           ( MODULUS         ),
  .REDUCTION_BITS    ( REDUCTION_BITS  ),
  .REDUN_WORD_BITS   ( REDUN_WORD_BITS ),
  .I_WORD            ( I_WORD          ),
  .COEF_BITS         ( COEF_BITS       )
)
poly_mod_mult_i (
  .i_clk   ( i_clk ),
  .i_clk_s ( clk_s ),
  .i_rst   ( i_rst ),
  .i_val         ( val_in      ),
  .i_reduce_only ( reduce_only ),
  .i_dat_a       ( dat_in      ),
  .i_dat_b       ( '0          ),
  .o_dat         ( dat_out     ),
  .o_val         ( val_out     ),
  .i_ram_we      ( ram_we      ),
  .i_ram_d       ( ram_d       )
);

endmodule