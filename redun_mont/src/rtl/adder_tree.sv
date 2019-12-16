/*******************************************************************************
   Adder tree, taken from Erics submission
*******************************************************************************/

module adder_tree_2_to_1
   #(
     parameter int NUM_ELEMENTS      = 9,
     parameter int BIT_LEN           = 16
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] S
   );


   generate
      if (NUM_ELEMENTS == 1) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0];
         end
      end else if (NUM_ELEMENTS == 2) begin // Return value
         always_comb begin
            S[BIT_LEN-1:0] = terms[0] + terms[1];
         end
      end else begin
         localparam integer NUM_RESULTS = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2);
         logic [BIT_LEN-1:0] next_level_terms[NUM_RESULTS];

         adder_tree_level #(.NUM_ELEMENTS(NUM_ELEMENTS),
                            .BIT_LEN(BIT_LEN)
         ) adder_tree_level (
                            .terms(terms),
                            .results(next_level_terms)
         );

         adder_tree_2_to_1 #(.NUM_ELEMENTS(NUM_RESULTS),
                                  .BIT_LEN(BIT_LEN)
         ) adder_tree_2_to_1 (
                                  .terms(next_level_terms),
                                  .S(S)
         );
      end
   endgenerate
endmodule


module adder_tree_level
   #(
     parameter int NUM_ELEMENTS = 3,
     parameter int BIT_LEN      = 19,

     parameter int NUM_RESULTS  = integer'(NUM_ELEMENTS/2) + (NUM_ELEMENTS%2)
    )
   (
    input  logic [BIT_LEN-1:0] terms[NUM_ELEMENTS],
    output logic [BIT_LEN-1:0] results[NUM_RESULTS]
   );

   always_comb begin
      for (int i=0; i<(NUM_ELEMENTS / 2); i++) begin
         results[i] = terms[i*2] + terms[i*2+1];
      end

      if( NUM_ELEMENTS % 2 == 1 ) begin
         results[NUM_RESULTS-1] = terms[NUM_ELEMENTS-1];
      end
   end
endmodule