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
localparam WORD_BITS = 32;
localparam REDUN_WORD_BITS = 1;
localparam NUM_WORDS = 32;
localparam I_WORD = NUM_WORDS + 1;
localparam COEF_BITS = WORD_BITS + REDUN_WORD_BITS;
localparam REDUCTION_BITS = 8;
localparam [WORD_BITS*NUM_WORDS-1:0] MODULUS = 1024'd124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331;

logic clk, rst;

logic [I_WORD-1:0][COEF_BITS-1:0] i_dat_a;
logic [I_WORD*COEF_BITS-1:0] in_a;
logic [2*I_WORD*COEF_BITS-1:0] in_a2;
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
  .REDUCTION_BITS  ( REDUCTION_BITS  ),
  .SIMULATION      ( 1               )
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
  logic [2*I_WORD*COEF_BITS-1:0] mod, out, out_exp;
  int sub_count;
  $display("Running test_0...");
  mod = MODULUS;
  in_a = 2;
  i_dat_a = int_to_poly(in_a);
  for (int i = 0; i < 100000; i++) begin: LOOP_TEST

    in_a2 = in_a**2;
    out_exp = in_a2 % mod;

    @(negedge clk);
    start = 1;
    @(negedge clk);
    start = 0;
    @(negedge clk);

    while(!o_val) @(negedge clk);
    out = poly_to_int(o_dat);

    // We might be off by several modulus - need to add wrapper TODO
    sub_count = 0;
    while (out >= mod) begin
      out -= mod;
      sub_count++;
    end

    if(out != out_exp) begin
      $display("INFO: Input:   0x%0x", in_a);
      $display("INFO: Input^2: 0x%0x", in_a2);
      $display("INFO: Output:  0x%0x", out);
      $display("INFO: Expected:0x%0x", out_exp);
      $fatal(1, "ERROR - Output did not match (sub_count %0d)", sub_count);
    end else begin
      $display("INFO: Loop %0d (output 0x%0x) OK (sub_count %0d)", i, out, sub_count);
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