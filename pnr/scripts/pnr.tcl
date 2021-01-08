##############################################
########### 1. DESIGN SETUP ##################
##############################################

set design tpu_top
set clk clk

sh rm -rf $design

set sc_dir "/home/standard_cell_libraries/NangateOpenCellLibrary_PDKv1_3_v2010_12"

set_app_var search_path "/home/standard_cell_libraries/NangateOpenCellLibrary_PDKv1_3_v2010_12/lib/Front_End/Liberty/NLDM \
			 /home/mohamed/Desktop/johnson/rtl"

set_app_var link_library "* NangateOpenCellLibrary_ss0p95vn40c.db"
set_app_var target_library "NangateOpenCellLibrary_ss0p95vn40c.db"


create_mw_lib   ./${design} \
                -technology $sc_dir/tech/techfile/milkyway/FreePDK45_10m.tf \
		        -mw_reference_library $sc_dir/lib/Back_End/mdb \
		        -open

set tlupmax "$sc_dir/tech/rcxt/FreePDK45_10m_Cmax.tlup"
set tlupmin "$sc_dir/tech/rcxt/FreePDK45_10m_Cmin.tlup"
set tech2itf "$sc_dir/tech/rcxt/FreePDK45_10m.map"

set_tlu_plus_files -max_tluplus $tlupmax \
                   -min_tluplus $tlupmin \
     		       -tech2itf_map $tech2itf


import_designs  ../syn/output/${design}.v \
                -format verilog \
		        -top ${design} \
		        -cel ${design}


source  ../syn/cons/cons.tcl

save_mw_cel -as ${design}_1_imported

##############################################
########### 2. Floorplan #####################
##############################################

## Create Starting Floorplan
############################
create_floorplan -core_utilization 0.6 \
	-start_first_row -flip_first_row \
	-left_io2core 12.4 -bottom_io2core 12.4 -right_io2core 12.4 -top_io2core 12.4


## CONSTRAINTS
##############
## Here, We define more constraints on your design that are related to floorplan stage.
#report_ignored_layers
#remove_ignored_layers -all
#set_ignored_layers -max_routing_layer metal6

## Initial Virtual Flat Placement
#################################
## Use the following command with any of its options to meet a specific target
#    create_fp_placement -timing -no_hierarchy_gravity -congestion 

create_fp_placement

##AH## ## To show design-specific blocks
##AH## gui_set_highlight_options -current_color yellow
##AH## change_selection [get_cells   alu_unit/*]

##AH## gui_set_highlight_options -current_color blue
##AH## change_selection [get_cells   ALU_Control_unit/*]

##AH## gui_set_highlight_options -current_color green
##AH## change_selection [get_cells   datamem/*]

##AH## gui_set_highlight_options -current_color orange
##AH## change_selection [get_cells   reg_file/*]

## ASSESSMENT
#############
## Analyze Congestion
# route_fp_proto -congestion_map_only -effort medium    
# View Congestion map : In GUI, Route > Global Route Congestion Map.

## Analyze Timing
# extract_rc; # Improves accuracy of timing after updated GR.

#report_timing -nosplit; # For Worst Setup violation report
#report_timing -nosplit -delay_type min; # For Worst Hold violation report

#report_constraint -all_violators -nosplit -max_delay; # For all Setup violation report
#report_constraint -all_violators -nosplit -min_delay; # For all Hold violations report

##Based on your assessment, you may need to do any of the following fixes

## FIXES
########
## You can use one or all of the follwoing based on your need.
#   set_fp_placement_strategy -virtual_IPO on 
#
#   create_bounds -name "temp" -coordinate {55 0 270 270} datamem
#   create_bounds -name "temp1" -coordinate {0 0 104 270} reg_file
#
#   set_congestion_options -max_util 0.4 -coordinate {x1 y1 x2 y2}; # if cell density is causing congestion.
#
#   create_placement_blockage -name PB -type hard -bbox {x1 y1 x2 y2}
#
#   set_fp_placement_strategy -congestion_effort high
#
## Then you need to re-run create_fp_placement
#   create_fp_placement -incremental; 
## Note:  use -incremental option if you want to refine the current virtual placement. Don't use it if you want to re-place the design from scratch 

## If there still congestion, change ignored layers, if it is still there, increase floorplan area.

save_mw_cel -as ${design}_2_fp


##################################################
########### 3. POWER NETWORK #####################
##################################################

## Defining Logical POWER/GROUND Connections
############################################
derive_pg_connection 	 -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	


## Define Power Ring 
####################
set_fp_rail_constraints  -set_ring -nets  {VDD VSS}  \
                         -horizontal_ring_layer { metal7 metal9 } \
                         -vertical_ring_layer { metal8 metal10 } \
			 -ring_spacing 1 \
			 -ring_width 4 \
			 -ring_offset 1 \
			 -extend_strap core_ring

