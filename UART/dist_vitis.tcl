setws ./build_workspace

app create -name test_uart -hw ./build/mcs_top.xsa -proc microblaze_I -os standalone -lang C++ -template {Empty Application (C++)}

importsources -name test_uart -path ./sw

app config -name test_uart build-config release

app build -name test_uart
