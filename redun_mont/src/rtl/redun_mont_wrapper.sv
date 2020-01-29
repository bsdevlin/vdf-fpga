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

module redun_wrapper
  import redun_mont_pkg::*;
(
  input logic     i_clk,
  input logic     i_reset,
  input logic     i_reset_mont,
  input logic     i_start,
  input redun0_t  i_sq_in,
  output redun0_t o_sq_out,
  output logic    o_valid,
  output logic    o_ready
);

localparam FIFO_RD_LTCY = 2;
redun0_t sq_in, mul_o;
logic valid_o;
logic [NUM_WRDS-1:0] fifo_in_empty, fifo_out_empty;
logic fifo_in_rd, fifo_out_rd;
logic [FIFO_RD_LTCY-1:0] fifo_in_val, fifo_out_val;
logic clk_int;
logic locked, locked_d;
logic [3:0] reset_cdc0;
logic reset_cdc1;

logic [NUM_WRDS-1:0] async_fifo_in_wr_rst_busy, async_fifo_in_rd_rst_busy, async_fifo_out_wr_rst_busy, async_fifo_out_rd_rst_busy;

always_comb begin
  o_valid = fifo_out_val[FIFO_RD_LTCY-1];
  fifo_in_rd = ~(|fifo_in_empty);
  fifo_out_rd = ~(|fifo_out_empty);
end

always_ff @ (posedge i_clk or posedge i_reset) begin
  if (i_reset) begin
    fifo_out_val <= 0;
    reset_cdc0 <= 1;
    o_ready <= 0;
    locked_d <= 0;
  end else begin
    locked_d <= locked;
    fifo_out_val <= {fifo_out_val, fifo_out_rd};
    reset_cdc0 <= {reset_cdc0, (~o_ready || i_reset_mont)};

    // Only allow data flow after everything is locked and reset complete
    o_ready <= locked_d && ~(|async_fifo_in_wr_rst_busy) &&
                           ~(|async_fifo_in_rd_rst_busy) && 
                           ~(|async_fifo_out_wr_rst_busy) &&
                           ~(|async_fifo_out_rd_rst_busy);
  end
end

always_ff @ (posedge clk_int) begin
  fifo_in_val <= {fifo_in_val, fifo_in_rd};
end

// False path this
always_ff @ (posedge clk_int) begin
  reset_cdc1 <= |reset_cdc0;
end


// Clock wizard to generate clock
clk_wiz_0 inst (
  .clk_out1( clk_int ),
  .reset   ( i_reset ),
  .locked  ( locked  ),
  .clk_in1 ( i_clk   )
);

// Async FIFO for clock crossing in and out
genvar gi;
generate
  for (gi = 0; gi < NUM_WRDS; gi++) begin: FIFO_GEN

    fifo_generator_16 async_fifo_in (
      .rst    ( i_reset || ~locked_d ),
      .wr_clk ( i_clk        ),
      .rd_clk ( clk_int      ),
      .din    ( i_sq_in[gi]  ),
      .wr_en  ( i_start      ),
      .rd_en  ( fifo_in_rd   ),
      .dout   ( sq_in[gi]    ),
      .full   (),
      .empty  ( fifo_in_empty[gi] ),
      .wr_rst_busy( async_fifo_in_wr_rst_busy[gi] ),
      .rd_rst_busy( async_fifo_in_rd_rst_busy[gi] )
    );
    fifo_generator_16 async_fifo_out (
      .rst    ( i_reset || ~locked_d ),
      .wr_clk ( clk_int      ),
      .rd_clk ( i_clk        ),
      .din    ( mul_o[gi]    ),
      .wr_en  ( valid_o      ),
      .rd_en  ( fifo_out_rd  ),
      .dout   ( o_sq_out[gi] ),
      .full   (),
      .empty  ( fifo_out_empty[gi] ),
      .wr_rst_busy( async_fifo_out_wr_rst_busy[gi] ),
      .rd_rst_busy( async_fifo_out_rd_rst_busy[gi] )
    );

  end
endgenerate

redun_mont redun_mont (
  .i_clk  ( clk_int                     ),
  .i_rst  ( reset_cdc1                  ),
  .i_sq   ( sq_in                       ),
  .i_val  ( fifo_in_val[FIFO_RD_LTCY-1] ),
  .o_mul  ( mul_o                       ),
  .o_val  ( valid_o                     )
);

endmodule