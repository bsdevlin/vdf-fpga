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

module poly_mod_mult_tb ();

localparam CLK_PERIOD = 100;

logic clk, rst;

logic [4:0][8:0] i_dat_a, i_dat_b;
logic [9:0][8:0] o_dat;
logic o_val, start;

initial begin
  rst = 0;
  repeat(2) #(20*CLK_PERIOD) rst = ~rst;
end

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

poly_mod_mult poly_mod_mult_i (
  .i_clk ( clk ),
  .i_rst ( rst ),
  .i_val ( start ),
  .i_dat_a ( i_dat_a ),
  .i_dat_b ( i_dat_b ),
  .o_dat ( o_dat ),
  .o_val ( o_val )
);

task test_0();
begin

  $display("Running test_0...");
  @(posedge clk);


  i_dat_a = 0;
  i_dat_a = int_to_poly(1 << 16 + 1);
  i_dat_b = int_to_poly(33);
  start = 1;
  @(posedge clk);

  start = 0;
  @(posedge clk);

  while(!o_val) @(posedge clk);


  $display("test_0 PASSED");
end
endtask;

function [4:0][8:0] int_to_poly(input [39:0] a);
  int_to_poly = 0;
  for (int i = 0; i < 4; i++)
    int_to_poly[i] = a >> i*8 % (1<<8);
endfunction

function [2*45-1:0] poly_to_int(input [4:0][8:0] a);
  poly_to_int = 0;
  for (int i = 0; i < 5; i++)
    poly_to_int += a[i]* i*(1<<8);
endfunction

initial begin
  start = 0;
  i_dat_a = 0;
  i_dat_b = 0;

  #(40*CLK_PERIOD);

  test_0();

  #1us $finish();
end
endmodule