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

module half_mult_tb ();
import common_pkg::*;

localparam CLK_PERIOD = 100;

localparam NUM_WRDS = 3;
localparam WRD_BITS = 16;
localparam NUM_ELEMENTS_OUT = NUM_WRDS;

typedef logic [NUM_ELEMENTS_OUT*(WRD_BITS+1)-1:0] fe_t;
typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
typedef logic [WRD_BITS:0] redun1_t [NUM_ELEMENTS_OUT];

logic clk, ctl;
redun0_t ina, inb;
redun1_t out;

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

half_multiply #(
  .NUM_ELEMENTS (NUM_WRDS),
  .DSP_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .NUM_ELEMENTS_OUT(NUM_ELEMENTS_OUT)
)
half_multiply_l (
  .clk ( clk ),
  .ctl ( ctl  ),
  .A   ( ina  ),
  .B   ( inb  ),
  .out ( out )
);

function redun0_t to_redun(input fe_t in);
  for (int i = 0; i < NUM_WRDS; i++)
    to_redun[i] = in[i*WRD_BITS +: WRD_BITS];
endfunction

function fe_t from_redun(input redun1_t in);
  from_redun = 0;
  for (int i = 0; i < NUM_ELEMENTS_OUT; i++)
    from_redun += in[i] << (i*WRD_BITS);
endfunction


initial begin

  ina = to_redun(0);
  inb = to_redun(0);

  ina[0] = 16'hff0F;
  ina[1] = 16'hfeef;
  inb[0] = 16'hffFF;
  inb[2] = 16'h0030;

  ctl = 0;
  repeat(10) @(posedge clk);
  $display("Result was %d", from_redun(out));


  ctl = 1;
  repeat(10) @(posedge clk);
  $display("Result was %d", from_redun(out));

  #1us $finish();
end
endmodule