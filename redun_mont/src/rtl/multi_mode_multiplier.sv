/*******************************************************************************
  Copyright 2019 Supranational LLC
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

/*

 This does 3 modes of multiplication:
 - i_ctl = 0 for multiply to get lower products
 - i_ctl = 1 for multiply to get higher products
 - i_ctl = 2 for square

 - i_add_term allows for an addition term to be added to the output products

 Adder type can be defined:
 - 0 for default 3:2 compressors
 - 1 for 2:1 compressor from Eric Pearson
 - 2 for 6:3 compressor from Kurt Baty
 */
module multi_mode_multiplier #(
  parameter int NUM_ELEMENTS     = 33,
  parameter int DSP_BIT_LEN      = 17,
  parameter int WORD_LEN         = 16,
  parameter int NUM_ELEMENTS_OUT = NUM_ELEMENTS*2,
  parameter int ADDER_TYPE       = 1, // Adder type 1 seems to give best results
  parameter bit PIPELINE_OUT     = 1, // Adds an extra pipeline stage to the output of the compressor tree
  parameter bit CTL_FIXED        = 0  // The multiplier has internal value for ctrl loop
)(
  input                          i_clk,
  input                          i_rst,
  input                          i_val,
  input        [1:0]             i_ctl[NUM_ELEMENTS],
  input        [DSP_BIT_LEN-1:0] i_dat_a[NUM_ELEMENTS],
  input        [DSP_BIT_LEN-1:0] i_dat_b[NUM_ELEMENTS],
  input        [DSP_BIT_LEN-1:0] i_add_term[NUM_ELEMENTS],
  output logic [DSP_BIT_LEN-1:0] o_dat[NUM_ELEMENTS*2],
  output logic                   o_val
);

localparam int OUT_BIT_LEN = (2*DSP_BIT_LEN - WORD_LEN) + $clog2(2*NUM_ELEMENTS+1);

logic [OUT_BIT_LEN-1:0]   res[NUM_ELEMENTS*2];
logic [DSP_BIT_LEN-1:0]   res_int[NUM_ELEMENTS*2];

logic [OUT_BIT_LEN-1:0]   add_r[NUM_ELEMENTS];
logic [DSP_BIT_LEN*2-1:0] mul_result[NUM_ELEMENTS][NUM_ELEMENTS];
logic [OUT_BIT_LEN-1:0]   grid[NUM_ELEMENTS*2][NUM_ELEMENTS*2];
logic [OUT_BIT_LEN-1:0]   grid_r[NUM_ELEMENTS*2][NUM_ELEMENTS*2];

logic [1:0] ctl [NUM_ELEMENTS];
logic [1:0] ctl_r [NUM_ELEMENTS];
logic [PIPELINE_OUT+1:0] val;

logic val_i;
logic i_val_r, val_i_r, i_val_rr, val_i_rr;
logic [1:0] ctl_int [NUM_ELEMENTS];

generate
  if (CTL_FIXED == 1) begin: GEN_CTL_FIXED
    always_ff @ (posedge i_clk) begin
      i_val_rr <= i_val_r;
      i_val_r <= i_val;
    end
    BUFG bufg_vali (
      .O(val_i),
      .I(i_val)
    );
    BUFG bufg_vali_r (
      .O(val_i_r),
      .I(i_val_r)
    );
    BUFG bufg_vali_rr (
      .O(val_i_rr),
      .I(i_val_rr)
    );    
    always_ff @ (posedge i_clk)
      if (i_rst) 
        for (int i = 0; i < NUM_ELEMENTS; i++)
          ctl_int[i] <= 2;
      else
        if (val_i)
          for (int i = 0; i < NUM_ELEMENTS; i++)
            ctl_int[i] <= ctl_int[i] == 2 ? 0 : ctl_int[i] + 1;
  end else begin
    always_comb begin
      val_i = i_val;
      for (int i = 0; i < NUM_ELEMENTS; i++)
        ctl_int[i] = i_ctl[i];
    end    
  end
endgenerate

