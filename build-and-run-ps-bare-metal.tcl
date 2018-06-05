#
# This scrip consists of two stages:
# Stage 1. is the build of .elf file that is used to program PS,
# stage 2. is to program the FPGA, program PS and start the execution.
#

set proj_name [lindex $::argv 0]
set hw_project_name [lindex $::argv 1]
set sdk_ws_dir [lindex $::argv 2]
set hdf_filename [lindex $::argv 3]

### Stage 1.
# Create an SDK workspace.
if {[file exists $sdk_ws_dir] == 0} {
    file mkdir $sdk_ws_dir
}
setws $sdk_ws_dir

# Create a hardware project in an SDK workspace.
if {[file exists $hw_project_name] == 0} {
    createhw -name $hw_project_name -hwspec $hdf_filename
}

proc get_processor_name {hw_project_name} {
    set periphs [getperipherals $hw_project_name]

    # For each line of the peripherals table.
    foreach line [split $periphs "\n"] {
        set values [regexp -all -inline {\S+} $line]

        # If the last column is "PROCESSOR", then get the "IP INSTANCE" name (1st col)
        if {[lindex $values end] == "PROCESSOR"} {
            return [lindex $values 0]
        }
    }
    return ""
}

# Generate the "Empty Application".
createapp \
  -name $proj_name \
  -app "Empty Application" \
  -proc [get_processor_name $hw_project_name] \
  -hwproject $hw_project_name \
  -os standalone

# Create a link to versioned source files.
file link -symbolic $sdk_ws_dir/$proj_name/src/stopwatch.c ../../../../ps/stopwatch.c

# Build all the projects.
configapp -app $proj_name -add define-compiler-symbols {IS_BARE_METAL=1}
projects -build -type all

### Stage 2.
# Connect to a remote hw_server
connect -host localhost -port 3121

# Program FPGA.
fpga $sdk_ws_dir/$hw_project_name/stopwatch_system_wrapper.bit

# PS7 initialization.
source $sdk_ws_dir/$hw_project_name/ps7_init.tcl

# Select a target
targets -set -filter {name =~ "ARM*#0"}

# Load a Vivado HW design.
loadhw -hw $sdk_ws_dir/$hw_project_name/system.hdf -mem-ranges [list {0x40000000 0xbfffffff}]

# Disable access protection for dow, mrd, and mwr commands.
configparams force-mem-access 1

# Stop active target.
stop

ps7_init
ps7_post_config

# Download ELF and binary file to target.
dow $sdk_ws_dir/$proj_name/Debug/$proj_name.elf

# Enable access protection for dow, mrd, and mwr commands.
configparams force-mem-access 0

# Resume active target.
con
