import os
import vitis

# Initialization script for Vitis 2023.2
src_dir = os.environ['SRC_DIR']

ws_path = f'{src_dir}/_build_workspace'
platform_name = 'platform_mcs'
hw_xsa = f'{src_dir}/_build/mcs_top.xsa'
hw_os = 'standalone'
hw_cpu = 'microblaze_I'
app_name = 'test_uart'
platform_path = f'{ws_path}/{platform_name}/export/{platform_name}/{platform_name}.xpfm'
platform_domain = 'standalone_microblaze_I'
src_loc = f'{src_dir}/sw'

client = vitis.create_client(workspace = ws_path)

# xiltimer added by default and need for empty application template
platform = client.create_platform_component(name = platform_name, hw = hw_xsa, os = hw_os, cpu = hw_cpu)
platform.build()

app = client.create_app_component(name = app_name, platform = platform_path, domain = platform_domain)
app.import_files(from_loc = src_loc, dest_dir_in_cmp = 'src')
app.set_app_config(key = "USER_COMPILE_OPTIMIZATION_LEVEL", values = "-Os")
app.set_app_config(key = "USER_COMPILE_OPTIMIZATION_OTHER_FLAGS", values = "-DNDEBUG")
app.set_app_config(key = "USER_COMPILE_DEBUG_LEVEL", values = "")
app.set_app_config(key = "USER_LINK_OTHER_FLAGS", values = "-s")
app.build(target = 'hw')

client.close()

vitis.dispose()
