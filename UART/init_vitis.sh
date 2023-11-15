#!/bin/sh

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.1
fi

# For Vivado 2023.2, you need to use classic mode or new style script.
${XILINX_VITIS}/bin/xsct ./init_vitis.tcl

${XILINX_VITIS}/bin/vitis -workspace ./vitis_workspace
