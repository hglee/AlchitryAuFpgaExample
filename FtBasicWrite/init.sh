#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./init.tcl