## Define Power Mesh 
####################
set_fp_rail_constraints -add_layer  -layer metal10 -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer metal9  -direction horizontal -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer metal8  -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer metal7  -direction horizontal -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum
set_fp_rail_constraints -add_layer  -layer metal6  -direction vertical   -max_strap 128 -min_strap 20 -min_width 2.5 -spacing minimum

#set_fp_rail_constraints -add_layer  -layer metal10 -direction vertical   -max_pitch 12 -min_pitch 12 -min_width 5 -spacing minimum
#set_fp_rail_constraints -add_layer  -layer metal9  -direction horizontal -max_pitch 12 -min_pitch 12 -min_width 5 -spacing minimum
#set_fp_rail_constraints -add_layer  -layer metal8  -direction vertical   -max_pitch 12 -min_pitch 12 -min_width 5 -spacing minimum
#set_fp_rail_constraints -add_layer  -layer metal7  -direction horizontal -max_pitch 12 -min_pitch 12 -min_width 5 -spacing minimum
#set_fp_rail_constraints -add_layer  -layer metal6  -direction vertical   -max_pitch 12 -min_pitch 12 -min_width 5 -spacing minimum


set_fp_rail_constraints -set_global

## Creating virtual PG pads
###########################
# you can create them with gui. Preroute > Create Virtual Power Pad
set die_llx [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 0]
set die_lly [lindex [lindex [ get_attribute [get_die_area] bbox] 0] 1]
set die_urx [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 0]
set die_ury [lindex [lindex [ get_attribute [get_die_area] bbox] 1] 1]

for {set i "[expr $die_llx + 20]"} {$i < "[expr $die_urx - 40]"} {set i [expr $i + 80]} {
	create_fp_virtual_pad -net VSS -point "{$i $die_lly}"
	create_fp_virtual_pad -net VDD -point "{[expr $i + 40] $die_lly}"

	create_fp_virtual_pad -net VSS -point "{$i $die_ury}"
	create_fp_virtual_pad -net VDD -point "{[expr $i + 40] $die_ury}"
}

for {set i "[expr $die_lly + 20]"} {$i < "[expr $die_ury - 40]"} {set i [expr $i + 80]} {
	create_fp_virtual_pad -net VSS -point "{$die_llx $i}"
	create_fp_virtual_pad -net VDD -point "{$die_llx [expr $i + 40]}"

	create_fp_virtual_pad -net VSS -point "{$die_urx $i}"
	create_fp_virtual_pad -net VDD -point "{$die_urx [expr $i + 40] }"
}




synthesize_fp_rail  -nets {VDD VSS} -synthesize_power_plan -target_voltage_drop 22 -voltage_supply 1.1 -power_budget 500
## Analyze IR-drop; Modify power network constraints and re-synthesize, as needed.
## Max IR is 2% of Nominal Supply. In our case, 0.02 x 1.1v= 22mv

commit_fp_rail

set_preroute_drc_strategy -max_layer metal6
preroute_standard_cells -fill_empty_rows -remove_floating_pieces

## If you want to remove power and recreate it
#remove_net_shape  [get_net_shapes -of_objects [get_nets -all "VSS VDD"]]
#remove_via  [get_vias -of_objects [get_nets -all "VSS VDD"]]
## MAy need => remove_fp_virtual_pad -all

## Analyze IR-drop; Modify power network constraints and re-synthesize, as needed.
analyze_fp_rail  -nets {VDD VSS} -power_budget 500 -voltage_supply 1.1


## Final Floorplan Assessment
#create_fp_placement -incremental all; # Updates fp placement after PG mesh creation.
#### Analyze Congestion
#### Analyze Timing


## Add Well Tie Cells
#####################
add_tap_cell_array -master   TAP \
     		   -distance 30 \
     		   -pattern  stagger_every_other_row

save_mw_cel -as ${design}_3_power

##############################################
########### 4. Placement #####################
##############################################
puts "start_place"

## CHECKS
#########
report_ignored_layers ; # To Make sure they are as wanted.
check_physical_design -stage pre_place_opt
check_physical_constraints

## CONSTRAINTS 
##############
## Here, We define more constraints on your design that are related to placement stage.

#### Scenario Creation ####create_scenario pw
#### Scenario Creation ####set_operating_conditions worst_low
#### Scenario Creation ####set_tlu_plus_files -max_tluplus $tlupmax \
#### Scenario Creation ####                   -min_tluplus $tlupmin \
#### Scenario Creation ####     		   -tech2itf_map $tech2itf
#### Scenario Creation ####
#### Scenario Creation ####set_scenario_options -leakage_power true; #If we need to optimize leakage power, more effective for multi-Vth designs.
#### Scenario Creation ####set power_default_toggle_rate 0.003
#### Scenario Creation ####set_scenario_options -dynamic_power true
#### Scenario Creation ####
#### Scenario Creation ####source  ../syn/cons/cons.tcl
#### Scenario Creation ####set_propagated_clock [get_clocks $clk]
#### Scenario Creation ####
#### Scenario Creation ####set_optimize_pre_cts_power_options -low_power_placement true
#### Scenario Creation ####
#### Scenario Creation ####report_scenario_options


