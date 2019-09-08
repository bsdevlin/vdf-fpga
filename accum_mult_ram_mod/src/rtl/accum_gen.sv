
// Coef 0
logic [8:0] accum_i_0 [1];
logic [8:0] accum_o_c_0, accum_o_s_0;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(1),
  .BIT_LEN(9)
)
ct_0 (
  .terms(accum_i_0),
  .C(accum_o_c_0),
  .S(accum_o_s_0)
);
always_comb accum_i_0 = {mul_grid[0][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[0] <= accum_o_c_0 + accum_o_s_0;

// Coef 1
logic [8:0] accum_i_1 [1];
logic [8:0] accum_o_c_1, accum_o_s_1;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(1),
  .BIT_LEN(9)
)
ct_1 (
  .terms(accum_i_1),
  .C(accum_o_c_1),
  .S(accum_o_s_1)
);
always_comb accum_i_1 = {mul_grid[0][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[1] <= accum_o_c_1 + accum_o_s_1;

// Coef 2
logic [9:0] accum_i_2 [2];
logic [9:0] accum_o_c_2, accum_o_s_2;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(2),
  .BIT_LEN(10)
)
ct_2 (
  .terms(accum_i_2),
  .C(accum_o_c_2),
  .S(accum_o_s_2)
);
always_comb accum_i_2 = {mul_grid[0][0][26:18],mul_grid[0][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[2] <= accum_o_c_2 + accum_o_s_2;

// Coef 3
logic [10:0] accum_i_3 [3];
logic [10:0] accum_o_c_3, accum_o_s_3;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(3),
  .BIT_LEN(11)
)
ct_3 (
  .terms(accum_i_3),
  .C(accum_o_c_3),
  .S(accum_o_s_3)
);
always_comb accum_i_3 = {mul_grid[0][0][35:27],mul_grid[0][1][17:9],mul_grid[1][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[3] <= accum_o_c_3 + accum_o_s_3;

// Coef 4
logic [10:0] accum_i_4 [4];
logic [10:0] accum_o_c_4, accum_o_s_4;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(4),
  .BIT_LEN(11)
)
ct_4 (
  .terms(accum_i_4),
  .C(accum_o_c_4),
  .S(accum_o_s_4)
);
always_comb accum_i_4 = {mul_grid[0][0][44:36],mul_grid[0][1][26:18],mul_grid[0][2][8:0],mul_grid[1][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[4] <= accum_o_c_4 + accum_o_s_4;

// Coef 5
logic [10:0] accum_i_5 [4];
logic [10:0] accum_o_c_5, accum_o_s_5;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(4),
  .BIT_LEN(11)
)
ct_5 (
  .terms(accum_i_5),
  .C(accum_o_c_5),
  .S(accum_o_s_5)
);
always_comb accum_i_5 = {mul_grid[0][1][35:27],mul_grid[0][2][17:9],mul_grid[1][0][26:18],mul_grid[1][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[5] <= accum_o_c_5 + accum_o_s_5;

// Coef 6
logic [11:0] accum_i_6 [6];
logic [11:0] accum_o_c_6, accum_o_s_6;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(6),
  .BIT_LEN(12)
)
ct_6 (
  .terms(accum_i_6),
  .C(accum_o_c_6),
  .S(accum_o_s_6)
);
always_comb accum_i_6 = {mul_grid[0][1][44:36],mul_grid[0][2][26:18],mul_grid[0][3][8:0],mul_grid[1][0][35:27],mul_grid[1][1][17:9],mul_grid[2][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[6] <= accum_o_c_6 + accum_o_s_6;

// Coef 7
logic [11:0] accum_i_7 [6];
logic [11:0] accum_o_c_7, accum_o_s_7;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(6),
  .BIT_LEN(12)
)
ct_7 (
  .terms(accum_i_7),
  .C(accum_o_c_7),
  .S(accum_o_s_7)
);
always_comb accum_i_7 = {mul_grid[0][2][35:27],mul_grid[0][3][17:9],mul_grid[1][0][44:36],mul_grid[1][1][26:18],mul_grid[1][2][8:0],mul_grid[2][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[7] <= accum_o_c_7 + accum_o_s_7;

// Coef 8
logic [11:0] accum_i_8 [7];
logic [11:0] accum_o_c_8, accum_o_s_8;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(7),
  .BIT_LEN(12)
)
ct_8 (
  .terms(accum_i_8),
  .C(accum_o_c_8),
  .S(accum_o_s_8)
);
always_comb accum_i_8 = {mul_grid[0][2][44:36],mul_grid[0][3][26:18],mul_grid[0][4][8:0],mul_grid[1][1][35:27],mul_grid[1][2][17:9],mul_grid[2][0][26:18],mul_grid[2][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[8] <= accum_o_c_8 + accum_o_s_8;

// Coef 9
logic [11:0] accum_i_9 [8];
logic [11:0] accum_o_c_9, accum_o_s_9;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(8),
  .BIT_LEN(12)
)
ct_9 (
  .terms(accum_i_9),
  .C(accum_o_c_9),
  .S(accum_o_s_9)
);
always_comb accum_i_9 = {mul_grid[0][3][35:27],mul_grid[0][4][17:9],mul_grid[1][1][44:36],mul_grid[1][2][26:18],mul_grid[1][3][8:0],mul_grid[2][0][35:27],mul_grid[2][1][17:9],mul_grid[3][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[9] <= accum_o_c_9 + accum_o_s_9;

// Coef 10
logic [12:0] accum_i_10 [9];
logic [12:0] accum_o_c_10, accum_o_s_10;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(9),
  .BIT_LEN(13)
)
ct_10 (
  .terms(accum_i_10),
  .C(accum_o_c_10),
  .S(accum_o_s_10)
);
always_comb accum_i_10 = {mul_grid[0][3][44:36],mul_grid[0][4][26:18],mul_grid[0][5][8:0],mul_grid[1][2][35:27],mul_grid[1][3][17:9],mul_grid[2][0][44:36],mul_grid[2][1][26:18],mul_grid[2][2][8:0],mul_grid[3][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[10] <= accum_o_c_10 + accum_o_s_10;

// Coef 11
logic [12:0] accum_i_11 [9];
logic [12:0] accum_o_c_11, accum_o_s_11;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(9),
  .BIT_LEN(13)
)
ct_11 (
  .terms(accum_i_11),
  .C(accum_o_c_11),
  .S(accum_o_s_11)
);
always_comb accum_i_11 = {mul_grid[0][4][35:27],mul_grid[0][5][17:9],mul_grid[1][2][44:36],mul_grid[1][3][26:18],mul_grid[1][4][8:0],mul_grid[2][1][35:27],mul_grid[2][2][17:9],mul_grid[3][0][26:18],mul_grid[3][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[11] <= accum_o_c_11 + accum_o_s_11;

// Coef 12
logic [12:0] accum_i_12 [11];
logic [12:0] accum_o_c_12, accum_o_s_12;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(11),
  .BIT_LEN(13)
)
ct_12 (
  .terms(accum_i_12),
  .C(accum_o_c_12),
  .S(accum_o_s_12)
);
always_comb accum_i_12 = {mul_grid[0][4][44:36],mul_grid[0][5][26:18],mul_grid[0][6][8:0],mul_grid[1][3][35:27],mul_grid[1][4][17:9],mul_grid[2][1][44:36],mul_grid[2][2][26:18],mul_grid[2][3][8:0],mul_grid[3][0][35:27],mul_grid[3][1][17:9],mul_grid[4][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[12] <= accum_o_c_12 + accum_o_s_12;

// Coef 13
logic [12:0] accum_i_13 [11];
logic [12:0] accum_o_c_13, accum_o_s_13;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(11),
  .BIT_LEN(13)
)
ct_13 (
  .terms(accum_i_13),
  .C(accum_o_c_13),
  .S(accum_o_s_13)
);
always_comb accum_i_13 = {mul_grid[0][5][35:27],mul_grid[0][6][17:9],mul_grid[1][3][44:36],mul_grid[1][4][26:18],mul_grid[1][5][8:0],mul_grid[2][2][35:27],mul_grid[2][3][17:9],mul_grid[3][0][44:36],mul_grid[3][1][26:18],mul_grid[3][2][8:0],mul_grid[4][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[13] <= accum_o_c_13 + accum_o_s_13;

// Coef 14
logic [12:0] accum_i_14 [12];
logic [12:0] accum_o_c_14, accum_o_s_14;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(12),
  .BIT_LEN(13)
)
ct_14 (
  .terms(accum_i_14),
  .C(accum_o_c_14),
  .S(accum_o_s_14)
);
always_comb accum_i_14 = {mul_grid[0][5][44:36],mul_grid[0][6][26:18],mul_grid[0][7][8:0],mul_grid[1][4][35:27],mul_grid[1][5][17:9],mul_grid[2][2][44:36],mul_grid[2][3][26:18],mul_grid[2][4][8:0],mul_grid[3][1][35:27],mul_grid[3][2][17:9],mul_grid[4][0][26:18],mul_grid[4][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[14] <= accum_o_c_14 + accum_o_s_14;

// Coef 15
logic [12:0] accum_i_15 [13];
logic [12:0] accum_o_c_15, accum_o_s_15;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(13),
  .BIT_LEN(13)
)
ct_15 (
  .terms(accum_i_15),
  .C(accum_o_c_15),
  .S(accum_o_s_15)
);
always_comb accum_i_15 = {mul_grid[0][6][35:27],mul_grid[0][7][17:9],mul_grid[1][4][44:36],mul_grid[1][5][26:18],mul_grid[1][6][8:0],mul_grid[2][3][35:27],mul_grid[2][4][17:9],mul_grid[3][1][44:36],mul_grid[3][2][26:18],mul_grid[3][3][8:0],mul_grid[4][0][35:27],mul_grid[4][1][17:9],mul_grid[5][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[15] <= accum_o_c_15 + accum_o_s_15;

// Coef 16
logic [12:0] accum_i_16 [14];
logic [12:0] accum_o_c_16, accum_o_s_16;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(14),
  .BIT_LEN(13)
)
ct_16 (
  .terms(accum_i_16),
  .C(accum_o_c_16),
  .S(accum_o_s_16)
);
always_comb accum_i_16 = {mul_grid[0][6][44:36],mul_grid[0][7][26:18],mul_grid[0][8][8:0],mul_grid[1][5][35:27],mul_grid[1][6][17:9],mul_grid[2][3][44:36],mul_grid[2][4][26:18],mul_grid[2][5][8:0],mul_grid[3][2][35:27],mul_grid[3][3][17:9],mul_grid[4][0][44:36],mul_grid[4][1][26:18],mul_grid[4][2][8:0],mul_grid[5][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[16] <= accum_o_c_16 + accum_o_s_16;

// Coef 17
logic [12:0] accum_i_17 [14];
logic [12:0] accum_o_c_17, accum_o_s_17;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(14),
  .BIT_LEN(13)
)
ct_17 (
  .terms(accum_i_17),
  .C(accum_o_c_17),
  .S(accum_o_s_17)
);
always_comb accum_i_17 = {mul_grid[0][7][35:27],mul_grid[0][8][17:9],mul_grid[1][5][44:36],mul_grid[1][6][26:18],mul_grid[1][7][8:0],mul_grid[2][4][35:27],mul_grid[2][5][17:9],mul_grid[3][2][44:36],mul_grid[3][3][26:18],mul_grid[3][4][8:0],mul_grid[4][1][35:27],mul_grid[4][2][17:9],mul_grid[5][0][26:18],mul_grid[5][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[17] <= accum_o_c_17 + accum_o_s_17;

// Coef 18
logic [12:0] accum_i_18 [16];
logic [12:0] accum_o_c_18, accum_o_s_18;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(16),
  .BIT_LEN(13)
)
ct_18 (
  .terms(accum_i_18),
  .C(accum_o_c_18),
  .S(accum_o_s_18)
);
always_comb accum_i_18 = {mul_grid[0][7][44:36],mul_grid[0][8][26:18],mul_grid[0][9][8:0],mul_grid[1][6][35:27],mul_grid[1][7][17:9],mul_grid[2][4][44:36],mul_grid[2][5][26:18],mul_grid[2][6][8:0],mul_grid[3][3][35:27],mul_grid[3][4][17:9],mul_grid[4][1][44:36],mul_grid[4][2][26:18],mul_grid[4][3][8:0],mul_grid[5][0][35:27],mul_grid[5][1][17:9],mul_grid[6][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[18] <= accum_o_c_18 + accum_o_s_18;

// Coef 19
logic [12:0] accum_i_19 [16];
logic [12:0] accum_o_c_19, accum_o_s_19;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(16),
  .BIT_LEN(13)
)
ct_19 (
  .terms(accum_i_19),
  .C(accum_o_c_19),
  .S(accum_o_s_19)
);
always_comb accum_i_19 = {mul_grid[0][8][35:27],mul_grid[0][9][17:9],mul_grid[1][6][44:36],mul_grid[1][7][26:18],mul_grid[1][8][8:0],mul_grid[2][5][35:27],mul_grid[2][6][17:9],mul_grid[3][3][44:36],mul_grid[3][4][26:18],mul_grid[3][5][8:0],mul_grid[4][2][35:27],mul_grid[4][3][17:9],mul_grid[5][0][44:36],mul_grid[5][1][26:18],mul_grid[5][2][8:0],mul_grid[6][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[19] <= accum_o_c_19 + accum_o_s_19;

// Coef 20
logic [13:0] accum_i_20 [17];
logic [13:0] accum_o_c_20, accum_o_s_20;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(17),
  .BIT_LEN(14)
)
ct_20 (
  .terms(accum_i_20),
  .C(accum_o_c_20),
  .S(accum_o_s_20)
);
always_comb accum_i_20 = {mul_grid[0][8][44:36],mul_grid[0][9][26:18],mul_grid[0][10][8:0],mul_grid[1][7][35:27],mul_grid[1][8][17:9],mul_grid[2][5][44:36],mul_grid[2][6][26:18],mul_grid[2][7][8:0],mul_grid[3][4][35:27],mul_grid[3][5][17:9],mul_grid[4][2][44:36],mul_grid[4][3][26:18],mul_grid[4][4][8:0],mul_grid[5][1][35:27],mul_grid[5][2][17:9],mul_grid[6][0][26:18],mul_grid[6][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[20] <= accum_o_c_20 + accum_o_s_20;

// Coef 21
logic [13:0] accum_i_21 [18];
logic [13:0] accum_o_c_21, accum_o_s_21;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(18),
  .BIT_LEN(14)
)
ct_21 (
  .terms(accum_i_21),
  .C(accum_o_c_21),
  .S(accum_o_s_21)
);
always_comb accum_i_21 = {mul_grid[0][9][35:27],mul_grid[0][10][17:9],mul_grid[1][7][44:36],mul_grid[1][8][26:18],mul_grid[1][9][8:0],mul_grid[2][6][35:27],mul_grid[2][7][17:9],mul_grid[3][4][44:36],mul_grid[3][5][26:18],mul_grid[3][6][8:0],mul_grid[4][3][35:27],mul_grid[4][4][17:9],mul_grid[5][1][44:36],mul_grid[5][2][26:18],mul_grid[5][3][8:0],mul_grid[6][0][35:27],mul_grid[6][1][17:9],mul_grid[7][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[21] <= accum_o_c_21 + accum_o_s_21;

// Coef 22
logic [13:0] accum_i_22 [19];
logic [13:0] accum_o_c_22, accum_o_s_22;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(19),
  .BIT_LEN(14)
)
ct_22 (
  .terms(accum_i_22),
  .C(accum_o_c_22),
  .S(accum_o_s_22)
);
always_comb accum_i_22 = {mul_grid[0][9][44:36],mul_grid[0][10][26:18],mul_grid[0][11][8:0],mul_grid[1][8][35:27],mul_grid[1][9][17:9],mul_grid[2][6][44:36],mul_grid[2][7][26:18],mul_grid[2][8][8:0],mul_grid[3][5][35:27],mul_grid[3][6][17:9],mul_grid[4][3][44:36],mul_grid[4][4][26:18],mul_grid[4][5][8:0],mul_grid[5][2][35:27],mul_grid[5][3][17:9],mul_grid[6][0][44:36],mul_grid[6][1][26:18],mul_grid[6][2][8:0],mul_grid[7][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[22] <= accum_o_c_22 + accum_o_s_22;

// Coef 23
logic [13:0] accum_i_23 [19];
logic [13:0] accum_o_c_23, accum_o_s_23;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(19),
  .BIT_LEN(14)
)
ct_23 (
  .terms(accum_i_23),
  .C(accum_o_c_23),
  .S(accum_o_s_23)
);
always_comb accum_i_23 = {mul_grid[0][10][35:27],mul_grid[0][11][17:9],mul_grid[1][8][44:36],mul_grid[1][9][26:18],mul_grid[1][10][8:0],mul_grid[2][7][35:27],mul_grid[2][8][17:9],mul_grid[3][5][44:36],mul_grid[3][6][26:18],mul_grid[3][7][8:0],mul_grid[4][4][35:27],mul_grid[4][5][17:9],mul_grid[5][2][44:36],mul_grid[5][3][26:18],mul_grid[5][4][8:0],mul_grid[6][1][35:27],mul_grid[6][2][17:9],mul_grid[7][0][26:18],mul_grid[7][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[23] <= accum_o_c_23 + accum_o_s_23;

// Coef 24
logic [13:0] accum_i_24 [21];
logic [13:0] accum_o_c_24, accum_o_s_24;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(21),
  .BIT_LEN(14)
)
ct_24 (
  .terms(accum_i_24),
  .C(accum_o_c_24),
  .S(accum_o_s_24)
);
always_comb accum_i_24 = {mul_grid[0][10][44:36],mul_grid[0][11][26:18],mul_grid[0][12][8:0],mul_grid[1][9][35:27],mul_grid[1][10][17:9],mul_grid[2][7][44:36],mul_grid[2][8][26:18],mul_grid[2][9][8:0],mul_grid[3][6][35:27],mul_grid[3][7][17:9],mul_grid[4][4][44:36],mul_grid[4][5][26:18],mul_grid[4][6][8:0],mul_grid[5][3][35:27],mul_grid[5][4][17:9],mul_grid[6][1][44:36],mul_grid[6][2][26:18],mul_grid[6][3][8:0],mul_grid[7][0][35:27],mul_grid[7][1][17:9],mul_grid[8][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[24] <= accum_o_c_24 + accum_o_s_24;

// Coef 25
logic [13:0] accum_i_25 [21];
logic [13:0] accum_o_c_25, accum_o_s_25;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(21),
  .BIT_LEN(14)
)
ct_25 (
  .terms(accum_i_25),
  .C(accum_o_c_25),
  .S(accum_o_s_25)
);
always_comb accum_i_25 = {mul_grid[0][11][35:27],mul_grid[0][12][17:9],mul_grid[1][9][44:36],mul_grid[1][10][26:18],mul_grid[1][11][8:0],mul_grid[2][8][35:27],mul_grid[2][9][17:9],mul_grid[3][6][44:36],mul_grid[3][7][26:18],mul_grid[3][8][8:0],mul_grid[4][5][35:27],mul_grid[4][6][17:9],mul_grid[5][3][44:36],mul_grid[5][4][26:18],mul_grid[5][5][8:0],mul_grid[6][2][35:27],mul_grid[6][3][17:9],mul_grid[7][0][44:36],mul_grid[7][1][26:18],mul_grid[7][2][8:0],mul_grid[8][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[25] <= accum_o_c_25 + accum_o_s_25;

// Coef 26
logic [13:0] accum_i_26 [22];
logic [13:0] accum_o_c_26, accum_o_s_26;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(22),
  .BIT_LEN(14)
)
ct_26 (
  .terms(accum_i_26),
  .C(accum_o_c_26),
  .S(accum_o_s_26)
);
always_comb accum_i_26 = {mul_grid[0][11][44:36],mul_grid[0][12][26:18],mul_grid[0][13][8:0],mul_grid[1][10][35:27],mul_grid[1][11][17:9],mul_grid[2][8][44:36],mul_grid[2][9][26:18],mul_grid[2][10][8:0],mul_grid[3][7][35:27],mul_grid[3][8][17:9],mul_grid[4][5][44:36],mul_grid[4][6][26:18],mul_grid[4][7][8:0],mul_grid[5][4][35:27],mul_grid[5][5][17:9],mul_grid[6][2][44:36],mul_grid[6][3][26:18],mul_grid[6][4][8:0],mul_grid[7][1][35:27],mul_grid[7][2][17:9],mul_grid[8][0][26:18],mul_grid[8][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[26] <= accum_o_c_26 + accum_o_s_26;

// Coef 27
logic [13:0] accum_i_27 [23];
logic [13:0] accum_o_c_27, accum_o_s_27;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(23),
  .BIT_LEN(14)
)
ct_27 (
  .terms(accum_i_27),
  .C(accum_o_c_27),
  .S(accum_o_s_27)
);
always_comb accum_i_27 = {mul_grid[0][12][35:27],mul_grid[0][13][17:9],mul_grid[1][10][44:36],mul_grid[1][11][26:18],mul_grid[1][12][8:0],mul_grid[2][9][35:27],mul_grid[2][10][17:9],mul_grid[3][7][44:36],mul_grid[3][8][26:18],mul_grid[3][9][8:0],mul_grid[4][6][35:27],mul_grid[4][7][17:9],mul_grid[5][4][44:36],mul_grid[5][5][26:18],mul_grid[5][6][8:0],mul_grid[6][3][35:27],mul_grid[6][4][17:9],mul_grid[7][1][44:36],mul_grid[7][2][26:18],mul_grid[7][3][8:0],mul_grid[8][0][35:27],mul_grid[8][1][17:9],mul_grid[9][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[27] <= accum_o_c_27 + accum_o_s_27;

// Coef 28
logic [13:0] accum_i_28 [24];
logic [13:0] accum_o_c_28, accum_o_s_28;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(24),
  .BIT_LEN(14)
)
ct_28 (
  .terms(accum_i_28),
  .C(accum_o_c_28),
  .S(accum_o_s_28)
);
always_comb accum_i_28 = {mul_grid[0][12][44:36],mul_grid[0][13][26:18],mul_grid[0][14][8:0],mul_grid[1][11][35:27],mul_grid[1][12][17:9],mul_grid[2][9][44:36],mul_grid[2][10][26:18],mul_grid[2][11][8:0],mul_grid[3][8][35:27],mul_grid[3][9][17:9],mul_grid[4][6][44:36],mul_grid[4][7][26:18],mul_grid[4][8][8:0],mul_grid[5][5][35:27],mul_grid[5][6][17:9],mul_grid[6][3][44:36],mul_grid[6][4][26:18],mul_grid[6][5][8:0],mul_grid[7][2][35:27],mul_grid[7][3][17:9],mul_grid[8][0][44:36],mul_grid[8][1][26:18],mul_grid[8][2][8:0],mul_grid[9][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[28] <= accum_o_c_28 + accum_o_s_28;

// Coef 29
logic [13:0] accum_i_29 [24];
logic [13:0] accum_o_c_29, accum_o_s_29;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(24),
  .BIT_LEN(14)
)
ct_29 (
  .terms(accum_i_29),
  .C(accum_o_c_29),
  .S(accum_o_s_29)
);
always_comb accum_i_29 = {mul_grid[0][13][35:27],mul_grid[0][14][17:9],mul_grid[1][11][44:36],mul_grid[1][12][26:18],mul_grid[1][13][8:0],mul_grid[2][10][35:27],mul_grid[2][11][17:9],mul_grid[3][8][44:36],mul_grid[3][9][26:18],mul_grid[3][10][8:0],mul_grid[4][7][35:27],mul_grid[4][8][17:9],mul_grid[5][5][44:36],mul_grid[5][6][26:18],mul_grid[5][7][8:0],mul_grid[6][4][35:27],mul_grid[6][5][17:9],mul_grid[7][2][44:36],mul_grid[7][3][26:18],mul_grid[7][4][8:0],mul_grid[8][1][35:27],mul_grid[8][2][17:9],mul_grid[9][0][26:18],mul_grid[9][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[29] <= accum_o_c_29 + accum_o_s_29;

// Coef 30
logic [13:0] accum_i_30 [26];
logic [13:0] accum_o_c_30, accum_o_s_30;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(26),
  .BIT_LEN(14)
)
ct_30 (
  .terms(accum_i_30),
  .C(accum_o_c_30),
  .S(accum_o_s_30)
);
always_comb accum_i_30 = {mul_grid[0][13][44:36],mul_grid[0][14][26:18],mul_grid[0][15][8:0],mul_grid[1][12][35:27],mul_grid[1][13][17:9],mul_grid[2][10][44:36],mul_grid[2][11][26:18],mul_grid[2][12][8:0],mul_grid[3][9][35:27],mul_grid[3][10][17:9],mul_grid[4][7][44:36],mul_grid[4][8][26:18],mul_grid[4][9][8:0],mul_grid[5][6][35:27],mul_grid[5][7][17:9],mul_grid[6][4][44:36],mul_grid[6][5][26:18],mul_grid[6][6][8:0],mul_grid[7][3][35:27],mul_grid[7][4][17:9],mul_grid[8][1][44:36],mul_grid[8][2][26:18],mul_grid[8][3][8:0],mul_grid[9][0][35:27],mul_grid[9][1][17:9],mul_grid[10][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[30] <= accum_o_c_30 + accum_o_s_30;

// Coef 31
logic [13:0] accum_i_31 [26];
logic [13:0] accum_o_c_31, accum_o_s_31;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(26),
  .BIT_LEN(14)
)
ct_31 (
  .terms(accum_i_31),
  .C(accum_o_c_31),
  .S(accum_o_s_31)
);
always_comb accum_i_31 = {mul_grid[0][14][35:27],mul_grid[0][15][17:9],mul_grid[1][12][44:36],mul_grid[1][13][26:18],mul_grid[1][14][8:0],mul_grid[2][11][35:27],mul_grid[2][12][17:9],mul_grid[3][9][44:36],mul_grid[3][10][26:18],mul_grid[3][11][8:0],mul_grid[4][8][35:27],mul_grid[4][9][17:9],mul_grid[5][6][44:36],mul_grid[5][7][26:18],mul_grid[5][8][8:0],mul_grid[6][5][35:27],mul_grid[6][6][17:9],mul_grid[7][3][44:36],mul_grid[7][4][26:18],mul_grid[7][5][8:0],mul_grid[8][2][35:27],mul_grid[8][3][17:9],mul_grid[9][0][44:36],mul_grid[9][1][26:18],mul_grid[9][2][8:0],mul_grid[10][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[31] <= accum_o_c_31 + accum_o_s_31;

// Coef 32
logic [13:0] accum_i_32 [27];
logic [13:0] accum_o_c_32, accum_o_s_32;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(27),
  .BIT_LEN(14)
)
ct_32 (
  .terms(accum_i_32),
  .C(accum_o_c_32),
  .S(accum_o_s_32)
);
always_comb accum_i_32 = {mul_grid[0][14][44:36],mul_grid[0][15][26:18],mul_grid[0][16][8:0],mul_grid[1][13][35:27],mul_grid[1][14][17:9],mul_grid[2][11][44:36],mul_grid[2][12][26:18],mul_grid[2][13][8:0],mul_grid[3][10][35:27],mul_grid[3][11][17:9],mul_grid[4][8][44:36],mul_grid[4][9][26:18],mul_grid[4][10][8:0],mul_grid[5][7][35:27],mul_grid[5][8][17:9],mul_grid[6][5][44:36],mul_grid[6][6][26:18],mul_grid[6][7][8:0],mul_grid[7][4][35:27],mul_grid[7][5][17:9],mul_grid[8][2][44:36],mul_grid[8][3][26:18],mul_grid[8][4][8:0],mul_grid[9][1][35:27],mul_grid[9][2][17:9],mul_grid[10][0][26:18],mul_grid[10][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[32] <= accum_o_c_32 + accum_o_s_32;

// Coef 33
logic [13:0] accum_i_33 [28];
logic [13:0] accum_o_c_33, accum_o_s_33;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(28),
  .BIT_LEN(14)
)
ct_33 (
  .terms(accum_i_33),
  .C(accum_o_c_33),
  .S(accum_o_s_33)
);
always_comb accum_i_33 = {mul_grid[0][15][35:27],mul_grid[0][16][17:9],mul_grid[1][13][44:36],mul_grid[1][14][26:18],mul_grid[1][15][8:0],mul_grid[2][12][35:27],mul_grid[2][13][17:9],mul_grid[3][10][44:36],mul_grid[3][11][26:18],mul_grid[3][12][8:0],mul_grid[4][9][35:27],mul_grid[4][10][17:9],mul_grid[5][7][44:36],mul_grid[5][8][26:18],mul_grid[5][9][8:0],mul_grid[6][6][35:27],mul_grid[6][7][17:9],mul_grid[7][4][44:36],mul_grid[7][5][26:18],mul_grid[7][6][8:0],mul_grid[8][3][35:27],mul_grid[8][4][17:9],mul_grid[9][1][44:36],mul_grid[9][2][26:18],mul_grid[9][3][8:0],mul_grid[10][0][35:27],mul_grid[10][1][17:9],mul_grid[11][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[33] <= accum_o_c_33 + accum_o_s_33;

// Coef 34
logic [13:0] accum_i_34 [29];
logic [13:0] accum_o_c_34, accum_o_s_34;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(29),
  .BIT_LEN(14)
)
ct_34 (
  .terms(accum_i_34),
  .C(accum_o_c_34),
  .S(accum_o_s_34)
);
always_comb accum_i_34 = {mul_grid[0][15][44:36],mul_grid[0][16][26:18],mul_grid[0][17][8:0],mul_grid[1][14][35:27],mul_grid[1][15][17:9],mul_grid[2][12][44:36],mul_grid[2][13][26:18],mul_grid[2][14][8:0],mul_grid[3][11][35:27],mul_grid[3][12][17:9],mul_grid[4][9][44:36],mul_grid[4][10][26:18],mul_grid[4][11][8:0],mul_grid[5][8][35:27],mul_grid[5][9][17:9],mul_grid[6][6][44:36],mul_grid[6][7][26:18],mul_grid[6][8][8:0],mul_grid[7][5][35:27],mul_grid[7][6][17:9],mul_grid[8][3][44:36],mul_grid[8][4][26:18],mul_grid[8][5][8:0],mul_grid[9][2][35:27],mul_grid[9][3][17:9],mul_grid[10][0][44:36],mul_grid[10][1][26:18],mul_grid[10][2][8:0],mul_grid[11][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[34] <= accum_o_c_34 + accum_o_s_34;

// Coef 35
logic [13:0] accum_i_35 [29];
logic [13:0] accum_o_c_35, accum_o_s_35;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(29),
  .BIT_LEN(14)
)
ct_35 (
  .terms(accum_i_35),
  .C(accum_o_c_35),
  .S(accum_o_s_35)
);
always_comb accum_i_35 = {mul_grid[0][16][35:27],mul_grid[0][17][17:9],mul_grid[1][14][44:36],mul_grid[1][15][26:18],mul_grid[1][16][8:0],mul_grid[2][13][35:27],mul_grid[2][14][17:9],mul_grid[3][11][44:36],mul_grid[3][12][26:18],mul_grid[3][13][8:0],mul_grid[4][10][35:27],mul_grid[4][11][17:9],mul_grid[5][8][44:36],mul_grid[5][9][26:18],mul_grid[5][10][8:0],mul_grid[6][7][35:27],mul_grid[6][8][17:9],mul_grid[7][5][44:36],mul_grid[7][6][26:18],mul_grid[7][7][8:0],mul_grid[8][4][35:27],mul_grid[8][5][17:9],mul_grid[9][2][44:36],mul_grid[9][3][26:18],mul_grid[9][4][8:0],mul_grid[10][1][35:27],mul_grid[10][2][17:9],mul_grid[11][0][26:18],mul_grid[11][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[35] <= accum_o_c_35 + accum_o_s_35;

// Coef 36
logic [13:0] accum_i_36 [31];
logic [13:0] accum_o_c_36, accum_o_s_36;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(31),
  .BIT_LEN(14)
)
ct_36 (
  .terms(accum_i_36),
  .C(accum_o_c_36),
  .S(accum_o_s_36)
);
always_comb accum_i_36 = {mul_grid[0][16][44:36],mul_grid[0][17][26:18],mul_grid[0][18][8:0],mul_grid[1][15][35:27],mul_grid[1][16][17:9],mul_grid[2][13][44:36],mul_grid[2][14][26:18],mul_grid[2][15][8:0],mul_grid[3][12][35:27],mul_grid[3][13][17:9],mul_grid[4][10][44:36],mul_grid[4][11][26:18],mul_grid[4][12][8:0],mul_grid[5][9][35:27],mul_grid[5][10][17:9],mul_grid[6][7][44:36],mul_grid[6][8][26:18],mul_grid[6][9][8:0],mul_grid[7][6][35:27],mul_grid[7][7][17:9],mul_grid[8][4][44:36],mul_grid[8][5][26:18],mul_grid[8][6][8:0],mul_grid[9][3][35:27],mul_grid[9][4][17:9],mul_grid[10][1][44:36],mul_grid[10][2][26:18],mul_grid[10][3][8:0],mul_grid[11][0][35:27],mul_grid[11][1][17:9],mul_grid[12][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[36] <= accum_o_c_36 + accum_o_s_36;

// Coef 37
logic [13:0] accum_i_37 [31];
logic [13:0] accum_o_c_37, accum_o_s_37;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(31),
  .BIT_LEN(14)
)
ct_37 (
  .terms(accum_i_37),
  .C(accum_o_c_37),
  .S(accum_o_s_37)
);
always_comb accum_i_37 = {mul_grid[0][17][35:27],mul_grid[0][18][17:9],mul_grid[1][15][44:36],mul_grid[1][16][26:18],mul_grid[1][17][8:0],mul_grid[2][14][35:27],mul_grid[2][15][17:9],mul_grid[3][12][44:36],mul_grid[3][13][26:18],mul_grid[3][14][8:0],mul_grid[4][11][35:27],mul_grid[4][12][17:9],mul_grid[5][9][44:36],mul_grid[5][10][26:18],mul_grid[5][11][8:0],mul_grid[6][8][35:27],mul_grid[6][9][17:9],mul_grid[7][6][44:36],mul_grid[7][7][26:18],mul_grid[7][8][8:0],mul_grid[8][5][35:27],mul_grid[8][6][17:9],mul_grid[9][3][44:36],mul_grid[9][4][26:18],mul_grid[9][5][8:0],mul_grid[10][2][35:27],mul_grid[10][3][17:9],mul_grid[11][0][44:36],mul_grid[11][1][26:18],mul_grid[11][2][8:0],mul_grid[12][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[37] <= accum_o_c_37 + accum_o_s_37;

// Coef 38
logic [13:0] accum_i_38 [32];
logic [13:0] accum_o_c_38, accum_o_s_38;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(32),
  .BIT_LEN(14)
)
ct_38 (
  .terms(accum_i_38),
  .C(accum_o_c_38),
  .S(accum_o_s_38)
);
always_comb accum_i_38 = {mul_grid[0][17][44:36],mul_grid[0][18][26:18],mul_grid[0][19][8:0],mul_grid[1][16][35:27],mul_grid[1][17][17:9],mul_grid[2][14][44:36],mul_grid[2][15][26:18],mul_grid[2][16][8:0],mul_grid[3][13][35:27],mul_grid[3][14][17:9],mul_grid[4][11][44:36],mul_grid[4][12][26:18],mul_grid[4][13][8:0],mul_grid[5][10][35:27],mul_grid[5][11][17:9],mul_grid[6][8][44:36],mul_grid[6][9][26:18],mul_grid[6][10][8:0],mul_grid[7][7][35:27],mul_grid[7][8][17:9],mul_grid[8][5][44:36],mul_grid[8][6][26:18],mul_grid[8][7][8:0],mul_grid[9][4][35:27],mul_grid[9][5][17:9],mul_grid[10][2][44:36],mul_grid[10][3][26:18],mul_grid[10][4][8:0],mul_grid[11][1][35:27],mul_grid[11][2][17:9],mul_grid[12][0][26:18],mul_grid[12][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[38] <= accum_o_c_38 + accum_o_s_38;

// Coef 39
logic [14:0] accum_i_39 [33];
logic [14:0] accum_o_c_39, accum_o_s_39;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(33),
  .BIT_LEN(15)
)
ct_39 (
  .terms(accum_i_39),
  .C(accum_o_c_39),
  .S(accum_o_s_39)
);
always_comb accum_i_39 = {mul_grid[0][18][35:27],mul_grid[0][19][17:9],mul_grid[1][16][44:36],mul_grid[1][17][26:18],mul_grid[1][18][8:0],mul_grid[2][15][35:27],mul_grid[2][16][17:9],mul_grid[3][13][44:36],mul_grid[3][14][26:18],mul_grid[3][15][8:0],mul_grid[4][12][35:27],mul_grid[4][13][17:9],mul_grid[5][10][44:36],mul_grid[5][11][26:18],mul_grid[5][12][8:0],mul_grid[6][9][35:27],mul_grid[6][10][17:9],mul_grid[7][7][44:36],mul_grid[7][8][26:18],mul_grid[7][9][8:0],mul_grid[8][6][35:27],mul_grid[8][7][17:9],mul_grid[9][4][44:36],mul_grid[9][5][26:18],mul_grid[9][6][8:0],mul_grid[10][3][35:27],mul_grid[10][4][17:9],mul_grid[11][1][44:36],mul_grid[11][2][26:18],mul_grid[11][3][8:0],mul_grid[12][0][35:27],mul_grid[12][1][17:9],mul_grid[13][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[39] <= accum_o_c_39 + accum_o_s_39;

// Coef 40
logic [14:0] accum_i_40 [34];
logic [14:0] accum_o_c_40, accum_o_s_40;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(34),
  .BIT_LEN(15)
)
ct_40 (
  .terms(accum_i_40),
  .C(accum_o_c_40),
  .S(accum_o_s_40)
);
always_comb accum_i_40 = {mul_grid[0][18][44:36],mul_grid[0][19][26:18],mul_grid[0][20][8:0],mul_grid[1][17][35:27],mul_grid[1][18][17:9],mul_grid[2][15][44:36],mul_grid[2][16][26:18],mul_grid[2][17][8:0],mul_grid[3][14][35:27],mul_grid[3][15][17:9],mul_grid[4][12][44:36],mul_grid[4][13][26:18],mul_grid[4][14][8:0],mul_grid[5][11][35:27],mul_grid[5][12][17:9],mul_grid[6][9][44:36],mul_grid[6][10][26:18],mul_grid[6][11][8:0],mul_grid[7][8][35:27],mul_grid[7][9][17:9],mul_grid[8][6][44:36],mul_grid[8][7][26:18],mul_grid[8][8][8:0],mul_grid[9][5][35:27],mul_grid[9][6][17:9],mul_grid[10][3][44:36],mul_grid[10][4][26:18],mul_grid[10][5][8:0],mul_grid[11][2][35:27],mul_grid[11][3][17:9],mul_grid[12][0][44:36],mul_grid[12][1][26:18],mul_grid[12][2][8:0],mul_grid[13][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[40] <= accum_o_c_40 + accum_o_s_40;

// Coef 41
logic [14:0] accum_i_41 [34];
logic [14:0] accum_o_c_41, accum_o_s_41;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(34),
  .BIT_LEN(15)
)
ct_41 (
  .terms(accum_i_41),
  .C(accum_o_c_41),
  .S(accum_o_s_41)
);
always_comb accum_i_41 = {mul_grid[0][19][35:27],mul_grid[0][20][17:9],mul_grid[1][17][44:36],mul_grid[1][18][26:18],mul_grid[1][19][8:0],mul_grid[2][16][35:27],mul_grid[2][17][17:9],mul_grid[3][14][44:36],mul_grid[3][15][26:18],mul_grid[3][16][8:0],mul_grid[4][13][35:27],mul_grid[4][14][17:9],mul_grid[5][11][44:36],mul_grid[5][12][26:18],mul_grid[5][13][8:0],mul_grid[6][10][35:27],mul_grid[6][11][17:9],mul_grid[7][8][44:36],mul_grid[7][9][26:18],mul_grid[7][10][8:0],mul_grid[8][7][35:27],mul_grid[8][8][17:9],mul_grid[9][5][44:36],mul_grid[9][6][26:18],mul_grid[9][7][8:0],mul_grid[10][4][35:27],mul_grid[10][5][17:9],mul_grid[11][2][44:36],mul_grid[11][3][26:18],mul_grid[11][4][8:0],mul_grid[12][1][35:27],mul_grid[12][2][17:9],mul_grid[13][0][26:18],mul_grid[13][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[41] <= accum_o_c_41 + accum_o_s_41;

// Coef 42
logic [14:0] accum_i_42 [36];
logic [14:0] accum_o_c_42, accum_o_s_42;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(36),
  .BIT_LEN(15)
)
ct_42 (
  .terms(accum_i_42),
  .C(accum_o_c_42),
  .S(accum_o_s_42)
);
always_comb accum_i_42 = {mul_grid[0][19][44:36],mul_grid[0][20][26:18],mul_grid[0][21][8:0],mul_grid[1][18][35:27],mul_grid[1][19][17:9],mul_grid[2][16][44:36],mul_grid[2][17][26:18],mul_grid[2][18][8:0],mul_grid[3][15][35:27],mul_grid[3][16][17:9],mul_grid[4][13][44:36],mul_grid[4][14][26:18],mul_grid[4][15][8:0],mul_grid[5][12][35:27],mul_grid[5][13][17:9],mul_grid[6][10][44:36],mul_grid[6][11][26:18],mul_grid[6][12][8:0],mul_grid[7][9][35:27],mul_grid[7][10][17:9],mul_grid[8][7][44:36],mul_grid[8][8][26:18],mul_grid[8][9][8:0],mul_grid[9][6][35:27],mul_grid[9][7][17:9],mul_grid[10][4][44:36],mul_grid[10][5][26:18],mul_grid[10][6][8:0],mul_grid[11][3][35:27],mul_grid[11][4][17:9],mul_grid[12][1][44:36],mul_grid[12][2][26:18],mul_grid[12][3][8:0],mul_grid[13][0][35:27],mul_grid[13][1][17:9],mul_grid[14][0][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[42] <= accum_o_c_42 + accum_o_s_42;

// Coef 43
logic [14:0] accum_i_43 [36];
logic [14:0] accum_o_c_43, accum_o_s_43;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(36),
  .BIT_LEN(15)
)
ct_43 (
  .terms(accum_i_43),
  .C(accum_o_c_43),
  .S(accum_o_s_43)
);
always_comb accum_i_43 = {mul_grid[0][20][35:27],mul_grid[0][21][17:9],mul_grid[1][18][44:36],mul_grid[1][19][26:18],mul_grid[1][20][8:0],mul_grid[2][17][35:27],mul_grid[2][18][17:9],mul_grid[3][15][44:36],mul_grid[3][16][26:18],mul_grid[3][17][8:0],mul_grid[4][14][35:27],mul_grid[4][15][17:9],mul_grid[5][12][44:36],mul_grid[5][13][26:18],mul_grid[5][14][8:0],mul_grid[6][11][35:27],mul_grid[6][12][17:9],mul_grid[7][9][44:36],mul_grid[7][10][26:18],mul_grid[7][11][8:0],mul_grid[8][8][35:27],mul_grid[8][9][17:9],mul_grid[9][6][44:36],mul_grid[9][7][26:18],mul_grid[9][8][8:0],mul_grid[10][5][35:27],mul_grid[10][6][17:9],mul_grid[11][3][44:36],mul_grid[11][4][26:18],mul_grid[11][5][8:0],mul_grid[12][2][35:27],mul_grid[12][3][17:9],mul_grid[13][0][44:36],mul_grid[13][1][26:18],mul_grid[13][2][8:0],mul_grid[14][0][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[43] <= accum_o_c_43 + accum_o_s_43;

// Coef 44
logic [14:0] accum_i_44 [36];
logic [14:0] accum_o_c_44, accum_o_s_44;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(36),
  .BIT_LEN(15)
)
ct_44 (
  .terms(accum_i_44),
  .C(accum_o_c_44),
  .S(accum_o_s_44)
);
always_comb accum_i_44 = {mul_grid[0][20][44:36],mul_grid[0][21][26:18],mul_grid[1][19][35:27],mul_grid[1][20][17:9],mul_grid[2][17][44:36],mul_grid[2][18][26:18],mul_grid[2][19][8:0],mul_grid[3][16][35:27],mul_grid[3][17][17:9],mul_grid[4][14][44:36],mul_grid[4][15][26:18],mul_grid[4][16][8:0],mul_grid[5][13][35:27],mul_grid[5][14][17:9],mul_grid[6][11][44:36],mul_grid[6][12][26:18],mul_grid[6][13][8:0],mul_grid[7][10][35:27],mul_grid[7][11][17:9],mul_grid[8][8][44:36],mul_grid[8][9][26:18],mul_grid[8][10][8:0],mul_grid[9][7][35:27],mul_grid[9][8][17:9],mul_grid[10][5][44:36],mul_grid[10][6][26:18],mul_grid[10][7][8:0],mul_grid[11][4][35:27],mul_grid[11][5][17:9],mul_grid[12][2][44:36],mul_grid[12][3][26:18],mul_grid[12][4][8:0],mul_grid[13][1][35:27],mul_grid[13][2][17:9],mul_grid[14][0][26:18],mul_grid[14][1][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[44] <= accum_o_c_44 + accum_o_s_44;

// Coef 45
logic [14:0] accum_i_45 [36];
logic [14:0] accum_o_c_45, accum_o_s_45;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(36),
  .BIT_LEN(15)
)
ct_45 (
  .terms(accum_i_45),
  .C(accum_o_c_45),
  .S(accum_o_s_45)
);
always_comb accum_i_45 = {mul_grid[0][21][35:27],mul_grid[1][19][44:36],mul_grid[1][20][26:18],mul_grid[1][21][8:0],mul_grid[2][18][35:27],mul_grid[2][19][17:9],mul_grid[3][16][44:36],mul_grid[3][17][26:18],mul_grid[3][18][8:0],mul_grid[4][15][35:27],mul_grid[4][16][17:9],mul_grid[5][13][44:36],mul_grid[5][14][26:18],mul_grid[5][15][8:0],mul_grid[6][12][35:27],mul_grid[6][13][17:9],mul_grid[7][10][44:36],mul_grid[7][11][26:18],mul_grid[7][12][8:0],mul_grid[8][9][35:27],mul_grid[8][10][17:9],mul_grid[9][7][44:36],mul_grid[9][8][26:18],mul_grid[9][9][8:0],mul_grid[10][6][35:27],mul_grid[10][7][17:9],mul_grid[11][4][44:36],mul_grid[11][5][26:18],mul_grid[11][6][8:0],mul_grid[12][3][35:27],mul_grid[12][4][17:9],mul_grid[13][1][44:36],mul_grid[13][2][26:18],mul_grid[13][3][8:0],mul_grid[14][0][35:27],mul_grid[14][1][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[45] <= accum_o_c_45 + accum_o_s_45;

// Coef 46
logic [14:0] accum_i_46 [36];
logic [14:0] accum_o_c_46, accum_o_s_46;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(36),
  .BIT_LEN(15)
)
ct_46 (
  .terms(accum_i_46),
  .C(accum_o_c_46),
  .S(accum_o_s_46)
);
always_comb accum_i_46 = {mul_grid[0][21][44:36],mul_grid[1][20][35:27],mul_grid[1][21][17:9],mul_grid[2][18][44:36],mul_grid[2][19][26:18],mul_grid[2][20][8:0],mul_grid[3][17][35:27],mul_grid[3][18][17:9],mul_grid[4][15][44:36],mul_grid[4][16][26:18],mul_grid[4][17][8:0],mul_grid[5][14][35:27],mul_grid[5][15][17:9],mul_grid[6][12][44:36],mul_grid[6][13][26:18],mul_grid[6][14][8:0],mul_grid[7][11][35:27],mul_grid[7][12][17:9],mul_grid[8][9][44:36],mul_grid[8][10][26:18],mul_grid[8][11][8:0],mul_grid[9][8][35:27],mul_grid[9][9][17:9],mul_grid[10][6][44:36],mul_grid[10][7][26:18],mul_grid[10][8][8:0],mul_grid[11][5][35:27],mul_grid[11][6][17:9],mul_grid[12][3][44:36],mul_grid[12][4][26:18],mul_grid[12][5][8:0],mul_grid[13][2][35:27],mul_grid[13][3][17:9],mul_grid[14][0][44:36],mul_grid[14][1][26:18],mul_grid[14][2][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[46] <= accum_o_c_46 + accum_o_s_46;

// Coef 47
logic [14:0] accum_i_47 [34];
logic [14:0] accum_o_c_47, accum_o_s_47;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(34),
  .BIT_LEN(15)
)
ct_47 (
  .terms(accum_i_47),
  .C(accum_o_c_47),
  .S(accum_o_s_47)
);
always_comb accum_i_47 = {mul_grid[1][20][44:36],mul_grid[1][21][26:18],mul_grid[2][19][35:27],mul_grid[2][20][17:9],mul_grid[3][17][44:36],mul_grid[3][18][26:18],mul_grid[3][19][8:0],mul_grid[4][16][35:27],mul_grid[4][17][17:9],mul_grid[5][14][44:36],mul_grid[5][15][26:18],mul_grid[5][16][8:0],mul_grid[6][13][35:27],mul_grid[6][14][17:9],mul_grid[7][11][44:36],mul_grid[7][12][26:18],mul_grid[7][13][8:0],mul_grid[8][10][35:27],mul_grid[8][11][17:9],mul_grid[9][8][44:36],mul_grid[9][9][26:18],mul_grid[9][10][8:0],mul_grid[10][7][35:27],mul_grid[10][8][17:9],mul_grid[11][5][44:36],mul_grid[11][6][26:18],mul_grid[11][7][8:0],mul_grid[12][4][35:27],mul_grid[12][5][17:9],mul_grid[13][2][44:36],mul_grid[13][3][26:18],mul_grid[13][4][8:0],mul_grid[14][1][35:27],mul_grid[14][2][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[47] <= accum_o_c_47 + accum_o_s_47;

// Coef 48
logic [14:0] accum_i_48 [34];
logic [14:0] accum_o_c_48, accum_o_s_48;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(34),
  .BIT_LEN(15)
)
ct_48 (
  .terms(accum_i_48),
  .C(accum_o_c_48),
  .S(accum_o_s_48)
);
always_comb accum_i_48 = {mul_grid[1][21][35:27],mul_grid[2][19][44:36],mul_grid[2][20][26:18],mul_grid[2][21][8:0],mul_grid[3][18][35:27],mul_grid[3][19][17:9],mul_grid[4][16][44:36],mul_grid[4][17][26:18],mul_grid[4][18][8:0],mul_grid[5][15][35:27],mul_grid[5][16][17:9],mul_grid[6][13][44:36],mul_grid[6][14][26:18],mul_grid[6][15][8:0],mul_grid[7][12][35:27],mul_grid[7][13][17:9],mul_grid[8][10][44:36],mul_grid[8][11][26:18],mul_grid[8][12][8:0],mul_grid[9][9][35:27],mul_grid[9][10][17:9],mul_grid[10][7][44:36],mul_grid[10][8][26:18],mul_grid[10][9][8:0],mul_grid[11][6][35:27],mul_grid[11][7][17:9],mul_grid[12][4][44:36],mul_grid[12][5][26:18],mul_grid[12][6][8:0],mul_grid[13][3][35:27],mul_grid[13][4][17:9],mul_grid[14][1][44:36],mul_grid[14][2][26:18],mul_grid[14][3][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[48] <= accum_o_c_48 + accum_o_s_48;

// Coef 49
logic [14:0] accum_i_49 [33];
logic [14:0] accum_o_c_49, accum_o_s_49;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(33),
  .BIT_LEN(15)
)
ct_49 (
  .terms(accum_i_49),
  .C(accum_o_c_49),
  .S(accum_o_s_49)
);
always_comb accum_i_49 = {mul_grid[1][21][44:36],mul_grid[2][20][35:27],mul_grid[2][21][17:9],mul_grid[3][18][44:36],mul_grid[3][19][26:18],mul_grid[3][20][8:0],mul_grid[4][17][35:27],mul_grid[4][18][17:9],mul_grid[5][15][44:36],mul_grid[5][16][26:18],mul_grid[5][17][8:0],mul_grid[6][14][35:27],mul_grid[6][15][17:9],mul_grid[7][12][44:36],mul_grid[7][13][26:18],mul_grid[7][14][8:0],mul_grid[8][11][35:27],mul_grid[8][12][17:9],mul_grid[9][9][44:36],mul_grid[9][10][26:18],mul_grid[9][11][8:0],mul_grid[10][8][35:27],mul_grid[10][9][17:9],mul_grid[11][6][44:36],mul_grid[11][7][26:18],mul_grid[11][8][8:0],mul_grid[12][5][35:27],mul_grid[12][6][17:9],mul_grid[13][3][44:36],mul_grid[13][4][26:18],mul_grid[13][5][8:0],mul_grid[14][2][35:27],mul_grid[14][3][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[49] <= accum_o_c_49 + accum_o_s_49;

// Coef 50
logic [13:0] accum_i_50 [32];
logic [13:0] accum_o_c_50, accum_o_s_50;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(32),
  .BIT_LEN(14)
)
ct_50 (
  .terms(accum_i_50),
  .C(accum_o_c_50),
  .S(accum_o_s_50)
);
always_comb accum_i_50 = {mul_grid[2][20][44:36],mul_grid[2][21][26:18],mul_grid[3][19][35:27],mul_grid[3][20][17:9],mul_grid[4][17][44:36],mul_grid[4][18][26:18],mul_grid[4][19][8:0],mul_grid[5][16][35:27],mul_grid[5][17][17:9],mul_grid[6][14][44:36],mul_grid[6][15][26:18],mul_grid[6][16][8:0],mul_grid[7][13][35:27],mul_grid[7][14][17:9],mul_grid[8][11][44:36],mul_grid[8][12][26:18],mul_grid[8][13][8:0],mul_grid[9][10][35:27],mul_grid[9][11][17:9],mul_grid[10][8][44:36],mul_grid[10][9][26:18],mul_grid[10][10][8:0],mul_grid[11][7][35:27],mul_grid[11][8][17:9],mul_grid[12][5][44:36],mul_grid[12][6][26:18],mul_grid[12][7][8:0],mul_grid[13][4][35:27],mul_grid[13][5][17:9],mul_grid[14][2][44:36],mul_grid[14][3][26:18],mul_grid[14][4][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[50] <= accum_o_c_50 + accum_o_s_50;

// Coef 51
logic [13:0] accum_i_51 [31];
logic [13:0] accum_o_c_51, accum_o_s_51;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(31),
  .BIT_LEN(14)
)
ct_51 (
  .terms(accum_i_51),
  .C(accum_o_c_51),
  .S(accum_o_s_51)
);
always_comb accum_i_51 = {mul_grid[2][21][35:27],mul_grid[3][19][44:36],mul_grid[3][20][26:18],mul_grid[3][21][8:0],mul_grid[4][18][35:27],mul_grid[4][19][17:9],mul_grid[5][16][44:36],mul_grid[5][17][26:18],mul_grid[5][18][8:0],mul_grid[6][15][35:27],mul_grid[6][16][17:9],mul_grid[7][13][44:36],mul_grid[7][14][26:18],mul_grid[7][15][8:0],mul_grid[8][12][35:27],mul_grid[8][13][17:9],mul_grid[9][10][44:36],mul_grid[9][11][26:18],mul_grid[9][12][8:0],mul_grid[10][9][35:27],mul_grid[10][10][17:9],mul_grid[11][7][44:36],mul_grid[11][8][26:18],mul_grid[11][9][8:0],mul_grid[12][6][35:27],mul_grid[12][7][17:9],mul_grid[13][4][44:36],mul_grid[13][5][26:18],mul_grid[13][6][8:0],mul_grid[14][3][35:27],mul_grid[14][4][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[51] <= accum_o_c_51 + accum_o_s_51;

// Coef 52
logic [13:0] accum_i_52 [31];
logic [13:0] accum_o_c_52, accum_o_s_52;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(31),
  .BIT_LEN(14)
)
ct_52 (
  .terms(accum_i_52),
  .C(accum_o_c_52),
  .S(accum_o_s_52)
);
always_comb accum_i_52 = {mul_grid[2][21][44:36],mul_grid[3][20][35:27],mul_grid[3][21][17:9],mul_grid[4][18][44:36],mul_grid[4][19][26:18],mul_grid[4][20][8:0],mul_grid[5][17][35:27],mul_grid[5][18][17:9],mul_grid[6][15][44:36],mul_grid[6][16][26:18],mul_grid[6][17][8:0],mul_grid[7][14][35:27],mul_grid[7][15][17:9],mul_grid[8][12][44:36],mul_grid[8][13][26:18],mul_grid[8][14][8:0],mul_grid[9][11][35:27],mul_grid[9][12][17:9],mul_grid[10][9][44:36],mul_grid[10][10][26:18],mul_grid[10][11][8:0],mul_grid[11][8][35:27],mul_grid[11][9][17:9],mul_grid[12][6][44:36],mul_grid[12][7][26:18],mul_grid[12][8][8:0],mul_grid[13][5][35:27],mul_grid[13][6][17:9],mul_grid[14][3][44:36],mul_grid[14][4][26:18],mul_grid[14][5][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[52] <= accum_o_c_52 + accum_o_s_52;

// Coef 53
logic [13:0] accum_i_53 [29];
logic [13:0] accum_o_c_53, accum_o_s_53;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(29),
  .BIT_LEN(14)
)
ct_53 (
  .terms(accum_i_53),
  .C(accum_o_c_53),
  .S(accum_o_s_53)
);
always_comb accum_i_53 = {mul_grid[3][20][44:36],mul_grid[3][21][26:18],mul_grid[4][19][35:27],mul_grid[4][20][17:9],mul_grid[5][17][44:36],mul_grid[5][18][26:18],mul_grid[5][19][8:0],mul_grid[6][16][35:27],mul_grid[6][17][17:9],mul_grid[7][14][44:36],mul_grid[7][15][26:18],mul_grid[7][16][8:0],mul_grid[8][13][35:27],mul_grid[8][14][17:9],mul_grid[9][11][44:36],mul_grid[9][12][26:18],mul_grid[9][13][8:0],mul_grid[10][10][35:27],mul_grid[10][11][17:9],mul_grid[11][8][44:36],mul_grid[11][9][26:18],mul_grid[11][10][8:0],mul_grid[12][7][35:27],mul_grid[12][8][17:9],mul_grid[13][5][44:36],mul_grid[13][6][26:18],mul_grid[13][7][8:0],mul_grid[14][4][35:27],mul_grid[14][5][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[53] <= accum_o_c_53 + accum_o_s_53;

// Coef 54
logic [13:0] accum_i_54 [29];
logic [13:0] accum_o_c_54, accum_o_s_54;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(29),
  .BIT_LEN(14)
)
ct_54 (
  .terms(accum_i_54),
  .C(accum_o_c_54),
  .S(accum_o_s_54)
);
always_comb accum_i_54 = {mul_grid[3][21][35:27],mul_grid[4][19][44:36],mul_grid[4][20][26:18],mul_grid[4][21][8:0],mul_grid[5][18][35:27],mul_grid[5][19][17:9],mul_grid[6][16][44:36],mul_grid[6][17][26:18],mul_grid[6][18][8:0],mul_grid[7][15][35:27],mul_grid[7][16][17:9],mul_grid[8][13][44:36],mul_grid[8][14][26:18],mul_grid[8][15][8:0],mul_grid[9][12][35:27],mul_grid[9][13][17:9],mul_grid[10][10][44:36],mul_grid[10][11][26:18],mul_grid[10][12][8:0],mul_grid[11][9][35:27],mul_grid[11][10][17:9],mul_grid[12][7][44:36],mul_grid[12][8][26:18],mul_grid[12][9][8:0],mul_grid[13][6][35:27],mul_grid[13][7][17:9],mul_grid[14][4][44:36],mul_grid[14][5][26:18],mul_grid[14][6][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[54] <= accum_o_c_54 + accum_o_s_54;

// Coef 55
logic [13:0] accum_i_55 [28];
logic [13:0] accum_o_c_55, accum_o_s_55;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(28),
  .BIT_LEN(14)
)
ct_55 (
  .terms(accum_i_55),
  .C(accum_o_c_55),
  .S(accum_o_s_55)
);
always_comb accum_i_55 = {mul_grid[3][21][44:36],mul_grid[4][20][35:27],mul_grid[4][21][17:9],mul_grid[5][18][44:36],mul_grid[5][19][26:18],mul_grid[5][20][8:0],mul_grid[6][17][35:27],mul_grid[6][18][17:9],mul_grid[7][15][44:36],mul_grid[7][16][26:18],mul_grid[7][17][8:0],mul_grid[8][14][35:27],mul_grid[8][15][17:9],mul_grid[9][12][44:36],mul_grid[9][13][26:18],mul_grid[9][14][8:0],mul_grid[10][11][35:27],mul_grid[10][12][17:9],mul_grid[11][9][44:36],mul_grid[11][10][26:18],mul_grid[11][11][8:0],mul_grid[12][8][35:27],mul_grid[12][9][17:9],mul_grid[13][6][44:36],mul_grid[13][7][26:18],mul_grid[13][8][8:0],mul_grid[14][5][35:27],mul_grid[14][6][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[55] <= accum_o_c_55 + accum_o_s_55;

// Coef 56
logic [13:0] accum_i_56 [27];
logic [13:0] accum_o_c_56, accum_o_s_56;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(27),
  .BIT_LEN(14)
)
ct_56 (
  .terms(accum_i_56),
  .C(accum_o_c_56),
  .S(accum_o_s_56)
);
always_comb accum_i_56 = {mul_grid[4][20][44:36],mul_grid[4][21][26:18],mul_grid[5][19][35:27],mul_grid[5][20][17:9],mul_grid[6][17][44:36],mul_grid[6][18][26:18],mul_grid[6][19][8:0],mul_grid[7][16][35:27],mul_grid[7][17][17:9],mul_grid[8][14][44:36],mul_grid[8][15][26:18],mul_grid[8][16][8:0],mul_grid[9][13][35:27],mul_grid[9][14][17:9],mul_grid[10][11][44:36],mul_grid[10][12][26:18],mul_grid[10][13][8:0],mul_grid[11][10][35:27],mul_grid[11][11][17:9],mul_grid[12][8][44:36],mul_grid[12][9][26:18],mul_grid[12][10][8:0],mul_grid[13][7][35:27],mul_grid[13][8][17:9],mul_grid[14][5][44:36],mul_grid[14][6][26:18],mul_grid[14][7][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[56] <= accum_o_c_56 + accum_o_s_56;

// Coef 57
logic [13:0] accum_i_57 [26];
logic [13:0] accum_o_c_57, accum_o_s_57;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(26),
  .BIT_LEN(14)
)
ct_57 (
  .terms(accum_i_57),
  .C(accum_o_c_57),
  .S(accum_o_s_57)
);
always_comb accum_i_57 = {mul_grid[4][21][35:27],mul_grid[5][19][44:36],mul_grid[5][20][26:18],mul_grid[5][21][8:0],mul_grid[6][18][35:27],mul_grid[6][19][17:9],mul_grid[7][16][44:36],mul_grid[7][17][26:18],mul_grid[7][18][8:0],mul_grid[8][15][35:27],mul_grid[8][16][17:9],mul_grid[9][13][44:36],mul_grid[9][14][26:18],mul_grid[9][15][8:0],mul_grid[10][12][35:27],mul_grid[10][13][17:9],mul_grid[11][10][44:36],mul_grid[11][11][26:18],mul_grid[11][12][8:0],mul_grid[12][9][35:27],mul_grid[12][10][17:9],mul_grid[13][7][44:36],mul_grid[13][8][26:18],mul_grid[13][9][8:0],mul_grid[14][6][35:27],mul_grid[14][7][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[57] <= accum_o_c_57 + accum_o_s_57;

// Coef 58
logic [13:0] accum_i_58 [26];
logic [13:0] accum_o_c_58, accum_o_s_58;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(26),
  .BIT_LEN(14)
)
ct_58 (
  .terms(accum_i_58),
  .C(accum_o_c_58),
  .S(accum_o_s_58)
);
always_comb accum_i_58 = {mul_grid[4][21][44:36],mul_grid[5][20][35:27],mul_grid[5][21][17:9],mul_grid[6][18][44:36],mul_grid[6][19][26:18],mul_grid[6][20][8:0],mul_grid[7][17][35:27],mul_grid[7][18][17:9],mul_grid[8][15][44:36],mul_grid[8][16][26:18],mul_grid[8][17][8:0],mul_grid[9][14][35:27],mul_grid[9][15][17:9],mul_grid[10][12][44:36],mul_grid[10][13][26:18],mul_grid[10][14][8:0],mul_grid[11][11][35:27],mul_grid[11][12][17:9],mul_grid[12][9][44:36],mul_grid[12][10][26:18],mul_grid[12][11][8:0],mul_grid[13][8][35:27],mul_grid[13][9][17:9],mul_grid[14][6][44:36],mul_grid[14][7][26:18],mul_grid[14][8][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[58] <= accum_o_c_58 + accum_o_s_58;

// Coef 59
logic [13:0] accum_i_59 [24];
logic [13:0] accum_o_c_59, accum_o_s_59;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(24),
  .BIT_LEN(14)
)
ct_59 (
  .terms(accum_i_59),
  .C(accum_o_c_59),
  .S(accum_o_s_59)
);
always_comb accum_i_59 = {mul_grid[5][20][44:36],mul_grid[5][21][26:18],mul_grid[6][19][35:27],mul_grid[6][20][17:9],mul_grid[7][17][44:36],mul_grid[7][18][26:18],mul_grid[7][19][8:0],mul_grid[8][16][35:27],mul_grid[8][17][17:9],mul_grid[9][14][44:36],mul_grid[9][15][26:18],mul_grid[9][16][8:0],mul_grid[10][13][35:27],mul_grid[10][14][17:9],mul_grid[11][11][44:36],mul_grid[11][12][26:18],mul_grid[11][13][8:0],mul_grid[12][10][35:27],mul_grid[12][11][17:9],mul_grid[13][8][44:36],mul_grid[13][9][26:18],mul_grid[13][10][8:0],mul_grid[14][7][35:27],mul_grid[14][8][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[59] <= accum_o_c_59 + accum_o_s_59;

// Coef 60
logic [13:0] accum_i_60 [24];
logic [13:0] accum_o_c_60, accum_o_s_60;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(24),
  .BIT_LEN(14)
)
ct_60 (
  .terms(accum_i_60),
  .C(accum_o_c_60),
  .S(accum_o_s_60)
);
always_comb accum_i_60 = {mul_grid[5][21][35:27],mul_grid[6][19][44:36],mul_grid[6][20][26:18],mul_grid[6][21][8:0],mul_grid[7][18][35:27],mul_grid[7][19][17:9],mul_grid[8][16][44:36],mul_grid[8][17][26:18],mul_grid[8][18][8:0],mul_grid[9][15][35:27],mul_grid[9][16][17:9],mul_grid[10][13][44:36],mul_grid[10][14][26:18],mul_grid[10][15][8:0],mul_grid[11][12][35:27],mul_grid[11][13][17:9],mul_grid[12][10][44:36],mul_grid[12][11][26:18],mul_grid[12][12][8:0],mul_grid[13][9][35:27],mul_grid[13][10][17:9],mul_grid[14][7][44:36],mul_grid[14][8][26:18],mul_grid[14][9][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[60] <= accum_o_c_60 + accum_o_s_60;

// Coef 61
logic [13:0] accum_i_61 [23];
logic [13:0] accum_o_c_61, accum_o_s_61;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(23),
  .BIT_LEN(14)
)
ct_61 (
  .terms(accum_i_61),
  .C(accum_o_c_61),
  .S(accum_o_s_61)
);
always_comb accum_i_61 = {mul_grid[5][21][44:36],mul_grid[6][20][35:27],mul_grid[6][21][17:9],mul_grid[7][18][44:36],mul_grid[7][19][26:18],mul_grid[7][20][8:0],mul_grid[8][17][35:27],mul_grid[8][18][17:9],mul_grid[9][15][44:36],mul_grid[9][16][26:18],mul_grid[9][17][8:0],mul_grid[10][14][35:27],mul_grid[10][15][17:9],mul_grid[11][12][44:36],mul_grid[11][13][26:18],mul_grid[11][14][8:0],mul_grid[12][11][35:27],mul_grid[12][12][17:9],mul_grid[13][9][44:36],mul_grid[13][10][26:18],mul_grid[13][11][8:0],mul_grid[14][8][35:27],mul_grid[14][9][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[61] <= accum_o_c_61 + accum_o_s_61;

// Coef 62
logic [13:0] accum_i_62 [22];
logic [13:0] accum_o_c_62, accum_o_s_62;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(22),
  .BIT_LEN(14)
)
ct_62 (
  .terms(accum_i_62),
  .C(accum_o_c_62),
  .S(accum_o_s_62)
);
always_comb accum_i_62 = {mul_grid[6][20][44:36],mul_grid[6][21][26:18],mul_grid[7][19][35:27],mul_grid[7][20][17:9],mul_grid[8][17][44:36],mul_grid[8][18][26:18],mul_grid[8][19][8:0],mul_grid[9][16][35:27],mul_grid[9][17][17:9],mul_grid[10][14][44:36],mul_grid[10][15][26:18],mul_grid[10][16][8:0],mul_grid[11][13][35:27],mul_grid[11][14][17:9],mul_grid[12][11][44:36],mul_grid[12][12][26:18],mul_grid[12][13][8:0],mul_grid[13][10][35:27],mul_grid[13][11][17:9],mul_grid[14][8][44:36],mul_grid[14][9][26:18],mul_grid[14][10][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[62] <= accum_o_c_62 + accum_o_s_62;

// Coef 63
logic [13:0] accum_i_63 [21];
logic [13:0] accum_o_c_63, accum_o_s_63;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(21),
  .BIT_LEN(14)
)
ct_63 (
  .terms(accum_i_63),
  .C(accum_o_c_63),
  .S(accum_o_s_63)
);
always_comb accum_i_63 = {mul_grid[6][21][35:27],mul_grid[7][19][44:36],mul_grid[7][20][26:18],mul_grid[7][21][8:0],mul_grid[8][18][35:27],mul_grid[8][19][17:9],mul_grid[9][16][44:36],mul_grid[9][17][26:18],mul_grid[9][18][8:0],mul_grid[10][15][35:27],mul_grid[10][16][17:9],mul_grid[11][13][44:36],mul_grid[11][14][26:18],mul_grid[11][15][8:0],mul_grid[12][12][35:27],mul_grid[12][13][17:9],mul_grid[13][10][44:36],mul_grid[13][11][26:18],mul_grid[13][12][8:0],mul_grid[14][9][35:27],mul_grid[14][10][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[63] <= accum_o_c_63 + accum_o_s_63;

// Coef 64
logic [13:0] accum_i_64 [21];
logic [13:0] accum_o_c_64, accum_o_s_64;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(21),
  .BIT_LEN(14)
)
ct_64 (
  .terms(accum_i_64),
  .C(accum_o_c_64),
  .S(accum_o_s_64)
);
always_comb accum_i_64 = {mul_grid[6][21][44:36],mul_grid[7][20][35:27],mul_grid[7][21][17:9],mul_grid[8][18][44:36],mul_grid[8][19][26:18],mul_grid[8][20][8:0],mul_grid[9][17][35:27],mul_grid[9][18][17:9],mul_grid[10][15][44:36],mul_grid[10][16][26:18],mul_grid[10][17][8:0],mul_grid[11][14][35:27],mul_grid[11][15][17:9],mul_grid[12][12][44:36],mul_grid[12][13][26:18],mul_grid[12][14][8:0],mul_grid[13][11][35:27],mul_grid[13][12][17:9],mul_grid[14][9][44:36],mul_grid[14][10][26:18],mul_grid[14][11][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[64] <= accum_o_c_64 + accum_o_s_64;

// Coef 65
logic [13:0] accum_i_65 [19];
logic [13:0] accum_o_c_65, accum_o_s_65;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(19),
  .BIT_LEN(14)
)
ct_65 (
  .terms(accum_i_65),
  .C(accum_o_c_65),
  .S(accum_o_s_65)
);
always_comb accum_i_65 = {mul_grid[7][20][44:36],mul_grid[7][21][26:18],mul_grid[8][19][35:27],mul_grid[8][20][17:9],mul_grid[9][17][44:36],mul_grid[9][18][26:18],mul_grid[9][19][8:0],mul_grid[10][16][35:27],mul_grid[10][17][17:9],mul_grid[11][14][44:36],mul_grid[11][15][26:18],mul_grid[11][16][8:0],mul_grid[12][13][35:27],mul_grid[12][14][17:9],mul_grid[13][11][44:36],mul_grid[13][12][26:18],mul_grid[13][13][8:0],mul_grid[14][10][35:27],mul_grid[14][11][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[65] <= accum_o_c_65 + accum_o_s_65;

// Coef 66
logic [13:0] accum_i_66 [19];
logic [13:0] accum_o_c_66, accum_o_s_66;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(19),
  .BIT_LEN(14)
)
ct_66 (
  .terms(accum_i_66),
  .C(accum_o_c_66),
  .S(accum_o_s_66)
);
always_comb accum_i_66 = {mul_grid[7][21][35:27],mul_grid[8][19][44:36],mul_grid[8][20][26:18],mul_grid[8][21][8:0],mul_grid[9][18][35:27],mul_grid[9][19][17:9],mul_grid[10][16][44:36],mul_grid[10][17][26:18],mul_grid[10][18][8:0],mul_grid[11][15][35:27],mul_grid[11][16][17:9],mul_grid[12][13][44:36],mul_grid[12][14][26:18],mul_grid[12][15][8:0],mul_grid[13][12][35:27],mul_grid[13][13][17:9],mul_grid[14][10][44:36],mul_grid[14][11][26:18],mul_grid[14][12][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[66] <= accum_o_c_66 + accum_o_s_66;

// Coef 67
logic [13:0] accum_i_67 [18];
logic [13:0] accum_o_c_67, accum_o_s_67;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(18),
  .BIT_LEN(14)
)
ct_67 (
  .terms(accum_i_67),
  .C(accum_o_c_67),
  .S(accum_o_s_67)
);
always_comb accum_i_67 = {mul_grid[7][21][44:36],mul_grid[8][20][35:27],mul_grid[8][21][17:9],mul_grid[9][18][44:36],mul_grid[9][19][26:18],mul_grid[9][20][8:0],mul_grid[10][17][35:27],mul_grid[10][18][17:9],mul_grid[11][15][44:36],mul_grid[11][16][26:18],mul_grid[11][17][8:0],mul_grid[12][14][35:27],mul_grid[12][15][17:9],mul_grid[13][12][44:36],mul_grid[13][13][26:18],mul_grid[13][14][8:0],mul_grid[14][11][35:27],mul_grid[14][12][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[67] <= accum_o_c_67 + accum_o_s_67;

// Coef 68
logic [13:0] accum_i_68 [17];
logic [13:0] accum_o_c_68, accum_o_s_68;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(17),
  .BIT_LEN(14)
)
ct_68 (
  .terms(accum_i_68),
  .C(accum_o_c_68),
  .S(accum_o_s_68)
);
always_comb accum_i_68 = {mul_grid[8][20][44:36],mul_grid[8][21][26:18],mul_grid[9][19][35:27],mul_grid[9][20][17:9],mul_grid[10][17][44:36],mul_grid[10][18][26:18],mul_grid[10][19][8:0],mul_grid[11][16][35:27],mul_grid[11][17][17:9],mul_grid[12][14][44:36],mul_grid[12][15][26:18],mul_grid[12][16][8:0],mul_grid[13][13][35:27],mul_grid[13][14][17:9],mul_grid[14][11][44:36],mul_grid[14][12][26:18],mul_grid[14][13][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[68] <= accum_o_c_68 + accum_o_s_68;

// Coef 69
logic [12:0] accum_i_69 [16];
logic [12:0] accum_o_c_69, accum_o_s_69;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(16),
  .BIT_LEN(13)
)
ct_69 (
  .terms(accum_i_69),
  .C(accum_o_c_69),
  .S(accum_o_s_69)
);
always_comb accum_i_69 = {mul_grid[8][21][35:27],mul_grid[9][19][44:36],mul_grid[9][20][26:18],mul_grid[9][21][8:0],mul_grid[10][18][35:27],mul_grid[10][19][17:9],mul_grid[11][16][44:36],mul_grid[11][17][26:18],mul_grid[11][18][8:0],mul_grid[12][15][35:27],mul_grid[12][16][17:9],mul_grid[13][13][44:36],mul_grid[13][14][26:18],mul_grid[13][15][8:0],mul_grid[14][12][35:27],mul_grid[14][13][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[69] <= accum_o_c_69 + accum_o_s_69;

// Coef 70
logic [12:0] accum_i_70 [16];
logic [12:0] accum_o_c_70, accum_o_s_70;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(16),
  .BIT_LEN(13)
)
ct_70 (
  .terms(accum_i_70),
  .C(accum_o_c_70),
  .S(accum_o_s_70)
);
always_comb accum_i_70 = {mul_grid[8][21][44:36],mul_grid[9][20][35:27],mul_grid[9][21][17:9],mul_grid[10][18][44:36],mul_grid[10][19][26:18],mul_grid[10][20][8:0],mul_grid[11][17][35:27],mul_grid[11][18][17:9],mul_grid[12][15][44:36],mul_grid[12][16][26:18],mul_grid[12][17][8:0],mul_grid[13][14][35:27],mul_grid[13][15][17:9],mul_grid[14][12][44:36],mul_grid[14][13][26:18],mul_grid[14][14][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[70] <= accum_o_c_70 + accum_o_s_70;

// Coef 71
logic [12:0] accum_i_71 [14];
logic [12:0] accum_o_c_71, accum_o_s_71;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(14),
  .BIT_LEN(13)
)
ct_71 (
  .terms(accum_i_71),
  .C(accum_o_c_71),
  .S(accum_o_s_71)
);
always_comb accum_i_71 = {mul_grid[9][20][44:36],mul_grid[9][21][26:18],mul_grid[10][19][35:27],mul_grid[10][20][17:9],mul_grid[11][17][44:36],mul_grid[11][18][26:18],mul_grid[11][19][8:0],mul_grid[12][16][35:27],mul_grid[12][17][17:9],mul_grid[13][14][44:36],mul_grid[13][15][26:18],mul_grid[13][16][8:0],mul_grid[14][13][35:27],mul_grid[14][14][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[71] <= accum_o_c_71 + accum_o_s_71;

// Coef 72
logic [12:0] accum_i_72 [14];
logic [12:0] accum_o_c_72, accum_o_s_72;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(14),
  .BIT_LEN(13)
)
ct_72 (
  .terms(accum_i_72),
  .C(accum_o_c_72),
  .S(accum_o_s_72)
);
always_comb accum_i_72 = {mul_grid[9][21][35:27],mul_grid[10][19][44:36],mul_grid[10][20][26:18],mul_grid[10][21][8:0],mul_grid[11][18][35:27],mul_grid[11][19][17:9],mul_grid[12][16][44:36],mul_grid[12][17][26:18],mul_grid[12][18][8:0],mul_grid[13][15][35:27],mul_grid[13][16][17:9],mul_grid[14][13][44:36],mul_grid[14][14][26:18],mul_grid[14][15][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[72] <= accum_o_c_72 + accum_o_s_72;

// Coef 73
logic [12:0] accum_i_73 [13];
logic [12:0] accum_o_c_73, accum_o_s_73;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(13),
  .BIT_LEN(13)
)
ct_73 (
  .terms(accum_i_73),
  .C(accum_o_c_73),
  .S(accum_o_s_73)
);
always_comb accum_i_73 = {mul_grid[9][21][44:36],mul_grid[10][20][35:27],mul_grid[10][21][17:9],mul_grid[11][18][44:36],mul_grid[11][19][26:18],mul_grid[11][20][8:0],mul_grid[12][17][35:27],mul_grid[12][18][17:9],mul_grid[13][15][44:36],mul_grid[13][16][26:18],mul_grid[13][17][8:0],mul_grid[14][14][35:27],mul_grid[14][15][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[73] <= accum_o_c_73 + accum_o_s_73;

// Coef 74
logic [12:0] accum_i_74 [12];
logic [12:0] accum_o_c_74, accum_o_s_74;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(12),
  .BIT_LEN(13)
)
ct_74 (
  .terms(accum_i_74),
  .C(accum_o_c_74),
  .S(accum_o_s_74)
);
always_comb accum_i_74 = {mul_grid[10][20][44:36],mul_grid[10][21][26:18],mul_grid[11][19][35:27],mul_grid[11][20][17:9],mul_grid[12][17][44:36],mul_grid[12][18][26:18],mul_grid[12][19][8:0],mul_grid[13][16][35:27],mul_grid[13][17][17:9],mul_grid[14][14][44:36],mul_grid[14][15][26:18],mul_grid[14][16][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[74] <= accum_o_c_74 + accum_o_s_74;

// Coef 75
logic [12:0] accum_i_75 [11];
logic [12:0] accum_o_c_75, accum_o_s_75;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(11),
  .BIT_LEN(13)
)
ct_75 (
  .terms(accum_i_75),
  .C(accum_o_c_75),
  .S(accum_o_s_75)
);
always_comb accum_i_75 = {mul_grid[10][21][35:27],mul_grid[11][19][44:36],mul_grid[11][20][26:18],mul_grid[11][21][8:0],mul_grid[12][18][35:27],mul_grid[12][19][17:9],mul_grid[13][16][44:36],mul_grid[13][17][26:18],mul_grid[13][18][8:0],mul_grid[14][15][35:27],mul_grid[14][16][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[75] <= accum_o_c_75 + accum_o_s_75;

// Coef 76
logic [12:0] accum_i_76 [11];
logic [12:0] accum_o_c_76, accum_o_s_76;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(11),
  .BIT_LEN(13)
)
ct_76 (
  .terms(accum_i_76),
  .C(accum_o_c_76),
  .S(accum_o_s_76)
);
always_comb accum_i_76 = {mul_grid[10][21][44:36],mul_grid[11][20][35:27],mul_grid[11][21][17:9],mul_grid[12][18][44:36],mul_grid[12][19][26:18],mul_grid[12][20][8:0],mul_grid[13][17][35:27],mul_grid[13][18][17:9],mul_grid[14][15][44:36],mul_grid[14][16][26:18],mul_grid[14][17][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[76] <= accum_o_c_76 + accum_o_s_76;

// Coef 77
logic [12:0] accum_i_77 [9];
logic [12:0] accum_o_c_77, accum_o_s_77;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(9),
  .BIT_LEN(13)
)
ct_77 (
  .terms(accum_i_77),
  .C(accum_o_c_77),
  .S(accum_o_s_77)
);
always_comb accum_i_77 = {mul_grid[11][20][44:36],mul_grid[11][21][26:18],mul_grid[12][19][35:27],mul_grid[12][20][17:9],mul_grid[13][17][44:36],mul_grid[13][18][26:18],mul_grid[13][19][8:0],mul_grid[14][16][35:27],mul_grid[14][17][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[77] <= accum_o_c_77 + accum_o_s_77;

// Coef 78
logic [12:0] accum_i_78 [9];
logic [12:0] accum_o_c_78, accum_o_s_78;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(9),
  .BIT_LEN(13)
)
ct_78 (
  .terms(accum_i_78),
  .C(accum_o_c_78),
  .S(accum_o_s_78)
);
always_comb accum_i_78 = {mul_grid[11][21][35:27],mul_grid[12][19][44:36],mul_grid[12][20][26:18],mul_grid[12][21][8:0],mul_grid[13][18][35:27],mul_grid[13][19][17:9],mul_grid[14][16][44:36],mul_grid[14][17][26:18],mul_grid[14][18][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[78] <= accum_o_c_78 + accum_o_s_78;

// Coef 79
logic [11:0] accum_i_79 [8];
logic [11:0] accum_o_c_79, accum_o_s_79;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(8),
  .BIT_LEN(12)
)
ct_79 (
  .terms(accum_i_79),
  .C(accum_o_c_79),
  .S(accum_o_s_79)
);
always_comb accum_i_79 = {mul_grid[11][21][44:36],mul_grid[12][20][35:27],mul_grid[12][21][17:9],mul_grid[13][18][44:36],mul_grid[13][19][26:18],mul_grid[13][20][8:0],mul_grid[14][17][35:27],mul_grid[14][18][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[79] <= accum_o_c_79 + accum_o_s_79;

// Coef 80
logic [11:0] accum_i_80 [7];
logic [11:0] accum_o_c_80, accum_o_s_80;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(7),
  .BIT_LEN(12)
)
ct_80 (
  .terms(accum_i_80),
  .C(accum_o_c_80),
  .S(accum_o_s_80)
);
always_comb accum_i_80 = {mul_grid[12][20][44:36],mul_grid[12][21][26:18],mul_grid[13][19][35:27],mul_grid[13][20][17:9],mul_grid[14][17][44:36],mul_grid[14][18][26:18],mul_grid[14][19][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[80] <= accum_o_c_80 + accum_o_s_80;

// Coef 81
logic [11:0] accum_i_81 [6];
logic [11:0] accum_o_c_81, accum_o_s_81;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(6),
  .BIT_LEN(12)
)
ct_81 (
  .terms(accum_i_81),
  .C(accum_o_c_81),
  .S(accum_o_s_81)
);
always_comb accum_i_81 = {mul_grid[12][21][35:27],mul_grid[13][19][44:36],mul_grid[13][20][26:18],mul_grid[13][21][8:0],mul_grid[14][18][35:27],mul_grid[14][19][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[81] <= accum_o_c_81 + accum_o_s_81;

// Coef 82
logic [11:0] accum_i_82 [6];
logic [11:0] accum_o_c_82, accum_o_s_82;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(6),
  .BIT_LEN(12)
)
ct_82 (
  .terms(accum_i_82),
  .C(accum_o_c_82),
  .S(accum_o_s_82)
);
always_comb accum_i_82 = {mul_grid[12][21][44:36],mul_grid[13][20][35:27],mul_grid[13][21][17:9],mul_grid[14][18][44:36],mul_grid[14][19][26:18],mul_grid[14][20][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[82] <= accum_o_c_82 + accum_o_s_82;

// Coef 83
logic [10:0] accum_i_83 [4];
logic [10:0] accum_o_c_83, accum_o_s_83;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(4),
  .BIT_LEN(11)
)
ct_83 (
  .terms(accum_i_83),
  .C(accum_o_c_83),
  .S(accum_o_s_83)
);
always_comb accum_i_83 = {mul_grid[13][20][44:36],mul_grid[13][21][26:18],mul_grid[14][19][35:27],mul_grid[14][20][17:9]};
always_ff @ (posedge i_clk) accum_grid_o[83] <= accum_o_c_83 + accum_o_s_83;

// Coef 84
logic [10:0] accum_i_84 [4];
logic [10:0] accum_o_c_84, accum_o_s_84;
compressor_tree_3_to_2 #(
  .NUM_ELEMENTS(4),
  .BIT_LEN(11)
)
ct_84 (
  .terms(accum_i_84),
  .C(accum_o_c_84),
  .S(accum_o_s_84)
);
always_comb accum_i_84 = {mul_grid[13][21][35:27],mul_grid[14][19][44:36],mul_grid[14][20][26:18],mul_grid[14][21][8:0]};
always_ff @ (posedge i_clk) accum_grid_o[84] <= accum_o_c_84 + accum_o_s_84;
