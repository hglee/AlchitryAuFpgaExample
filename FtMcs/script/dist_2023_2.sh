#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.2
fi

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.2
fi

rm -rf ./_build
rm -rf ./_build_workspace

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/dist.tcl

${XILINX_VITIS}/bin/vitis -s ${SCRIPT_DIR}/dist_vitis.py

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/dist2_2023_2.tcl

cp ${SRC_DIR}/_build_workspace/ft_mcs/build/ft_mcs.elf ${SRC_DIR}/bin/
cp ${SRC_DIR}/_build/mcs_top.xsa ${SRC_DIR}/bin/
cp ${SRC_DIR}/_build/ft_mcs.runs/impl_1/mcs_top.bin ${SRC_DIR}/bin/
