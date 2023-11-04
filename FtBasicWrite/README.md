# FtBasicWrite

Generate 16 bit sequence number and transfer to PC.

## Target
### Software

* Xilinx Vivado 2023.1

### Hardware

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## Create Project and Build

0. Create project using script.

You can create project using init.sh script.

Edit install path (XILINX_VIVADO) in init.sh then run if you want.

You can skip step 1 ~ 4 if you created project by script.

1. Create new RTL project in Vivado.

You need to select part 'xc7a35tftg256-1'.

![Parts](docs/01_part.png)

2. Add constraint file to project.

Add alchitry.xdc in constraint directory to project.

3. Add source files to project.

Add all source files in hdl directory to project.

4. Set 'bin_file' option to implementation.

You need generate bin file to upload.

Right click on 'Implementation' and enable 'bin_file' in 'write_bitstream' section.

![bin file option](docs/02_imple.png)

5. Generate Bitstream

After generate, you can find 'top.bin' file under project folder.

## Upload

1. Prepare loader program

You need to use loader program to upload: https://github.com/alchitry/alchitry-loader.git

Clones repository and build loader program.

2. Connect USB

Connect USB cable to main Au board and unbind first USB device.

For example, you can see detected USB devices like this in Linux:

```
[ 4461.753982] ftdi_sio 3-3:1.0: FTDI USB Serial Device converter detected
[ 4461.754117] usb 3-3: Detected FT2232H
[ 4461.754428] usb 3-3: FTDI USB Serial Device converter now attached to ttyUSB0
[ 4461.756568] ftdi_sio 3-3:1.1: FTDI USB Serial Device converter detected
[ 4461.756630] usb 3-3: Detected FT2232H
[ 4461.756841] usb 3-3: FTDI USB Serial Device converter now attached to ttyUSB1
```

Then unbind first USB device like this:

```
echo '3-3:1.0' | sudo tee /sys/bus/usb/drivers/ftdi_sio/unbind
```

3. Upload bin file

You can upload to RAM like this:

```
sudo ./alchitry_loader -t au -r top.bin
```

You can see message after upload like this:

```
Found Alchitry Au as device 0.
Programming FPGA...
Done.
```

## Test

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
sudo ./streamer 0 1 0
```

You can see RX transfer rate if it works properly like this (on ThinkPad T540p, Ubuntu 22.04):

```
Driver version:1.0.14
Library version:1.0.26
Total 1 device(s)
TX:0.00MiB/s RX:122.45MiB/s, total:122.45MiB
TX:0.00MiB/s RX:125.37MiB/s, total:125.37MiB
TX:0.00MiB/s RX:118.82MiB/s, total:118.82MiB
```

And little fast on recent machine (on AMD 3900x, Ubuntu 22.04):

```
Driver version:1.0.14
Library version:1.0.26
Total 1 device(s)
TX:0.00MiB/s RX:141.72MiB/s, total:141.72MiB
TX:0.00MiB/s RX:141.72MiB/s, total:141.72MiB
TX:0.00MiB/s RX:141.92MiB/s, total:141.92MiB
```
