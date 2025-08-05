#==============================================================================
# CTE Vibe Code - Radiant 專案自動化腳本
# Target: Lattice LIFCL-40-9BG400C
# Integration with existing IMX25_verify project
#==============================================================================

# 基於您現有的專案配置
set project_name "cte_vibe_ai_drone"
set device_part "LIFCL-40-9BG400C"
set performance_grade "9_High-Performance_1.0V"
set package "BG400"
set operating_condition "COM"

# 建立新專案 (或修改現有專案)
puts "🚀 建立 CTE Vibe Code Radiant 專案..."

# 新建專案
prj_create -name $project_name -impl "CTE_Implementation" -dev $device_part -performance $performance_grade -synthesis "synplify"

# 設定專案屬性
prj_set_impl_opt -impl "CTE_Implementation" top "cte_vibe_top"
prj_set_impl_opt -impl "CTE_Implementation" hdl "verilog"

# 添加設計檔案
puts "📁 添加 RTL 設計檔案..."
prj_add_source "rtl/cte_vibe_top.v"
prj_add_source "rtl/cte_imx25_interface.v"
prj_add_source "rtl/cte_isp_pipeline.v"
prj_add_source "rtl/cte_ai_processing_stage.v"
prj_add_source "rtl/cte_vibe_interface.v"
prj_add_source "rtl/cte_performance_monitor.v"
prj_add_source "rtl/cte_memory_controller.v"

# 添加約束檔案
puts "📐 添加約束檔案..."
prj_add_source "constraints/cte_vibe_pins.pdc" -file_type "pdc"
prj_add_source "constraints/cte_vibe_timing.sdc" -file_type "sdc"

# 添加 IP 核心
puts "🔧 配置 IP 核心..."
# PLL IP for clock generation
# DDR3/4 controller IP
# 其他必要的 IP

# 設定合成選項
puts "⚙️ 配置合成選項..."
prj_set_synthesis_opt -hdl_param "TARGET_FPS=32.5"
prj_set_synthesis_opt -hdl_param "TARGET_LATENCY_MS=28"
prj_set_synthesis_opt -hdl_param "TARGET_POWER_W=3.5"

# 設定實現選項
puts "🎯 配置實現選項..."
prj_set_impl_opt -impl "CTE_Implementation" -strategy "Area"  # 基於您的設定

# 自動化建置流程
proc build_cte_vibe {} {
    puts "🔨 開始自動化建置流程..."
    
    # 1. 合成
    puts "🧪 執行合成..."
    prj_run Synthesis -impl "CTE_Implementation"
    
    # 檢查合成結果
    if {[prj_get_result -impl "CTE_Implementation" Synthesis] != "Pass"} {
        puts "❌ 合成失敗!"
        return -1
    }
    puts "✅ 合成成功"
    
    # 2. 映射
    puts "🗺️ 執行映射..."
    prj_run Map -impl "CTE_Implementation"
    
    if {[prj_get_result -impl "CTE_Implementation" Map] != "Pass"} {
        puts "❌ 映射失敗!"
        return -1
    }
    puts "✅ 映射成功"
    
    # 3. 佈局佈線
    puts "🔀 執行佈局佈線..."
    prj_run PAR -impl "CTE_Implementation"
    
    if {[prj_get_result -impl "CTE_Implementation" PAR] != "Pass"} {
        puts "❌ 佈局佈線失敗!"
        return -1
    }
    puts "✅ 佈局佈線成功"
    
    # 4. 生成位流檔案
    puts "📡 生成位流檔案..."
    prj_run Export -impl "CTE_Implementation"
    
    # 5. 生成報告
    generate_reports
    
    puts "🎉 CTE Vibe Code 建置完成!"
    return 0
}

# 生成詳細報告
proc generate_reports {} {
    puts "📊 生成效能報告..."
    
    # 時序報告
    prj_run Timer -impl "CTE_Implementation"
    
    # 資源使用報告
    prj_run Resource -impl "CTE_Implementation"
    
    # 功耗報告
    prj_run Power -impl "CTE_Implementation"
    
    puts "📋 報告已生成在 impl/CTE_Implementation/報告目錄"
}

# 自動化測試流程
proc run_automated_tests {} {
    puts "🧪 執行自動化測試..."
    
    # 啟動 ModelSim 進行功能模擬
    exec modelsim -batch -do ../testbench/generated/run_modelsim.do
    
    puts "✅ 自動化測試完成"
}

# 主要建置和測試流程
puts "🚁 CTE Vibe Code for AI Image Drone Chip"
puts "======================================="
puts "Target: Lattice LIFCL-40-9BG400C"
puts "Performance: 4K@32.5fps, 28ms latency, 3.5W power"
puts ""

if {[build_cte_vibe] == 0} {
    puts "🎯 建置成功! 開始測試..."
    run_automated_tests
    puts ""
    puts "🎉 CTE Vibe Code 準備就緒!"
    puts "📁 位流檔案: impl/CTE_Implementation/cte_vibe_ai_drone_CTE_Implementation.bit"
    puts "📊 報告目錄: impl/CTE_Implementation/"
} else {
    puts "❌ 建置失敗，請檢查錯誤訊息"
}
