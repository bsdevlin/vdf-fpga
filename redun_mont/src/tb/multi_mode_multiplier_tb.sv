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

module multi_mode_multiplier_tb ();
import common_pkg::*;
import redun_mont_pkg::*;

localparam CLK_PERIOD = 100;


localparam NUM_ELEMENTS_OUT = NUM_WRDS*2;

typedef logic [NUM_WRDS*2*(WRD_BITS+1)-1:0] fe_t;
typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
typedef logic [WRD_BITS:0] redun1_t [NUM_WRDS*2];

logic clk;
logic [2:0] ctl;
redun0_t ina, inb, add_term;
redun1_t out;

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

multi_mode_multiplier #(
  .NUM_ELEMENTS    ( NUM_WRDS                        ),
  .DSP_BIT_LEN     ( WRD_BITS+1                      ),
  .WORD_LEN        ( WRD_BITS                        ),
  .NUM_ELEMENTS_OUT( NUM_ELEMENTS_OUT                )
)
multi_mode_multiplier (
  .i_clk   ( clk ),
  .i_ctl   ( ctl ),
  .i_add_term ( add_term ),
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
  fe1_t a_, b_, exp;

  a_ = 'h1ebfb4da2ba2fec8ff0ecf6cc26c30912fdfbe874e4e01ce9f0a8fd0c1fc65b3dbba01d0fc89934c014a9894fdcc180196239570c793de3835de00010e296e01f4794238becd56694cd1aa388d443cb10a8c79127f281a110329c4e5212be39ec1fa026db21b682c62b0c0cdeb36cdc203795323ca1f7992278ebfdb678ddabfb2cd;
  b_ = 'hb0ad4555c1ee34c8cb0577d7105a475171760330d577a0777ddcb955b302ad0803487d78ca267e8e9f5e3f46e35e10ca641a27e622b2d04bb09f3f5e3ad274b1744f34aeaf90fd45129a02a298dbc430f404f9988c862d10b58c91faba2aa2922f079229b0c8f88d86bfe6def7d026294ed9dee2504b5d30466f7b0488e2666b;
  add_term = to_redun(0);

  ina = to_redun(a_);
  inb = to_redun(b_);

  exp = a_*b_;

  ctl = 3'b010;
  $display("in_a 0x%x, in_b 0x%x", from_redun0(ina), from_redun0(inb));
  repeat(10) @(posedge clk);
  $display("R 0x%560x", from_redun1(out));
  $display("E 0x%560x", exp);
  if (exp != from_redun1(out))
    $fatal(1, "ERROR: Wrong result");
  else
    $display("INFO: Correct result");

  #1us $finish();
end
endmodule