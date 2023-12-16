#!/bin/sh

rm -rf _build_linux-x64

dotnet publish --self-contained true -r linux-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_linux-x64 TestRead/TestRead.csproj

dotnet publish --self-contained true -r linux-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_linux-x64 TestWrite/TestWrite.csproj

dotnet publish --self-contained true -r linux-x64 -p:PublishSingleFile=true -p:IncludeAllContentForSelfExtract=true -c Release -o _build_linux-x64 McsChartApp/McsChartApp.csproj

cp ./ext/Linux/x64/libftd3xx.so ./_build_linux-x64

rm -f ./_build_linux-x64/*.pdb
