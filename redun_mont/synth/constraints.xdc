
create_clock -period 8.000 -name i_clk -waveform {0.000 4.000} [get_ports -filter { NAME =~  "clk" && DIRECTION == "IN" }]

set_false_path -from [get_clocks redun_wrapper/inst/inst/clk_in1] -to [get_cells {redun_wrapper/locked_int[0]}]