always_comb o_val = val[PIPELINE_OUT+1];

 always_ff @ (posedge i_clk) begin
   if (i_rst) begin
     val <= 0;
     for (int i = 0; i < NUM_ELEMENTS; i++) begin
       add_r[i] <= 0;
       ctl[i] <= 0;
       ctl_r[i] <= 0;
     end
   end else begin
     val <= {val, val_i};
     for (int i = 0; i < NUM_ELEMENTS; i++) begin
       ctl[i] <= i_ctl[i];
       ctl_r[i] <= ctl[i];
       if (ctl_int[i] == 0) begin
         add_r[i] <= 0;
         add_r[i] <= i_add_term[i];
       end else if (ctl_int[i] == 1) begin
         add_r[NUM_ELEMENTS-i-1] <= 0;
         add_r[NUM_ELEMENTS-i-1] <= i_add_term[i];
       end else if (ctl_int[i] == 2) begin
         add_r[i] <= 0;
         add_r[i] <= i_add_term[i];
       end
     end
   end
 end

   // Instantiate half the multipliers
   // Swap order if we only need top half
   // In square mode we need to swap there products go
   genvar i, j;
   generate
      for (i=0; i<NUM_ELEMENTS; i=i+1) begin : mul_A
         for (j=0; j<NUM_ELEMENTS; j=j+1) begin : mul_B
           if (i+j < NUM_ELEMENTS_OUT) begin
              logic [DSP_BIT_LEN-1:0] mul_a, mul_b;
              logic [1:0] ctl_int;
              
              if (CTL_FIXED == 1) begin
                always_ff @ (posedge i_clk)
                  if (i_rst) 
                    ctl_int <= 2;
                  else
                    if (val_i)
                      ctl_int <= ctl_int == 2 ? 0 : ctl_int + 1;
              end else begin
                always_comb ctl_int = i_ctl[i];
              end
              
              always_comb begin
                if (ctl_int == 0) begin
                  // Multiply lower half
                  mul_a = i_dat_a[i];
                  mul_b = i_dat_b[j];
                end else if (ctl_int == 1) begin
                  // Multiply upper half
                  mul_a = i_dat_a[NUM_ELEMENTS-i-1];
                  mul_b = i_dat_b[NUM_ELEMENTS-j-1];
                end else begin
                  // Square - elements in upper diagonal are reflected horizontally
                  if (i > j) begin
                    mul_a = i_dat_a[i];
                    mul_b = i_dat_b[NUM_ELEMENTS-j-1];
                  end else begin
                    mul_a = i_dat_a[i];
                    mul_b = i_dat_b[j];
                  end
                end
              end
