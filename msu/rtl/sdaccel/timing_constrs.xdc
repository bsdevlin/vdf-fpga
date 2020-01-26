#set_false_path -from [get_clocks inst/inst_wrapper/inst_kernel/msu/redun_wrapper/inst/inst/clk_in1] -to [get_cells inst/inst_wrapper/inst_kernel/msu/redun_wrapper/locked_int[0]]
set_false_path -to [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/reset_int*]

set_property MAX_FANOUT 10 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/redun_mont/mul_in_sel*]
set_property MAX_FANOUT 10 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/mult_ctl*]
