/*******************************************************************************
  Copyright 2019 Benjamin Devlin
  Copyright 2019 Eric Pearson

  Originally based off Eric Pearson's log2 adder but changed to log4.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/

module adder_tree_log4 #(
  parameter int NUM_ELEMENTS      = 9,
  parameter int BIT_LEN           = 16
)(
  input        [BIT_LEN-1:0] i_terms [NUM_ELEMENTS],
  output logic [BIT_LEN-1:0] o_s
);


generate
  if (NUM_ELEMENTS < 4) begin
    always_comb begin
      o_s[BIT_LEN-1:0] = 0;
      for (int i = 0; i < NUM_ELEMENTS; i++)
        o_s[BIT_LEN-1:0] += i_terms[i];
    end
  end else begin
    localparam integer NUM_RESULTS = integer'(NUM_ELEMENTS / 4) + (NUM_ELEMENTS % 4);

    logic [BIT_LEN-1:0] next_level_terms[NUM_RESULTS];

     adder_tree_level_4 #(
       .NUM_ELEMENTS ( NUM_ELEMENTS ),
       .BIT_LEN      ( BIT_LEN      ),
       .NUM_RESULTS  ( NUM_RESULTS  )
     ) adder_tree_level_4 (
       .i_terms  ( i_terms          ),
       .o_results( next_level_terms )
     );

    adder_tree_log4 #(
      .NUM_ELEMENTS ( NUM_RESULTS ),
      .BIT_LEN      ( BIT_LEN )
    ) adder_tree_log4 (
      .i_terms( next_level_terms ),
      .o_s    ( o_s               )
    );

  end
endgenerate

endmodule

module adder_tree_level_4 #(
  parameter int NUM_ELEMENTS = 3,
  parameter int BIT_LEN      = 19,
  parameter int NUM_RESULTS  = integer'(NUM_ELEMENTS/4) + (NUM_ELEMENTS%4)
)(
  input        [BIT_LEN-1:0] i_terms   [NUM_ELEMENTS],
  output logic [BIT_LEN-1:0] o_results [NUM_RESULTS]
);

always_comb begin
  for (int i=0; i<(NUM_ELEMENTS / 4); i++) begin
    o_results[i] = 0;
    for (int j = 0; j < 4; j++)
      o_results[i] += i_terms[i*4+j];
   end

   for (int i = 0; i < (NUM_ELEMENTS % 4); i++)
     o_results[(NUM_ELEMENTS/4) + i] = i_terms[NUM_ELEMENTS-(NUM_ELEMENTS%4) + i];
end

endmodule