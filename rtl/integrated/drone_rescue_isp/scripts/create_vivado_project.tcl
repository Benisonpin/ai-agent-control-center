# Vivado 專案建立腳本
create_project drone_rescue_isp ./vivado_proj -part xc7z020clg484-1
set_property board_part digilentinc.com:zybo-z7-20:part0:1.0 [current_project]

# 加入 RTL 檔案
add_files -fileset sources_1 [glob ./rtl/*.sv]
add_files -fileset sim_1 [glob ./sim/*.sv]

# 設定頂層
set_property top drone_rescue_isp_top [current_fileset]

# 合成設定 - 優化面積和功耗
set_property strategy {Vivado Synthesis 2023} [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE {AreaOptimized_high} [get_runs synth_1]

puts "專案建立完成！"
