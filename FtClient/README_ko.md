# FtClient

FT600 (FTD3xx) 읽기/쓰기 클라이언트 예제입니다.

## 대상

* CMake 3.10 above
* C++20 Compiler

## 빌드

```
mkdir build
cd build
cmake ..
make
```

## 읽기 테스트

'TestRead' 프로그램은 FT600에서 데이터를 받아옵니다. FT600에서 데이터를 받아오기 위해서 'TestRead' 프로그램을 실행합니다.

```
sudo ./TestRead
```

정상적으로 동작하는 경우 다음과 같이 RX 전송율을 확인할 수 있습니다 (ThinkPad T540p, Ubuntu 22.04 기준):

```
Number of devices: 1
173.68 (MB/s) - 173703168 bytes in 1000138 (us)
173.75 (MB/s) - 173768704 bytes in 1000091 (us)
173.80 (MB/s) - 173801472 bytes in 1000012 (us)
174.57 (MB/s) - 174587904 bytes in 1000124 (us)
```

## 쓰기 테스트

'TestWrite' 프로그램은 FT600으로 데이터를 보냅니다. FT600으로 데이터를 보내기 위해서 'TestWrite' 프로그램을 실행합니다.

정상적으로 동작하는 경우 다음과 같이 TX 전송율을 확인할 수 있습니다 (ThinkPad T540p, Ubuntu 22.04 기준):

```
Number of devices: 1
188.40 (MB/s) - 188416000 bytes in 1000099 (us)
186.73 (MB/s) - 186744832 bytes in 1000101 (us)
186.72 (MB/s) - 186744832 bytes in 1000139 (us)
```
