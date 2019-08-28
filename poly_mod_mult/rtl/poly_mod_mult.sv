/*
  Multiplier using polynomial method. Input and output are in the
  redundant form, if conversion is required it needs to be performed seperatley.

  Copyright (C) 2019  Benjamin Devlin.

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

// test with 16 bit input, 2 words. 9 bits per coeffient to match DSP

module poly_mod_mult #(
  parameter IN_BITS   = 40,
  parameter WORD_BITS = 8,   // should match DSP size
  parameter NUM_WORDS = 4,
  parameter REDUN_WORD_BITS = 1, // One redundant bit per word
  parameter REDUN_WORDS = 1, // Require one redundant word for repeated multiplication
  parameter I_WORD = NUM_WORDS + REDUN_WORDS,
  parameter COEF_BITS = WORD_BITS + REDUN_WORD_BITS
) (
  input i_clk,
  input i_rst,
  input i_val,                                           // A pulse on this signal will start operating on inputs
  input i_mode,                                          // 0 = mult, 1 = square
  input [I_WORD-1:0][COEF_BITS-1:0]          i_dat_a,    // One extra word for overflow - bits here must be padded (in redundant form)
  input [I_WORD-1:0][COEF_BITS-1:0]          i_dat_b,
  output logic [I_WORD*2-1:0][COEF_BITS-1:0] o_dat,
  output logic                               o_val
);

// if squaring we don't need to do all mults, can just 2* to get same result in adder tree
// Internally we use 18x27 multipliers, input bits should be multipliers
// Coeff is 8 bits

// The log(log of the bits / cooef) will determine how many extra bits we need
localparam int SLICE = 2*(I_WORD*COEF_BITS)/45;
localparam ACCUM_EXTRA_BITS = $clog2(2*SLICE);
localparam PIPES = 5;

logic [I_WORD-1:0][COEF_BITS-1:0]    dat_a; // [I_WORD-1:0][COEF_BITS-1:0]
logic [I_WORD-1:0][COEF_BITS-1:0]    dat_b;
//logic [2*SLICE-1:0][SLICE*45:0] mul_out;
logic [2*SLICE-1:0][2*I_WORD-1:0][WORD_BITS-1:0] mul_out, mul_out_comb;

logic [2*I_WORD-1:0][WORD_BITS+ACCUM_EXTRA_BITS-1:0] accum_out, accum_out_comb;
 
logic [I_WORD*2:0][COEF_BITS-1:0] overflow_out, overflow_out_comb;  // + 1 here from I_WORD


logic [PIPES:0] val;
logic mode;

always_comb begin
  o_val = val[PIPES];
  o_dat = overflow_out;
end

always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    dat_a <= 0;
    dat_b <= 0;
    mul_out <= 0;
    accum_out <= 0;
    overflow_out <= 0;
    mode <= 0;
  end else begin
    val <= {val, i_val};
    dat_a <= i_dat_a;
    dat_b <= i_dat_b;
    mode <= i_mode;
    
    mul_out <= mul_out_comb;
    accum_out <= accum_out_comb;
    overflow_out <= overflow_out_comb;
  end
end



// Stage 1 do multiplications
always_comb begin
  // First we do all the multiplications required, fill the mul_out grid (2*(I_WORD*I_BITS)/45)^2
  // Alternate between 18 and 27 bits
  // TODO squaring we can skip diagonal elements
  mul_out_comb = 0;
  for (int i = 0; i < SLICE; i++) begin
    for (int j = 0; j < SLICE; j++) begin
      case({j%2, i%2})
        2'b00: mul_out_comb[i*SLICE+j][i*5 + j*5 +: 5] <= mul0(dat_a[i*3 +: 2], dat_b[j*3 +: 3]);
        2'b01: mul_out_comb[i*SLICE+j][(i-1)*5 + 2 + j*5 +: 5] <= mul1(dat_a[(i-1)*5 + 2 +: 3], dat_b[j*5 +: 2]);
        2'b10: mul_out_comb[i*SLICE+j][i*5 + (j-1)*5 + 3 +: 5] <= mul0(dat_a[i*5 +: 2], dat_b[ (j-1)*5 + 3 +: 3]);
        2'b11: mul_out_comb[i*SLICE+j][(i-1)*5 + 2 + (j-1)*5 + 3 +: 5] <= mul1(dat_a[(i-1)*5 + 2 +: 3], dat_b[ (j-1)*5 + 3 +: 2]);
      endcase
    end
  end
end

// Stage 2
// For each column we accumulate the multiplier results, each 8 bits
// Each column is now a coeffient - 9 bits
always_comb begin
  accum_out_comb = 0;
  for (int i = 0; i < I_WORD*2; i++)
    for (int j = 0; j < SLICE*2; j++)
      accum_out_comb[i] += mul_out[j][i];
  
end

// Stage 3 now we add any overflow bits from coeffient behind us
always_comb begin
  overflow_out_comb = 0;
  for (int i = 0; i < I_WORD*2; i++)
    overflow_out_comb[i] = accum_out[i] + (i > 0 ? accum_out[i-1][COEF_BITS +: (WORD_BITS + ACCUM_EXTRA_BITS - COEF_BITS)] : 0);
    
  overflow_out_comb[I_WORD*2] = accum_out[I_WORD*2-1][COEF_BITS +: (WORD_BITS + ACCUM_EXTRA_BITS - COEF_BITS)]; 
end

function [44:0] mul0(input [2:0][7:0] a, input [3:0][7:0] b);
  $display("mul0 %x and %x", a, b);
  mul0 = a*b;
endfunction

function [44:0] mul1(input [3:0][7:0] a, input [2:0][7:0] b);
  $display("mul1 %x and %x", a, b);
  mul1 = a*b;
endfunction

endmodule