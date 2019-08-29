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
module poly_mod_mult #(
  parameter bit SQ_MODE = 1,            // Only square (on i_dat_a)
  parameter int WORD_BITS = 8,          // Radix of each coeff.
  parameter int NUM_WORDS = 4,          // Number of words
  parameter int REDUN_WORD_BITS = 1,    // Redundant bits per word
  parameter int I_WORD = NUM_WORDS + 1, // Require one redundant word for repeated multiplication
  parameter int COEF_BITS = WORD_BITS + REDUN_WORD_BITS // This is size of DSP 
) (
  input i_clk,
  input i_rst,
  input i_val,                                           // A pulse on this signal will start operating on inputs                           
  input [I_WORD-1:0][COEF_BITS-1:0]          i_dat_a,    // One extra word for overflow - bits here must be padded (in redundant form)
  input [I_WORD-1:0][COEF_BITS-1:0]          i_dat_b,
  output logic [I_WORD*2-1:0][COEF_BITS-1:0] o_dat,
  output logic                               o_val
);

// TODO need to figure formula for extra bits - how many bits we can remove via carry stage add
localparam int ACCUM_EXTRA_BITS = SQ_MODE == 0 ? $clog2(I_WORD**2) : $clog2((I_WORD**2 + I_WORD)/2);

localparam PIPES = 5;

 // Convert this to a flat array for multiplication plus any padding
logic [I_WORD*COEF_BITS-1:0] dat_a, dat_b;
logic [COEF_BITS*2-1:0] mul_res;
logic [I_WORD**2-1:0][COEF_BITS*I_WORD*2-1:0] mul_out, mul_out_comb;

// Convert back to our polynomial representation
logic [2*I_WORD-1:0][WORD_BITS+ACCUM_EXTRA_BITS-1:0] accum_out, accum_out_comb;
 
logic [I_WORD*2:0][COEF_BITS-1:0] overflow_out, overflow_out_comb;

logic [PIPES:0] val;

always_comb begin
  o_val = val[PIPES];
  o_dat = overflow_out;
end

// Registered processes
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    dat_a <= 0;
    dat_b <= 0;
    mul_out <= 0;
    accum_out <= 0;
    overflow_out <= 0;
  end else begin
    val <= {val, i_val};
    dat_a[I_WORD*COEF_BITS-1:0] <= i_dat_a;
    if (SQ_MODE == 0) begin
      dat_b[I_WORD*COEF_BITS-1:0] <= i_dat_b;
    end
    mul_out <= mul_out_comb;
    accum_out <= accum_out_comb;
    overflow_out <= overflow_out_comb;
  end
end

// Stage 1 do multiplications
always_comb begin
  // First we do all the multiplications required
  // Squaring we can skip elements above diagonal and just shift elements below diagonal to double them
  mul_out_comb = 0;
  for (int i = 0; i < I_WORD; i++) begin
    for (int j = 0; j < I_WORD; j++) begin
      if (!(SQ_MODE == 1 && i < j)) begin
        // For squares - diagonal elements stay the same but below the diagonal get shifted 1 bit (doubled) during accumulator
        mul_res = mul(dat_a[i*COEF_BITS +: COEF_BITS], dat_a[j*COEF_BITS +: COEF_BITS]);
        // We need to split the mul_result up over the words (skip the redundant bits), and shift into the right locations
        mul_out_comb[i*I_WORD+j] = mul_shift(mul_res, i, j);
      end
    end
  end
end

// Stage 2
// For each column we accumulate the multiplier results, each COEF_BITS bits
// Each column is now COEF_BITS + ACCUM_EXTRA_BITS wide
always_comb begin
  accum_out_comb = 0;
  for (int i = 0; i < I_WORD*2; i++)
    for (int j = 0; j < I_WORD; j++)
      for (int k = 0; k < I_WORD; k++)
      // Here we check for elements we need to double if in SQ_MODE
      if (SQ_MODE == 1 && j > k) begin
        accum_out_comb[i] += 2*mul_out[j*I_WORD+k][i*COEF_BITS +: WORD_BITS];
      end else begin
        accum_out_comb[i] += mul_out[j*I_WORD+k][i*COEF_BITS +: WORD_BITS];
      end
end

// Stage 3 now we add any overflow bits from coeffient behind us
always_comb begin
  overflow_out_comb = 0;
  for (int i = 0; i < I_WORD*2; i++) begin
    overflow_out_comb[i] = accum_out[i][COEF_BITS-1:0] + (i > 0 ? accum_out[i-1][WORD_BITS + ACCUM_EXTRA_BITS - 1 : COEF_BITS] << 1 : 0);
  end  
  overflow_out_comb[I_WORD*2] = accum_out[I_WORD*2-1][WORD_BITS + ACCUM_EXTRA_BITS - 1 : COEF_BITS]; 
end

// Stage 4 is the reduction stage




function [COEF_BITS*2-1:0] mul(input [COEF_BITS-1:0] a, b);
  mul = a*b;
endfunction

function [COEF_BITS*I_WORD*2-1:0] mul_shift(input [COEF_BITS*2-1:0] a, input int i, j);
  localparam NUM_SHIFTS = (COEF_BITS*2 + WORD_BITS - 1)/WORD_BITS;
  logic [NUM_SHIFTS*WORD_BITS-1:0] a_;
  mul_shift = 0;
  a_ = a;
  for (int k = 0; k < NUM_SHIFTS; k++) begin
    mul_shift[(i+j)*COEF_BITS + k*COEF_BITS +: WORD_BITS] = a_[WORD_BITS*k +: WORD_BITS];
  end
endfunction


endmodule