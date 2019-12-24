# We call this after place and route to adjust MMCM to remove any slack

set_property CLKFBOUT_MULT_F    49  [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/inst/inst/mmcme4_adv_inst]   #48
set_property CLKOUT0_DIVIDE_f   7.875 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/inst/inst/mmcme4_adv_inst]  #4.0
