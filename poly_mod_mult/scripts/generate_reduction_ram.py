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


WORD_BITS = 35
NUM_WORDS = 30
MODULUS = 124066695684124741398798927404814432744698427125735684128131855064976895337309138910015071214657674309443149407457493434579063840841220334555160125016331040933690674569571217337630239191517205721310197608387239846364360850220896772964978569683229449266819903414117058030106528073928633017118689826625594484331
REDUCTION_BITS = 15

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
always_comb_s = 'always_comb begin\n'
for i in range(I_WORD*2 - NUM_WORDS + 1):
  for j in range(REDUCTION_STAGES):
    mem_s += 'reduction_ram_t reduction_ram_{}_{};\n'.format(i, j)
    init_s += '  $readmemh("reduction_ram_{}.{}.mem", reduction_ram_{}_{}.ram);\n'.format(i, j, i, j)
    always_comb_s += ' reduction_ram_d[{}][{}] = reduction_ram_{}_{}.ram[reduction_ram_a[{}][{}]];\n'.format(i, j, i, j, i, j)

init_s += 'end\n\n'
always_comb_s += 'end\n\n'
f = open('../rtl/reduction_ram.sv', 'w')
f.write(mem_s)
f.write(init_s)
f.write(always_comb_s)
f.close()
