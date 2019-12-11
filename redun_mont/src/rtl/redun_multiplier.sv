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

module redun_multiplier #(
  parameter DAT_BITS,
  parameter WRD_BITS,
  parameter NUM_WRDS = DAT_BITS/WRD_BITS
)(
  input i_clk,
  input i_rst,
  input              [NUM_WRDS-1:0][WRD_BITS:0]   i_mul_a,
  input              [NUM_WRDS-1:0][WRD_BITS:0]   i_mul_b,
  output logic       [2*NUM_WRDS-1:0][WRD_BITS:0] o_mul
);

localparam ACC_BITS = $clog2(2*NUM_WRDS)+WRD_BITS+1;

// Multiplication grid
logic [2*(WRD_BITS+1)-1:0] mul_res[NUM_WRDS*NUM_WRDS];
logic [ACC_BITS-1:0]       grid[NUM_WRDS*2][NUM_WRDS*2];

// Compressor tree results
logic [2*NUM_WRDS-1:0][ACC_BITS-1:0] col_res;
// Accumulated and 1 bit carry-propigated results
logic [2*NUM_WRDS-1:0][WRD_BITS:0] accum_res;

 int x, y;

// Multiplication
always_ff @ (posedge i_clk) begin
  for (x = 0; x < NUM_WRDS; x++)
    for (y = 0; y < NUM_WRDS; y++)
      mul_res[x+NUM_WRDS*y] <= i_mul_a[x]*i_mul_b[y];
end

