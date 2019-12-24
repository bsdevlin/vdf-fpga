/*
  Copyright 2019 Supranational LLC

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

#ifndef _CONFIG_H_
#define _CONFIG_H_

#include <gmp.h>

#define T_LEN                 64

#define MSU_BYTES_PER_WORD    4
#define MSU_WORD_LEN          (MSU_BYTES_PER_WORD*8)
#define EXTRA_ELEMENTS        2
#define NUM_SEGMENTS          4

// Constants for Ozturk construction
#define REDUNDANT_ELEMENTS    2
#define WORD_LEN              16

// Used for Mont reducer
#define WRD_BITS            32
#define IN_BITS             1024
#define DAT_BITS            IN_BITS+WRD_BITS
#define NUM_WRDS            DAT_BITS/WRD_BITS
#define TOT_BITS            NUM_WRDS*(WRD_BITS+1)
#define MONT_MASK           (1 << DAT_BITS) - 1
#define MONT_REDUCE_BITS    DAT_BITS
// Values when using 1024+32 bits:
#define MONT_FACTOR         0x135faf5cb1d1180cf031096710f9d7df19c33c4c4fb744c2a4d0fb04a49015272417ea53b2d8a463736bedc12e78b10d414648af2ae714a5cfffbca8bce7775c3e4c0b7dada4446b97fb8838e56d1321f3e61130c64141bb301eb30018c44b123cc3c1bc4671ce9c166d6a6e4516a7d3ad176b9cf85260839f4d817a13527b910fa9e9bd
#define MONT_RECIP_SQ       0x2345bc86977e99b4fa1385f6363d8917091785bcb5532e401640ba1692b6fe2a7a20cc1cf9a442bdbf3aaf7c7eb6d42ad681bdedeb20fe319afbc165b2a5af71a7e3eb301f25886eb962edb34f089e72f4ae246dcab527f22c6fe03dca5d25700b8de55ee203cc59ac0ef2bba574b85200a89174fadc85618faaca751d1ef017


// Use to define size of word on cpp side (1,2,4,8) depending on bit_len
#define BN_BUFFER_SIZE        4  // top.sv BIT_LEN = 17-32

// Use to create offset when using larger words for bit_len
// Such as when bit_len in top.sv is 17b and is 16b here, offset is 16
#define BN_BUFFER_OFFSET      0

void bn_shl(mpz_t bn, int bits);
void bn_shr(mpz_t bn, int bits);
void bn_init_mask(mpz_t mask, int bits);

#endif
