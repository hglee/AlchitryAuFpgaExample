setws ./vitis_workspace

app create -name test_uart -hw ./project/mcs_top.xsa -proc microblaze_I -os standalone -lang C++ -template {Empty Application (C++)}

importsources -name test_uart -path ./sw
