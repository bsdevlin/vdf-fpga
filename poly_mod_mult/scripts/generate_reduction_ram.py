#!/usr/bin/python3

#  This needs to be called before simulation / synthesis to make sure the
#  reduction ram files and include file is created.
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


WORD_BITS = 16
NUM_WORDS = 64
MODULUS = 124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331
REDUCTION_BITS = 23

USE_MEM_INIT = 1
USE_MEM_WE = 1
REGISTER_RAM_Q = 1
USE_URAM_PERCENT = 100

GEN_MEM_FILES = 0;

################################
# Shouldn't need to change these
################################
REDUN_WORD_BITS = 1
I_WORD = NUM_WORDS + 1
COEF_BITS = WORD_BITS + REDUN_WORD_BITS

def poly_to_int(poly):
  value = 0
  value_t = 0
  base = 0
  while(poly > 0):
    value_t = poly & ((1 << COEF_BITS) - 1)
    value += (value_t << base)
    base += WORD_BITS
    poly = poly >> COEF_BITS
  return value

# Generate the files for reduction bits
# Make sure you add them to the Vivado project
max_r_bits = (COEF_BITS*(I_WORD*2 - NUM_WORDS + 1))
num_r_slots = (max_r_bits + REDUCTION_BITS - 1) // REDUCTION_BITS
if(GEN_MEM_FILES):
  for i in range(num_r_slots):
    bits = REDUCTION_BITS
    if (bits*(i+1) > max_r_bits):
      bits = max_r_bits - bits*i
    filename = 'reduction_ram_{}.mem'.format(i)
    f = open('../data/' + filename, 'w')
    for k in range (2 ** bits):
      value = poly_to_int(k << (i*REDUCTION_BITS + NUM_WORDS*COEF_BITS))
      value = hex(value % MODULUS)[2:]
      f.write(value.zfill((WORD_BITS*NUM_WORDS + 3)//4))
      f.write('\n')
    f.close()

#Generate the verilog with the memory and memread calls
mem_s = ''
init_s = 'initial begin\n'

if (REGISTER_RAM_Q):
  ram_d_s = 'always_ff @(posedge i_clk) begin\n'
else:
  ram_d_s = 'always_comb begin\n'
  
ram_write = '''
logic [$clog2({})-1:0] addr;
logic [REDUCTION_BITS-1:0] dat_cnt;
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    dat_cnt <= 0;
    addr <= 0;
  end else begin
    if (i_ram_we) begin
      case(addr)
'''.format(num_r_slots)

for i in range(num_r_slots):
  bits = REDUCTION_BITS
  if (bits*(i+1) > max_r_bits):
    bits = max_r_bits - bits*i
      
  if (USE_URAM_PERCENT > 100*i/num_r_slots):
    mem_s += '(* ram_style="ultra" *) '
  mem_s += 'logic [NUM_WORDS*WORD_BITS-1:0] reduction_ram_{} [(1 << {})-1:0];\n'.format(i, bits)
  init_s += '  $readmemh("reduction_ram_{}.mem", reduction_ram_{});\n'.format(i, i)

  if (REGISTER_RAM_Q):
    ram_d_s += '  reduction_ram_q[{}] <= reduction_ram_{}[reduction_ram_a[{}][{}-1:0]];\n'.format(i, i, i, bits)
  else:
    ram_d_s += '  reduction_ram_q[{}] = reduction_ram_{}[reduction_ram_a[{}][{}-1:0]];\n'.format(i, i, i, bits)
  ram_write += '        {}: reduction_ram_{}[dat_cnt] <= i_ram_d;\n'.format(i, i)

init_s += 'end\n\n'
ram_d_s += 'end\n\n'
f = open('../rtl/reduction_ram.sv', 'w')

ram_write = ram_write[:len(ram_write)-1] + '''
      endcase
      dat_cnt <= dat_cnt + 1;
      if (&dat_cnt) addr <= addr + 1;
    end
  end
end\n
'''

f.write(mem_s)
if (USE_MEM_WE):
  f.write(ram_write)
if (USE_MEM_INIT):
  f.write(init_s)
f.write(ram_d_s)
f.close()
