# Setting Timing Constraints
###  ceate your clock here

create_clock -name clk -period 3.01 [get_ports clk]

###  set clock constrain

set_ideal_network       [get_ports clk]
set_dont_touch_network  [all_clocks]

# I/O delay should depend on the real enironment. Here only shows an example of setting

set_input_delay -max 1.505 -clock [get_clocks clk] [remove_from_collection [all_inputs] [get_ports clk]]
set_output_delay -max 1.505 -clock [get_clocks clk] [all_outputs]

set_clock_uncertainty 0.20 [get_clocks]
set_false_path -hold -from [remove_from_collection [all_inputs] [get_ports clk]]
set_false_path -hold -to [all_outputs]

# Setting wireload model

set auto_wire_load_selection area_reselect
set_wire_load_mode enclosed
set_wire_load_selection_group predcaps

# Setting DRC Constraint
# Defensive setting: smallest fanout_load 0.041 and WLM max fanout # 20 => 0.041*20 = 0.82
# max_transition and max_capacitance are given in the cell library

set_max_fanout 1.64 $design

# Area Constraint
set_max_area   0

set_fix_hold [get_clocks clk]
