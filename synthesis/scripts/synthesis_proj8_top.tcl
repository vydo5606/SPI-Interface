#############################
set DESIGN "proj8_top"
#############################

set_db init_lib_search_path { /apps/design_kits/ibm_kits/IBM_IP/ibm_cmos8hp/std_cell/sc/v.20110613/synopsys/ss_125/ ../../macros/gf180mcu_fd_ip_sram__sram64x8m8wm1 }
set_db library { IBM_CMOS8HP_SS125.lib gf180mcu_fd_ip_sram__sram64x8m8wm1__ss_125C_1v62.lib }

set_db init_hdl_search_path ../../source

read_hdl {reset_sync.v reset_sequencer.v SPI_interface.v spi_mem_cdc.v memory_controller.v sram_test.v proj8_top.v}

elaborate ${DESIGN}
source ../constraints/constraints_${DESIGN}.tcl

uniquify ${DESIGN} -verbose
check_design

set_db syn_generic_effort medium
set_db syn_map_effort medium

syn_generic
syn_map

report_timing -max_paths 10 > ../reports/${DESIGN}_timing.rpt
report_gates > ../reports/${DESIGN}_gates.rpt
report_area > ../reports/${DESIGN}_area.rpt
report_power > ../reports/${DESIGN}_power.rpt
report_design > ../reports/${DESIGN}_const.rpt

write_hdl > ../netlists/${DESIGN}.v
write_sdc > ../netlists/${DESIGN}.sdc
write_sdf > ../netlists/${DESIGN}.sdf

echo "Synthesis Complete"