## INITIAL PLACEMENT
####################
## Initial Placement can be done using the following command using any of its target options 
#place_opt -area_recovery |-power |-congestion|
place_opt

## ASSESSMENT
#############
## Open Congestion Map. == > If congested, improve congestion similar to floorplanning.
## Report Timing 

## FIXES
########
# For seriuos congestion issue use the following commands:
#   set placer_enable_enhanced_router TRUE; # enabling the actual GR instead of GR estimator. Increased run time!
#   refine_placement ==> Optimizes congestion only

# If there are violating timing paths, apply optimization -focus- as needed: 
#   report_path_group
#   group_path -name $clk -critical_range 1 -weight 5


## OPTIMIZATION
###############
# psynopt -area_recovery |-power| |-congestion| 
psynopt

#The  psynopt  command  performs incremental preroute or postroute opti-
#mization on the current design. Performs incremental timing-driven  (setup timing, by default) logic optimization with placement legalization.
# It considers other targets using different options
# ex : psynopt -no_design_rule | -only_design_rule | -size_only ==> Used for Focused placment optimization

## FINAL ASSESSMENT
###################

check_legality
## If no legalized cells => legalize_placement -effort high -incremental 
# Check Congestion
# Check Timing 
# report_design_physical -utilization

# DEFINING POWER/GROUND NETS AND PINS			 
derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	

## Tie fixed values
set tie_pins [get_pins -all -filter "constant_value == 0 || constant_value == 1 && name !~ V* && is_hierarchical == false "]

derive_pg_connection 	 -power_net VDD		\
			 -ground_net VSS	\
			 -tie


connect_tie_cells -objects $tie_pins \
                  -obj_type port_inst \
		  -tie_low_lib_cell  LOGIC0_X1 \
		  -tie_high_lib_cell LOGIC1_X1





puts "finish_place"

save_mw_cel -as ${design}_4_placed

##############################################
########### 5. CTS       #####################
##############################################

puts "start_cts"

## CHECKS
#########
check_physical_design -stage pre_clock_opt 
check_clock_tree 
report_clock_tree


## CONSTRAINTS 
##############
## Here, We define more constraints on your design that are related to CTS stage.

set_driving_cell -lib_cell BUF_X16 -pin Z [get_ports $clk]
###OR
# set_input_transition -rise 0.3 [get_ports $clk]
# set_input_transition -fall 0.2 [get_ports $clk]


#### Set Clock Exceptions


### Set Clock Control/Targets
set_clock_tree_options \
                -clock_trees $clk \
		-target_early_delay 0.1 \
		-target_skew 0.5 \
		-max_capacitance 300 \
		-max_fanout 10 \
		-max_transition 0.150

set_clock_tree_options -clock_trees $clk \
		-buffer_relocation true \
		-buffer_sizing true \
		-gate_relocation true \
		-gate_sizing true 

## Selection of CTS cells
set_clock_tree_references -references [get_lib_cells */CLKBUF*] 
#set_clock_tree_references -references [get_lib_cells */BUF*] 
#set_clock_tree_references -references [get_lib_cells */INV*] 

## Selection of CTO cells
#set_clock_tree_references -sizing_only -references "BEST_PRACTICE_buffers_for_CTS_CTO_sizing"
#set_clock_tree_references -delay_insertion_only -references "BEST_PRACTICE_cels_for_CTS_CTO_delay_insertion" 



### Set Clock Physical Constraints
## Clock Non-Default Ruls (NDR) - Set it to be double width and double spacing 
define_routing_rule my_route_rule  \
  -widths   {metal3 0.14 metal4 0.28 metal5 0.28} \
  -spacings {metal3 0.14 metal4 0.28 metal5 0.28} 

set_clock_tree_options -clock_trees $clk \
                       -routing_rule my_route_rule  \
		       -layer_list "metal3 metal4 metal5"

## To avoid NDR at clock sinks
set_clock_tree_options -use_default_routing_for_sinks 1

report_clock_tree -settings


## Clock Tree : Synhtesis, Optimization, and Routing
####################################################
## The 3 steps can be done with the combo command clock_opt. But below, we do them individually.

## 1- CTS 
clock_opt -only_cts -no_clock_route
## analyze
    report_design_physical -utilization
    report_clock_tree -summary ; # reports for the clock tree, regardless of relation between FFs
    report_clock_tree
    report_clock_timing -type summary ; # reports for the clock tree, considering relation between FFs
    report_timing
    report_timing -delay_type min
    report_constraints -all_violators -max_delay -min_delay
    # Check Congestion
    # Check Timing


