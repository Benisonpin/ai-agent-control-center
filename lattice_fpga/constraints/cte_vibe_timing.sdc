#==============================================================================
# CTE Vibe Code Timing Constraints
# Target: 4K@32.5fps, 28ms latency, optimized for LIFCL-40
#==============================================================================

# 主時鐘定義
create_clock -name clk_100m -period 10.0 [get_ports clk_100m]
create_clock -name clk_200m -period 5.0 [get_ports clk_200m]

# IMX25 相機時鐘 (根據實際感測器規格)
create_clock -name imx25_pclk -period 13.33 [get_ports imx25_pclk] ;# 75MHz

# PLL 生成的衍生時鐘
create_generated_clock -name clk_ai_proc -source [get_ports clk_100m] -divide_by 2 -multiply_by 5 [get_pins u_cte_pll/outcore_o]     ;# 250MHz
create_generated_clock -name clk_pixel -source [get_ports clk_100m] -divide_by 1 -multiply_by 2 [get_pins u_cte_pll/outglobal_o]   ;# 200MHz  
create_generated_clock -name clk_memory -source [get_ports clk_100m] -divide_by 1 -multiply_by 4 [get_pins u_cte_pll/outglobal2_o] ;# 400MHz

#==============================================================================
# 關鍵時序需求 - CTE Vibe Code AI Processing
#==============================================================================

# AI 處理延遲約束 - 確保 28ms 總延遲
set_max_delay -from [get_ports {imx25_data[*]}] -to [get_ports {ai_data_out[*]}] 28000000.0 ;# 28ms in ps

# 幀率約束 - 確保 32.5fps (30.77ms per frame)
set_min_delay -from [get_pins u_imx25_if/frame_start_o] -to [get_pins u_imx25_if/frame_start_o] 30770000.0 ;# 30.77ms

