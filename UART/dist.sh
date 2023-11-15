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

# For Vivado 2023.2, you need to use classic mode or new style script.
${XILINX_VITIS}/bin/xsct ./dist_vitis.tcl

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist2.tcl

cp ./build_workspace/test_uart/Release/test_uart.elf ./bin/
cp ./build/mcs_top.xsa ./bin/
cp ./build/au_sample_uart.runs/impl_1/mcs_top.bin ./bin/
