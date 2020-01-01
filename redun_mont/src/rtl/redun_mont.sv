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
  output logic              o_val
);

localparam COL_BIT_LEN = 2*(WRD_BITS+1) - WRD_BITS;
localparam OUT_BIT_LEN = COL_BIT_LEN + $clog2(NUM_WRDS);
localparam PIPELINE_MULT = 1;
localparam CTL_FIXED = 0;
localparam MULT_CYCLES = 1 + PIPELINE_MULT;


redun0_t mul_a, mul_b, hmul_out_h, tmp_h, i_sq_l, mult_out_l, mont_factor, p_conv;
redun1_t mult_out, mult_out_r;

logic val, val_o;

logic [1:0] ctl [NUM_WRDS];
logic [$clog2(MULT_CYCLES):0] cnt [NUM_WRDS];  // also make ctl one hot
enum {IDLE, START, MUL0, MUL1, MUL2} state [NUM_WRDS];

// Assign input to multiplier
always_comb begin

  for (int i = 0; i < NUM_WRDS; i++)
    hmul_out_h[i] = mult_out[NUM_WRDS-1-i];
    
  mult_out_l = mult_out[0:NUM_WRDS-1];
  mont_factor = to_redun(MONT_FACTOR);
  p_conv = to_redun(P);

  mul_a = i_sq_l;
  mul_b = i_sq_l;
  for (int i = 0; i < NUM_WRDS; i++)
      case(state[i])
        IDLE: begin // Squaring
          mul_a[i] = i_sq_l[i];
          mul_b[i] = i_sq_l[i];
        end
        START: begin
          mul_a[i] = i_sq_l[i];
          mul_b[i] = i_sq_l[i];
        end
        MUL0: begin // Squaring
          mul_a[i] = mult_out_l[i];
          mul_b[i] = mont_factor[i];
        end
        MUL1: begin
          mul_a[i] = mult_out_l[i];
          mul_a[NUM_WRDS-1][WRD_BITS] = 0;
          mul_b[i] = p_conv[i];
        end
        MUL2: begin
          mul_a[i] = hmul_out_h[i];
          mul_b[i] = hmul_out_h[i];
        end
      endcase

end


// State machine and logic requiring reset
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    o_val <= 0;
    o_mul <= to_redun(0);
    for (int i = 0; i < NUM_WRDS; i++) begin
      state[i] <= IDLE;
      cnt[0] <= 0;
      ctl[i] <= 0;
    end
    tmp_h <= to_redun(0);
    mult_out_r <= to_redun1(0);
    i_sq_l <= to_redun(0);
  end else begin
    mult_out_r <= mult_out;
    o_val <= 0;
    for (int i = 0; i < NUM_WRDS; i++) cnt[i] <= cnt[i] + 1;
    val <= 0;
    for (int i = 0; i < NUM_WRDS; i++)
        case(state[i])
          IDLE: begin
           // cnt_oh <= 0;
            for (int i = 0; i < NUM_WRDS; i++) ctl[i] <= 2;
            // Waiting for valid and square
          end
          START: begin
            if(cnt[i] == MULT_CYCLES) begin
              cnt[i] <= 0;
              state[i] <= MUL0;
              ctl[i] <= 2;
            end
          end
          MUL0: begin
            ctl[i] <= 0;
            tmp_h[i] <= 0;
           // val <= cnt[i] == MULT_CYCLES-1;
            if(cnt[i] == MULT_CYCLES) begin
              state[i] <= MUL1;
              cnt[i] <= 0;
             
              tmp_h[i] <= mult_out[NUM_WRDS+i] + (i == 0 ? mult_out[NUM_WRDS-1][WRD_BITS] : 0);

            end
          end
          MUL1: begin
            ctl[i] <= 1;
            if (i == 0 && cnt[i]==0) begin
              tmp_h[0] <= tmp_h[0] + 1;
            end
      //      val <= cnt[i] == MULT_CYCLES-1;
            if(cnt[i] == MULT_CYCLES) begin
              state[i] <= MUL2;
              cnt[i] <= 0;
            end
          end
          MUL2: begin
              ctl[i] <= 2;
              tmp_h[i] <= 0;
          //  val <= cnt[i] == MULT_CYCLES-1;
            if(cnt[i] == MULT_CYCLES) begin
              state[i] <= MUL0;
              o_mul[i] <= hmul_out_h[i];
              o_val <= 1;
              cnt[i] <= 0;
            end
          end
        endcase

    if (i_val) begin
      i_sq_l <= i_sq;
      for (int i = 0; i < NUM_WRDS; i++) begin
        cnt[i] <= MULT_CYCLES;
        state[i] <= START;
      end      
      val <= 1;
    end
  end
end

multi_mode_multiplier #(
  .NUM_ELEMENTS    ( NUM_WRDS                        ),
  .DSP_BIT_LEN     ( WRD_BITS+1                      ),
  .WORD_LEN        ( WRD_BITS                        ),
  .NUM_ELEMENTS_OUT( NUM_WRDS+SPECULATIVE_CARRY_WRDS ),
  .PIPELINE_OUT    ( PIPELINE_MULT                   ),
  .CTL_FIXED       ( CTL_FIXED                       )
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