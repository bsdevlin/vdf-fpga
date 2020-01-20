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

module redun_wrapper
  import redun_mont_pkg::*;
(
  input logic     i_clk,
  input logic     i_reset,
  input logic     i_start,
  input redun0_t  i_sq_in,
  output redun0_t o_sq_out,
  output logic    o_valid,
  output logic    o_locked
);

localparam FIFO_RD_LTCY = 2;
redun0_t sq_in, mul_o;
logic valid_o, locked_o;
logic [NUM_WRDS-1:0] fifo_in_empty, fifo_out_empty;
logic [FIFO_RD_LTCY-1:0] fifo_in_val, fifo_out_val;
logic clk_int;
logic [4:0] locked;
logic [4:0] locked_int;
logic reset_int;

always_comb begin
  o_valid = fifo_out_val[FIFO_RD_LTCY-1];
  o_locked = locked[4];
end

always_ff @ (posedge i_clk) begin
  if (i_reset) begin
    locked <= 0;
    fifo_out_val <= 0;
  end else begin
    locked <= {locked, locked_o};
    fifo_out_val <= {fifo_out_val, ~fifo_out_empty[0]};
  end
end

always_ff @ (posedge clk_int) begin
  if (i_reset) begin
    fifo_in_val <= 0;
    locked_int <= 0;
    reset_int <= 1;
  end else begin
    fifo_in_val <= {fifo_in_val, ~fifo_in_empty[0]};
    locked_int <= {locked_int, locked_o};
    reset_int <= ~locked_int[4];
  end
end

// Clock wizard to generate clock
clk_wiz_0 inst (
  .clk_out1( clk_int  ),
  .reset   ( i_reset  ),
  .locked  ( locked_o ),
  .clk_in1 ( i_clk    )
);

// Async FIFO for clock crossing in and out
genvar gi;
generate
  for (gi = 0; gi < NUM_WRDS; gi++) begin: FIFO_GEN

    fifo_generator_16 async_fifo_in (
      .rst    ( i_reset || reset_int ),
      .wr_clk ( i_clk        ),
      .rd_clk ( clk_int      ),
      .din    ( i_sq_in[gi]  ),
      .wr_en  ( i_start      ),
      .rd_en  ( 1'd1         ),
      .dout   ( sq_in[gi]    ),
      .full   (),
      .empty  ( fifo_in_empty[gi] ),
      .wr_rst_busy(),
      .rd_rst_busy()
    );
    fifo_generator_16 async_fifo_out (
      .rst    ( i_reset || reset_int ),
      .wr_clk ( clk_int      ),
      .rd_clk ( i_clk        ),
      .din    ( mul_o[gi]    ),
      .wr_en  ( valid_o      ),
      .rd_en  ( 1'd1         ),
      .dout   ( o_sq_out[gi] ),
      .full   (),
      .empty  ( fifo_out_empty[gi] ),
      .wr_rst_busy(),
      .rd_rst_busy()
    );

  end
endgenerate

redun_mont redun_mont (
  .i_clk  ( clk_int                     ),
  .i_rst  ( reset_int                   ),
  .i_sq   ( sq_in                       ),
  .i_val  ( fifo_in_val[FIFO_RD_LTCY-1] ),
  .o_mul  ( mul_o                       ),
  .o_val  ( valid_o                     )
);

endmodule