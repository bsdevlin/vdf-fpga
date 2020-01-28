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

#ifndef _SQUARER_H_
#define _SQUARER_H_

#include <gmp.h>
#include <stdint.h>
#include <Config.h>

class Squarer {
protected:
    uint64_t mod_len;
    mpz_t modulus;
public:
    Squarer(uint64_t _mod_len, mpz_t _modulus) {
        mod_len = _mod_len;

        mpz_init(modulus);
        mpz_set(modulus, _modulus);
    }
    virtual ~Squarer() {
        mpz_clear(modulus);
    }

    virtual uint64_t msu_words_in() = 0;
    virtual uint64_t msu_words_out() = 0;

    // Pack data into a buffer to be transmitted to the SDAccel RTL kernel.
    virtual void pack(mpz_t msu_in, uint64_t t_start, uint64_t t_final,
                      mpz_t sq_in) = 0;

    // Unpack data from a buffer after receiving from the SDAccel RTL kernel.
    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) = 0;
};

class SquarerOzturk : public Squarer {
protected:
    int words_in;
    int words_out;

public:
    SquarerOzturk(uint64_t _mod_len, mpz_t _modulus)
        : Squarer(_mod_len, _modulus) {
        int nonredundant_elements = _mod_len / WORD_LEN;
        int num_elements = nonredundant_elements + REDUNDANT_ELEMENTS;
        // Only the square in/out words are included here
        words_in  = (nonredundant_elements+1)/2;
        words_out = num_elements;
    }

    virtual uint64_t msu_words_in() {
        return(T_LEN/MSU_WORD_LEN*2 + words_in);
    }

    virtual uint64_t msu_words_out() {
        return(T_LEN/MSU_WORD_LEN + words_out);
    }

    virtual void pack(mpz_t msu_in, uint64_t t_start, uint64_t t_final,
                      mpz_t sq_in) {
        mpz_set(msu_in, sq_in);

        // t_final
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_final);

        // t_start
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_start);

    }
    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) {
        *t_final = mpz_get_ui(msu_out);
        bn_shr(msu_out, T_LEN);

        // Reduce the polynomial from redundant form
        reduce_polynomial(sq_out, msu_out, word_len, MSU_WORD_LEN);
    }

    void reduce_polynomial(mpz_t result, mpz_t poly,
                           int word_len, int padded_word_len) {
        uint64_t mask = (1ULL<<padded_word_len)-1;

        // Combine all of the coefficients
        mpz_t tmp;
        mpz_init(tmp);
        mpz_set_ui(result, 0);
        int count = 0;
        while(mpz_cmp_ui(poly, 0)) {
            uint64_t coeff = mpz_get_ui(poly);
            coeff &= mask;
            bn_shr(poly, padded_word_len);

            mpz_set_ui(tmp, coeff);
            bn_shl(tmp, word_len*count);
            mpz_add(result, result, tmp);
            count++;
        }
        mpz_clear(tmp);

        // Reduce mod M
        mpz_mod(result, result, modulus);
    }
};

class MontReducer : public Squarer {
protected:
    int words_in;
    int words_out;
    mpz_t reducer;
    mpz_t mask;
    mpz_t factor;
    mpz_t converted_one;
    mpz_t reciprocal_sq;
    mpz_t reciprocal;
public:
    MontReducer(uint64_t _mod_len, mpz_t _modulus)
        : Squarer(_mod_len, _modulus) {
        // Only the square in/out words are included here
        words_in  = (DAT_BITS/8)/MSU_BYTES_PER_WORD;
        words_out = (DAT_BITS/8)/MSU_BYTES_PER_WORD;
        mont_init();
    }

    virtual uint64_t msu_words_in() {
        return(T_LEN/MSU_WORD_LEN*2 + words_in);
    }

    virtual uint64_t msu_words_out() {
        return(T_LEN/MSU_WORD_LEN + words_out);
    }

    virtual void pack(mpz_t msu_in, uint64_t t_start, uint64_t t_final,
                      mpz_t sq_in) {

        // Convert into Montgomery form
        mpz_set(msu_in, sq_in);
        to_mont(msu_in);

        // t_final
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_final);

