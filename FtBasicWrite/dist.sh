#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

rm -rf ./build
rm -rf ./top.bin

${XILINX_VIVADO}/bin/vivado -mode tcl -source ./dist.tcl

cp ./build/au_ft_basic_write.runs/impl_1/top.bin .
