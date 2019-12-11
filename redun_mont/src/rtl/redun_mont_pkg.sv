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

package redun_mont_pkg;

  /////////////////////////// Parameters ///////////////////////////
  localparam DAT_BITS = 1024+32; // Extra 32 bits so we don't have overflow
  localparam WRD_BITS = 32;
  localparam NUM_WRDS = DAT_BITS/WRD_BITS;

  localparam [DAT_BITS-1:0] P = 'hb0ad4555c1ee34c8cb0577d7105a475171760330d577a0777ddcb955b302ad0803487d78ca267e8e9f5e3f46e35e10ca641a27e622b2d04bb09f3f5e3ad274b1744f34aeaf90fd45129a02a298dbc430f404f9988c862d10b58c91faba2aa2922f079229b0c8f88d86bfe6def7d026294ed9dee2504b5d30466f7b0488e2666b;

  // Parameters used during Montgomery multiplication
  localparam [DAT_BITS-1:0] MONT_MASK = {DAT_BITS{1'd1}};
  localparam int MONT_REDUCE_BITS = DAT_BITS;
  localparam [DAT_BITS-1:0] MONT_FACTOR = 'h135faf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd;
  localparam [DAT_BITS-1:0] MONT_RECIP_SQ = 'h2345bc86977e99b4fa1385f6363d8917091785bcb5532e401640ba1692b6fe2a7a20cc1cf9a442bdbf3aaf7c7eb6d42ad681bdedeb20fe319afbc165b2a5af71a7e3eb301f25886eb962edb34f089e72f4ae246dcab527f22c6fe03dca5d25700b8de55ee203cc59ac0ef2bba574b85200a89174fadc85618faaca751d1ef017; // Required for conversion into Montgomery form
  localparam int SPECULATIVE_CARRY_WRDS = 4;

  typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
  typedef logic [WRD_BITS:0] redun1_t [NUM_WRDS*2];
  typedef logic [DAT_BITS-1:0] fe_t;

  function speculative_carry(input redun1_t in); // Do we need to look at redundant bits?
    speculative_carry = 0;
    for (int i = NUM_WRDS-1-SPECULATIVE_CARRY_WRDS; i < NUM_WRDS; i++)
      if (&in[i][WRD_BITS-1:0]) speculative_carry = 1;
  endfunction

  function redun0_t get_l_wrds(input redun1_t in);
    for (int i = 0; i < NUM_WRDS; i++)
      get_l_wrds[i] = in[i];
  endfunction

  function redun0_t get_h_wrds(input redun1_t in);
    for (int i = 0; i < NUM_WRDS; i++)
      get_h_wrds[i] = in[i+NUM_WRDS];
  endfunction

  function redun0_t to_redun(input fe_t in);
    for (int i = 0; i < NUM_WRDS; i++)
      to_redun[i] = in[i*WRD_BITS +: WRD_BITS];
  endfunction

  function fe_t from_redun(input redun0_t in);
    from_redun = 0;
    for (int i = 0; i < NUM_WRDS; i++)
      from_redun += in[i] << (i*WRD_BITS);
  endfunction

  function check_overflow(input redun0_t in);
    logic [DAT_BITS:0] res;
    res = 0;
    for (int i = 0; i < NUM_WRDS; i++)
      res += in[i] << (i*WRD_BITS);
    check_overflow = res[DAT_BITS];
  endfunction

    // Montgomery multiplication
  function fe_t fe_mul_mont(fe_t a, b);
    logic [$bits(fe_t)*2:0] m_, tmp;
    m_ = a * b;
    tmp = (m_ & MONT_MASK) * MONT_FACTOR;
    tmp = tmp & MONT_MASK;
    tmp = tmp * P;
    tmp = tmp + m_;
    tmp = tmp >> MONT_REDUCE_BITS;
    if (tmp >= P) tmp -= P;
    fe_mul_mont = tmp;
  endfunction

  function fe_t to_mont(fe_t a);
    to_mont = fe_mul_mont(a, MONT_RECIP_SQ);
  endfunction

  function fe_t from_mont(fe_t a);
    from_mont = fe_mul_mont(a, 1);
  endfunction

endpackage