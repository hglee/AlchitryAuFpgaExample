#!/bin/sh

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.2
fi

${XILINX_VITIS}/bin/vitis -s ./init_vitis.py

${XILINX_VITIS}/bin/vitis -w ./vitis_workspace
