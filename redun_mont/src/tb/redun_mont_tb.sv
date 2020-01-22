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

localparam CLK_PERIOD = 8000;  // Reference clock is 125MHz
localparam T = 7;

logic clk, rst;
redun0_t in, out, out_;
logic in_val, out_val;
logic [T_LEN-1:0] out_cnt;

initial begin
  rst = 1;
  #(20*CLK_PERIOD) rst = ~rst;
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
  int unsigned seed;
  fe1_t chk;
  logic [T-1:0] i;
  in_val = 0;
  i = 0;
  seed = 2;
  in = to_redun(0);

  @(posedge clk);
  // Wait for reset pulse and then lock
  while (rst != 1) @(posedge clk);
  while (rst != 0) @(posedge clk);

  repeat (20) @(posedge clk);
  $srandom(seed);
  a = 0;
  for (int i = 0; i < DAT_BITS/32; i++)
    a[i*32 +: 32] = $urandom();

  a = a % P; // Our starting value
  $display("Seed, 0x%0x, Starting value: 0x%0x", seed, a);
  
  a_ = to_mont(a);

  // Some values known to check corner case bugs
  //a_ = 'h169dc883e74b196ec8c19a022500b84d6702a2561f8fb9a5ef91c03321e5749d6f94f7422f9494f3062cad1b7e7cd26bf48c365e9d7b7ab71a6b398dc2b52c1c38f172c6b939f8f1f714f41f14f8ae81f15ed5518d246ab5146d2f1ae87fc0b7e55424c7a859f3bff40ecb87b9f04a0c95b7442fd860f429bf41b0fee3a4f5e1;
  a_ = 'h4255b52b6d3d048cb3425e412445fac98f647499af4e8f921b4c9aaab9273cee859849311c1fad94b65bd1b999d5b0c7b2a7c81506e3950a24eb3bb8037abdcce6b97c4943c8d93f2e433ec85fd426cbc91c767285bf9c0d9697d93330c9ea970f5705bb91a401339d2c488401368181bdf20a54483a9070ad86306b44687cd0;
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
    out_ = out;
    a_ = fe_mul_mont(a_, a_);
    @(posedge clk);
    i++;
  end

  res = from_mont(from_redun(out_));
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