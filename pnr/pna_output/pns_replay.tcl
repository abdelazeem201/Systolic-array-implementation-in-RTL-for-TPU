# reset
set_fp_rail_constraints -remove_all_layers
remove_fp_virtual_pad -all              
set_fp_rail_strategy -reset             
set_fp_block_ring_constraints -remove_all
set_fp_rail_region_constraints  -remove 
# global constraints
set_fp_rail_constraints -set_global 

# layer constraints
set_fp_rail_constraints -add_layer  -layer metal10 -direction vertical -max_strap 128 -min_strap 20 -max_width 5.000000 -min_width 2.500000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer metal9 -direction horizontal -max_strap 128 -min_strap 20 -max_width 5.000000 -min_width 2.500000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer metal8 -direction vertical -max_strap 128 -min_strap 20 -max_width 5.000000 -min_width 2.500000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer metal7 -direction horizontal -max_strap 128 -min_strap 20 -max_width 5.000000 -min_width 2.500000 -spacing minimum 
set_fp_rail_constraints -add_layer  -layer metal6 -direction vertical -max_strap 128 -min_strap 20 -max_width 5.000000 -min_width 2.500000 -spacing minimum 

# ring and strap constraints
set_fp_rail_constraints  -set_ring -nets { VDD VSS } -horizontal_ring_layer { metal7,metal9 } -vertical_ring_layer { metal8,metal10 } -ring_width 4.000000 -ring_spacing 1.000000 -ring_offset 1.000000 -extend_strap core_ring 

# strategies
set_fp_rail_strategy  -use_tluplus true 

# block ring constraints

# regions

# virtual pads
create_fp_virtual_pad -net VSS -point { 20.000000 0.000000 }
create_fp_virtual_pad -net VDD -point { 60.000000 0.000000 }
create_fp_virtual_pad -net VSS -point { 20.000000 392.600006 }
create_fp_virtual_pad -net VDD -point { 60.000000 392.600006 }
create_fp_virtual_pad -net VSS -point { 100.000000 0.000000 }
create_fp_virtual_pad -net VDD -point { 140.000000 0.000000 }
create_fp_virtual_pad -net VSS -point { 100.000000 392.600006 }
create_fp_virtual_pad -net VDD -point { 140.000000 392.600006 }
create_fp_virtual_pad -net VSS -point { 180.000000 0.000000 }
create_fp_virtual_pad -net VDD -point { 220.000000 0.000000 }
create_fp_virtual_pad -net VSS -point { 180.000000 392.600006 }
create_fp_virtual_pad -net VDD -point { 220.000000 392.600006 }
create_fp_virtual_pad -net VSS -point { 260.000000 0.000000 }
create_fp_virtual_pad -net VDD -point { 300.000000 0.000000 }
create_fp_virtual_pad -net VSS -point { 260.000000 392.600006 }
create_fp_virtual_pad -net VDD -point { 300.000000 392.600006 }
create_fp_virtual_pad -net VSS -point { 340.000000 0.000000 }
create_fp_virtual_pad -net VDD -point { 380.000000 0.000000 }
create_fp_virtual_pad -net VSS -point { 340.000000 392.600006 }
create_fp_virtual_pad -net VDD -point { 380.000000 392.600006 }
create_fp_virtual_pad -net VSS -point { 0.000000 20.000000 }
create_fp_virtual_pad -net VDD -point { 0.000000 60.000000 }
create_fp_virtual_pad -net VSS -point { 393.660004 20.000000 }
create_fp_virtual_pad -net VDD -point { 393.660004 60.000000 }
create_fp_virtual_pad -net VSS -point { 0.000000 100.000000 }
create_fp_virtual_pad -net VDD -point { 0.000000 140.000000 }
create_fp_virtual_pad -net VSS -point { 393.660004 100.000000 }
create_fp_virtual_pad -net VDD -point { 393.660004 140.000000 }
create_fp_virtual_pad -net VSS -point { 0.000000 180.000000 }
create_fp_virtual_pad -net VDD -point { 0.000000 220.000000 }
create_fp_virtual_pad -net VSS -point { 393.660004 180.000000 }
create_fp_virtual_pad -net VDD -point { 393.660004 220.000000 }
create_fp_virtual_pad -net VSS -point { 0.000000 260.000000 }
create_fp_virtual_pad -net VDD -point { 0.000000 300.000000 }
create_fp_virtual_pad -net VSS -point { 393.660004 260.000000 }
create_fp_virtual_pad -net VDD -point { 393.660004 300.000000 }
create_fp_virtual_pad -net VSS -point { 0.000000 340.000000 }
create_fp_virtual_pad -net VDD -point { 0.000000 380.000000 }
create_fp_virtual_pad -net VSS -point { 393.660004 340.000000 }
create_fp_virtual_pad -net VDD -point { 393.660004 380.000000 }

# synthesize_fp_rail 
synthesize_fp_rail -nets { VDD VSS } -voltage_supply 1.050000 -power_budget 10.000000  -target_voltage_drop 21.000000  
