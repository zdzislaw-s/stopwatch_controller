#! /bin/sh
#
# This script bootstraps the process of building hardware, building software
# and deploying the results to ZedBoard.
#
# There are two major tools involved in the process - vivado, which is executed
# in a batch mode (hardware part), and XSCT which builds the software (bare
# metal) and deploys it the board.
#

vivado -nojournal -nolog -mode batch -source build-pl.tcl
