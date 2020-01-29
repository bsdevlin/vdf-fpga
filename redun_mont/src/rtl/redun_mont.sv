/*******************************************************************************
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
*******************************************************************************/

/*
 This performs repeated modular squaring using Montgomery multiplication technique.
 We use redundant bit representation to minimize delay from carry chains.
 Single clock cycle multiplier which can either calculate the square, lower, or upper
 products is used.
 If we detect a possible carry over the bit shift boundary, we will propigate carrys to make sure
 we have correct data.
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

redun0_t mul_a, mul_b;
redun0_t hmul_out_h, hmul_out_h_r, add_term, add_term_p1, add_term_r;
redun0_t i_sq_r, i_sq_r_a, i_sq_r_b;
redun1_t mult_out, mult_out_r, mult_out_equalized, mult_out_equalized_r, mult_out_equalized_rr;
fe_t mult_out_h_equalized, mult_out_h_equalized_r, mult_out_h_equalized_rr, mult_out_h_equalized_rrr;
logic [(NUM_WRDS+1)*WRD_BITS-1:0] mult_out_l_equalized;

logic [2:0] o_val_d;
logic i_val_r;

logic mul0_equalize, mul1_equalize, mul2_equalize, mul2_carry;
logic [WRD_BITS:0] mul0_bndry, mul1_bndry, mul2_bndry;


typedef enum logic [4:0] {IDLE  = 1 << 0,
                          START = 1 << 1,
                          MUL0  = 1 << 2,
                          MUL1  = 1 << 3,
                          MUL2  = 1 << 4} state_index_t;
state_index_t state, next_state, state_r;

typedef enum logic [2:0] {SQR   = 1 << 0,
                          MUL_L = 1 << 1,
                          MUL_H = 1 << 2} mult_ctl_t;
mult_ctl_t mult_ctl, next_mult_ctl;

logic [3:0] mul_in_sel;

// Assign input to multiplier
always_comb begin
  for (int i = 0; i < NUM_WRDS; i++) begin
    add_term_p1[i] = add_term[i] + (i == 0 && mult_ctl == MUL_H ? 1 : 0);
    hmul_out_h[i] = mult_out[NUM_WRDS-1-i];
    hmul_out_h_r[i] = mult_out_r[NUM_WRDS-1-i];
  end

  next_state = IDLE;
  next_mult_ctl = SQR;

  unique case (state)
    IDLE: begin
      next_mult_ctl = SQR;
      if (i_val_r)
        next_state = START;
      else
        next_state = IDLE;
    end
    START: begin
      if (mul2_carry) begin
        next_mult_ctl = SQR;
        next_state = START;
      end else begin
        next_mult_ctl = MUL_L;
        next_state = MUL0;
      end
    end
    MUL0: begin
      if (mul2_equalize) begin
        next_mult_ctl = MUL_L;
        next_state = MUL2;
      end else begin
        next_mult_ctl = MUL_H;
        next_state = MUL1;
      end
    end
    MUL1: begin
      if (mul0_equalize) begin
        next_mult_ctl = MUL_L;
        next_state = MUL0;
      end else begin
        next_mult_ctl = SQR;
        next_state = MUL2;
      end
    end
    MUL2: begin
      if (mul1_equalize) begin
        next_mult_ctl = MUL_H;
        next_state = MUL1;
      end else if (mul2_equalize) begin
        next_mult_ctl = SQR;
        next_state = START;
      end else begin
        next_mult_ctl = MUL_L;
        next_state = MUL0;
      end
    end
  endcase
end

// Logic for selecting where inputs for the multiplier come from
always_ff @ (posedge i_clk) begin
  mul_in_sel <= 0;
  unique case (state)
    IDLE: begin
      mul_in_sel[0] <= 1;
    end
    START: begin
      if (mul2_carry)
        mul_in_sel[0] <= 1;
      else
        mul_in_sel[1] <= 1;
    end
    MUL0: begin
      if (mul2_equalize)
        mul_in_sel[0] <= 1;
      else
        mul_in_sel[2] <= 1;
    end
    MUL1: begin
      if (mul0_equalize)
        mul_in_sel[0] <= 1;
      else
        mul_in_sel[3] <= 1;
    end
    MUL2: begin
      if (mul1_equalize)
        mul_in_sel[0] <= 1;
      else
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
      mul_a = mult_out[0:NUM_WRDS-1];
      mul_b = to_redun(MONT_FACTOR);
    end
    mul_in_sel[2]: begin
      mul_a = mult_out[0:NUM_WRDS-1];
      mul_b = to_redun(P);
    end
    mul_in_sel[3]: begin
      mul_a = hmul_out_h;
      mul_b = hmul_out_h;
    end
  endcase
end

// Boundary cases for when we need to equalize the result
always_comb begin
  mul0_bndry = (state == MUL0) ? mult_out[NUM_WRDS-1][WRD_BITS:0] : 0;
  mul1_bndry = (state == MUL1) ? mult_out[NUM_WRDS-1][WRD_BITS:0] : 0;
  mul2_bndry = (state == MUL2) ? mult_out[NUM_WRDS][WRD_BITS:0] : 0;

  mult_out_equalized = equalize(mult_out_r);
  mult_out_h_equalized = from_redun(hmul_out_h_r);
  mult_out_l_equalized = mul2_carry ? from_redun(mult_out_r[0:NUM_WRDS-1]) : 0;
end

// Logic without a reset
always_ff @ (posedge i_clk) begin
  mult_out_r <= mult_out;
  mult_out_h_equalized_r <= mult_out_h_equalized;
  mult_out_h_equalized_rr <= mult_out_h_equalized_r;
  mult_out_h_equalized_rrr <= mult_out_h_equalized_rr;
  mult_out_equalized_r <= mult_out_equalized;
  mult_out_equalized_rr <= mult_out_equalized_r;

  mult_ctl <= next_mult_ctl;

  i_sq_r_a <= i_sq_r_a;
  i_sq_r_b <= i_sq_r_b;

  for (int i = 0; i < NUM_WRDS; i++) begin
    o_mul[i] <= mult_out_h_equalized_rrr[i*WRD_BITS +: WRD_BITS] + (i == 0 ? mult_out_l_equalized[DAT_BITS +: WRD_BITS] : 0);
    if (mul2_carry) begin
      i_sq_r_a[i] <= mult_out_h_equalized_rrr[i*WRD_BITS +: WRD_BITS] + (i == 0 ? mult_out_l_equalized[DAT_BITS +: WRD_BITS] : 0);
      i_sq_r_b[i] <= mult_out_h_equalized_rrr[i*WRD_BITS +: WRD_BITS] + (i == 0 ? mult_out_l_equalized[DAT_BITS +: WRD_BITS] : 0);
    end
  end

  add_term_r <= add_term;

  // Register input
  i_sq_r <= i_sq;

  if (state == IDLE) begin
    i_sq_r_a <= i_sq_r;
    i_sq_r_b <= i_sq_r;
  end

  add_term <= to_redun(0);

  if (o_val) begin
    i_sq_r_a <= o_mul;
    i_sq_r_b <= o_mul;
  end

  if (mul0_equalize) begin
    if (state_r == MUL0) begin
      i_sq_r_a <= mult_out_equalized[0:NUM_WRDS-1];
      i_sq_r_b <= to_redun(MONT_FACTOR);
    end
    if (state_r == MUL1)
      add_term <= mult_out_equalized_r[NUM_WRDS:2*NUM_WRDS-1];
  end else begin
    if (state == MUL0)
      add_term <= mult_out[NUM_WRDS:2*NUM_WRDS-1];
  end

  if (state == MUL2) begin
    i_sq_r_a <= mult_out_equalized[0:NUM_WRDS-1];
    i_sq_r_b <= to_redun(P);
  end

  if (mul1_equalize) begin
    add_term <= add_term_r;
    if (state_r == MUL1) begin // We do this because we might need to hold the inputs in case of overflow
      i_sq_r_a <= mult_out_equalized[0:NUM_WRDS-1];
      i_sq_r_b <= to_redun(P);
    end
  end

  if (mul2_equalize) begin
    add_term <= to_redun(0);
  end
end

// Logic requiring reset
always_ff @ (posedge i_clk or posedge i_rst) begin
  if (i_rst) begin
    state <= IDLE;
    state_r <= IDLE;
    o_val_d <= 0;
    mul0_equalize <= 0;
    mul1_equalize <= 0;
    mul2_equalize <= 0;
    mul2_carry <= 0;
    o_val <= 0;
    i_val_r <= 0;
  end else begin

    i_val_r <= i_val;
    o_val <= o_val_d[2];

    if (mul2_equalize) mul2_carry <= 1;
    if (o_val_d[2]) mul2_carry <= 0;

    if ((state_r == MUL2 && ~mul2_carry) || (mul2_equalize && state_r == MUL2))
      o_val_d <= 1;
    else
      o_val_d <= o_val_d << 1;

    state <= next_state;
    state_r <= state;

    // Make sure we don't equalize while other stages are doing so, detect the worst case overflow condition
    if ((mul0_bndry >= (1 << WRD_BITS) - BOUNDARY_THRESHOLD) && ~(mul0_equalize || mul1_equalize || mul2_equalize || mul2_carry))
      mul0_equalize <= 1;
    if ((mul1_bndry >= (1 << WRD_BITS) - BOUNDARY_THRESHOLD) && ~(mul0_equalize || mul1_equalize || mul2_equalize || mul2_carry))
      mul1_equalize <= 1;
    if ((mul2_bndry >= (1 << WRD_BITS) - BOUNDARY_THRESHOLD) && ~(mul0_equalize || mul1_equalize || mul2_equalize || mul2_carry))
      mul2_equalize <= 1;

    if (state_r == MUL1) mul0_equalize <= 0;
    if (state_r == MUL2) mul1_equalize <= 0;
    if (state_r == MUL0) mul2_equalize <= 0;
  end
end

multi_mode_multiplier #(
  .NUM_ELEMENTS    ( NUM_WRDS                        ),
  .DSP_BIT_LEN     ( WRD_BITS+1                      ),
  .WORD_LEN        ( WRD_BITS                        ),
  .NUM_ELEMENTS_OUT( NUM_WRDS+SPECULATIVE_CARRY_WRDS )
)
multi_mode_multiplier (
  .i_clk      ( i_clk       ),
  .i_rst      ( i_rst       ),
  .i_ctl      ( mult_ctl    ),
  .i_dat_a    ( mul_a       ),
  .i_dat_b    ( mul_b       ),
  .i_add_term ( add_term_p1 ),
  .o_dat      ( mult_out    )
);

endmodule