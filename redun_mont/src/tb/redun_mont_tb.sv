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

logic clk, rst;
redun0_t in, out;
logic in_val, out_val, overflow;
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
  .i_clk ( clk ),
  .i_rst ( rst ),
  .i_mul_a ( in ),
  .i_mul_b ( in ),
  .i_val ( in_val ),
  .o_mul ( out ),
  .o_val ( out_val ),
  .o_overflow(overflow)
);


initial begin
  int i = 0;
  fe_t a, a_;
  in_val = 0;
  in = to_redun(0);
  #(40*CLK_PERIOD);
  a = 2;
  a_ = to_mont(a);
  in = to_redun(a_);


  @(posedge clk);
  in_val = 1;
  @(posedge clk);
  in_val = 0;
  in = to_redun(0);

  for (int i = 0; i < 1000; i++) begin
    while (out_val == 0) @(posedge clk);

    $display("#%0d Expected, Got:\n0x%0x\n0x%0x", i, fe_mul_mont(a_, a_), from_redun(out));
    assert (from_redun(out) == fe_mul_mont(a_, a_)) else $fatal("ERROR -  wrong");
    a_ = fe_mul_mont(a_, a_);
    @(posedge clk);
  end

  #1us $finish();
end
endmodule