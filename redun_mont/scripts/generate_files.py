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
# This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <https://www.gnu.org/licenses/>.


####################
# Generate the multiplier output to carry-save adder tree mapping
####################

BITS = 1024
MODULUS = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab
A_DSP_W = 26
B_DSP_W = 17
GRID_BIT = 64
RAM_A_W = 10

URAM_PERCENT = 50
USE_INIT = 1


RES_W = A_DSP_W+B_DSP_W
NUM_COL = (BITS+A_DSP_W-1)//A_DSP_W;
NUM_ROW = (BITS+B_DSP_W-1)//B_DSP_W;

A_DIFF = A_DSP_W//GRID_BIT
B_DIFF = B_DSP_W//GRID_BIT


#Generate multiplier that uses redundant form
def gen_multiplier():
  MAX_COEF = ((2*BITS)+GRID_BIT-1)//GRID_BIT
  accum_s = '\n'
  products = list()
  # Make a list of all offsets where products start
  for x in range(NUM_COL):
    for y in range(NUM_ROW):
      products.append((x, y, x*A_DSP_W+y*B_DSP_W))


  # Now match these to coef
  coef = list()
  max_bits_l = list()
  for i in range(MAX_COEF):
    size = list()
    # First do a pass just to check bit sizes  - also need to account for offset
    for j in products:
      start = max(j[2], i*GRID_BIT)
      end = min(j[2]+RES_W, (i+1)*GRID_BIT)
      if (end > start):
        size.append(end-i*GRID_BIT)#start)
    # Max bits 1 + clog2() of the max size in our list
    #max_bits = max(size) + math.ceil(math.log2(size.count(max(size))))
    max_bits = max(size) + math.ceil(math.log2(len(size)))
    max_bits_l.append(max_bits)

    coef_l = list()
    for j in products:
      # Check if we are in range
      offset = (j[0]*A_DSP_W)+(j[1]*B_DSP_W)
      start = max(j[2], i*GRID_BIT)
      end = min(j[2]+RES_W, (i+1)*GRID_BIT)
      if (end > start):
        bitwidth = end-start
        start_padding = max(start - i*GRID_BIT, 0)
        end_padding = max(start+max_bits-end-start_padding, 0)
        coef_l.append('{{{{{}{{1\'d0}}}},mul_grid[{}][{}][{}+:{}],{{{}{{1\'d0}}}}}}'.format(end_padding, j[0], j[1], start-offset, bitwidth, start_padding))



    coef.append(coef_l)

  # Create compressor trees and output
  for idx, i in enumerate(coef):
    if (len(i) == 1):
      accum_s +='''
// Coef {}
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[{}] <= {};
'''.format(idx, idx, i[0])
    elif (len(i) == 2):
      accum_s +='''
// Coef {}
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[{}] <= {};
'''.format(idx, idx, ' + '.join(i))
    else:
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
always_ff @ (posedge i_clk) if (o_mul.rdy) accum_grid_o[{}] <= accum_o_c_{} + accum_o_s_{};
'''.format(idx, max_bits_l[idx]-1, idx, len(i), max_bits_l[idx]-1, idx, idx, len(i), max_bits_l[idx], idx, idx, idx, idx, idx, ','.join(i), idx, idx, idx)



f = open('../src/rtl/multiplier_generated.sv', 'w')
f.write(get_accum_gen())
f.close()

