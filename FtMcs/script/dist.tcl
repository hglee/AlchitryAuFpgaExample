set src_dir $::env(SRC_DIR)

create_project -force ft_mcs $src_dir/_build -part xc7a35tftg256-1

add_files $src_dir/hdl
add_files -fileset constrs_1 $src_dir/constraint/

set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_1]

create_ip -name microblaze_mcs -vendor xilinx.com -module_name cpu
set_property CONFIG.MEMSIZE 131072 [get_ips cpu]
set_property CONFIG.USE_IO_BUS true [get_ips cpu]

generate_target all [get_files cpu.xci]
export_ip_user_files -of_objects [get_files cpu.xci] -no_script -sync -force

launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_runs impl_1

write_hw_platform -fixed -include_bit -force -file $src_dir/_build/mcs_top.xsa

quit
