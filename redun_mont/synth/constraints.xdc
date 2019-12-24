
# This is the reference 125MHz clock
create_clock -period 8.000 -name clk -waveform {0.000 4.000} [get_ports -filter { NAME =~  "*clk*" && DIRECTION == "IN" }]
