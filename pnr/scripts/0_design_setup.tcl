source setup.tcl

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


read_sdc  -version Latest "../pre_layout/design_data/CHIP_syn.sdc"

set_tlu_plus_files -max_tluplus /usr/cadtool/cad/synopsys/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmax.tluplus -min_tluplus /usr/cadtool/cad/synopsys/SAED32_EDK/tech/star_rcxt/saed32nm_1p9m_Cmin.tluplus -tech2itf_map  /usr/cadtool/cad/synopsys/SAED32_EDK/tech/star_rcxt/saed32nm_tf_itf_tluplus.map

derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS} -create_ports top

save_mw_cel CHIP
save_mw_cel -as 0_design_setup