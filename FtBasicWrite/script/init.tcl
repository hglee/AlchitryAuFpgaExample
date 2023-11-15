set src_dir $::env(SRC_DIR)

create_project -force au_ft_basic_write $src_dir/project -part xc7a35tftg256-1

add_files $src_dir/hdl
add_files -fileset constrs_1 $src_dir/constraint/

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

start_gui
