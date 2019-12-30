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
// This is the max size we can expect on the output

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


initial begin
  fe_t a, a_, res, exp;
  logic [T-1:0] i;
  in_val = 0;
  i = 0;
  in = to_redun(0);
  @(posedge clk);
  // Wait for reset pulse and then lock
  while (rst != 1) @(posedge clk);
  while (rst != 0) @(posedge clk);

  repeat (20) @(posedge clk);

  a = 2; // Our starting value
  a_ = to_mont(a);

  //a_ = 'ha434820f4ac1a2d2182928233b96c22874e05d476afbbaff4d5242a58bc4d6f1dc9709c344ad39d3cf27c15d6b778b2f77df59890ec092b953ccbaade4c57ecccca6a6ee77cb82114d8f042461356f33786c7a48aa8bf577a95a1dc025ddff50888f2a984f1019c7348b64cf93a985a4e5cb28a0e3f369f968d6362e0db575e8;
  //a_='h8a0824bcfdf4ca166cbe8217e2ba866e78769358f148a26fffbdf7e335d5d419810c0c98838729f91fb88b991d221f5d3ebcc029f4ba10a42df34b3477a4bde91535b0290f7db8839f75718aa330f5b5d720fab8a17ac2c3014fe6c3dd5e35224371405328cab7c2c06630f4253d5b5b3cc49a54854536ac0c36c4d35f976c3e;
  //a_= 'h7c46d717430049b5e2471b405ccc6ad2f65a6fa44456a874bec5a3f0ab9a383cd30537498d33ab4a6260d9c63a8367bfaf77158e709b46114789ae0b97218c3815047cdee375c3b753cc9057577ac4a40515d51749dbca79c68c96698775820356bbf1f9e6a0ba365abf82187573f7e955c42dd33c62d441da1bd51bf4ee230e;
  //a_= 'h5af3dc0aea7d81d4f264e7db04ea9328912ba1f9a846752b19e103ce31531454b6682369ae9b92bee8df4974c5b1105730a5d3f038d8a3e4231986903e39d11497f20b40ce831d6a25ee59405d8ec14147784e81a3139655cfea1ff8b221f878d1995f6519142f7f982d78d87ab2c832885d5cb37547076fbfda0f02f5c11ea4;
  //a_ = 'h8a0824bcfdf4ca166cbe8217e2ba866e78769358f148a26fffbdf7e335d5d419810c0c98838729f91fb88b991d221f5d3ebcc029f4ba10a42df34b3477a4bde91535b0290f7db8839f75718aa330f5b5d720fab8a17ac2c3014fe6c3dd5e35224371405328cab7c2c06630f4253d5b5b3cc49a54854536ac0c36c4d35f976c3e;
  a = from_mont(a_);

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