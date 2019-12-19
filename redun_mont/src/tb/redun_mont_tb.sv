/*
  Copyright (C) 2019  Benjamin Devlin and Zcash Foundation

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

module redun_mont_tb ();
import redun_mont_pkg::*;
import common_pkg::*;

localparam CLK_PERIOD = 100;
localparam NUM_ITERATIONS = 100000;

logic clk, rst;
redun0_t in, out;
logic in_val, out_val, overflow;
// This is the max size we can expect on the output

initial begin
  rst = 0;
  repeat(2) #(10*CLK_PERIOD) rst = ~rst;
end

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end


redun_mont redun_mont (
  .i_clk ( clk   ),
  .i_rst ( rst   ),
  .i_sq  ( in    ),
  .i_val ( in_val ),
  .o_mul ( out ),
  .o_val ( out_val ),
  .o_overflow(overflow)
);


initial begin
  fe_t a, a_, res, exp;
  int i;
  in_val = 0;
  in = to_redun(0);
  
  repeat (20) @(posedge clk);

  a = 2; // Our starting value
  a_ = to_mont(a);

  a_ = 'ha434820f4ac1a2d2182928233b96c22874e05d476afbbaff4d5242a58bc4d6f1dc9709c344ad39d3cf27c15d6b778b2f77df59890ec092b953ccbaade4c57ecccca6a6ee77cb82114d8f042461356f33786c7a48aa8bf577a95a1dc025ddff50888f2a984f1019c7348b64cf93a985a4e5cb28a0e3f369f968d6362e0db575e8;
  a = from_mont(a_);
  
  in = to_redun(a_);

  @(negedge clk);
  in_val = 1;
  @(negedge clk);
  in_val = 0;
  in = to_redun(0);

  for (i = 0; i < NUM_ITERATIONS; i++) begin
    while (out_val == 0) @(posedge clk);
    $display("#%0d Expected, Got:\n0x%0x\n0x%0x", i, fe_mul_mont(a_, a_), from_redun(out));
    assert (from_redun(out) == fe_mul_mont(a_, a_)) else begin
      $display("ERROR -  wrong");
      break;
    end
    a_ = fe_mul_mont(a_, a_);
    @(posedge clk);
  end

  res = from_mont(from_redun(out));
  exp = mod_sq(a,  i);

  $display("Final result was:");
  $display("0x%0x", res);

  if (res != exp)
    $fatal("ERROR - final result was wrong, expected:\n0x%0x", exp);
  else
    $display("Result was correct");

  repeat(2) @(posedge clk);
  $finish();
end
endmodule