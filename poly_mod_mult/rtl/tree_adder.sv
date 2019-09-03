/*
  Simple block for adding multiple inputs together in a single clock cycle.

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