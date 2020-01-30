add_cells_to_pblock [get_pblocks pblock_dynamic_SLR2] [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/redun_mont]
add_cells_to_pblock [get_pblocks pblock_dynamic_SLR2] [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/inst/inst/mmcme4_adv_inst]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets WRAPPER_INST/SH/kernel_clks_i/clkwiz_kernel_clk0/inst/CLK_CORE_DRP_I/clk_inst/clk_out1]

# This is to get different seeds
set_property LOC DSP48E2_X9Y296 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/redun_mont/multi_mode_multiplier/GEN_MULA[32].GEN_MULB[7].async_mult/o_dat0/DSP_OUTPUT_INST]