@echo off

rd /s /q _build_win-x64

dotnet publish --self-contained true -r win-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_win-x64 TestRead\TestRead.csproj

dotnet publish --self-contained true -r win-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_win-x64 TestWrite\TestWrite.csproj

dotnet publish --self-contained true -r win-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_win-x64 McsChartApp\McsChartApp.csproj

copy ext\Windows\x64\FTD3xx.dll _build_win-x64

del _build_win-x64\*.pdb
