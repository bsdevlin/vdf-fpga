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
  input        [WRD_BITS:0] i_mul_a [NUM_WRDS],
  input        [WRD_BITS:0] i_mul_b [NUM_WRDS],
  input                     i_val,
  output logic [WRD_BITS:0] o_mul [NUM_WRDS],
  output logic              o_val,
  output logic              o_overflow
);

localparam COL_BIT_LEN = 2*(WRD_BITS+1) - WRD_BITS;
localparam OUT_BIT_LEN = COL_BIT_LEN + $clog2(NUM_WRDS);

localparam MULT_CYCLES = 2'd1;

redun0_t mul_a, mul_b, add_o;
redun1_t mul_out1, tmp;

logic [1:0] cnt;
enum {IDLE, MUL0, MUL1, MUL2, ADD0} state;

// Assign input to multiplier
always_comb begin

  case(state)
    IDLE: begin
      mul_a = i_mul_a;
      mul_b = i_mul_b;
    end
    MUL0: begin
      mul_a = i_mul_a;
      mul_b = i_mul_b;
    end
    MUL1: begin
      mul_a = get_l_wrds(mul_out1);
      mul_a[NUM_WRDS-1][WRD_BITS] = 0;
      mul_b = to_redun(MONT_FACTOR);
    end
    MUL2: begin
      mul_a = get_l_wrds(mul_out1);
      mul_a[NUM_WRDS-1][WRD_BITS] = 0;
      mul_b = to_redun(P);
    end
    ADD0: begin
      for (int i = 0; i < NUM_WRDS; i++) begin
        mul_a[i] = tmp[i+NUM_WRDS] + mul_out1[i+NUM_WRDS] + (i == 0 ? tmp[NUM_WRDS-1][WRD_BITS] + mul_out1[NUM_WRDS-1][WRD_BITS] + 1 : 0);
        mul_b[i] = mul_a[i];
      end
    end
  endcase
  
end

// State machine
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    cnt <= 0;
    o_overflow <= 0;
    o_val <= 0;
    o_mul <= to_redun(0);
    state <= IDLE;
    for (int i = 0; i< NUM_WRDS*2; i++) begin
      tmp[i] <= 0;
    end
  end else begin
    o_val <= 0;
    cnt <= cnt + 1;
    case(state) 
      IDLE: begin
        cnt <= 0;
        // Waiting for valid
      end
      MUL0: begin // Need to check for overflow.
        if(cnt == MULT_CYCLES) begin
          state <= MUL1;
          cnt <= 0;
        end
      end
      MUL1: begin
        if (cnt == 0) tmp <= mul_out1;
        o_overflow <= o_overflow || check_overflow(mul_a);
        if(cnt == MULT_CYCLES) begin
          state <= MUL2;
          cnt <= 0;
        end
      end
      MUL2: begin
        o_overflow <= o_overflow || check_overflow(mul_a);
        if(cnt == MULT_CYCLES) begin
          state <= ADD0;
          cnt <= 0;
        end
      end      
      ADD0: begin
        o_overflow <= o_overflow || check_overflow(mul_a);
        for (int i = 0; i < NUM_WRDS; i++) begin
          o_mul[i] <= tmp[i+NUM_WRDS] + mul_out1[i+NUM_WRDS] + (i == 0 ? tmp[NUM_WRDS-1][WRD_BITS] + mul_out1[NUM_WRDS-1][WRD_BITS] + 1 : 0);
        end
        o_val <= 1;
        cnt <= 1;
        state <= MUL0;
      end
    endcase

    if (i_val) begin
      cnt <= 0;
      o_val <= 0;        
      state <= MUL0;
      o_overflow <= 0;
    end    
  end
end

// Multiplier

multiply #(
  .NUM_ELEMENTS (NUM_WRDS),
  .A_BIT_LEN (WRD_BITS+1),
  .B_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .MUL_OUT_BIT_LEN(2*(WRD_BITS+1)),
  .COL_BIT_LEN(COL_BIT_LEN),
  .EXTRA_TREE_BITS($clog2(NUM_WRDS)),
  .OUT_BIT_LEN(OUT_BIT_LEN)
)
multiply0 (
  .clk ( i_clk ),
  .A   ( mul_a ),
  .B   ( mul_b ),
  .out ( mul_out1  )
);


endmodule