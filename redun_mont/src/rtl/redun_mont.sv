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

/*
 This performs repeated modular squaring using Montgomery multiplication technique.

 We use redundant bit representation to minimize delay from carry chains.

 Single clock cycle multiplier which can either calculate the square, lower, or upper
 products is used.

 Montgomery parameters are extended to include a redundant word so that we can skip the final
 overflow check.

 One hot control signals.

 Everything fits inside a single SLR.

 redun_mont_pkg contains functions for calculating Montgomery values and commonly used typedefs.
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

redun0_t mul_a, mul_b, mul_o;
redun0_t hmul_out_h, hmul_out_h_r, hmul_out_h_rr, tmp_h;
redun0_t i_sq_r, i_sq_r_a, i_sq_r_b;
redun0_t mult_out_l, mult_out_l_r, mult_out_l_rr, mult_out_l_rrr;
redun1_t mult_out;

// This version of output has the carry propigated over 3 cycles
redun0_t mult_out_c0, mult_out_c1, mult_out_c2;
logic [(NUM_WRDS+1)*WRD_BITS-1:0] mul_out_collapsed, mul_out_collapsed_r;
logic [(NUM_WRDS+1)*WRD_BITS-1:0] mult_out_l_collapsed;

logic [4:0] state, next_state, state_r;
logic o_val_r, i_val_r, o_val_rr;
logic [7:0] o_val_d;

logic mul2_ovrflw;
logic [WRD_BITS-1:0] mul2_ovrflw_dat;

enum {IDLE  = 0,
      START = 1,
      MUL0  = 2,
      MUL1  = 3,
      MUL2  = 4} state_index_t;

typedef enum logic [2:0] {SQR  = 1 << 0,
                          MUL_L = 1 << 1,
                          MUL_H  = 1 << 2} mult_ctl_t;
mult_ctl_t mult_ctl, next_mult_ctl;

logic [3:0] mul_in_sel;

// Assign input to multiplier
always_comb begin
  for (int i = 0; i < NUM_WRDS; i++)
    hmul_out_h[i] = mult_out[NUM_WRDS-1-i];

  mult_out_l = mult_out[0:NUM_WRDS-1];

  next_state = 0;
  next_mult_ctl = SQR;

  unique case (1'b1)
    state[IDLE]: begin
      next_mult_ctl = SQR;
      if (i_val_r)
        next_state[START] = 1;
      else
        next_state[IDLE] = 1;
    end
    state[START]: begin
      if (mul2_ovrflw) begin
        if (o_val_d[6]) begin
          next_mult_ctl = SQR;
          next_state[START] = 1;
        end else begin
          next_mult_ctl = MUL_L;
          next_state[START] = 1;
        end
      end else begin
        next_mult_ctl = MUL_L;
        next_state[MUL0] = 1;
      end
    end
    state[MUL0]: begin
      next_mult_ctl = MUL_H;
      next_state[MUL1] = 1;
    end
    state[MUL1]: begin
      next_mult_ctl = SQR;
      next_state[MUL2] = 1;
    end
    state[MUL2]: begin
      next_mult_ctl = MUL_L;
      next_state[MUL0] = 1;
    end
  endcase

  // Overflow overrides previous state
  if (mul2_ovrflw) begin
    next_state = 0;
    next_state[START] = 1;
  end
end

// Logic for selecting where inputs for the multiplier come from
always_ff @ (posedge i_clk) begin
  mul_in_sel <= 0;
  unique case (1'b1)
    state[IDLE]: begin
      mul_in_sel[0] <= 1;
    end
    state[START]: begin
      if (mul2_ovrflw) begin
        mul_in_sel[0] <= 1;
      end else begin
        mul_in_sel[1] <= 1;
      end
    end
    state[MUL0]: begin
      mul_in_sel[2] <= 1;
    end
    state[MUL1]: begin
      mul_in_sel[3] <= 1;
    end
    state[MUL2]: begin
      mul_in_sel[1] <= 1;
    end
  endcase
end

always_comb begin
  unique case (1'b1)
    mul_in_sel[0]: begin
      mul_a = i_sq_r_a;
      mul_b = i_sq_r_b;
    end
    mul_in_sel[1]: begin
      mul_a = mult_out_l;
      mul_b = to_redun(MONT_FACTOR);
    end
    mul_in_sel[2]: begin
      mul_a = mult_out_l;
      mul_a[NUM_WRDS-1][WRD_BITS] = 0;
      mul_b = to_redun(P);
    end
    mul_in_sel[3]: begin
      mul_a = hmul_out_h;
      mul_b = hmul_out_h;
    end
  endcase
end



// Logic for propigating carry in case of overflow
always_comb begin
  mul_out_collapsed = 0;
  for (int i = 0; i < NUM_WRDS; i++)
    mul_out_collapsed += (mult_out_c1[i] << (i*WRD_BITS));

  mult_out_l_collapsed = 0;
  for (int i = 0; i < NUM_WRDS; i++)
    mult_out_l_collapsed += (mult_out_l[i] << (i*WRD_BITS));
end

// Logic without a reset
always_ff @ (posedge i_clk) begin
  mult_ctl <= next_mult_ctl;

  mult_out_l_r <= mult_out_l;
  mult_out_l_r[NUM_WRDS-1][WRD_BITS] <= 0;

  mult_out_l_rr <= mult_out_l_r;
  mult_out_l_rrr <= mul2_ovrflw ? mult_out_l_rrr : mult_out_l_rr;

  mult_out_c0 <= mult_out_l;
  mult_out_c0[NUM_WRDS-1][WRD_BITS] <= 0;
  mult_out_c1 <=  mult_out_c0;
  mult_out_c2 <= mult_out_c1;

  mul_out_collapsed_r <= mul_out_collapsed;

  state_r <= state;

  hmul_out_h_r <= hmul_out_h;
  hmul_out_h_rr <= hmul_out_h_r;
  mul_o <= hmul_out_h_r;

  // Register input
  i_sq_r <= i_sq;
  if (state[IDLE]) begin
    i_sq_r_a <= i_sq_r;
    i_sq_r_b <= i_sq_r;
  end else begin
    i_sq_r_a <= mul_o;
    i_sq_r_b <= mul_o;
  end

  if (state[MUL0])
    for (int i = 0; i < NUM_WRDS; i++)
      tmp_h[i] <= mult_out[NUM_WRDS+i] + (i == 0 ? (mult_out_l_collapsed[NUM_WRDS*WRD_BITS +: WRD_BITS] + 1) : 0);
  else
    tmp_h <= to_redun(0);

  i_val_r <= i_val;

  if (mul2_ovrflw) begin
    i_sq_r_a <= mult_out_l_rrr;
    i_sq_r_b <= to_redun(P);

    // Need to add in overflow result, also can propigate carry one level here
    for (int i = 0; i < NUM_WRDS; i++)
      mul_o[i] <= mul_o[i][WRD_BITS-1:0] + (i == 0 ? mul_out_collapsed_r[NUM_WRDS*WRD_BITS +: WRD_BITS] : mul_o[i-1][WRD_BITS]);

  end

  if (o_val_d[6]) begin
    i_sq_r_a <= mul_o;
    i_sq_r_b <= mul_o;
  end

  o_mul <= mul_o;

end

// Logic requiring reset
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    state <= 0;
    state[IDLE] <= 1;
    o_val_r <= 0;
    o_val_rr <= 0;
    o_val <= 0;
    o_val_d <= 0;
    mul2_ovrflw <= 0;
    mul2_ovrflw_dat <= 0;
  end else begin
    o_val_r <= state[MUL2];
    o_val_rr <= o_val_r;
    o_val <= (o_val_rr && ~mul2_ovrflw) || o_val_d[6];
    o_val_d <= {o_val_d, o_val_rr && mul2_ovrflw};

    mul2_ovrflw_dat <= state_r[MUL1] ? mult_out[NUM_WRDS][WRD_BITS-1:0] : {WRD_BITS{1'd0}};

    // We check for a condition we we might have overflow in the multiplier in the lower words,
    // so we actually need to reverse the multiplication and we do it to check
    if ((mul2_ovrflw_dat >= ({WRD_BITS{1'b1}} - NUM_WRDS)) && state_r[MUL2]) begin
      mul2_ovrflw <= 1;
    end

    if (state[IDLE] || o_val_d[6]) begin
      mul2_ovrflw_dat <= 0;
      mul2_ovrflw <= 0;
    end

    state <= next_state;
  end
end

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