import vitis

# Initialization script for Vitis 2023.2
ws_path = './build_workspace'
platform_name = 'platform_mcs'
hw_xsa = './build/mcs_top.xsa'
hw_os = 'standalone'
hw_cpu = 'microblaze_I'
app_name = 'test_uart'
platform_path = f'{ws_path}/{platform_name}/export/{platform_name}/{platform_name}.xpfm'
platform_domain = 'standalone_microblaze_I'
src_loc = './sw'

client = vitis.create_client(workspace = ws_path)

platform = client.create_platform_component(name = platform_name, hw = hw_xsa, os = hw_os, cpu = hw_cpu)
platform.build()

app = client.create_app_component(name = app_name, platform = platform_path, domain = platform_domain)
app.import_files(from_loc = src_loc, dest_dir_in_cmp = 'src')
app.build(target = 'hw')

client.close()
