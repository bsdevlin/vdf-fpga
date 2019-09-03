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


WORD_BITS = 17
NUM_WORDS = 57
MODULUS = 124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331
REDUCTION_BITS = 23

USE_MEM_INIT = 0
USE_MEM_WE = 1
REGISTER_RAM_Q = 1
USE_URAM_PERCENT = 100

################################
# Shouldn't need to change these
################################
REDUN_WORD_BITS = 1
I_WORD = NUM_WORDS + 1
COEF_BITS = WORD_BITS + REDUN_WORD_BITS
REDUCTION_STAGES = (COEF_BITS + REDUCTION_BITS - 1) // REDUCTION_BITS;

# Generate the files for reduction bits
# Make sure you add them to the Vivado project
for i in range(I_WORD*2 - NUM_WORDS + 1):
  for j in range(REDUCTION_STAGES):
    filename = 'reduction_ram_{}.{}.mem'.format(i, j)
    f = open('../data/' + filename, 'w')
    for k in range (2 ** REDUCTION_BITS):
      f.write(hex((k << (j*REDUCTION_BITS + (i+NUM_WORDS)*WORD_BITS)) % MODULUS)[2:].zfill((WORD_BITS*NUM_WORDS)//4))
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
logic [$clog2((I_WORD*2 - NUM_WORDS + 1)*REDUCTION_STAGES)-1:0] addr;
logic [REDUCTION_BITS-1:0] dat_cnt;
always_ff @ (posedge i_clk) begin
  if (i_rst) begin
    dat_cnt <= 0;
    addr <= 0;
  end else begin
    if (i_ram_we) begin
      case(addr)
'''

for i in range(I_WORD*2 - NUM_WORDS + 1):
  for j in range(REDUCTION_STAGES):
    if (USE_URAM_PERCENT > 100*(i*REDUCTION_STAGES + j)/(REDUCTION_STAGES*(I_WORD*2 - NUM_WORDS + 1))):
      mem_s += '(* ram_style="ultra" *) '
    mem_s += 'logic [NUM_WORDS*WORD_BITS-1:0] reduction_ram_{}_{} [(1 << REDUCTION_BITS)-1:0];\n'.format(i, j)
    init_s += '  $readmemh("reduction_ram_{}.{}.mem", reduction_ram_{}_{});\n'.format(i, j, i, j)

    if (REGISTER_RAM_Q):
      ram_d_s += '  reduction_ram_q[{}][{}] <= reduction_ram_{}_{}[reduction_ram_a[{}][{}]];\n'.format(i, j, i, j, i, j)
    else:
      ram_d_s += '  reduction_ram_q[{}][{}] = reduction_ram_{}_{}[reduction_ram_a[{}][{}]];\n'.format(i, j, i, j, i, j)
      
    ram_write += '        {}: reduction_ram_{}_{}[dat_cnt] <= i_ram_d;\n'.format(i*REDUCTION_STAGES + j, i, j)

init_s += 'end\n\n'
ram_d_s += 'end\n\n'
f = open('../rtl/reduction_ram.sv', 'w')

ram_write += '''
      endcase
      dat_cnt <= dat_cnt + 1;
      if (&dat_cnt) addr <= addr + 1;
    end
  end
end
'''

f.write(mem_s)
if (USE_MEM_WE):
  f.write(ram_write)
if (USE_MEM_INIT):
  f.write(init_s)
f.write(ram_d_s)
f.close()
