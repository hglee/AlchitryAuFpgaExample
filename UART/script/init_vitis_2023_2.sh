#!/bin/sh

if [ -z "$XILINX_VITIS" ]; then
    export XILINX_VITIS=/opt/Xilinx/Vitis/2023.2
fi

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

${XILINX_VITIS}/bin/vitis -s ${SCRIPT_DIR}/init_vitis.py

${XILINX_VITIS}/bin/vitis -w ${SRC_DIR}/vitis_workspace
