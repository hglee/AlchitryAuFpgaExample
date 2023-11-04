#!/bin/sh

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.1
fi

${XILINX_VITIS}/bin/xsct ./init_vitis.tcl

${XILINX_VITIS}/bin/vitis -workspace ./vitis_workspace
