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
  parameter int                       COEF_BITS = WORD_BITS + REDUN_WORD_BITS, // This is size of DSP
  parameter bit                       SIMULATION = 0
) (
  input i_clk,
  input i_rst,
  input i_val,                                         // A pulse on this signal will start operating on inputs
  input i_reduce_only,                                 // This takes the input and only does a reduction operation
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat_a,    // One extra word for overflow - bits here must be in redundant form
  input [I_WORD-1:0][COEF_BITS-1:0]        i_dat_b,
  output logic [I_WORD-1:0][COEF_BITS-1:0] o_dat,
  output logic                             o_val
);

localparam int ACCUM_EXTRA_BITS = (SQ_MODE == 0 ? $clog2(I_WORD**2) : $clog2((I_WORD**2 + I_WORD)/2));
localparam int REDUCTION_STAGES = (COEF_BITS + REDUCTION_BITS - 1) / REDUCTION_BITS;
localparam int MULT_SPLITS = (2*COEF_BITS + WORD_BITS - 1) / WORD_BITS;     // Number of splits per grid element for multiplication
localparam int NUM_ACCUM_COLS = (2*I_WORD*COEF_BITS + WORD_BITS -1) / WORD_BITS;
localparam int REDUCTION_EXTRA_BITS = $clog2(REDUCTION_STAGES*(I_WORD*2-NUM_WORDS));
localparam PIPES = 5;

genvar g_i, g_j, g_k;

logic [PIPES:0] val;

// Multiplication grid
logic [I_WORD-1:0][COEF_BITS-1:0] dat_a, dat_b;
logic [I_WORD-1:0][I_WORD-1:0][COEF_BITS*2-1:0] mul_out;

// Convert back to our polynomial representation
logic [NUM_ACCUM_COLS-1:0][WORD_BITS+ACCUM_EXTRA_BITS-1:0] accum_out;
logic [NUM_ACCUM_COLS-1:0][COEF_BITS-1:0] overflow_out, overflow_out0;

// These are for the reduction step, could be muxed onto those above
logic [NUM_WORDS-1:0][WORD_BITS+REDUCTION_EXTRA_BITS-1:0] accum_r_out;
logic [NUM_WORDS:0][COEF_BITS-1:0] overflow_r_out;

// This represents an array of RAMs used for the reduction values
typedef struct {
  logic [NUM_WORDS*WORD_BITS-1:0] ram [(1 << REDUCTION_BITS)-1:0];
} reduction_ram_t;

