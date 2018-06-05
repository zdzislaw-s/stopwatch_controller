#
# This script recreates Vivado project, so it is possible to generate hardware
# related artefacts. Once this is done, the script hands over to another script,
# that is building software and deploying the application to ZedBoard.
#

# Recreate project
source ./recreate-project.tcl

set proj_name $_xil_proj_name_

# Synthesize project
launch_runs -jobs 4 synth_1
wait_on_run synth_1

# Implement project
launch_runs impl_1 -jobs 4 -to_step write_bitstream
wait_on_run impl_1

# Export project to SDK
set impl1_dir $origin_dir/$proj_name/$proj_name.runs/impl_1
set bit_filename [lindex [glob -dir $impl1_dir *.bit] 0]
set bit_filename_only [lindex [split $bit_filename /] end]
set top_module_name [lindex [split $bit_filename_only .] 0]
set sdk_dir $origin_dir/$proj_name/$proj_name.sdk

file mkdir $sdk_dir

set hdf_filename $sdk_dir/$top_module_name.hdf
write_sysdef \
  -force \
  -hwdef $impl1_dir/$top_module_name.hwdef \
  -bitfile $impl1_dir/$top_module_name.bit \
  -meminfo $impl1_dir/$top_module_name.mmi \
  $hdf_filename

exec xsct build-and-run-ps-bare-metal.tcl \
  $proj_name \
  ${top_module_name}_hw_platform_0 \
  $sdk_dir \
  $hdf_filename
