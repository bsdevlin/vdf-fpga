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

module msu_tb ();

import common_pkg::*;
import redun_mont_pkg::*;

localparam int            CLK_PERIOD = 8000;  // Reference clock is 125MHz
localparam [T_LEN-1:0]    START_CNT = 0;
localparam [T_LEN-1:0]    END_CNT = 1;
localparam [DAT_BITS-1:0] INIT_VALUE = 'h5088a4237f8687e0c9f061cbd5605fbcebafdd0af208da101a0774e816608e6cd1c38b13d0a71f4e6a47f919dafdc89ae6a484d039efaaaabaf74489e025f30a23b3a18f84e28656733525e1fa0b47b6bbf3f25f842cc9fb130083df163b60db38645384a52d18498c68673d66784d6a94e4149e7e286eeaa148fae615d2f94e;

localparam AXI_LEN = 32;

logic clk, rst;


if_axi_stream #(.DAT_BYTS(AXI_LEN/8), .CTL_BITS(1)) s_axis_if (clk); // Input stream
if_axi_stream #(.DAT_BYTS(AXI_LEN/8), .CTL_BITS(1)) m_axis_if (clk); // Output stream

logic [AXI_LEN/8-1:0] m_axis_if_keep;

always_comb begin
  m_axis_if.set_mod_from_keep( m_axis_if_keep );
end

// Need to generate .sop
always_ff @ (posedge clk) begin
  if (rst)
    m_axis_if.sop <= 1;
  else
    if (m_axis_if.val && m_axis_if.rdy)
      if (m_axis_if.eop)
        m_axis_if.sop <= 1;
      else
        m_axis_if.sop <= 0;
end

initial begin
  rst = 0;
  repeat(2) #(20*CLK_PERIOD) rst = ~rst;
end

initial begin
  clk = 0;
  forever #CLK_PERIOD clk = ~clk;
end

logic start_xfer, ap_start, ap_done;

msu #(
  .AXI_LEN( AXI_LEN ),
  .T_LEN  ( T_LEN   )
)
msu (
  .clk   ( clk ),
  .reset ( rst ),
  .s_axis_tvalid ( s_axis_if.val ),
  .s_axis_tready ( s_axis_if.rdy ),
  .s_axis_tdata  ( s_axis_if.dat ),
  .s_axis_tkeep  ( s_axis_if.get_keep_from_mod() ),
  .s_axis_tlast  ( s_axis_if.eop ),
  .s_axis_xfer_size_in_bytes(),
  .m_axis_tvalid ( m_axis_if.val  ),
  .m_axis_tready ( m_axis_if.rdy  ),
  .m_axis_tdata  ( m_axis_if.dat  ),
  .m_axis_tkeep  ( m_axis_if_keep ),
  .m_axis_tlast  ( m_axis_if.eop  ),
  .m_axis_xfer_size_in_bytes(),
  .ap_start   ( ap_start   ),
  .ap_done    ( ap_done    ),
  .start_xfer ( start_xfer )
);

initial begin
  logic [common_pkg::MAX_SIM_BYTS*8-1:0] in_dat, out_dat, res, exp;
  integer signed out_len;
  s_axis_if.reset_source();
  m_axis_if.rdy = 0;
  ap_start = 0;
  in_dat = {to_mont(INIT_VALUE), END_CNT, START_CNT};
  @(posedge clk);
  // Wait for reset to toggle
  while (rst != 1) @(posedge clk);
  while (rst != 0) @(posedge clk);

  @(posedge clk);
  ap_start = 1;

  @(posedge clk);
  ap_start = 0;

  // Send in initial value
  s_axis_if.put_stream(in_dat, ((DAT_BITS+2*T_LEN+AXI_LEN-1)/AXI_LEN)*(AXI_LEN/8));

  // Wait for result
  m_axis_if.get_stream(out_dat, out_len, 0);
  out_dat = out_dat >> T_LEN;
  
  res = 0;
  for (int i = 0; i < NUM_WRDS; i++)
    res += (out_dat[i*(WRD_BITS+1) +: WRD_BITS+1] << (i*WRD_BITS));
  
  res = from_mont(res);
  exp = mod_sq(INIT_VALUE,  (END_CNT-START_CNT));

  if (exp == res) begin
    $display("INFO: Result matched - 0x%0x", res);
  end else begin
    $fatal(1, "ERROR: Expected:\n0x%0x\nResult:\n0x%0x", exp, res);
  end

  #1us $finish();
end
endmodule