// TODO replace with multiply and include muxing
/*
              multiplier #(
                .A_BIT_LEN(DSP_BIT_LEN),
                .B_BIT_LEN(DSP_BIT_LEN)
              ) multiplier (
                .clk(i_clk),
                .A(mul_a),
                .B(mul_b),
                .P(mul_result[i][j])
               );
*/
              always_comb mul_result[i][j] = mul_a * mul_b;
            end else begin
              always_comb mul_result[i][j] = 0;
            end
         end
      end
   endgenerate

   logic [1:0] grid_ctl_int [NUM_ELEMENTS][NUM_ELEMENTS];
   generate
    if (CTL_FIXED == 1) begin  
        logic [1:0] grid_ctl [NUM_ELEMENTS][NUM_ELEMENTS];
        
        always_ff @ (posedge i_clk)
          if (i_rst)
            for (int ii=0; ii<NUM_ELEMENTS; ii=ii+1)
              for (int jj=0; jj<NUM_ELEMENTS; jj=jj+1)
                grid_ctl_int[ii][jj] <= 2;
          else
            if (val_i_r)
              for (int ii=0; ii<NUM_ELEMENTS; ii=ii+1)
                for (int jj=0; jj<NUM_ELEMENTS; jj=jj+1)
                  grid_ctl_int[ii][jj] <= grid_ctl_int[ii][jj] == 2 ? 0 : grid_ctl_int[ii][jj] + 1;
      end else begin
        always_comb
          for (int ii=0; ii<NUM_ELEMENTS; ii=ii+1)
            for (int jj=0; jj<NUM_ELEMENTS; jj=jj+1)
              grid_ctl_int[ii][jj] = ctl[i];
      end
   endgenerate
   
   
   always_comb begin
      for (int ii=0; ii<NUM_ELEMENTS*2; ii=ii+1) begin
         for (int jj=0; jj<NUM_ELEMENTS*2; jj=jj+1) begin
            grid[ii][jj] = 0;
         end
      end

      for (int ii=0; ii<NUM_ELEMENTS; ii=ii+1) begin : grid_row
         for (int jj=0; jj<NUM_ELEMENTS; jj=jj+1) begin : grid_col
         
           if (grid_ctl_int[ii][jj] == 0) begin
             grid[(ii+jj)][(2*ii)]       = mul_result[ii][jj][WORD_LEN-1 : 0];
             grid[(ii+jj+1)][((2*ii)+1)] = mul_result[ii][jj][2*DSP_BIT_LEN-1 : WORD_LEN];
           end else if (grid_ctl_int[ii][jj] == 1) begin
             grid[(ii+jj+1)][((2*ii)+1)] = mul_result[ii][jj][WORD_LEN-1 : 0];
             grid[(ii+jj)][(2*ii)]       = mul_result[ii][jj][2*DSP_BIT_LEN-1 : WORD_LEN];
           end else begin
              if (ii <= jj) begin
                if (ii+jj < NUM_ELEMENTS) begin
                  if (ii == jj) begin
                    grid[(ii+jj)][(2*ii)]       = mul_result[ii][jj][WORD_LEN-1 : 0];
                    grid[(ii+jj+1)][((2*ii)+1)] = mul_result[ii][jj][2*DSP_BIT_LEN-1 : WORD_LEN];
                  end else begin
                    grid[(ii+jj)][(2*ii)]       = {mul_result[ii][jj][WORD_LEN-2 : 0], 1'b0};
                    grid[(ii+jj+1)][((2*ii)+1)] =  mul_result[ii][jj][2*DSP_BIT_LEN-1 : WORD_LEN-1];
                  end
                end else begin
                  if (ii == jj) begin
                    grid[(ii+jj)][(2*ii)]       = mul_result[ii][NUM_ELEMENTS-jj-1][WORD_LEN-1 : 0];
                    grid[(ii+jj+1)][((2*ii)+1)] = mul_result[ii][NUM_ELEMENTS-jj-1][2*DSP_BIT_LEN-1 : WORD_LEN];
                  end else begin
                    grid[(ii+jj)][(2*ii)]       = {mul_result[ii][NUM_ELEMENTS-jj-1][WORD_LEN-2 : 0], 1'b0};
                    grid[(ii+jj+1)][((2*ii)+1)] =  mul_result[ii][NUM_ELEMENTS-jj-1][2*DSP_BIT_LEN-1 : WORD_LEN-1];
                  end
                end
              end
            end
         end
      end
   end

   always_ff @ (posedge i_clk) 
      for (int ii=0; ii<NUM_ELEMENTS*2; ii=ii+1) 
         for (int jj=0; jj<NUM_ELEMENTS*2; jj=jj+1) 
            grid_r[ii][jj] <=  grid[ii][jj];
      
   // Sum each column using compressor tree
   generate
      // First and last can always come from grid
      if (PIPELINE_OUT == 0) begin
        always_comb begin
          res[0] = grid_r[0][0] + add_r[0];
          res[NUM_ELEMENTS*2-1] = grid_r[NUM_ELEMENTS*2-1][NUM_ELEMENTS*2-1];
        end
      end else begin
        always_ff @ (posedge i_clk) begin
          res[0] <= grid_r[0][0] + add_r[0];
          res[NUM_ELEMENTS*2-1] <= grid_r[NUM_ELEMENTS*2-1][NUM_ELEMENTS*2-1];
        end
      end

      for (i=1; i<NUM_ELEMENTS*2-1; i=i+1) begin : col_sums
         localparam integer CUR_ELEMENTS = (i < NUM_ELEMENTS) ?
                                              ((i*2)+1) :
                                              ((NUM_ELEMENTS*4) - 1 - (i*2));
         localparam integer GRID_INDEX   = (i < NUM_ELEMENTS) ?
                                              0 :
                                              (((i - NUM_ELEMENTS) * 2) + 1);

         localparam integer TOT_ELEMENTS = CUR_ELEMENTS + (i < NUM_ELEMENTS);

         logic [OUT_BIT_LEN-1:0] terms [TOT_ELEMENTS];
         if (i < NUM_ELEMENTS)
           always_comb begin
             terms = {grid_r[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)], add_r[i]};
           end
         else
           always_comb begin
             terms = grid_r[i][GRID_INDEX:(GRID_INDEX + CUR_ELEMENTS - 1)];
           end

// TODO - We could really make to branches or accumulators, and sum the outputs, to save on logic
           if (ADDER_TYPE == 0) begin

             logic [OUT_BIT_LEN-1:0] Cout_col;
             logic [OUT_BIT_LEN-1:0] S_col;

             compressor_tree_3_to_2 #(
               .NUM_ELEMENTS(TOT_ELEMENTS),
               .BIT_LEN(OUT_BIT_LEN)
             )
             compressor_tree_3_to_2 (
               .terms(terms),
               .C(Cout_col),
               .S(S_col)
             );

             if (PIPELINE_OUT == 0) begin
               always_comb  res[i] = Cout_col[OUT_BIT_LEN-1:0] + S_col[OUT_BIT_LEN-1:0];
             end else begin
               always_ff @ (posedge i_clk)  res[i] <= Cout_col[OUT_BIT_LEN-1:0] + S_col[OUT_BIT_LEN-1:0];
             end

           end else if (ADDER_TYPE == 1) begin

             logic [OUT_BIT_LEN-1:0] res_int;

             adder_tree_2_to_1 #(
               .NUM_ELEMENTS(TOT_ELEMENTS),
               .BIT_LEN(OUT_BIT_LEN)
             )
             adder_tree_2_to_1 (
               .terms(terms),
               .S(res_int)
             );

             if (PIPELINE_OUT == 0) begin
               always_comb  res[i] = res_int;
             end else begin
               always_ff @ (posedge i_clk)  res[i] <= res_int;
             end

           end else if (ADDER_TYPE == 2) begin

             logic [OUT_BIT_LEN-1:0] Cout_col;
             logic [OUT_BIT_LEN-1:0] S_col;

             compressor_tree_6_to_3_then_3_to_2 #(
               .NUM_ELEMENTS(TOT_ELEMENTS),
               .BIT_LEN(OUT_BIT_LEN)
             )
             compressor_tree_6_to_3_then_3_to_2 (
               .terms(terms),
               .C2(Cout_col),
               .S(S_col)
             );

             if (PIPELINE_OUT == 0) begin
               always_comb  res[i] = Cout_col[OUT_BIT_LEN-1:0] + S_col[OUT_BIT_LEN-1:0];
             end else begin
               always_ff @ (posedge i_clk)  res[i] <= Cout_col[OUT_BIT_LEN-1:0] + S_col[OUT_BIT_LEN-1:0];
             end

           end else
             fatal(0, "ERROR - unsupported value for ADDER_TYPE");

      end
