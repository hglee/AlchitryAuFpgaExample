# FtFIFOWrite

16 비트 값을 생성하고 FIFO을 이용하여 PC로 전송하는 예제입니다.

## 대상
### 소프트웨어

* Xilinx Vivado 2023.1

### 하드웨어

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## 프로젝트 생성과 빌드

0. 스크립트로 프로젝트 생성하기

`init.sh` 스크립트를 실행하여 프로젝트를 생성할 수 있습니다.

필요한 경우 `init.sh` 스크립트 안에 설치 경로 (XILINX_VIVADO)를 수정하여 실행합니다.

스크립트로 프로젝트를 생성한 경우 1 ~ 4 단계 과정을 생략할 수 있습니다.

1. Vivado에서 새 RTL 프로젝트 생성

프로젝트 생성 시 part를 `xc7a35tftg256-1` 로 선택합니다.

![Parts](docs/01_part.png)

2. 프로젝트에 constraint 파일 추가

`constraint` 디렉토리의 `alchitry.xdc` 파일을 프로젝트에 추가합니다.

3. 프로젝트에 소스 파일 추가

`hdl` 디렉토리의 모든 소스 파일을 프로젝트에 추가합니다.

4. implementation 의 `bin_file` 옵션 설정

업로드를 위해서 bin file 형태로 생성할 필요가 있습니다.

`Implementation` 에서 우클릭 후 `write_bitstream` 부분의 `bin_file` 을 활성화합니다.

![bin file option](docs/02_imple.png)

5. 비트스트림 생성

정상적으로 생성된 경우 프로젝트 디렉토리 하위에서 `top.bin` 을 찾을 수 있습니다.

## 업로드와 테스트

[이전 방식](../FtBasicWrite/README_ko.md#테스트) 을 참고합니다.
