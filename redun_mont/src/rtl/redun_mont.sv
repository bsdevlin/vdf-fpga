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
  input i_clk,
  input i_rst,
  input        [WRD_BITS:0] i_sq [NUM_WRDS],
  input                     i_val,
  output logic [WRD_BITS:0] o_mul [NUM_WRDS],
  output logic              o_val,
  output logic              o_overflow
);

localparam COL_BIT_LEN = 2*(WRD_BITS+1) - WRD_BITS;
localparam OUT_BIT_LEN = COL_BIT_LEN + $clog2(NUM_WRDS);
localparam MULT_CYCLES = 2'd1;

redun0_t mul_a, mul_b, hmul_out_h, tmp_h, i_sq_l;
redun1_t mult_out, mult_out_r;

logic val, val_o;

logic [1:0] ctl, cnt;  // also make ctl one hot
enum {IDLE, START, MUL0, MUL1, MUL2, FULL_MULT} state;

// Assign input to multiplier
always_comb begin

  for (int i = 0; i < NUM_WRDS; i++)
    hmul_out_h[i] = mult_out[NUM_WRDS-1-i];

  case(state)
    IDLE: begin // Squaring
      mul_a = i_sq_l;
      mul_b = i_sq_l;
    end
    START: begin
      mul_a = i_sq_l;
      mul_b = i_sq_l;
    end
    MUL0: begin // Squaring
      mul_a = mult_out[0:NUM_WRDS-1];
      mul_b = to_redun(MONT_FACTOR);
    end
    MUL1: begin
      mul_a = mult_out[0:NUM_WRDS-1];
      mul_a[NUM_WRDS-1][WRD_BITS] = 0;
      mul_b = to_redun(P);
    end
    MUL2: begin
      mul_a = hmul_out_h;
      mul_b = hmul_out_h;
    end
  endcase

end

// Logic without reset
always_ff @ (posedge i_clk) begin
  i_sq_l <= i_sq;
end

// State machine and logic requiring reset
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
  //  cnt <= 0;
    val <= 0;
    o_overflow <= 0;
    o_val <= 0;
    o_mul <= to_redun(0);
    state <= IDLE;
    ctl <= 0;
    tmp_h <= to_redun(0);
    mult_out_r <= to_redun1(0);
  end else begin
    mult_out_r <= mult_out;
    o_val <= 0;
    cnt <= cnt + 1;
    val <= 0;
    case(state)
      IDLE: begin
        cnt <= 0;
       // cnt_oh <= 0;
        ctl <= 2;
        // Waiting for valid and square
      end
      START: begin
        cnt <= 0;
        state <= MUL0;
        ctl <= 2;
        o_overflow <= 0;
      end
      MUL0: begin
        ctl <= 0;
        tmp_h <= to_redun(0);
                val <= cnt == 0;
        if(cnt == MULT_CYCLES) begin
          state <= MUL1;
          cnt <= 0;
         
          // TODO pipeline this with mult_out_r
        for (int i = 0; i < NUM_WRDS; i++) begin
          tmp_h[i] <= mult_out[NUM_WRDS+i];// + i == 0 ? 1 : 0;
        end

        end
      end
      MUL1: begin
        ctl <= 1;
        if (cnt==0) begin
          tmp_h[0] <= tmp_h[0] + 1;
        end
        val <= cnt == 0;
        if(cnt == MULT_CYCLES) begin
          state <= MUL2;
          cnt <= 0;
        end
      end
      MUL2: begin
        ctl <= 2;
        tmp_h <= to_redun(0);
        val <= cnt == 0;
        if(cnt == MULT_CYCLES) begin
          state <= MUL0;
          o_mul <= hmul_out_h;
          o_val <= 1;
          ctl <= 2;
          cnt <= 0;
        end
      end
      FULL_MULT: begin
       // Need to get upper words
      end
    endcase

    if (i_val) begin
      state <= START;
      val <= 1;
    end
  end
end

multi_mode_multiplier #(
  .NUM_ELEMENTS (NUM_WRDS),
  .DSP_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .NUM_ELEMENTS_OUT(NUM_WRDS+SPECULATIVE_CARRY_WRDS)
)
multi_mode_multiplier (
  .i_clk      ( i_clk    ),
  .i_rst      ( i_rst    ),
  .i_val      ( val      ),
  .i_ctl      ( ctl      ),
  .i_dat_a    ( mul_a    ),
  .i_dat_b    ( mul_b    ),
  .i_add_term ( tmp_h    ),
  .o_dat      ( mult_out ),
  .o_val      ( val_o    )
);

endmodule