#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/init.tcl
