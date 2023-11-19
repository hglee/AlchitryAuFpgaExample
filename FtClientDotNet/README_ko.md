# FtClient

FT600 (FTD3xx) 읽기/쓰기 클라이언트 예제입니다 (.NET).

## 대상

* .NET 6

## 빌드

```
dotnet build -c Release
```

## 읽기 테스트

'TestRead' 프로그램은 FT600에서 데이터를 받아옵니다. FT600에서 데이터를 받아오기 위해서 'TestRead' 프로그램을 실행합니다. 동적 라이브러리 (.so 혹은 .dll)을 빌드된 디렉토리에서 찾을 수 있도록 주의합니다.

```
sudo dotnet run --project TestRead -c Release
```

정상적으로 동작하는 경우 다음과 같이 RX 전송율을 확인할 수 있습니다 (ThinkPad T540p, Ubuntu 22.04 기준):

```
Number of devices: 1
Flags: 4, Type: 258, ID: 403601E, SerialNumber: 000000000001, Description: FTDI SuperSpeed-FIFO Bridge
177.57 (MB/s) - 177569792 bytes in 1000025.10 (us)
177.60 (MB/s) - 177602560 bytes in 1000010.60 (us)
175.10 (MB/s) - 175112192 bytes in 1000084.80 (us)
```

## 쓰기 테스트

'TestWrite' 프로그램은 FT600으로 데이터를 보냅니다. FT600으로 데이터를 보내기 위해서 'TestWrite' 프로그램을 실행합니다. 동적 라이브러리 (.so 혹은 .dll)을 빌드된 디렉토리에서 찾을 수 있도록 주의합니다.

```
sudo dotnet run --project TestWrite -c Release
```

정상적으로 동작하는 경우 다음과 같이 TX 전송율을 확인할 수 있습니다 (ThinkPad T540p, Ubuntu 22.04 기준):

```
Number of devices: 1
Flags: 4, Type: 258, ID: 403601E, SerialNumber: 000000000001, Description: FTDI SuperSpeed-FIFO Bridge
186.32 (MB/s) - 186351616 bytes in 1000152.10 (us)
181.88 (MB/s) - 181895168 bytes in 1000104.30 (us)
186.08 (MB/s) - 186089472 bytes in 1000026.20 (us)
```
