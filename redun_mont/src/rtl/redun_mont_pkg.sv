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
  // Use calculate_mont_factor() if changing these
  localparam [DAT_BITS-1:0] MONT_FACTOR = 'haf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd;
  // Use calculate_mont_recip_sq() if changing these
  localparam [DAT_BITS-1:0] MONT_RECIP_SQ = 'h58b6b1dcb36adcf186462fbda363868143cd067218a255fed7e327077ebab5f2891924b886e600d645be2fa61b6d3a3400f7e12284c85c2db619a3fb89545a3418ec6f222eda770dee9ba482f7963e9b881df2beeb79422f076244f99c486faf82e6b397c0d75519d4e9987bdc91dff1356678097d38ed9b474abcaf2675c32c;

  // These are needed to make sure we account for overflow during masking or shifting
  localparam int SPECULATIVE_CARRY_WRDS = 2;

  // This is how much slack we allow before equalizing values
  localparam int BOUNDARY_THRESHOLD = 2;//NUM_WRDS;

  // Parameters used by msu interface
  localparam int T_LEN = 64;
  localparam int AXI_LEN = 32;

  // Parameter that can be tuned to generate different build seeds
  localparam [15:0] BUILD_SEED = 16'h3;

  typedef logic [WRD_BITS:0] redun0_t [NUM_WRDS];
  typedef logic [WRD_BITS:0] redun1_t [NUM_WRDS*2];
  typedef logic [WRD_BITS:0] redun2_t [NUM_WRDS+SPECULATIVE_CARRY_WRDS];
  typedef logic [DAT_BITS-1:0] fe_t;
  typedef logic [2*DAT_BITS-1:0] fe1_t;

  function speculative_carry(input redun1_t in);
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

  function fe1_t from_redun(input redun0_t in);
    from_redun = 0;
    for (int i = 0; i < NUM_WRDS; i++)
      from_redun += in[i] << (i*WRD_BITS);
  endfunction

  function fe1_t from_redun1(input redun1_t in);
    from_redun1 = 0;
    for (int i = 0; i < NUM_WRDS*2; i++)
      from_redun1 += in[i] << (i*WRD_BITS);
  endfunction

  // This function is used to correct for carries in the case
  // we detect we might overflow the half way boundary
  parameter BOUNDARY = NUM_WRDS;
  function redun1_t equalize(input redun1_t in);
    fe1_t res;
    res = 0;
    for (int i = 0; i < BOUNDARY; i++)
      res += in[i] << (i*WRD_BITS);
    for (int i = 0; i < NUM_WRDS*2; i++)
      equalize[i] = (i < BOUNDARY) ? res[i*WRD_BITS +: WRD_BITS] : (i == BOUNDARY) ? in[i] + res[BOUNDARY*WRD_BITS +: BOUNDARY] : in[i];
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

  // Functions to calculate Montgomery parameters
  function fe_t fe_sub(fe_t a, b);
    logic [$bits(fe_t):0] a_, b_;
    a_ = a;
    b_ = b;
    fe_sub = b_ > a_ ? a_- b_ + P : a_ - b_;
  endfunction

  // Inversion using extended euclidean algorithm
  function fe_t fe_inv(fe_t a, b = 1);
    fe_t u, v;
    logic [$bits(fe_t):0] x1, x2;

    u = a; v = P;
    x1 = b; x2 = 0;
    while (u != 1 && v != 1) begin
      while (u % 2 == 0) begin
        u = u / 2;
        if (x1 % 2 == 0)
          x1 = x1 / 2;
        else
          x1 = (x1 + P) / 2;
      end
      while (v % 2 == 0) begin
        v = v / 2;
        if (x2 % 2 == 0)
          x2 = x2 / 2;
       else
         x2 = (x2 + P) / 2;
      end
      if (u >= v) begin
        u = u - v;
        x1 = fe_sub(x1, x2);
      end else begin
        v = v - u;
        x2 = fe_sub(x2, x1);
      end
    end
    if (u == 1)
      return x1;
    else
      return x2;
  endfunction

  function fe_t calculate_mont_factor();
    logic [DAT_BITS*2:0] reducer, reciprocal;
    reducer = 1 << DAT_BITS;
    reciprocal = fe_inv(reducer % P);
    calculate_mont_factor = (reducer * reciprocal - 1) / P;
  endfunction

  function fe_t calculate_mont_recip_sq();
    logic [DAT_BITS*2:0] reducer;
    reducer = 1 << DAT_BITS;
    calculate_mont_recip_sq = (reducer * reducer) % P;
  endfunction

endpackage