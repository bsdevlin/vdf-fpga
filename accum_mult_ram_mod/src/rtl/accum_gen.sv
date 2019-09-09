
// Coef 0
always_ff @ (posedge i_clk) accum_grid_o[0] <= {{1{1'd0}},mul_grid[0][0][0+:64],{0{1'd0}}};

// Coef 1
logic [66:0] accum_i_1 [3];
logic [66:0] accum_o_c_1, accum_o_s_1;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(3),
  .BIT_LEN(67)
)
ct_1 (
  .terms(accum_i_1),
  .C(accum_o_c_1),
  .S(accum_o_s_1)
);
always_comb accum_i_1 = {{{0{1'd0}},mul_grid[0][0][64+:64],{0{1'd0}}},{{0{1'd0}},mul_grid[0][1][0+:64],{0{1'd0}}},{{0{1'd0}},mul_grid[1][0][0+:64],{0{1'd0}}}};
always_ff @ (posedge i_clk) accum_grid_o[1] <= accum_o_c_1 + accum_o_s_1;

// Coef 2
logic [66:0] accum_i_2 [3];
logic [66:0] accum_o_c_2, accum_o_s_2;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(3),
  .BIT_LEN(67)
)
ct_2 (
  .terms(accum_i_2),
  .C(accum_o_c_2),
  .S(accum_o_s_2)
);
always_comb accum_i_2 = {{{0{1'd0}},mul_grid[0][1][64+:64],{0{1'd0}}},{{0{1'd0}},mul_grid[1][0][64+:64],{0{1'd0}}},{{0{1'd0}},mul_grid[1][1][0+:64],{0{1'd0}}}};
always_ff @ (posedge i_clk) accum_grid_o[2] <= accum_o_c_2 + accum_o_s_2;

// Coef 3
always_ff @ (posedge i_clk) accum_grid_o[3] <= {{0{1'd0}},mul_grid[1][1][64+:64],{0{1'd0}}};
