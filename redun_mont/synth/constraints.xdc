create_clock -period 5.000 -name clk -waveform {0.000 2.500} [get_ports clk]



set_property USER_SLR_ASSIGNMENT SLR0 [get_cells redun_mont/half_multiply]
set_property USER_SLR_ASSIGNMENT SLR1 [get_cells redun_mont/squarer0]
