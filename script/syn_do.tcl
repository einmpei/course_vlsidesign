set REPORTS_PATH ./reports
set OUTPUTS_PATH ./output
set SYN_EFF high
set MAP_EFF high

elaborate
########################################
##Synthesize the design to generic gates
########################################
synthesize -to_generic -eff ${SYN_EFF}
puts "Runtime & Memory after 'synthesize -to_generic'"
timestat GENERIC
report datapath > ${REPORTS_PATH}/${DESIGN}_datapath_generic.rpt
##Synthesizing to gates

########################################
#Synthesize to gate level netlist with the given
#technology library (without optimization)
########################################
synthesize -to_mapped -eff ${MAP_EFF} -no_incr
puts "Runtime & Memory after 'synthesize -to_map -no_incr'"
timestat MAPPED
report datapath > ${REPORTS_PATH}/${DESIGN}_datapath_map.rpt
##intermediate netlist for LEC verification
write_hdl -lec > ${OUTPUTS_PATH}/${DESIGN}_intermediate.v
write_do_lec -revised_design ${OUTPUTS_PATH}/${DESIGN}_intermediate.v > ./wlec_rtltog1_dofile
##ungroup -threshold <value>

########################################
#Incremental synthesis
########################################
#Synthesize to gate level netlist with the given
#technology library (with optimization)
synthesize -to_mapped -eff ${MAP_EFF} -incr
puts "Runtime & Memory after incremental synthesis"
timestat INCREMENTAL
write_design -basename ${OUTPUTS_PATH}/${DESIGN}_m
write_sdc > ${OUTPUTS_PATH}/${DESIGN}_m.sdc

########################################
#write_do_lec
########################################
#This 'do' file will be used to compare
#intermediate to final optimized netlist
########################################
write_do_lec -golden_design ${OUTPUTS_PATH}/${DESIGN}_intermediate.v -revised_design ${OUTPUTS_PATH}/${DESIGN}_m.v > ./wlec_g1tog2_dofile
report qor
