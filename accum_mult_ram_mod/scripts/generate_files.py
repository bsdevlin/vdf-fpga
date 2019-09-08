#!/usr/bin/python3

import math

#  This needs to be called before simulation / synthesis to make sure the
#  reduction ram files and include files are created.
#
#  Copyright (C) 2019  Benjamin Devlin
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https:#www.gnu.org/licenses/>.


####################
# Generate the multiplier output to carry-save adder tree mapping
####################

GEN_ACCUM = 1
BITS = 381
A_DSP_W = 27
B_DSP_W = 18
GRID_BIT = 9 # Should be multiple of A_BIT_W and B_BIT_W

RES_W = A_DSP_W+B_DSP_W
NUM_COL = (BITS+A_DSP_W-1)//A_DSP_W;
NUM_ROW = (BITS+B_DSP_W-1)//B_DSP_W;

A_DIFF = A_DSP_W//GRID_BIT
B_DIFF = B_DSP_W//GRID_BIT


def get_accum_gen():
  MAX_COEF = ((2*BITS)+GRID_BIT-1)//GRID_BIT
  accum_s = ''
  products = list()
  # Make a list of all offsets where products start
  for x in range(NUM_COL):
    for y in range(NUM_ROW):
      products.append((x, y, x*A_DSP_W+y*B_DSP_W))

  # Now match these to coef
  coef = list()
  for i in range(MAX_COEF):
    coef_l = list()
    for j in products:
      # Check if we are in range
      if i*GRID_BIT >= j[2] and i*GRID_BIT < (j[2]+RES_W):
        offset = (j[0]*A_DSP_W)+(j[1]*B_DSP_W)
        coef_l.append('mul_grid[{}][{}][{}:{}]'.format(j[0], j[1], min((i+1)*GRID_BIT-1, j[2]+RES_W)-offset, i*GRID_BIT-offset))
    coef.append(coef_l)

  # Create compressor trees and output
  for idx, i in enumerate(coef):
    MAX_BITS = GRID_BIT + math.ceil(math.log2(len(i)))
    accum_s +='''
// Coef {}
logic [{}:0] accum_i_{} [{}];
logic [{}:0] accum_o_c_{}, accum_o_s_{};
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS({}),
  .BIT_LEN({})
)
ct_{} (
  .terms(accum_i_{}),
  .C(accum_o_c_{}),
  .S(accum_o_s_{})
);
always_comb accum_i_{} = {{{}}};
always_ff @ (posedge i_clk) accum_grid_o[{}] <= accum_o_c_{} + accum_o_s_{};
'''.format(idx, MAX_BITS-1, idx, len(i), MAX_BITS-1, idx, idx, len(i), MAX_BITS, idx, idx, idx, idx, idx, ','.join(i), idx, idx, idx)

  return accum_s

if (GEN_ACCUM):
  f = open('../src/rtl/accum_gen.sv', 'w')
  f.write(get_accum_gen())
  f.close()