// Address drivers for RAM
logic [REDUCTION_BITS-1:0] reduction_ram_a [I_WORD*2-NUM_WORDS:0][REDUCTION_STAGES-1:0];
// Data output from RAM
logic [I_WORD*2-NUM_WORDS:0][REDUCTION_STAGES-1:0][NUM_WORDS*WORD_BITS-1:0] reduction_ram_d;
// Include our file that is generated from the python script ../scripts/generate_reduction_ram.py
`include "reduction_ram.sv"

always_comb begin
  o_val = val[PIPES];
  o_dat = overflow_r_out;
  overflow_out = (i_reduce_only && i_val) ? i_dat_a : overflow_out0;
end

// Registered processes
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    dat_a <= 0;
    dat_b <= 0;
    for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++)
      for (int j = 0; j < REDUCTION_STAGES; j++)
        reduction_ram_a[i][j] <= 0;
  end else begin
    val <= {val, i_val};
    if (i_reduce_only && i_val) begin
      val <= 0;
      val[3] <= 1;
    end
    dat_a[I_WORD*COEF_BITS-1:0] <= i_dat_a;
    if (SQ_MODE == 0) begin
      dat_b[I_WORD*COEF_BITS-1:0] <= i_dat_b;
    end
    for (int i = 0; i <= I_WORD*2-NUM_WORDS; i++)
      for (int j = 0; j < REDUCTION_STAGES; j++)
        if (j == REDUCTION_STAGES-1)
          reduction_ram_a[i][j] <= overflow_out[i+NUM_WORDS][COEF_BITS-1 : REDUCTION_BITS*(REDUCTION_STAGES-1)];
        else
          reduction_ram_a[i][j] <= overflow_out[i+NUM_WORDS][REDUCTION_BITS*j +: REDUCTION_BITS];
  end
end

// Stage 1 instantiate the multipliers
generate
  for (g_i = 0; g_i < I_WORD; g_i++) begin: MUL0_I_GEN
    for (g_j = 0; g_j < I_WORD; g_j++) begin: MUL0_J_GEN
      if (!(SQ_MODE == 1 && g_i < g_j)) begin
      
        multiplier #(
          .IN_BITS ( COEF_BITS )
        )
        multiplier_stage0 (
          .i_clk ( i_clk ),
          .i_dat_a ( dat_a[g_i] ),
          .i_dat_b ( SQ_MODE == 1 ? dat_a[g_j] : dat_b[g_j] ),
          .o_dat ( mul_out[g_i][g_j] )
        );
        
      end else begin
        always_comb mul_out[g_i][g_j] = 0;
      end
    end
  end
endgenerate

// Stage 2 is the accumulate adder tree from multiplier output
generate
  for (g_k = 0; g_k < NUM_ACCUM_COLS; g_k++) begin: ACC0_K_GEN
    localparam int IN_BITS = SQ_MODE == 1 ? WORD_BITS + 1 : WORD_BITS;
    logic [I_WORD*2-1:0][IN_BITS-1:0]    accum_i;
    logic [IN_BITS + $clog2(I_WORD)-1:0] accum_o;

    tree_adder #(
      .NUM_IN  ( I_WORD*2 ),
      .IN_BITS ( IN_BITS  )
    )
    tree_adder_stage1 (
      .i_clk ( i_clk   ),
      .i_dat ( accum_i ),
      .o_dat ( accum_o )
    );

    always_comb begin
      accum_out[g_k] = accum_o;
      accum_i = get_grid_elements(g_k);
    end
  end
endgenerate

// Stage 3 now we add any overflow bits from coeffient behind us
generate
  for (g_k = 0; g_k < NUM_ACCUM_COLS; g_k++) begin: CARRY0_K_GEN
    logic [1:0][WORD_BITS-1:0] carry0_i;
    
    tree_adder #(
      .NUM_IN  ( 2         ),
      .IN_BITS ( WORD_BITS )
    )
    tree_adder_stage1 (
      .i_clk ( i_clk ),
      .i_dat ( carry0_i           ),
      .o_dat ( overflow_out0[g_k] )
    );
    
    always_comb begin
      carry0_i[0] = accum_out[g_k][WORD_BITS-1:0];
      carry0_i[1] = (g_k == 0) ? 0 : accum_out[g_k-1][WORD_BITS + ACCUM_EXTRA_BITS - 1 : WORD_BITS];
    end
  end
endgenerate

// Stage 4 is the accum reduction stage. Take values from RAM and accumulate
generate
  for (g_i = 0; g_i < NUM_WORDS; g_i++) begin: ACCUM1_I_GEN
    localparam NUM_IN = 1 + (1 + I_WORD*2-NUM_WORDS)*REDUCTION_STAGES;
    logic [NUM_IN-1:0][WORD_BITS:0] accum1_i;
    
    tree_adder #(
      .NUM_IN  ( NUM_IN        ),
      .IN_BITS ( WORD_BITS + 1 )
    )
    tree_adder_stage4 (
      .i_clk ( i_clk ),
      .i_dat ( accum1_i         ),
      .o_dat ( accum_r_out[g_i] )
    );
    
    for(g_j = 0; g_j <= I_WORD*2-NUM_WORDS; g_j++) begin: ACCUM1_J_GEN
      for(g_k = 0; g_k < REDUCTION_STAGES; g_k++) begin: ACCUM1_K_GEN
        always_comb accum1_i[g_j*REDUCTION_STAGES+g_k] = {1'd0, reduction_ram_d[g_j][g_k][g_i*WORD_BITS +: WORD_BITS]};
      end
    end
    always_comb accum1_i[NUM_IN-1] = overflow_out0[g_i];
  end
endgenerate

// Stage 5 final stage overflow addition - same as stage 3, propigate one level of carry
generate
  for (g_k = 0; g_k < NUM_WORDS; g_k++) begin: CARRY1_K_GEN
    logic [1:0][WORD_BITS-1:0] carry1_i;
    
    tree_adder #(
      .NUM_IN  ( 2         ),
      .IN_BITS ( WORD_BITS )
    )
    tree_adder_stage1 (
      .i_clk ( i_clk ),
      .i_dat ( carry1_i            ),
      .o_dat ( overflow_r_out[g_k] )
    );
    
    always_comb begin
      carry1_i[0] = accum_r_out[g_k][WORD_BITS-1:0];
      carry1_i[1] = (g_k == 0) ? 0 : accum_r_out[g_k-1][WORD_BITS + REDUCTION_EXTRA_BITS - 1 : WORD_BITS];
    end
  end
  always_comb overflow_r_out[NUM_WORDS] = accum_r_out[NUM_WORDS-1][WORD_BITS + REDUCTION_EXTRA_BITS - 1 : WORD_BITS];
endgenerate

// For a given coef, return what grid elements should be accumulated
// It will be everything below us that hasn't been accumulated yet
function [I_WORD*2-1:0][(SQ_MODE == 1 ? WORD_BITS + 1 : WORD_BITS)-1 : 0] get_grid_elements(input int coef);
  int element_cnt, j, max;
  logic [I_WORD-1:0][I_WORD-1:0][$clog2(MULT_SPLITS)-1:0] mul_grid_cnt;
  
  // Loop through all coefs up to the one we want.
  mul_grid_cnt = 0;
  for (int h = 0; h <= coef; h++) begin
    get_grid_elements = 0;
    element_cnt = 0;
    max = h;
    for (int y = 0; y <= h; y++) begin // x
      for (int x = 0; x <= max; x++) begin
        if (SQ_MODE == 0 || y <= x) begin
          if (mul_grid_cnt[x][y] == MULT_SPLITS) continue;
          if (x >= I_WORD || y >= I_WORD) continue;
          if (mul_grid_cnt[x][y] == MULT_SPLITS-1) begin
            get_grid_elements[element_cnt] = mul_out[x][y][COEF_BITS*2-1 : (MULT_SPLITS-1)*WORD_BITS ] << (SQ_MODE == 1 && x > y ? 1 : 0);
          end else begin
            get_grid_elements[element_cnt] = mul_out[x][y][ mul_grid_cnt[x][y]*WORD_BITS +: WORD_BITS ] << (SQ_MODE == 1 && x > y ? 1 : 0);
          end
          mul_grid_cnt[x][y] += 1;
          element_cnt += 1;
        end
      end
      max--;
    end
  end
endfunction

endmodule