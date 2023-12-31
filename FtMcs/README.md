# FtMcs

Receives start command from PC and generate data to PC.

Using Microblaze MCS, it receives commands from FT600, generates data, and transmits it to FT600.

You can use the client application to send commands and check received data.

Using the client application, you can send commands and check the received data on the chart.

## Target
### Software

* Xilinx Vivado 2023.1, 2023.2
* Xilinx Vitis 2023.1, 2023.2

### Hardware

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## Create Vivado Project and Build

You can create project using [init.sh](script/init.sh) script.

See [UART](../UART/README.md) for detailed initial Vivado MCS setting.

## Create Vitis Project and Build

You can create project using [init_vitis.sh](script/init_vitis.sh) script.

See [UART](../UART/README.md) for detailed initial Vitis MCS setting.

## Upload

Same as [FtBasicWrite](../FtBasicWrite/README.md)

## Test

You can use 'McsChartApp' program in [FtClientDotNet](../FtClientDotNet/README.md#mcs-chart-app) to test.
