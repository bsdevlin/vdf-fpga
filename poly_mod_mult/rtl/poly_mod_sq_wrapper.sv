/*
  In this wrapper we check the result is not greater than MODULUS and
  do a correction subtraction if it is, and then convert to integer form.

  Copyright (C) 2019  Benjamin Devlin.

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
module poly_mod_sq_wrapper #(
  parameter int                       WORD_BITS = 16,
  parameter int                       NUM_WORDS = 8,
  parameter [WORD_BITS*NUM_WORDS-1:0] MODULUS = (1 << 127) - 10,
  parameter int                       REDUCTION_BITS = 9,
  parameter int                       REDUN_WORD_BITS = 1,
  parameter int                       I_WORD = NUM_WORDS + 1,
  parameter int                       COEF_BITS = WORD_BITS + REDUN_WORD_BITS
) (
  input i_clk,
  input i_rst,
  input i_val,
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat,
  output logic [I_WORD-1:0][COEF_BITS-1:0] o_dat,
  output logic                             o_val
);

// For now just add pipeline stages to the input and output
localparam PIPES = 3;

logic [PIPES-1:0]                            val_in, val_out;
logic [PIPES-1:0][I_WORD-1:0][COEF_BITS-1:0] dat_in, dat_out;

always_ff @ (posedge i_clk) begin
  val_in <= {val_in, i_val};
  dat_in <= {dat_in, i_dat};
  {o_val, val_out[PIPES-1:1]} <= val_out;
  {o_dat, dat_out[PIPES-1:1]} <= dat_out;
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
  .i_rst   ( i_rst ),
  .i_val   ( val_in[PIPES-1] ),
  .i_dat_a ( dat_in[PIPES-1] ),
  .i_dat_b ( '0              ),
  .o_dat   ( dat_out[0]      ),
  .o_val   ( val_out[0]      )
);

endmodule