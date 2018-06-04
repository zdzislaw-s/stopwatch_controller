#! /bin/sh
#
# This script is just a bootstrap of the process of building hardware, building
# software and deploying the results to ZedBoard.
# There are two major tools involved in the process - vivado, which is executed
# in a batch mode (hardware part), and XSCT where software is built and
# the deployment takes place.
#

vivado -nojournal -nolog -mode batch -source build-hardware.tcl
