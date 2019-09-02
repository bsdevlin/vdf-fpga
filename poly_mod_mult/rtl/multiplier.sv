/*
  Simple block for performing single clock multiplication.

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