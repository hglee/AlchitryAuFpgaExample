#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.2
fi

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.2
fi

rm -rf ./build
rm -rf ./build_workspace

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist.tcl

${XILINX_VITIS}/bin/vitis -s ./dist_vitis.py

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist2_2023_2.tcl

cp ./build_workspace/test_uart/build/test_uart.elf ./bin/
cp ./build/mcs_top.xsa ./bin/
cp ./build/au_sample_uart.runs/impl_1/mcs_top.bin ./bin/
