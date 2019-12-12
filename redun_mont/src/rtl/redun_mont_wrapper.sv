/*
  Copyright (C) 2019  Benjamin Devlin

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

module redun_wrapper
  import redun_mont_pkg::*;
(
  input logic        clk,
  input logic        reset,
  input logic        start,
  input redun0_t     sq_in,
  output redun0_t    sq_out,
  output logic       valid
);

redun0_t mul_i, mul_o;
logic start_r, valid_o, reset_r;

always_ff @ (posedge clk) begin
  mul_i <= sq_in;
  start_r <= start;
  valid <= valid_o;
  sq_out <= mul_o;
  reset_r <= reset;
end

redun_mont redun_mont (
  .i_clk   ( clk     ),
  .i_rst   ( reset_r ),
  .i_mul_a ( mul_i   ),
  .i_mul_b ( mul_i   ),
  .i_val   ( start_r ),
  .o_mul   ( mul_o   ),
  .o_val   ( valid_o ),
  .o_overflow()
);

endmodule