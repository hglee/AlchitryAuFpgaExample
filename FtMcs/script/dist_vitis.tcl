set src_dir $::env(SRC_DIR)

setws $src_dir/_build_workspace

app create -name ft_mcs -hw $src_dir/_build/mcs_top.xsa -proc microblaze_I -os standalone -lang C++ -template {Empty Application (C++)}

importsources -name ft_mcs -path $src_dir/sw

app config -name ft_mcs build-config release

app build -name ft_mcs
