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
localparam [T_LEN-1:0]    END_CNT = 100;
localparam [DAT_BITS-1:0] INIT_VALUE = 'h0851698569993e83a65eb9c589d31d57613b9e0d304af253e72a25fb62d56a81322aa13a270c77f95a51d16e8e209a0277038ce55ddae57fbe0cec83f5be0b04d09c764c8f3c413cfd57c8a5d299c5cc82fd6dfdbd477a87715a0d413f32420fc7b34411325e1217a71096848fde90ec745558c7335696741d41c91186caf806b;
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
  
  //in_dat = 'h169dc883e74b196ec8c19a022500b84d6702a2561f8fb9a5ef91c03321e5749d6f94f7422f9494f3062cad1b7e7cd26bf48c365e9d7b7ab71a6b398dc2b52c1c38f172c6b939f8f1f714f41f14f8ae81f15ed5518d246ab5146d2f1ae87fc0b7e55424c7a859f3bff40ecb87b9f04a0c95b7442fd860f429bf41b0fee3a4f5e100000000000000640000000000000000;
  
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

  $display("INFO: Result in Mont form - 0x%0x", res);
  $display("original in was:\nx0%0x", from_mont(in_dat >> 128));

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