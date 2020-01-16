# We call this after place and route to adjust MMCM to remove any slack

set mmcm_cell [get_cells WRAPPER_INST/CL/vdf_1/inst/inst_wrapper/inst_kernel/msu/redun_wrapper/inst/inst/mmcme4_adv_inst]

set period [get_property PERIOD [get_clocks clk_out1_clk_wiz_0]]
puts "INFO: Before adjustment MCMM - period is $period"

set slack [get_property SLACK [get_timing_paths]]
set mult_f [get_property CLKFBOUT_MULT_F $mmcm_cell]
set cnt 0

while {$cnt < 100 & $slack < 0} {
  set mult_f [expr {$mult_f * 0.99}]
  # expr {double(round(100*$total_rate))/100}
  set_property CLKFBOUT_MULT_F $mult_f $mmcm_cell
  set slack [get_property SLACK [get_timing_paths]]
  puts "INFO: cnt $cnt, mult_f is $mult_f and slack is $slack"
  set cnt [expr {$cnt + 1}]
}

set period [get_property PERIOD [get_clocks clk_out1_clk_wiz_0]]

puts "INFO: Finished adjusting MCMM - period is now $period"

report_timing -file "adjust_mmcm_post_timing.rpt"