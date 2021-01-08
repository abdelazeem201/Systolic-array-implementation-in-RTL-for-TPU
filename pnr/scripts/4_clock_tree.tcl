source setup.tcl
set power_cg_auto_identify true
source -echo ../pre_layout/design_data/add_tie.tcl
identify_clock_gating
set_clock_tree_options -max_transition 0.500 -max_capacitance 600.000 -max_fanout 2000 -max_rc_scale_factor 0.000 -target_early_delay 0.000 -target_skew 0.000 -buffer_relocation TRUE -gate_sizing FALSE -buffer_sizing TRUE -gate_relocation TRUE -layer_list {M1 M2 M3 M4 M5 M6 M7 M8 M9 } -logic_level_balance FALSE -insert_boundary_cell FALSE -ocv_clustering FALSE -ocv_path_sharing FALSE -operating_condition max
set_fix_hold [all_clocks]
clock_opt -fix_hold_all_clocks -no_clock_route
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}

report_timing

report_timing -delay_type min

save_mw_cel CHIP
save_mw_cel -as 4_cts
