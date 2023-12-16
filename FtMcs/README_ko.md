# FtMcs

시작 명령을 PC로 부터 받아서 PC로 생성된 데이터를 전송합니다.

## 대상
### 소프트웨어

* Xilinx Vivado 2023.1, 2023.2
* Xilinx Vitis 2023.1, 2023.2

### 하드웨어

* Alchitry Au Board : Xilinx Artix 7 FPGA
* Alchitry Ft Module : FTDI FT600 USB3 Bridge

## Vivado 프로젝트 생성과 빌드

[init.sh](script/init.sh) 스크립트를 실행하여 프로젝트를 생성할 수 있습니다.

Vivado MCS 초기 설정 관련 세부 사항은 [UART](../UART/README_ko.md) 를 참고합니다.

## Vitis 프로젝트 생성과 빌드

[init_vitis.sh](script/init_vitis.sh) 스크립트를 실행하여 프로젝트를 생성할 수 있습니다.

Vitis MCS 초기 설정 관련 세부 사항은 [UART](../UART/README_ko.md) 를 참고합니다.

## 업로드

[이전 방식](../FtBasicWrite/README_ko.md) 을 참고합니다.

## 테스트

[FtClientDotNet](../FtClientDotNet/README_ko.md#mcs-chart-app) 의 'McsChartApp' 프로그램을 사용하여 테스트할 수 있습니다.
