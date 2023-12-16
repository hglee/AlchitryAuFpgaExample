set src_dir $::env(SRC_DIR)

open_project $src_dir/_build/ft_mcs.xpr

add_files -norecurse $src_dir/_build_workspace/ft_mcs/build/ft_mcs.elf
set_property SCOPED_TO_REF cpu [get_files -all -of_objects [get_fileset sources_1] {ft_mcs.elf}]
set_property SCOPED_TO_CELLS { inst/microblaze_I } [get_files -all -of_objects [get_fileset sources_1] {ft_mcs.elf}]

reset_run impl_1 -prev_step 
launch_runs impl_1 -to_step write_bitstream -jobs 8
wait_on_runs impl_1

quit