endgenerate

   logic [1:0] res_ctl_int [NUM_ELEMENTS*2];
   generate
    if (CTL_FIXED == 1) begin  
        logic [1:0] res_ctl [NUM_ELEMENTS*2];
        
        always_ff @ (posedge i_clk)
          if (i_rst)
            for (int ii=0; ii<NUM_ELEMENTS*2; ii=ii+1)
              res_ctl_int[ii] <= 2;
          else
            if ((PIPELINE_OUT == 0 && val_i_r) ||
              (PIPELINE_OUT == 1 && val_i_rr) )
              for (int ii=0; ii<NUM_ELEMENTS*2; ii=ii+1)
                res_ctl_int[ii] <= res_ctl_int[ii] == 2 ? 0 : res_ctl_int[ii] + 1;
      end else begin
        always_comb
          for (int ii=0; ii<NUM_ELEMENTS*2; ii=ii+1)
              res_ctl_int[ii] = PIPELINE_OUT == 0 ? ctl[i/2] : ctl_r[i/2];
      end
   endgenerate
   
   // Propigate carry on the boundary depending on direction
   always_comb
     for (int ii = 0; ii < NUM_ELEMENTS*2; ii++) begin
       if(res_ctl_int[ii] == 0) begin
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       end else if (res_ctl_int[ii] == 1) begin
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii < NUM_ELEMENTS_OUT-1 ? res[ii+1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       end else begin
         res_int[ii] = res[ii][WORD_LEN-1:0] + (ii > 0 ? res[ii-1][OUT_BIT_LEN-1:WORD_LEN] : 0);
       end
     end

   always_ff @ (posedge i_clk) begin
     for (int i = 0; i < NUM_ELEMENTS*2; i++) begin// Also check for bit overflow here if in mode 1
       if (res_ctl_int[i] == 0) begin
         o_dat[i] <= res_int[i];
       end else if (res_ctl_int[i] == 1) begin
         if (i == NUM_ELEMENTS-1)
           o_dat[i] <= res_int[i] + res_int[NUM_ELEMENTS][WORD_LEN];
         else if (i == NUM_ELEMENTS && res_ctl_int[i] == 1)
           o_dat[i] <= res_int[i][WORD_LEN-1:0];
         else
           o_dat[i] <= res_int[i];
       end else begin
         o_dat[i] <= res_int[i];
       end
     end
   end
   
   
endmodule
