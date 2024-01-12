# FtBasicRead

Receives data from PC.

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

## Upload

Same as [FtBasicWrite](../FtBasicWrite/README.md#upload)

## Test

You can use 'TestWrite' program in [FtClient](../FtClient/README.md#write-test) to test.

If you want to use FTDI example, follow belows.

1. Prepare sample program

You can use D3XX sample program in FTDI homepage: https://ftdichip.com/drivers/d3xx-drivers/

Download Linux Driver (libftd3xx-linux-x86_64-xxx.tgz) and build sample program.

If you want to build with static library, edit top line in Makefile like this:

```
LIBS = -L . -lftd3xx-static -lstdc++
```

2. Run sample program

Connect **another USB cable to Ft module** and run sample program, streamer.

```
sudo ./streamer 1 0 0
```

You can see TX transfer rate if it works properly like this (on ThinkPad T540p, Ubuntu 22.04):

```
Driver version:1.0.14
Library version:1.0.26
Total 1 device(s)
TX:148.14MiB/s RX:0.00MiB/s, total:148.14MiB
TX:157.65MiB/s RX:0.00MiB/s, total:157.65MiB
TX:145.36MiB/s RX:0.00MiB/s, total:145.36MiB
```
