#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.1
fi

rm -rf ./_build
rm -rf ./_build_workspace

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/dist.tcl

# For Vivado 2023.2, you need to use classic mode or new style script.
${XILINX_VITIS}/bin/xsct ${SCRIPT_DIR}/dist_vitis.tcl

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/dist2.tcl

cp ${SRC_DIR}/_build_workspace/test_uart/Release/test_uart.elf ${SRC_DIR}/bin/
cp ${SRC_DIR}/_build/mcs_top.xsa ${SRC_DIR}/bin/
cp ${SRC_DIR}/_build/au_sample_uart.runs/impl_1/mcs_top.bin ${SRC_DIR}/bin/
