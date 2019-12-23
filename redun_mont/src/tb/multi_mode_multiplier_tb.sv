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

module multi_mode_multiplier_tb ();
import common_pkg::*;

localparam CLK_PERIOD = 100;

localparam NUM_WRDS = 3;
localparam WRD_BITS = 16;
localparam NUM_ELEMENTS_OUT = NUM_WRDS+1;

typedef logic [NUM_WRDS*2*(WRD_BITS+1)-1:0] fe_t;
typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
typedef logic [WRD_BITS:0] redun1_t [NUM_WRDS*2];

logic clk;
logic [1:0] ctl;
redun0_t ina, inb, add_term;
redun1_t out;

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

multi_mode_multiplier #(
  .NUM_ELEMENTS (NUM_WRDS),
  .DSP_BIT_LEN (WRD_BITS+1),
  .WORD_LEN (WRD_BITS),
  .NUM_ELEMENTS_OUT(NUM_ELEMENTS_OUT)
)
multi_mode_multiplier (
  .i_clk   ( clk ),
  .i_ctl   ( ctl ),
  .i_add_term ( add_term ),
  .i_val (0),
  .o_val(),
  .i_dat_a ( ina ),
  .i_dat_b ( inb ),
  .o_dat   ( out )
);

function redun0_t to_redun(input fe_t in);
  for (int i = 0; i < NUM_WRDS; i++)
    to_redun[i] = in[i*WRD_BITS +: WRD_BITS];
endfunction

function fe_t from_redun1(input redun1_t in);
  from_redun1 = 0;
  for (int i = 0; i < NUM_WRDS*2; i++)
    from_redun1 += in[i] << (i*WRD_BITS);
endfunction

function fe_t from_redun0(input redun0_t in);
  from_redun0 = 0;
  for (int i = 0; i < NUM_WRDS; i++)
    from_redun0 += in[i] << (i*WRD_BITS);
endfunction


initial begin

  ina = to_redun(0);
  inb = to_redun(0);
  add_term = to_redun(0);

  ina[0] = 16'h2;
  ina[1] = 16'h1;
  ina[2] = 16'hFFFF;

  inb[0] = 16'h2;
  inb[1] = 16'h1;
  inb[2] = 16'hFFFF;

  ctl = 0;
  $display("in_a 0x%x, in_b 0x%x", from_redun0(ina), from_redun0(inb));
  repeat(10) @(posedge clk);
  $display("Result 0x%x", from_redun1(out));


  ctl = 1;
  repeat(10) @(posedge clk);
  $display("Result 0x%x", from_redun1(out));

  ctl = 2;
  repeat(10) @(posedge clk);
  $display("Result 0x%x\nExpect 0x%x", from_redun1(out), from_redun0(ina)*from_redun0(ina));

  #1us $finish();
end
endmodule