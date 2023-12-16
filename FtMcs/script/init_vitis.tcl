set src_dir $::env(SRC_DIR)

setws $src_dir/vitis_workspace

app create -name ft_mcs -hw $src_dir/project/mcs_top.xsa -proc microblaze_I -os standalone -lang C++ -template {Empty Application (C++)}

importsources -name ft_mcs -path $src_dir/sw