## 2- CTO
## To Consider Hold Fix -- Design Dependent
   set_fix_hold [all_clocks]
   set_fix_hold_options -prioritize_tns
set_propagated_clock [all_clocks]
clock_opt -only_psyn -no_clock_route
#analyze


## 3- Clock Tree Routing
route_group -all_clock_nets
#analyze


## If any issue at analysis, update CT constraints 
##################################################

# DEFINING POWER/GROUND NETS AND PINS			 
derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	
			 
save_mw_cel -as ${design}_5_cts

puts "finish_cts"

##############################################
########### 6. Routing   #####################
##############################################

## Before starting to route, you should add spare cells
insert_spare_cells -lib_cell {NOR2_X4 NAND2_X4} \
		   -num_instances 20 \
		   -cell_name SPARE_PREFIX_NAME \
		   -tie

set_dont_touch  [all_spare_cells] true
set_attribute [all_spare_cells]  is_soft_fixed true

##############################################

puts "start_route"

check_physical_design -stage pre_route_opt; # dump check_physical_design result to file ./cpd_pre_route_opt_*/index.html
all_ideal_nets
all_high_fanout -nets -threshold 100
check_routeability


set_delay_calculation_options -arnoldi_effort low

#Defines the delay model used to compute a timing arc delay value for a cell or net
#set_delay_calculation_options -preroute     elmore | awe (Asymptotic Waveform Evaluation)
#                              -routed_clock elmore | arnoldi
#			       -postroute    elmore | arnoldi
#			       -awe_effort     low | medium | high
#			       -arnoldi_effort low | medium | high
			      

set_route_options -groute_timing_driven true \
	          -groute_incremental true \
	          -track_assign_timing_driven true \
	          -same_net_notch check_and_fix 

set_si_options -route_xtalk_prevention true\
	       -delta_delay true \
	       -min_delta_delay true \
	       -static_noise true\
	       -timing_window true 


## route_opt : global, track, and detail routing, S&R, logic and placement optimizations with ECO routing
##             End goal: Design that meets timing, crosstalk and route DRC rules

#route_opt -effort high \
#	  -stage track        : which stage to run optimization after
#	  -xtalk_reduction    : to reduce crosstalk in routing 
#	  -incremental        : to improve results of a routed design.
#	  -initial_route_only : This is to avoid full routing and post-routing optimizations. Only do the basic steps.

## To Consider Hold Fix
#   set_fix_hold_options -prioritize_tns
   set_fix_hold [all_clocks]
   set_prefer -min  [get_lib_cells "*/BUF_X2 */BUF_X1"]
   set_fix_hold_options -preferred_buffer

set_propagated_clock [all_clocks]
route_opt

psynopt  -only_hold_time -congestion
route_zrt_eco -open_net_driven true
verify_zrt_route
route_zrt_detail -incremental true -initial_drc_from_input true
#route_opt -effort high -stage track -xtalk_reduction

derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	




#report_noise
#report_timing -crosstalk_delta


save_mw_cel -as ${design}_6_routed

puts "finish_route"

##############################################
########### 7. Finishing #####################
##############################################


insert_stdcell_filler -cell_without_metal {FILLCELL_X32 FILLCELL_X16 FILLCELL_X8 FILLCELL_X4 FILLCELL_X2 FILLCELL_X1} \
	-connect_to_power VDD -connect_to_ground VSS

insert_zrt_redundant_vias 

derive_pg_connection     -power_net VDD		\
			 -ground_net VSS	\
			 -power_pin VDD		\
			 -ground_pin VSS	

save_mw_cel -as ${design}_7_finished

save_mw_cel -as ${design}

##############################################
########### 8. Checks and Outputs ############
##############################################

verify_zrt_route
verify_lvs -ignore_floating_port -ignore_floating_net \
           -check_open_locator -check_short_locator

set_write_stream_options -map_layer $sc_dir/tech/strmout/FreePDK45_10m_gdsout.map \
                         -output_filling fill \
			 -child_depth 20 \
			 -output_outdated_fill  \
			 -output_pin  {text geometry}

write_stream -lib $design \
                  -format gds\
		  -cells $design\
		  ./output/${design}.gds



define_name_rules  no_case -case_insensitive
change_names -rule no_case -hierarchy
change_names -rule verilog -hierarchy
set verilogout_no_tri	 true
set verilogout_equation  false


write_verilog -pg -no_physical_only_cells ./output/${design}_icc.v
write_verilog -no_physical_only_cells ./output/${design}_icc_nopg.v

extract_rc
write_parasitics -output ./output/${design}.spef


close_mw_cel
close_mw_lib

exit
