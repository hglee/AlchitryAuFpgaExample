create_project -force au_ft_basic_write ./project -part xc7a35tftg256-1

add_files ./hdl
add_files -fileset constrs_1 ./constraint/

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

start_gui
