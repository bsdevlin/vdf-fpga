
create_clock -period 8.000 -name i_clk -waveform {0.000 4.000} [get_ports -filter { NAME =~  "clk" && DIRECTION == "IN" }]

create_pblock sl_exclusion
resize_pblock [get_pblocks sl_exclusion] -add {CLOCKREGION_X4Y0:CLOCKREGION_X5Y9}
set_property EXCLUDE_PLACEMENT 1 [get_pblocks sl_exclusion]

create_pblock SLR2
add_cells_to_pblock [get_pblocks SLR2] [get_cells -quiet [list redun_wrapper/redun_mont]]
add_cells_to_pblock SLR2 [get_cells [list redun_wrapper/inst]]
resize_pblock [get_pblocks SLR2] -add {CLOCKREGION_X0Y10:CLOCKREGION_X5Y14}


set_property MAX_FANOUT 10 [get_cells redun_wrapper/redun_mont/mul_in_sel*]
set_property MAX_FANOUT 10 [get_cells redun_wrapper/redun_mont/mult_ctl*]


set_max_delay -from [get_cells redun_wrapper/reset_cdc0*] -to [get_cells redun_wrapper/reset_cdc1*] -datapath_only 8.0