        // t_start
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_start);

    }
    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) {
        *t_final = mpz_get_ui(msu_out);
        bn_shr(msu_out, T_LEN);

        bn_shr(msu_out, 16); // We also send the seed so want to shift it out

        // Reduce the polynomial from redundant form
        reduce_polynomial(sq_out, msu_out, word_len, WRD_BITS+1);

        // Convert out of Montgomery form
        from_mont(sq_out);
    }

    void reduce_polynomial(mpz_t result, mpz_t poly,
                           int word_len, int padded_word_len) {
        uint64_t mask = (1ULL<<padded_word_len)-1;

        // Combine all of the coefficients
        mpz_t tmp;
        mpz_init(tmp);
        mpz_set_ui(result, 0);
        int count = 0;
        while(mpz_cmp_ui(poly, 0)) {
            uint64_t coeff = mpz_get_ui(poly);
            coeff &= mask;
            bn_shr(poly, padded_word_len);

            mpz_set_ui(tmp, coeff);
            bn_shl(tmp, word_len*count);
            mpz_add(result, result, tmp);
            count++;
        }
        mpz_clear(tmp);

    }

    // Calculate our montgomery values
    void mont_init() {

      mpz_init(reducer);
      mpz_set_ui(reducer, 1);
      bn_shl(reducer, DAT_BITS);

      mpz_init(mask);
      mpz_sub_ui(mask, reducer, 1);

      mpz_init(reciprocal);
      mpz_mod(reciprocal, reducer, modulus);
      mpz_invert(reciprocal, reciprocal, modulus);

      mpz_init(reciprocal_sq);
      mpz_mul(reciprocal_sq, reducer, reducer);
      mpz_mod(reciprocal_sq, reciprocal_sq, modulus);

      mpz_init(factor);
      mpz_mul(factor, reducer, reciprocal);
      mpz_sub_ui(factor, factor, 1);
      mpz_cdiv_q(factor, factor, modulus);

      mpz_init(converted_one);
      mpz_mod(converted_one, reducer, modulus);

      gmp_printf("Montgomery FACTOR is 0x%Zx\n", factor);
      gmp_printf("Montgomery MASK is 0x%Zx\n", mask);
      gmp_printf("Montgomery CONVERTED_ONE is 0x%Zx\n", converted_one);
      gmp_printf("Montgomery RECIPROCAL is 0x%Zx\n", reciprocal);
      gmp_printf("Montgomery RECIPROCAL_SQ is 0x%Zx\n", reciprocal_sq);

    }

    // Montgomery multiplication
    void mont_mult(mpz_t result, mpz_t op1, mpz_t op2) {
      mpz_t tmp;
      mpz_init(tmp);
      mpz_mul(tmp, op1, op2);

      mpz_and(result, tmp, mask);
      mpz_mul(result, result, factor);
      mpz_and(result, result, mask);

      mpz_mul(result, result, modulus);
      mpz_add(result, result, tmp);
      bn_shr(result, DAT_BITS);
    }

    // Convert into Montgomery form
    void to_mont(mpz_t result) {
      mont_mult(result, result, reciprocal_sq);
    }

    // Convert from Montgomery form
    void from_mont(mpz_t result) {
      mpz_t tmp;
      mpz_init(tmp);
      mpz_set_ui(tmp, 1);
      mont_mult(result, result, tmp);
    }
};


class SquarerOzturkDirect : public SquarerOzturk {
public:
    SquarerOzturkDirect(uint64_t _mod_len, mpz_t _modulus)
        : SquarerOzturk(_mod_len, _modulus) {
    }

    virtual uint64_t msu_words_in() {
        return(words_in);
    }

    virtual uint64_t msu_words_out() {
        return(words_out);
    }

    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) {
        // Reduce the polynomial from redundant form
        reduce_polynomial(sq_out, msu_out, word_len, MSU_WORD_LEN);
    }
};


class SquarerSimple : public Squarer {
public:
    SquarerSimple(uint64_t _mod_len, mpz_t _modulus)
        : Squarer(_mod_len, _modulus) {
    }

    virtual uint64_t msu_words_in() {
        return(T_LEN/MSU_WORD_LEN*2 + mod_len / (BN_BUFFER_SIZE*8));
    }

    virtual uint64_t msu_words_out() {
        return(T_LEN/MSU_WORD_LEN   + mod_len / (BN_BUFFER_SIZE*8));
    }

    virtual void pack(mpz_t msu_in, uint64_t t_start, uint64_t t_final,
                      mpz_t sq_in) {
        mpz_set(msu_in, sq_in);

        // t_final
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_final);

        // t_start
        bn_shl(msu_in, T_LEN);
        mpz_add_ui(msu_in, msu_in, t_start);

    }
    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) {
        *t_final = mpz_get_ui(msu_out);
        bn_shr(msu_out, T_LEN);
        mpz_set(sq_out, msu_out);
    }
};

class SquarerSimpleDirect : public SquarerSimple {
public:
    SquarerSimpleDirect(uint64_t _mod_len, mpz_t _modulus)
        : SquarerSimple(_mod_len, _modulus) {
    }

    virtual uint64_t msu_words_in() {
        return(mod_len / (BN_BUFFER_SIZE*8));
    }

    virtual uint64_t msu_words_out() {
        return(mod_len / (BN_BUFFER_SIZE*8));
    }

    virtual void unpack(mpz_t sq_out, uint64_t *t_final, mpz_t msu_out,
                        int word_len) {
        mpz_set(sq_out, msu_out);
    }
};

#endif
