# Software Stopwatch
This repository includes artefacts that I created in the course of doing tutorials 1 to 15 from https://www.beyond-circuits.com/wordpress/tutorial/

## Overview
The instructions below describe artefacts that are present in this repository and process of building and deploying the resultant application to ZedBoard. The instructions were created with the following in mind:
Hardware:
    - ZedBoard Rev. D
    - PmodSSD (https://reference.digilentinc.com/reference/pmod/pmodssd/start).
    - PmodENC (https://reference.digilentinc.com/reference/pmod/pmodenc/start).
Software:
    - Ubuntu 16.04 LTS
    - Vivado 2018.1

## Layout
The layout of the repository is as follows:
pl/ - artefacts relevant to the Programmable Logic. Of the most importance are:
    pl/ip_repo/src/debounce.v - logic for cancelling the button bounce effect.
    pl/ip_repo/src/ssd.v - logic for driving PmodSSD.
    pl/ip_repo/src/encoder.v - logic for driving PmodENC.
    pl/ip_repo/hdl/stopwatch_controller_v1_0_S00_AXI.v - interfacing with other IPs via AXI4 Lite.
    pl/ip_repo/hdl/stopwatch_controller_v1_0.v - module that maintains instances of ssd, encoder, debounce and stopwatch_controller_v1_0_S00_AXI.
    The above source files are packaged into a single IP core, i.e. stopwatch_controller.

    pl/src/verilog/stopwatch_system_wrapper.v - Verilog module where system from stopwatch_system.pdf is specified.
    pl/src/constraints/stopwatch.tcl - Tcl file with unmanaged constraints.

ps/ - artefacts relevant to the Processing System - there is only one file there:
    ps/stopwatch.c - C code that is executed by the Processing System.

README.md - this file.
recreate-project.tcl - Tcl script for creating Vivado project.
stopwatch_system.pdf - block diagram of the system.
stopwatch_system.3gp - video clip where the running system is presented.

## Building and Executing
1. In terminal, go to some working folder (./), which should be empty at this point.
1. Execute:
    $ vivado -mode batch -source <path-to-recreate-project.tcl> -tclargs --origin_dir <your-origin_dir>
    for testing this instructions, I used:
    $ vivado -mode batch -source ../../projects-vcs/stopwatch_controller/recreate-project.tcl -tclargs --origin_dir "../.."

    If successful, you should see the following message from that execution:
    "INFO: Project created:stopwatch_controller"

1. Open the created Vivado project (./stopwatch_controller/stopwatch_controller.xpr) in Vivado with "File > Project > Open"
1. In the "Flow Navigator" panel find and select "Generate Bitstream".
1. After the generation completes select "File > Export > Export Hardware..."
    make sure that the check box "Include bitstream" is selected.
1. Launch SDK with "File > Launch SDK"
1. Within the SDK/Eclipse go to "File > New > Application Project", for project name select "stopwatch-controller", and make the project "Empty Application"
1. Back in the terminal change your working directory as follows:
    $ cd ./stopwatch_controller/stopwatch_controller.sdk/stopwatch-controller/src
    and create a soft link to projects-vcs/stopwatch_controller/ps/stopwatch.c there - for example:
    $ ln -s ../../../../../../projects-vcs/stopwatch_controller/ps/stopwatch.c
1. Switch back to SDK/Eclipse and refresh the "Project Explorer" view.
1. Build the application with "Project > Build All"
1. Once build completes, program your FPGA with stopwatch_system_wrapper.bit by means "Xilix > Program FPGA"
    The blue LED Done should light up.
1. Run the stopwatch-controller project with "Run > Run > Launch on Hardware (GDB)"
