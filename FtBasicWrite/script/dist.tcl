set src_dir $::env(SRC_DIR)

create_project -force au_ft_basic_write $src_dir/_build -part xc7a35tftg256-1

add_files $src_dir/hdl
add_files -fileset constrs_1 $src_dir/constraint/

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_runs impl_1

quit
