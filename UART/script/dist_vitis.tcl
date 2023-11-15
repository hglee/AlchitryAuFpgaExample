set src_dir $::env(SRC_DIR)

setws $src_dir/_build_workspace

app create -name test_uart -hw $src_dir/_build/mcs_top.xsa -proc microblaze_I -os standalone -lang C++ -template {Empty Application (C++)}

importsources -name test_uart -path $src_dir/sw

app config -name test_uart build-config release

app build -name test_uart
