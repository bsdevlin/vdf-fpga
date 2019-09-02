/*
  Simple block for adding multiple inputs together in a single clock cycle.

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

module tree_adder #(
  parameter int NUM_IN,
  parameter int IN_BITS
) (
  input i_clk,
  input        [NUM_IN-1:0][IN_BITS-1:0]      i_dat,
  output logic [IN_BITS + $clog2(NUM_IN)-1:0] o_dat
);

logic [IN_BITS + $clog2(NUM_IN)-1:0] dat_comb;

always_comb begin
  dat_comb = 0;
  for (int i = 0; i < NUM_IN; i++)
    dat_comb += i_dat[i];
end

always_ff @ (posedge i_clk) begin
  o_dat <= dat_comb;
end

endmodule