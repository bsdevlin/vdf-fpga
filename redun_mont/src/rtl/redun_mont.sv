/*
  Copyright (C) 2019  Benjamin Devlin

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

redun0_t mul_a, mul_b, hmul_a, hmul_b, hmul_out_h, tmp_h, tmp_zero;
redun1_t tmp,  sqr_out, mult_out;
redun2_t hmul_out;


logic hmul_ctl;
logic val, val_o;

logic [1:0] cnt;
enum {IDLE, MUL0, MUL1, MUL2, ADD0, FULL_MULT} state;

// Assign input to multiplier
always_comb begin
  for (int i = 0; i < NUM_WRDS; i++)
    hmul_out_h[i] = hmul_out[NUM_WRDS-1-i];
    
  hmul_a = mult_out[0:NUM_WRDS-1];//sqr_out[0:NUM_WRDS-1];
  hmul_b = to_redun(MONT_FACTOR);
  
  case(state)
    IDLE: begin // Squaring
      mul_a = i_sq;
      mul_b = i_sq;
    end
    MUL0: begin // Squaring
      hmul_a = mult_out[0:NUM_WRDS-1];//sqr_out[0:NUM_WRDS-1];
      hmul_b = to_redun(MONT_FACTOR);
    end
    MUL1: begin 
      hmul_a = hmul_out[0:NUM_WRDS-1];
      hmul_a[NUM_WRDS-1][WRD_BITS] = 0;
      hmul_b = to_redun(P);
    end
    MUL2: begin     
      mul_a = hmul_out_h;
      mul_b = hmul_out_h;
    end
  endcase

end

// State machine
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    cnt <= 0;
    val <= 0;
    o_overflow <= 0;
    o_val <= 0;
    o_mul <= to_redun(0);
    state <= IDLE;
    hmul_ctl <= 0;
    for (int i = 0; i< NUM_WRDS*2; i++) begin
      tmp[i] <= 0;
    end
    tmp_h <= to_redun(0);
    tmp_zero <= to_redun(0);
  end else begin
    o_val <= 0;
    cnt <= cnt + 1;
    val <= val_o;
    for (int i = 0; i < NUM_WRDS; i++) begin
      tmp_h[i] <= mult_out[NUM_WRDS+i]; //sqr_out[NUM_WRDS+i]; // + i == 0 ? 1 : 0;
    end    
    case(state)
      IDLE: begin
        cnt <= 0;
        hmul_ctl <= 0;
        // Waiting for valid
      end
      MUL0: begin
        tmp_h <= to_redun(0);
        if(cnt == MULT_CYCLES) begin
          state <= MUL1;
          tmp <= mult_out;//sqr_out;
          hmul_ctl <= 1;
          cnt <= 0;
        end
      end
      MUL1: begin
        if(cnt == MULT_CYCLES) begin
          state <= MUL2;
          hmul_ctl <= 0;
          cnt <= 0;
        end
      end
      MUL2: begin
        if(cnt == MULT_CYCLES) begin
          state <= MUL0;
          o_mul <= hmul_out_h;
          o_val <= 1;
          hmul_ctl <= 0;
          cnt <= 0;
        end
      end
      FULL_MULT: begin
        hmul_ctl <= 1; // Need to get upper words
      end
    endcase
    
    val <= i_val;

    if (i_val) begin
      cnt <= 0;
      o_val <= 0;
      state <= MUL0;
      o_overflow <= 0;
    end
  end
end

// Half multiplier
half_multiply #(
  .NUM_ELEMENTS (NUM_WRDS),
  .DSP_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .NUM_ELEMENTS_OUT(NUM_WRDS+SPECULATIVE_CARRY_WRDS)
)
half_multiply (
  .clk ( i_clk ),
  .ctl ( hmul_ctl ),
  .A   ( hmul_a   ),
  .B   ( hmul_b   ),
  .ADD_i ( tmp_h  ), 
  .i_sqr ( 0 ),
  .out ( hmul_out )
);

// Unit for squaring
squarer #(
  .NUM_ELEMENTS (NUM_WRDS),
  .A_BIT_LEN (WRD_BITS+1),
  .B_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .MUL_OUT_BIT_LEN(2*(WRD_BITS+1)),
  .COL_BIT_LEN(COL_BIT_LEN),
  .EXTRA_TREE_BITS($clog2(NUM_WRDS)),
  .OUT_BIT_LEN(OUT_BIT_LEN)
)
squarer0 (
  .clk ( i_clk ),
  .A   ( mul_a ),
  .B   ( mul_b ),
  .out ( sqr_out  )
);

multi_mode_multiplier #(
  .NUM_ELEMENTS (NUM_WRDS),
  .DSP_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .NUM_ELEMENTS_OUT(NUM_WRDS+SPECULATIVE_CARRY_WRDS)
)
multi_mode_multiplier (
  .i_clk ( i_clk ),
  .i_val ( val   ),
  .i_ctl ( 2'd2  ),
  .i_dat_a ( mul_a),
  .i_dat_b ( mul_b ),
  .i_add_term (tmp_zero),
  .o_dat (mult_out),
  .o_val ( val_o )
);


endmodule