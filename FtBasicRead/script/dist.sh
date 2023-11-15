#!/bin/sh

if [ -z "$XILINX_VIVADO" ]; then
    export XILINX_VIVADO=/opt/Xilinx/Vivado/2023.1
fi

rm -rf ./_build

export SCRIPT_DIR=$(dirname -- "$0")
export SRC_DIR=$SCRIPT_DIR/..

${XILINX_VIVADO}/bin/vivado -mode tcl -source ${SCRIPT_DIR}/dist.tcl

cp ${SRC_DIR}/_build/au_ft_basic_read.runs/impl_1/top.bin ${SRC_DIR}/bin/
