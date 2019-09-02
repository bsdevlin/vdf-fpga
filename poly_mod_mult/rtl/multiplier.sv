/*
  Simple block for performing single clock multiplication.

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

module multiplier #(
  parameter int IN_BITS
) (
  input i_clk,
  input        [IN_BITS-1:0]   i_dat_a,
  input        [IN_BITS-1:0]   i_dat_b,
  output logic [IN_BITS*2-1:0] o_dat
);


always_ff @ (posedge i_clk) begin
  o_dat <= i_dat_a * i_dat_b;
end

endmodule