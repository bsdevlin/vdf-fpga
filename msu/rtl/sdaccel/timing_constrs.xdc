set_property MAX_FANOUT 10 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/redun_mont/mul_in_sel*]
set_property MAX_FANOUT 10 [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/redun_mont/mult_ctl*]

#set_max_delay -from [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/reset_cdc0*] -to [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/reset_cdc1*] -datapath_only 4.0