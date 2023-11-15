#!/bin/sh

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.1
fi

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

# For Vivado 2023.2, you need to use classic mode or new style script.
${XILINX_VITIS}/bin/xsct ${SCRIPT_DIR}/init_vitis.tcl

${XILINX_VITIS}/bin/vitis -workspace ${SRC_DIR}/vitis_workspace
