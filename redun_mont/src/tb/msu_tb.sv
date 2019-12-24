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
localparam [T_LEN-1:0]    END_CNT = 10;
localparam [DAT_BITS-1:0] INIT_VALUE = 2;

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
  logic [common_pkg::MAX_SIM_BYTS*8-1:0] in_dat, out_dat;
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
  s_axis_if.put_stream(in_dat, (DAT_BITS+2*T_LEN+7)/8);

  // Wait for result
  m_axis_if.get_stream(out_dat, out_len, 0);

  #1us $finish();
end
endmodule