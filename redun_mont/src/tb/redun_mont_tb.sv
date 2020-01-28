/*******************************************************************************
  Copyright 2019 Benjamin Devlin

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*******************************************************************************/
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

task run_test(fe_t a);
  fe_t a_, res, exp;
  int unsigned seed;
  fe1_t chk;
  logic [T-1:0] i;

  rst = 1;
  in_val = 0;
  i = 0;
  seed = 2;
  in = to_redun(0);
  @(posedge clk);

  #(20*CLK_PERIOD) rst = ~rst;

  $display("INFO: Test starting value: 0x%0x", a);
  a_ = to_mont(a);
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
      $display("\nInput: 0x%0x", from_mont(a_));
      $display("Expected, Got:\n0x%0x\n0x%0x", fe_mul_mont(a_, a_), from_redun(out));
      $fatal(1, "ERROR - #%0d wrong", i);
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
    $fatal(1, "ERROR - final result was wrong, expected:\n0x%0x", exp);
  else
    $display("Result was correct");

endtask

initial begin

  // Some values known to cause corner case bugs with overflow
  run_test('h2e302a0630cda173284912c59134767df0bf474909fa9ae734cb40932f26d5bbb58038050fda5b75f5d6bc0edcd13cc1bfff9535da103f84b53f3af55a8e9bc4b575158cd307b6c4fe49eb291cc309e6188c96d80ee48ef291e3ce0bb60d98d17e6a0e8694e0400a7fa03e3840559dd1a1425f0956fc44d79a9f5c35cf8ae0cd);
  run_test('hacb9bb28117812b94e6203838d277d32e2a93e5b5155dcbc8949935c44fc53430c2dee90eecebb4d0aabe6462c57123d698c73137858425496903d4a9cdd17fb9f478d8cfe96a9becba6edaaa4fa7c6976874d50e7b47817decc0569cc2cc5792563e5ea8d66f7f3abb97d0aee1aefa528737a2c4ee780911218de98e08fdcc9);
  run_test('h6903c708926709846f92a5a9f094779b6f4f9491d6f8e8f16b87f0e4e934a4bd12e9de0d80c729f02f01ec64e8eb19a3684754e6e9e523f9bb8d2d4c627df603857fcbc87147f84c03fef266e4f73cd4a6c04d8a681426823058b3da4b4856dc237270d49dd944ab66337e1f76f69edbb8f874f2cf29a9f34f20ce2883e7674b);
  run_test('h64fcea92a9ee80885a03f54fc0c275161a5deffe76fa9d7c370e623045197c326b9ab9a47371e694d486d267d5bd7ac4b519f76328074d8aed64cfac7d09b736c6178234b79c0ca06dfb19f2c18bb487256fae7e763f9d73c2d2a5c258f7c7b912b61317fd6d0536251a26e2282adb9a3ca65174c58bc9ddb4392331c9e7f841);
  run_test('ha9e18f842654910dd14236759d6f12bb494ace3b850ae6b65b74f5595be1eb724cca7f0c487cf9907c94fa815ce71fdfad3bf1cd9e668f1d5403ed486229606d0bfa87e6477f18b29b5eebdd8315b1159fb275da7c64d482db7fb66b446b70ed27f9be48091ded9102b0fa8333691a9fbbe22600010abd3133395aa5672162b0);
  run_test('ha9f90c189cf48824b955a47270abf6e39c33bc62ef1226a8927f703f5d04cc86bf6b9c8c5558be2c292c2cbf370a4c064ec36a89712391a83b9497846f66205e7d0bfc4ace13a8a4f27f6a7b24100fa3f0dec33bf6fcc9bc9d45e881fb6610859ffab32225ce7d84d22ba37717e30febedd1452af285e0a914dfe70e9f2b89cb);
  run_test('hc7bdd8f74509905ed01cbe4be486dee5baa6d954fd6cbe2e2348798672b650d01e0405955489f569a0360f239553f749bcd52604aceba480e0e766b4e9dd3344c626f5e555c3a76cefd6e0a557d34637707b79a30504696d5485087351f35e75f1e9dc5dbeec4d9343e71025396a676d70ef0b4ac28bd79145167981bc7cc66);
  run_test(2);

  $display("INFO: ALL TESTS FINISHED...");
  repeat(2) @(posedge clk);
  $finish();
end

endmodule