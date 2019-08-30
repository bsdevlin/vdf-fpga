/*
  Multiplier with reduction using polynomial method. Input and output are in the
  redundant form, if conversion is required it needs to be performed seperatley.
  
  If you change these parameters make sure to remove the reduction_lut*.mem files
  to prevent using wrong values.

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
  parameter bit                       SQ_MODE = 1,            // Only square (on i_dat_a)
  parameter int                       WORD_BITS = 8,          // Radix of each coeff.
  parameter int                       NUM_WORDS = 4,          // Number of words
  parameter [WORD_BITS*NUM_WORDS-1:0] MODULUS = 128,
  parameter int                       REDUCTION_BITS = 9,     // This is the number of bits we take at once for reduction
  parameter int                       REDUN_WORD_BITS = 1,    // Redundant bits per word
  // Below here the parameters should not be changed
  parameter int                       I_WORD = NUM_WORDS + 1, // Require one redundant word for repeated multiplication
  parameter int                       COEF_BITS = WORD_BITS + REDUN_WORD_BITS // This is size of DSP 
) (
  input i_clk,
  input i_rst,
  input i_val,                                         // A pulse on this signal will start operating on inputs                           
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat_a,    // One extra word for overflow - bits here must be in redundant form
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat_b,
  output logic [I_WORD-1:0][COEF_BITS-1:0] o_dat,
  output logic                             o_val
);


localparam int ACCUM_EXTRA_BITS = SQ_MODE == 0 ? $clog2(I_WORD**2) : $clog2((I_WORD**2 + I_WORD)/2);
localparam int REDUCTION_STAGES = (COEF_BITS + REDUCTION_BITS - 1) / REDUCTION_BITS;
localparam int REDUCTION_EXTRA_BITS = $clog2(REDUCTION_STAGES*(I_WORD*2-NUM_WORDS));
localparam PIPES = 5;

logic [PIPES:0] val;

 // Convert this to a flat array for multiplication plus any padding
logic [I_WORD*COEF_BITS-1:0] dat_a, dat_b;
logic [COEF_BITS*2-1:0] mul_res;
logic [I_WORD**2-1:0][COEF_BITS*I_WORD*2-1:0] mul_out, mul_out_comb;

// Convert back to our polynomial representation
logic [I_WORD*2-1:0][WORD_BITS+ACCUM_EXTRA_BITS-1:0] accum_out, accum_out_comb;
logic [I_WORD*2:0][COEF_BITS-1:0] overflow_out, overflow_out_comb;

// These are for the reduction step, could be muxed onto those above
logic [NUM_WORDS-1:0][WORD_BITS+REDUCTION_EXTRA_BITS-1:0] accum_r_out, accum_r_out_comb;
logic [NUM_WORDS:0][COEF_BITS-1:0] overflow_r_out, overflow_r_out_comb;

// This represents an array of RAMs used for the reduction values
typedef struct {
  logic [NUM_WORDS*WORD_BITS-1:0] ram [(1 << REDUCTION_BITS)-1:0];
} reduction_ram_t;

// An array of our RAM for reduction
reduction_ram_t reduction_ram [I_WORD*2-NUM_WORDS:0][REDUCTION_STAGES-1:0];
// Address drivers for RAM
logic [REDUCTION_BITS-1:0] reduction_ram_a [I_WORD*2-NUM_WORDS:0][REDUCTION_STAGES-1:0];
// Data output from RAM
logic [I_WORD*2-NUM_WORDS:0][REDUCTION_STAGES-1:0][NUM_WORDS*WORD_BITS-1:0] reduction_ram_d;

genvar g_i, g_j;
generate
  for (g_i = 0; g_i <= I_WORD*2-NUM_WORDS; g_i++)
    for (g_j = 0; g_j < REDUCTION_STAGES; g_j++)
        always_comb
          reduction_ram_d[g_i][g_j] = reduction_ram[g_i][g_j].ram[reduction_ram_a[g_i][g_j]];
endgenerate

initial begin
  // First check if it exists and if it dosen't, create it
  int fd;

  logic [COEF_BITS*I_WORD*2-1:0] value;
  logic [NUM_WORDS*WORD_BITS-1:0] value_mod;
  
  // Create files if needed
  for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++) begin
    for (int j = 0; j < REDUCTION_STAGES; j++) begin
      fd = $fopen ($sformatf("reduction_lut_%0d.%0d.mem", i,j), "r");
      if (!fd) begin
        $display("INFO: Lut reduction file (reduction_lut_%0d.%0d.mem) does not exist, creating...", i, j);
        fd = $fopen ($sformatf("reduction_lut_%0d.%0d.mem", i,j), "w");
        if (!fd)
          $fatal(1, "ERROR: Could not open file for writing!");
        for (int k = 0; k < (1 << REDUCTION_BITS); k++) begin
          value = (k << (j*REDUCTION_BITS + (i+NUM_WORDS)*WORD_BITS));
          value_mod = value %  MODULUS;
          $fdisplay (fd, "%x", value_mod);
        end
      end
      $fclose(fd);
    end
  end

  // Load memory
  for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++)
    for (int j = 0; j < REDUCTION_STAGES; j++) begin
      fd = $fopen ($sformatf("reduction_lut_%0d.%0d.mem", i,j), "r");
      for (int k = 0; k < (1 << REDUCTION_BITS); k++)
        $fscanf(fd, "%x\n", reduction_ram[i][j].ram[k]);
      $fclose(fd);
    end
end

always_comb begin
  o_val = val[PIPES];
  o_dat = overflow_r_out;
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
    for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++)
      for (int j = 0; j < REDUCTION_STAGES; j++)
        reduction_ram_a[i][j] <= 0;
  end else begin
    val <= {val, i_val};
    dat_a[I_WORD*COEF_BITS-1:0] <= i_dat_a;
    if (SQ_MODE == 0) begin
      dat_b[I_WORD*COEF_BITS-1:0] <= i_dat_b;
    end
    mul_out <= mul_out_comb;
    accum_out <= accum_out_comb;
    overflow_out <= overflow_out_comb;
    accum_r_out <= accum_r_out_comb;
    overflow_r_out <= overflow_r_out_comb;
    for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++)
      for (int j = 0; j < REDUCTION_STAGES; j++)
        if (j == REDUCTION_STAGES-1)
          reduction_ram_a[i][j] <= overflow_out_comb[i+NUM_WORDS][COEF_BITS-1 : REDUCTION_BITS*(REDUCTION_STAGES-1)];
        else
          reduction_ram_a[i][j] <= overflow_out_comb[i+NUM_WORDS][REDUCTION_BITS*j +: REDUCTION_BITS];
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
    overflow_out_comb[i] = accum_out[i][WORD_BITS-1:0] + (i > 0 ? accum_out[i-1][WORD_BITS + ACCUM_EXTRA_BITS - 1 : WORD_BITS] : 0);
  end  
  overflow_out_comb[I_WORD*2] = accum_out[I_WORD*2-1][WORD_BITS + ACCUM_EXTRA_BITS - 1 : WORD_BITS]; 
end

// Stage 4 is the accum reduction stage. First load values into RAM address
always_comb begin
  accum_r_out_comb = 0;
  for (int i = 0; i < NUM_WORDS; i++) begin
    accum_r_out_comb[i] = overflow_out[i];
    for (int j = 0; j <= I_WORD*2-NUM_WORDS; j++) begin
      for (int k = 0; k < REDUCTION_STAGES; k++) begin
        accum_r_out_comb[i] += reduction_ram_d[j][k][i*WORD_BITS +: WORD_BITS];
      end
    end
  end
end

// Stage 5 final stage overflow addition - same as stage 3, propigate one level of carry
always_comb begin
  overflow_r_out_comb = 0;
  for (int i = 0; i < NUM_WORDS; i++) begin
    overflow_r_out_comb[i] = accum_r_out[i][WORD_BITS-1:0] + (i > 0 ? accum_r_out[i-1][WORD_BITS + REDUCTION_EXTRA_BITS - 1 : WORD_BITS]: 0);
  end  
  overflow_r_out_comb[NUM_WORDS] = accum_r_out[NUM_WORDS-1][WORD_BITS + REDUCTION_EXTRA_BITS - 1 : WORD_BITS]; 
end

// This function does the mutliplication
function [COEF_BITS*2-1:0] mul(input [COEF_BITS-1:0] a, b);
  mul = a*b;
endfunction

// This function splits the mutliplation result up correctly accross coefficients
function [COEF_BITS*I_WORD*2-1:0] mul_shift(input [COEF_BITS*2-1:0] a, input int i, j);
  localparam NUM_SHIFTS = (COEF_BITS*2 + WORD_BITS - 1)/WORD_BITS;
  logic [COEF_BITS*(I_WORD+1)*2:0] mul_shift_;
  logic [NUM_SHIFTS*WORD_BITS-1:0] a_;
  mul_shift_ = 0;
  a_ = a;
  for (int k = 0; k < NUM_SHIFTS; k++) begin
    mul_shift_[(i+j)*COEF_BITS + k*COEF_BITS +: WORD_BITS] = a_[WORD_BITS*k +: WORD_BITS];
  end
  mul_shift = mul_shift_;
endfunction

endmodule