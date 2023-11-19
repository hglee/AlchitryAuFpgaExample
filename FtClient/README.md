# FtClient

FT600 (FTD3xx) Read/Write Client Example Program

## Target

* CMake 3.10 above
* C++20 Compiler

## Build

```
mkdir build
cd build
cmake ..
make
```

## Read Test

The 'TestRead' program receives data from the FT600. To receive from FT600, run the 'TestRead' program.

```
sudo ./TestRead
```

You can check the RX transfer rate if it works properly as follows (on ThinkPad T540p, Ubuntu 22.04):

```
Number of devices: 1
173.68 (MB/s) - 173703168 bytes in 1000138 (us)
173.75 (MB/s) - 173768704 bytes in 1000091 (us)
173.80 (MB/s) - 173801472 bytes in 1000012 (us)
174.57 (MB/s) - 174587904 bytes in 1000124 (us)
```

## Write Test

The 'TestWrite' program sends data to the FT600. To send to FT600, run the 'TestWrite' program.

```
sudo ./TestWrite
```

You can check the TX transfer rate if it works properly as follows (on ThinkPad T540p, Ubuntu 22.04):

```
Number of devices: 1
188.40 (MB/s) - 188416000 bytes in 1000099 (us)
186.73 (MB/s) - 186744832 bytes in 1000101 (us)
186.72 (MB/s) - 186744832 bytes in 1000139 (us)
```
