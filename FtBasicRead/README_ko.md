# FtBasicWrite

PC로 부터 데이터를 받는 예제입니다.

## 대상
### 소프트웨어

* Xilinx Vivado 2023.1

### 하드웨어

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## 프로젝트 생성과 빌드

0. 스크립트로 프로젝트 생성하기

[init.sh](script/init.sh) 스크립트를 실행하여 프로젝트를 생성할 수 있습니다.

필요한 경우 [init.sh](script/init.sh) 스크립트 안에 설치 경로 (XILINX_VIVADO)를 수정하여 실행합니다.

스크립트로 프로젝트를 생성한 경우 1 ~ 4 단계 과정을 생략할 수 있습니다.

1. Vivado에서 새 RTL 프로젝트 생성

프로젝트 생성 시 part를 `xc7a35tftg256-1` 로 선택합니다.

![Parts](../docs/part.png)

2. 프로젝트에 constraint 파일 추가

`constraint` 디렉토리의 `alchitry.xdc` 파일을 프로젝트에 추가합니다.

3. 프로젝트에 소스 파일 추가

`hdl` 디렉토리의 모든 소스 파일을 프로젝트에 추가합니다.

4. implementation 의 `bin_file` 옵션 설정

업로드를 위해서 bin file 형태로 생성할 필요가 있습니다.

`Implementation` 에서 우클릭 후 `write_bitstream` 부분의 `bin_file` 을 활성화합니다.

![bin file option](../docs/imple.png)

5. 비트스트림 생성

정상적으로 생성된 경우 프로젝트 디렉토리 하위에서 `top.bin` 을 찾을 수 있습니다.

## 업로드

[FtBasicWrite](../FtBasicWrite/README_ko.md#업로드) 와 동일한 방식으로 업로드합니다.

## 테스트

[FtClient](../FtClient/README_ko.md#쓰기-테스트) 의 'TestWrite' 프로그램을 사용해서 테스트 할 수 있습니다.

FTDI 쪽 예제를 사용하려면 아래 방법을 사용할 수 있습니다.

1. 샘플 프로그램 준비

FTDI 홈페이지 상의 D3XX 샘플 프로그램을 사용하여 동작을 확인할 수 있습니다: https://ftdichip.com/drivers/d3xx-drivers/

Linux의 경우 Linux Driver (libftd3xx-linux-x86_64-xxx.tgz) 를 다운로드하여 샘플 프로그램을 빌드합니다.

static 라이브러리로 빌드하는 경우, Makefile 상단 부분을 다음과 같이 수정합니다:

```
LIBS = -L . -lftd3xx-static -lstdc++
```

2. 샘플 프로그램 실행

**다른 USB 케이블을 Ft 모듈로 연결** 하고 샘플 프로그램인 streamer 을 실행합니다.

```
sudo ./streamer 1 0 0
```

정상적으로 동작하는 경우 다음과 같이 TX 전송율을 확인할 수 있습니다 (ThinkPad T540p, Ubuntu 22.04 기준):

```
Driver version:1.0.14
Library version:1.0.26
Total 1 device(s)
TX:148.14MiB/s RX:0.00MiB/s, total:148.14MiB
TX:157.65MiB/s RX:0.00MiB/s, total:157.65MiB
TX:145.36MiB/s RX:0.00MiB/s, total:145.36MiB
```
