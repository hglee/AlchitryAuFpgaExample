#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.1
fi

rm -rf ./build
rm -rf ./build_workspace

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist.tcl

${XILINX_VITIS}/bin/xsct ./dist_vitis.tcl

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist2.tcl

cp ./build/au_sample_uart.runs/impl_1/mcs_top.bin .
