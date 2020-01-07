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

package redun_mont_pkg;

  /////////////////////////// Parameters ///////////////////////////
  localparam WRD_BITS = 16;
  localparam IN_BITS = 1024;
  localparam DAT_BITS = IN_BITS+WRD_BITS; // Extra word so we don't have final check against modulus
  localparam NUM_WRDS = DAT_BITS/WRD_BITS;
  localparam TOT_BITS = NUM_WRDS*(WRD_BITS+1);

  localparam [DAT_BITS-1:0] P = 'hb0ad4555c1ee34c8cb0577d7105a475171760330d577a0777ddcb955b302ad0803487d78ca267e8e9f5e3f46e35e10ca641a27e622b2d04bb09f3f5e3ad274b1744f34aeaf90fd45129a02a298dbc430f404f9988c862d10b58c91faba2aa2922f079229b0c8f88d86bfe6def7d026294ed9dee2504b5d30466f7b0488e2666b;

  // Parameters used during Montgomery multiplication
  localparam [DAT_BITS-1:0] MONT_MASK = {DAT_BITS{1'd1}};
  localparam int MONT_REDUCE_BITS = DAT_BITS;

  // Montgomery values for different WRD_BITS
  localparam [DAT_BITS-1:0] MONT_FACTOR = WRD_BITS == 16 ?
    'haf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd : WRD_BITS == 32 ?
    'h135faf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd : WRD_BITS == 64 ?
    'h81e7d8ca135faf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd : 0;

  localparam [DAT_BITS-1:0] MONT_RECIP_SQ = WRD_BITS == 16 ?
    'h58b6b1dcb36adcf186462fbda363868143cd067218a255fed7e327077ebab5f2891924b886e600d645be2fa61b6d3a3400f7e12284c85c2db619a3fb89545a3418ec6f222eda770dee9ba482f7963e9b881df2beeb79422f076244f99c486faf82e6b397c0d75519d4e9987bdc91dff1356678097d38ed9b474abcaf2675c32c : WRD_BITS == 32 ?
    'h2345bc86977e99b4fa1385f6363d8917091785bcb5532e401640ba1692b6fe2a7a20cc1cf9a442bdbf3aaf7c7eb6d42ad681bdedeb20fe319afbc165b2a5af71a7e3eb301f25886eb962edb34f089e72f4ae246dcab527f22c6fe03dca5d25700b8de55ee203cc59ac0ef2bba574b85200a89174fadc85618faaca751d1ef017 : WRD_BITS == 64 ?
    'h0c9e2b0881288cec72faec20cc9714075b68b276451ccb29b795aa157daaf2b51d7f38e926284baa557126eb80e0df90b92564d0c3a3d65fada784f34bcb273964bfde67ec9447b70f03e69c7977b3facddf04015650a1bfdeb7e5db55df6d0078d62b57de2f279bb1bc86370b0a385b39601a6055db8fdb9c3b89a3f27b9e68: 0;

  // These are needed to make sure we account for overflow during masking or shifting
  localparam int SPECULATIVE_CARRY_WRDS = 2;

  // Parameters used by msu interface
  localparam int T_LEN = 64;
  localparam int AXI_LEN = 32;

  typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
  typedef logic [WRD_BITS:0] redun1_t [NUM_WRDS*2];
  typedef logic [WRD_BITS:0] redun2_t [NUM_WRDS+SPECULATIVE_CARRY_WRDS];
  typedef logic [DAT_BITS-1:0] fe_t;
  typedef logic [2*DAT_BITS-1:0] fe1_t;

  function speculative_carry(input redun1_t in); // Do we need to look at redundant bits?
    speculative_carry = 0;
    for (int i = NUM_WRDS-1-SPECULATIVE_CARRY_WRDS; i < NUM_WRDS; i++)
      if (&in[i][WRD_BITS-1:0]) speculative_carry = 1;
  endfunction

  function redun0_t to_redun(input fe_t in);
    for (int i = 0; i < NUM_WRDS; i++)
      to_redun[i] = in[i*WRD_BITS +: WRD_BITS];
  endfunction

  function redun1_t to_redun1(input fe1_t in);
    for (int i = 0; i < NUM_WRDS*2; i++)
      to_redun1[i] = in[i*WRD_BITS +: WRD_BITS];
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
    if (tmp >= P) $display("WARN: mismatch in inputs.\nIn : 0x%0x\nIn : 0x%0x\nOut: 0x%0x", a, b, tmp); // This is generally OK as long as converted value still tracks, we check this in testbench
    fe_mul_mont = tmp;
  endfunction

  function fe_t to_mont(fe_t a);
    to_mont = fe_mul_mont(a, MONT_RECIP_SQ);
  endfunction

  function fe_t from_mont(fe_t a);
    from_mont = fe_mul_mont(a, 1);
  endfunction

  function fe_t mod_sq(fe_t a, t);
    logic [DAT_BITS*2-1:0] tmp;
    tmp = a;
    for (fe_t i = 0; i < t; i++) begin
      tmp = (tmp * tmp) % P;
    end
    mod_sq = tmp[DAT_BITS-1:0];
  endfunction

endpackage