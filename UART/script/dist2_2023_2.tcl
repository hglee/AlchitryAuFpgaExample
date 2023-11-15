set src_dir $::env(SRC_DIR)

open_project $src_dir/_build/au_sample_uart.xpr

add_files -norecurse $src_dir/_build_workspace/test_uart/build/test_uart.elf
set_property SCOPED_TO_REF cpu [get_files -all -of_objects [get_fileset sources_1] {test_uart.elf}]
set_property SCOPED_TO_CELLS { inst/microblaze_I } [get_files -all -of_objects [get_fileset sources_1] {test_uart.elf}]

reset_run impl_1 -prev_step 
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_runs impl_1

quit
