/*
  Copyright (C) 2019  Benjamin Devlin

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

module redun_mont
  import redun_mont_pkg::*;
(
  input           i_clk,
  input           i_rst,
  input redun0_t  i_sq,
  input           i_val,
  output redun0_t o_mul,
  output logic    o_val
);

redun0_t mul_a, mul_b, hmul_out_h, hmul_out_h_r, tmp_h, i_sq_l, mult_out_l;
redun1_t mult_out;

logic [4:0] state, next_state, state_bufg;
logic mul_sq_bufg, o_val_r;

enum {IDLE  = 0, 
      START = 1, 
      MUL0  = 2,
      MUL1  = 3, 
      MUL2  = 4} state_index_t;

// BUFGs drive our global one-hot control values
genvar gi;
generate
  for (gi = 0; gi < 5; gi++) begin : GEN_CTL
    BUFG ctl_bufg (
      .O(state_bufg[gi]),
      .I(state[gi])
    );
  end
  // We need one extra for squaring
  BUFG ctl_bufg (
    .O(mul_sq_bufg),
    .I(state[MUL2] || state[START])
  );  
endgenerate

// Assign input to multiplier
always_comb begin
  for (int i = 0; i < NUM_WRDS; i++)
    hmul_out_h[i] = mult_out[NUM_WRDS-1-i];

  mult_out_l = mult_out[0:NUM_WRDS-1];
  
  mul_a = i_sq_l;
  mul_b = i_sq_l;
      
  next_state = 0;
  unique case (1'b1)
    state_bufg[IDLE]: begin
      mul_a = i_sq_l;
      mul_b = i_sq_l;
      if (i_val) 
        next_state[START] = 1; 
      else
        next_state[IDLE] = 1;
    end
    state_bufg[START]: begin
      mul_a = i_sq_l;
      mul_b = i_sq_l;
      next_state[MUL0] = 1;
    end
    state_bufg[MUL0]: begin
      mul_a = mult_out_l;
      mul_b = to_redun(MONT_FACTOR);
      next_state[MUL1] = 1;
    end
    state_bufg[MUL1]: begin
      mul_a = mult_out_l;
      mul_a[NUM_WRDS-1][WRD_BITS] = 0;
      mul_b = to_redun(P);
      next_state[MUL2] = 1;
    end
    state_bufg[MUL2]: begin
      mul_a = hmul_out_h;
      mul_b = hmul_out_h;
      next_state[MUL0] = 1;
    end
  endcase           
end

// Logic without a reset
always_ff @ (posedge i_clk) begin
  hmul_out_h_r <= hmul_out_h;
  o_mul <= hmul_out_h_r;
  i_sq_l <= i_sq;
  if (state_bufg[MUL0]) 
    for (int i = 0; i < NUM_WRDS; i++)
      tmp_h[i] <= mult_out[NUM_WRDS+i] + (i == 0 ? (mult_out[NUM_WRDS-1][WRD_BITS] + 1) : 0);
  else
    tmp_h <= to_redun(0);
  o_val_r <= (state_bufg[MUL2]);
  o_val <= o_val_r;
end

// Logic requiring reset
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    state <= 0;
    state[IDLE] <= 1;
  end else begin
    state <= next_state;
  end
end

logic [2:0] mult_ctl;
always_comb mult_ctl = {state_bufg[MUL1], 
                        state_bufg[MUL0], 
                        mul_sq_bufg};
                 
multi_mode_multiplier #(
  .NUM_ELEMENTS    ( NUM_WRDS                        ),
  .DSP_BIT_LEN     ( WRD_BITS+1                      ),
  .WORD_LEN        ( WRD_BITS                        ),
  .NUM_ELEMENTS_OUT( NUM_WRDS+SPECULATIVE_CARRY_WRDS )
)
multi_mode_multiplier (
  .i_clk      ( i_clk    ),
  .i_ctl      ( mult_ctl ),
  .i_dat_a    ( mul_a    ),
  .i_dat_b    ( mul_b    ),
  .i_add_term ( tmp_h    ),
  .o_dat      ( mult_out )
);

endmodule