// Sort into grid
always_comb begin
  for (x=0; x<NUM_WRDS*2; x++)
    for (y=0; y<NUM_WRDS*2; y++)
      grid[x][y] = 0;


  for (x=0; x<NUM_WRDS; x++) begin : grid_row
       for (y=0; y<NUM_WRDS; y++) begin : grid_col
          grid[x+y][(2*x)] =
              {{GRID_PAD_LONG{1'b0}},
               mul_result[(NUM_WRDS*ii)+jj][WORD_LEN-1:0]};
          grid[(ii+jj+1)][((2*ii)+1)] =
              {{GRID_PAD_SHORT{1'b0}},
               mul_result[(NUM_WRDS*ii)+jj][MUL_OUT_BIT_LEN-1:WORD_LEN]};
       end
    end
 end

// Compressor trees to add result
// Adding diagonals through our grid
genvar gx, gy;
generate
  for (gx = 0; gx < 2*NUM_WRDS; gx++) begin: ACCUM_I_GEN  // Start point

    localparam NUM_ROW = gx > NUM_WRDS ? 1+(gx-NUM_WRDS)*2 - (NUM_WRDS-gx) : 1+(gx*2);

    logic [NUM_ROW-1:0][WRD_BITS:0] compress_i;
    logic [ACC_BITS-1:0] compress_c;
    logic [ACC_BITS-1:0] compress_s;
    logic [ACC_BITS-1:0] compress_r;

    int x = 0;
    int y = 0;

    for (gy = 0; gy <= gx; gy++) begin: ACCUM_J_GEN  // End point

      x = x + 1;

      compress_i[gy] = mul_res[][]

    end

    compressor_tree_3_to_2 #(
      .NUM_ELEMENTS(NUM_ROW),
      .BIT_LEN(ACC_BITS)
    )
    ct (
      .terms(compress_i),
      .C(compress_c),
      .S(compress_s)
    );

    always_comb compress_r = compress_c + compress_s;

  end
endgenerate




localparam int NUM_COL = (DAT_BITS+A_DSP_W-1)/A_DSP_W;
localparam int NUM_ROW = (DAT_BITS+B_DSP_W-1)/B_DSP_W;
localparam int NUM_GRID = (2*DAT_BITS+AGRID_W-1)/AGRID_W;
localparam int BIT_LEN = A_DSP_W+B_DSP_W+$clog2(NUM_GRID);
localparam int PIPE = 4;

logic [A_DSP_W*NUM_COL-1:0] dat_a;
logic [B_DSP_W*NUM_ROW-1:0] dat_b;
(* DONT_TOUCH = "yes" *) logic [A_DSP_W+B_DSP_W-1:0] mul_grid [NUM_COL][NUM_ROW];
logic [(A_DSP_W+B_DSP_W+DAT_BITS*2)-1:0] mul_grid_flat [NUM_COL*NUM_ROW];

logic [BIT_LEN-1:0] accum_grid [NUM_GRID];
logic [(DAT_BITS*2)-1:0] mul_res;

logic [PIPE-1:0] val, sop, eop;
logic [PIPE-1:0][CTL_BITS-1:0] ctl;

genvar gx, gy;

// Flow control
always_comb begin
  i_mul.rdy = o_mul.rdy;
  o_mul.val = val[PIPE-1];
  o_mul.sop = sop[PIPE-1];
  o_mul.eop = eop[PIPE-1];
  o_mul.ctl = ctl[PIPE-1];
  o_mul.err = 0;
  o_mul.mod = 0;
end

always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    val <= 0;
    sop <= 0;
    eop <= 0;
    ctl <= 0;
  end else begin
    if (o_mul.rdy) begin
      val <= {val, i_mul.val};
      sop <= {sop, i_mul.sop};
      eop <= {eop, i_mul.eop};
      ctl <= {ctl, i_mul.ctl};
    end
  end
end

// Logic for handling multiple pipelines
always_ff @ (posedge i_clk) begin
  if (o_mul.rdy) begin
    dat_a <= 0;
    dat_b <= 0;
    dat_a <= i_mul.dat[0+:DAT_BITS];
    dat_b <= i_mul.dat[DAT_BITS+:DAT_BITS];
    o_mul.dat <= mul_res;
  end
end


always_ff @ (posedge i_clk) begin
  for (int i = 0; i < NUM_COL; i++)
    for (int j = 0; j < NUM_ROW; j++) begin
      if (o_mul.rdy)
        mul_grid[i][j] <= dat_a[i*A_DSP_W +: A_DSP_W] * dat_b[j*B_DSP_W +: B_DSP_W];
    end
end

// Convert the multiplication grid into a flat grid
always_comb begin
  for (int i = 0; i < NUM_COL; i++)
    for (int j = 0; j < NUM_ROW; j++) begin
      mul_grid_flat[(i*NUM_ROW)+j] = 0;
      mul_grid_flat[(i*NUM_ROW)+j][(i*A_DSP_W)+(j*B_DSP_W) +: A_DSP_W+B_DSP_W] = mul_grid[i][j];
    end
end

// Accumulate the columns
generate
  for (gx = 0; gx < NUM_GRID; gx++) begin: GEN_ACCUM_GRID

    logic [BIT_LEN-1:0] terms [NUM_COL*NUM_ROW];
    logic [BIT_LEN-1:0] c;
    logic [BIT_LEN-1:0] s;

    for (gy = 0; gy < NUM_COL*NUM_ROW; gy++) begin: GEN_ACCUM_VAL

      always_comb begin
        terms[gy] =  mul_grid_flat[gy][gx*AGRID_W +: AGRID_W];
      end
    end

    compressor_tree_3_to_2 #(
      .NUM_ELEMENTS ( NUM_COL*NUM_ROW  ),
      .BIT_LEN      ( BIT_LEN          )
    )
    compressor_tree_3_to_2_i (
      .terms ( terms ),
      .C     ( c     ),
      .S     ( s     )
    );

    // Add the result
    always_ff @ (posedge i_clk) begin
      if (o_mul.rdy)
        accum_grid[gx] <= c + s;
    end

  end
endgenerate

// This stage propagates the carry
always_comb begin
  mul_res = 0;
  for (int i = 0; i < NUM_GRID; i++) begin
    mul_res += accum_grid[i] << i*AGRID_W;
  end
end

endmodule