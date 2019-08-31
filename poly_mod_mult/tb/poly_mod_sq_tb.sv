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
`timescale 1ps/1ps

module poly_mod_sq_tb ();

localparam CLK_PERIOD = 100;
localparam WORD_BITS = 16;
localparam REDUN_WORD_BITS = 1;
localparam NUM_WORDS = 8;
localparam I_WORD = NUM_WORDS + 1;
localparam COEF_BITS = WORD_BITS + REDUN_WORD_BITS;
localparam REDUCTION_BITS = 9;
localparam [WORD_BITS*NUM_WORDS-1:0] MODULUS = (1 << 127) - 10;

logic clk, rst;

logic [I_WORD-1:0][COEF_BITS-1:0] i_dat_a;
logic [I_WORD*COEF_BITS-1:0] in_a;
logic [I_WORD-1:0][COEF_BITS-1:0] o_dat;
logic o_val, start;

initial begin
  rst = 0;
  repeat(2) #(20*CLK_PERIOD) rst = ~rst;
end

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

poly_mod_sq_wrapper #(
  .WORD_BITS       ( WORD_BITS       ),
  .NUM_WORDS       ( NUM_WORDS       ),
  .REDUN_WORD_BITS ( REDUN_WORD_BITS ),
  .I_WORD          ( I_WORD          ),
  .COEF_BITS       ( COEF_BITS       ),
  .MODULUS         ( MODULUS         ),
  .REDUCTION_BITS  ( REDUCTION_BITS  )

)
poly_mod_mult_i (
  .i_clk ( clk     ),
  .i_rst ( rst     ),
  .i_val ( start   ),
  .i_dat ( i_dat_a ),
  .o_dat ( o_dat   ),
  .o_val ( o_val   )
);

task test_0();
begin
  logic [1024-1:0] out, out_exp;
  $display("Running test_0...");

  in_a = 2;
  i_dat_a = int_to_poly(in_a);
  for (int i = 0; i < 1000; i++) begin: LOOP_TEST

    out_exp = (in_a**2) % MODULUS;

    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;
    @(negedge clk);

    while(!o_val) @(negedge clk);
    out = poly_to_int(o_dat);

    // We might be off by several modulus - need to add wrapper TODO
    while (out > MODULUS) out -= MODULUS;

    if(out != out_exp) begin
      $display("INFO: Input: %0d (0x%0x), Output: %0d (0x%0x), Expected: %0d (0x%0x)", in_a, in_a, out, out, out_exp, out_exp);
      $fatal(1, "ERROR - Output did not match");
    end else begin
      $display("INFO: Loop %0d (input %0d) OK", i, in_a);
    end

    // Next inputs
    i_dat_a = o_dat;
    in_a = out;
  end

  $display("test_0 PASSED");
end
endtask;

function [I_WORD-1:0][COEF_BITS-1:0] int_to_poly(input [WORD_BITS*NUM_WORDS-1:0] a);
  int_to_poly = 0;
  for (int i = 0; i < NUM_WORDS; i++)
    int_to_poly[i] = (a >> i * WORD_BITS) % (1 << WORD_BITS);
endfunction

function [I_WORD*COEF_BITS-1:0] poly_to_int(input [I_WORD-1:0][COEF_BITS-1:0] a);
  poly_to_int = 0;
  for (int i = 0; i < I_WORD; i++)
    poly_to_int += a[i]*(1<<(i*WORD_BITS));
endfunction

initial begin
  start = 0;
  i_dat_a = 0;

  #(40*CLK_PERIOD);

  test_0();

  #1us $finish();
end
endmodule