# Pipeline 階段間時序約束
set_max_delay -from [get_pins u_isp_pipeline/*] -to [get_pins {u_ai_stage[*]/*}] 5000.0 ;# 5ns max between stages

#==============================================================================
# IMX25 介面時序約束
#==============================================================================

# 輸入延遲約束 (相對於 imx25_pclk)
set_input_delay -clock imx25_pclk -min 2.0 [get_ports {imx25_data[*]}]
set_input_delay -clock imx25_pclk -max 8.0 [get_ports {imx25_data[*]}]
set_input_delay -clock imx25_pclk -min 2.0 [get_ports imx25_href]
set_input_delay -clock imx25_pclk -max 8.0 [get_ports imx25_href]
set_input_delay -clock imx25_pclk -min 2.0 [get_ports imx25_vsync]
set_input_delay -clock imx25_pclk -max 8.0 [get_ports imx25_vsync]

# 輸出延遲約束
set_output_delay -clock clk_pixel -min 1.0 [get_ports imx25_reset_n]
set_output_delay -clock clk_pixel -max 5.0 [get_ports imx25_reset_n]
set_output_delay -clock clk_pixel -min 1.0 [get_ports imx25_pwdn]
set_output_delay -clock clk_pixel -max 5.0 [get_ports imx25_pwdn]

#==============================================================================
# DDR Memory 介面時序約束
#==============================================================================

# DDR 時鐘約束
set_output_delay -clock clk_memory -min 1.0 [get_ports ddr_ck]
set_output_delay -clock clk_memory -max 3.0 [get_ports ddr_ck]

# DDR 資料線約束
set_output_delay -clock clk_memory -min 0.5 [get_ports {ddr_dq[*]}]
set_output_delay -clock clk_memory -max 2.5 [get_ports {ddr_dq[*]}]
set_input_delay -clock clk_memory -min 1.0 [get_ports {ddr_dq[*]}]
set_input_delay -clock clk_memory -max 4.0 [get_ports {ddr_dq[*]}]

# DDR 控制信號約束
set_output_delay -clock clk_memory -min 0.5 [get_ports {ddr_addr[*] ddr_ba[*] ddr_cas_n ddr_ras_n ddr_we_n ddr_cs_n ddr_cke ddr_odt}]
set_output_delay -clock clk_memory -max 2.0 [get_ports {ddr_addr[*] ddr_ba[*] ddr_cas_n ddr_ras_n ddr_we_n ddr_cs_n ddr_cke ddr_odt}]

#==============================================================================
# AI 處理管線時序約束
#==============================================================================

# AI 處理階段間的最大延遲
set_max_delay -from [get_pins {u_ai_stage[0]/*}] -to [get_pins {u_ai_stage[1]/*}] 4000.0 ;# 4ns Stage 0->1
set_max_delay -from [get_pins {u_ai_stage[1]/*}] -to [get_pins {u_ai_stage[2]/*}] 4000.0 ;# 4ns Stage 1->2
set_max_delay -from [get_pins {u_ai_stage[2]/*}] -to [get_pins {u_ai_stage[3]/*}] 4000.0 ;# 4ns Stage 2->3

# Vibe Code 介面時序約束
set_input_delay -clock clk_ai_proc -min 2.0 [get_ports {vibe_cmd[*]}]
set_input_delay -clock clk_ai_proc -max 8.0 [get_ports {vibe_cmd[*]}]
set_output_delay -clock clk_ai_proc -min 1.0 [get_ports {vibe_status[*]}]
set_output_delay -clock clk_ai_proc -max 5.0 [get_ports {vibe_status[*]}]

#==============================================================================
# 時鐘域交叉約束
#==============================================================================

# IMX25 到像素處理域
set_max_delay -from [get_clocks imx25_pclk] -to [get_clocks clk_pixel] 15.0
set_min_delay -from [get_clocks imx25_pclk] -to [get_clocks clk_pixel] 1.0

# 像素處理到 AI 處理域
set_max_delay -from [get_clocks clk_pixel] -to [get_clocks clk_ai_proc] 10.0
set_min_delay -from [get_clocks clk_pixel] -to [get_clocks clk_ai_proc] 1.0

# AI 處理到記憶體域
set_max_delay -from [get_clocks clk_ai_proc] -to [get_clocks clk_memory] 8.0
set_min_delay -from [get_clocks clk_ai_proc] -to [get_clocks clk_memory] 1.0

#==============================================================================
# False Path 和 Multicycle Path
#==============================================================================

# 重置信號是 False Path
set_false_path -from [get_ports rst_n]

# Debug 信號不需要嚴格時序
set_false_path -to [get_ports {debug_led[*]}]
set_false_path -from [get_ports {debug_sw[*]}]
set_false_path -to [get_ports test_point]

# 配置介面可以是多週期路徑
set_multicycle_path -setup 2 -from [get_ports {ai_config[*]}]
set_multicycle_path -hold 1 -from [get_ports {ai_config[*]}]

#==============================================================================
# 效能目標約束
#==============================================================================

# 確保系統能達到目標效能
set_max_delay -from [get_ports {imx25_vsync}] -to [get_ports {ai_data_valid}] 28000000.0 ;# 28ms latency requirement
set_min_delay -from [get_ports {imx25_vsync}] -to [get_ports {imx25_vsync}] 30770000.0   ;# 32.5fps requirement

# 功耗相關的時序約束 (降低切換頻率來省電)
set_case_analysis 0 [get_ports {debug_sw[3]}] ;RetryBPContinueEditsdc# 功耗相關的時序約束 (降低切換頻率來省電)
set_case_analysis 0 [get_ports {debug_sw[3]}] ;# Power saving mode

# 高效能模式下的寬鬆約束
set_multicycle_path -setup 2 -hold 1 -through [get_pins u_perf_mon/*] -when {debug_sw[0] == 1'b1}

#==============================================================================
# 專用時序群組 - CTE Vibe Code 優化
#==============================================================================

# 關鍵路徑群組 - AI 處理鏈
group_path -name "AI_CRITICAL_PATH" -from [get_pins u_imx25_if/pixel_data_o*] -to [get_pins u_output_fmt/formatted_o*]
set_max_delay -group "AI_CRITICAL_PATH" 20000.0 ;# 20ns for critical AI path

# 記憶體存取群組
group_path -name "MEMORY_ACCESS" -from [get_pins u_mem_ctrl/*] -to [get_ports {ddr_*}]
set_max_delay -group "MEMORY_ACCESS" 8000.0 ;# 8ns for memory access

# Vibe 控制群組
group_path -name "VIBE_CONTROL" -from [get_ports {vibe_cmd[*]}] -to [get_ports {vibe_status[*]}]
set_max_delay -group "VIBE_CONTROL" 50000.0 ;# 50ns for control interface (less critical)
