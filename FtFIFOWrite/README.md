# FtFIFOWrite

Generate 16 bit sequence number and transfer to PC using FIFO.

## Target
### Software

* Xilinx Vivado 2023.1

### Hardware

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## Create Project and Build

0. Create project using script.

You can create project using [init.sh](script/init.sh) script.

Edit install path (XILINX_VIVADO) in [init.sh](script/init.sh) then run if you want.

You can skip step 1 ~ 4 if you created project by script.

1. Create new RTL project in Vivado.

You need to select part 'xc7a35tftg256-1'.

<img src='../docs/part.png' alt='Parts' width='700'/>

2. Add constraint file to project.

Add alchitry.xdc in constraint directory to project.

3. Add source files to project.

Add all source files in hdl directory to project.

4. Set 'bin_file' option to implementation.

You need generate bin file to upload.

Right click on 'Implementation' and enable 'bin_file' in 'write_bitstream' section.

<img src='../docs/imple.png' alt='bin file option' width='700'/>

5. Generate Bitstream

After generate, you can find 'top.bin' file under project folder.

## Upload & Test

Same as [FtBasicWrite](../FtBasicWrite/README.md#test)
