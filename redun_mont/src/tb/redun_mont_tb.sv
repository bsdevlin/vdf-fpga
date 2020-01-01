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
`timescale 1ps/1ps

module redun_mont_tb ();
import redun_mont_pkg::*;
import common_pkg::*;

localparam CLK_PERIOD = 8000;  // Reference clock is 125MHz
localparam T = 30;

logic clk, rst;
redun0_t in, out;
logic in_val, out_val;
logic [T_LEN-1:0] out_cnt;

initial begin
  rst = 0;
  repeat(2) #(20*CLK_PERIOD) rst = ~rst;
end

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

redun_mont redun_mont (
  .i_clk  ( clk     ),
  .i_rst  ( rst     ),
  .i_sq   ( in      ),
  .i_val  ( in_val  ),
  .o_mul  ( out     ),
  .o_val  ( out_val )
);

always_ff @ (posedge clk)
  if (rst)
    out_cnt <= 0;
  else
    if (out_val) out_cnt <= out_cnt + 1;

initial begin
  fe_t a, a_, res, exp;
  fe1_t chk;
  logic [T-1:0] i;
  in_val = 0;
  i = 0;
  in = to_redun(0);
  @(posedge clk);
  // Wait for reset pulse and then lock
  while (rst != 1) @(posedge clk);
  while (rst != 0) @(posedge clk);

  repeat (20) @(posedge clk);

  a = random_vector(DAT_BITS/8) % P; // Our starting value
  
  a_ = to_mont(a);
  
  a = from_mont(a_);
  chk = a;

  @(negedge clk);
  in = to_redun(a_);
  in_val = 1;
  @(negedge clk);
  in_val = 0;
  in = to_redun(0);

  while(&i == 0) begin
    while (out_val == 0) @(posedge clk);
    if (i % 100 == 0) $write(".");
    if (i % 10000 == 0) $write("\n");
    assert (from_redun(out) == fe_mul_mont(a_, a_)) else begin
      $display("\nInput: 0x%0x", a_);
      $display("Expected, Got:\n0x%0x\n0x%0x", fe_mul_mont(a_, a_), from_redun(out));
      $display("ERROR - #%0d wrong", i);
      break;
    end
    chk = (chk*chk) % P;
    assert (from_mont(from_redun(out)) == chk) else begin
      $display("\nInput: 0x%0x", a_);
      $display("Mont output was bad - Expected, Got:\n0x%0x\n0x%0x", chk, from_mont(from_redun(out)));
      $display("ERROR - #%0d wrong", i);
      break;
    end
    
    a_ = fe_mul_mont(a_, a_);
    @(posedge clk);
    i++;
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