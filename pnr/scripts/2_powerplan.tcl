source setup.tcl
set power_cg_auto_identify true

set_fp_rail_constraints -add_layer  -layer M4 -direction horizontal -max_strap 1 -min_strap 1 -max_width 2 -min_width 2 -spacing minimum
set_fp_rail_constraints -add_layer  -layer M5 -direction vertical -max_strap 4 -min_strap 2 -max_width 2 -min_width 2 -spacing minimum
set_fp_rail_constraints  -set_ring -nets  {VDD VSS}  -horizontal_ring_layer { M4 } -vertical_ring_layer { M5 } -ring_width 4 -ring_offset 1 -extend_strap core_ring

synthesize_fp_rail  -nets {VDD VSS} -voltage_supply 1.05 -synthesize_power_plan -synthesize_power_pads -analyze_power -power_budget 10 -use_strap_ends_as_pads -create_virtual_rail M1
commit_fp_rail


set_pnet_options -complete "M4 M5"
create_fp_placement -incremental all
preroute_standard_cells -extend_for_multiple_connections  -extension_gap 20 -connect horizontal  -remove_floating_pieces  -do_not_route_over_macros  -fill_empty_rows  -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}

save_mw_cel CHIP
save_mw_cel -as 2_powerplan