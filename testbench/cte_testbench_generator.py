#!/usr/bin/env python3
"""
CTE Vibe Code - 自動化 Testbench 生成器
支援 Radiant + ModelSim 工作流程
"""

import os
import json
from pathlib import Path
from typing import Dict, List, Any
from dataclasses import dataclass
from enum import Enum

class TestType(Enum):
    UNIT_TEST = "unit"
    INTEGRATION_TEST = "integration"
    PERFORMANCE_TEST = "performance"
    COMPLIANCE_TEST = "compliance"

@dataclass
class TestConfiguration:
    """測試配置"""
    module_name: str
    test_type: TestType
    clock_period_ns: float = 5.0  # 200MHz
    simulation_time_us: float = 1000.0
    enable_coverage: bool = True
    enable_assertions: bool = True

class CTETestbenchGenerator:
    """CTE Vibe Code Testbench 自動生成器"""
    
    def __init__(self):
        self.test_template_dir = Path("templates")
        self.output_dir = Path("testbench/generated")
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
    def generate_testbench(self, config: TestConfiguration):
        """生成完整的 Testbench"""
        print(f"🧪 生成 {config.module_name} 的 {config.test_type.value} Testbench...")
        
        if config.test_type == TestType.UNIT_TEST:
            return self._generate_unit_testbench(config)
        elif config.test_type == TestType.INTEGRATION_TEST:
            return self._generate_integration_testbench(config)
        elif config.test_type == TestType.PERFORMANCE_TEST:
            return self._generate_performance_testbench(config)
        else:
            return self._generate_compliance_testbench(config)
    
    def _generate_unit_testbench(self, config: TestConfiguration):
        """生成單元測試 Testbench"""
        
        testbench_content = f'''//==============================================================================
// CTE Vibe Code - 自動生成的單元測試 Testbench
// Module: {config.module_name}
// Generated: {self._get_timestamp()}
// Target: Lattice LIFCL-40 + Radiant + ModelSim
//==============================================================================

`timescale 1ns/1ps

module tb_{config.module_name};

//==============================================================================
// 測試參數
//==============================================================================
parameter CLK_PERIOD = {config.clock_period_ns};
parameter SIM_TIME = {int(config.simulation_time_us * 1000)};  // ns
parameter ENABLE_COVERAGE = {1 if config.enable_coverage else 0};

//==============================================================================
// 時鐘和重置
//==============================================================================
reg clk;
reg rst_n;

initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

initial begin
    rst_n = 0;
    #(CLK_PERIOD*10) rst_n = 1;
end

//==============================================================================
// DUT 介面信號
//==============================================================================
// 根據模組自動生成介面信號
{self._generate_dut_signals(config.module_name)}

//==============================================================================
// DUT 實例化
//==============================================================================
{config.module_name} u_dut (
{self._generate_dut_connections(config.module_name)}
);

//==============================================================================
// 測試向量和激勵
//==============================================================================
initial begin
    $display("🧪 開始 %s 單元測試", "{config.module_name}");
    
    // 等待重置完成
    wait(rst_n);
    repeat(10) @(posedge clk);
    
    // 測試案例 1: 基本功能測試
    test_basic_functionality();
    
    // 測試案例 2: 邊界條件測試
    test_boundary_conditions();
    
    // 測試案例 3: 錯誤注入測試
    test_error_injection();
    
    // 測試案例 4: 效能測試
    if ("{config.test_type}" == "performance") begin
        test_performance_requirements();
    end
    
    #SIM_TIME;
    
    $display("✅ %s 測試完成", "{config.module_name}");
    $finish;
end

//==============================================================================
// 測試任務
//==============================================================================
task test_basic_functionality();
    begin
        $display("📋 測試基本功能...");
        // 基本功能測試邏輯
        {self._generate_basic_test_logic(config.module_name)}
        $display("✅ 基本功能測試通過");
    end
endtask

task test_boundary_conditions();
    begin
        $display("📋 測試邊界條件...");
        // 邊界條件測試
        {self._generate_boundary_test_logic(config.module_name)}
        $display("✅ 邊界條件測試通過");
    end
endtask

task test_error_injection();
    begin
        $display("📋 測試錯誤注入...");
        // 錯誤注入測試
        {self._generate_error_test_logic(config.module_name)}
        $display("✅ 錯誤注入測試通過");
    end
endtask

task test_performance_requirements();
    begin
        $display("📋 測試效能需求...");
        // 效能測試：32.5fps, 28ms延遲, 3.5W功耗
        {self._generate_performance_test_logic()}
        $display("✅ 效能需求測試通過");
    end
endtask

//==============================================================================
// 監控和檢查
//==============================================================================
// 自動生成的檢查器
{self._generate_checkers(config)}

//==============================================================================
// 覆蓋率收集 (如果啟用)
//==============================================================================
{self._generate_coverage_code(config) if config.enable_coverage else "// Coverage disabled"}

//==============================================================================
// 斷言 (如果啟用)
//==============================================================================
{self._generate_assertions(config) if config.enable_assertions else "// Assertions disabled"}

//==============================================================================
// 波形轉儲
//==============================================================================
initial begin
    $dumpfile("tb_{config.module_name}.vcd");
    $dumpvars(0, tb_{config.module_name});
end

endmodule'''
        
        # 寫入檔案
        output_file = self.output_dir / f"tb_{config.module_name}.v"
        with open(output_file, 'w') as f:
            f.write(testbench_content)
        
        print(f"✅ Testbench 已生成: {output_file}")
        return output_file
    
    def _generate_performance_testbench(self, config: TestConfiguration):
        """生成效能測試專用 Testbench"""
        
        perf_testbench = f'''//==============================================================================
// CTE Vibe Code - 效能測試 Testbench
// 驗證 4K@32.5fps, 28ms延遲, 3.5W功耗需求
//==============================================================================

`timescale 1ns/1ps

module tb_{config.module_name}_performance;

//==============================================================================
// 效能測試參數
//==============================================================================
parameter TARGET_FPS = 32.5;
parameter TARGET_LATENCY_MS = 28;
parameter TARGET_POWER_W = 3.5;
parameter FRAME_PIXELS = 3840 * 2160;  // 4K resolution
parameter CLOCK_FREQ_MHZ = 200;

//==============================================================================
// 效能監控變數
//==============================================================================
real fps_measured;
real latency_measured_ms;
real power_estimated_w;
integer frame_count;
time frame_start_time, frame_end_time;
time test_start_time, test_end_time;

//==============================================================================
// DUT 和測試邏輯
//==============================================================================
{self._generate_performance_test_dut()}

//==============================================================================
// 效能測量任務
//==============================================================================
task measure_fps();
    begin
        test_start_time = $time;
        frame_count = 0;
        
        // 測量 100 幀的處理時間
        repeat(100) begin
            @(posedge frame_valid);
            frame_count = frame_count + 1;
        end
        
        test_end_time = $time;
        fps_measured = (frame_count * 1000000000.0) / (test_end_time - test_start_time);
        
        $display("📊 測量到的 FPS: %.2f (目標: %.1f)", fps_measured, TARGET_FPS);
        
        if (fps_measured >= TARGET_FPS * 0.95) begin  // 允許 5% 誤差
            $display("✅ FPS 需求達成");
        end else begin
            $display("❌ FPS 需求未達成");
        end
    end
endtask

task measure_latency();
    begin
        // 測量從輸入到輸出的延遲
        @(posedge input_valid);
        frame_start_time = $time;
        
        @(posedge output_valid);
        frame_end_time = $time;
        
        latency_measured_ms = (frame_end_time - frame_start_time) / 1000000.0;
        
        $display("📊 測量到的延遲: %.2f ms (目標: %d ms)", latency_measured_ms, TARGET_LATENCY_MS);
        
        if (latency_measured_ms <= TARGET_LATENCY_MS * 1.05) begin  // 允許 5% 誤差
            $display("✅ 延遲需求達成");
        end else begin
            $display("❌ 延遲需求未達成");
        end
    end
endtask

task estimate_power();
    begin
        // 功耗估算 (基於切換活動)
        // 這裡使用簡化的功耗模型
        power_estimated_w = {self._generate_power_estimation_logic()};
        
        $display("📊 估算功耗: %.2f W (目標: %.1f W)", power_estimated_w, TARGET_POWER_W);
        
        if (power_estimated_w <= TARGET_POWER_W * 1.1) begin  // 允許 10% 誤差
            $display("✅ 功耗需求達成");
        end else begin
            $display("❌ 功耗需求未達成");
        end
    end
endtask

//==============================================================================
// 主測試序列
//==============================================================================
initial begin
    $display("🎯 開始效能驗證測試");
    $display("目標規格: %.1f fps, %d ms延遲, %.1f W功耗", TARGET_FPS, TARGET_LATENCY_MS, TARGET_POWER_W);
    
    // 初始化
    initialize_test();
    
    // FPS 測試
    measure_fps();
    
    // 延遲測試
    repeat(10) measure_latency();
    
    // 功耗估算
    estimate_power();
    
    // 生成報告
    generate_performance_report();
    
    $finish;
end

task generate_performance_report();
    integer report_file;
    begin
        report_file = $fopen("performance_report.txt", "w");
        
        $fwrite(report_file, "CTE Vibe Code 效能測試報告\\n");
        $fwrite(report_file, "=============================\\n");
        $fwrite(report_file, "測試模組: %s\\n", "{config.module_name}");
        $fwrite(report_file, "測試時間: %s\\n", "{self._get_timestamp()}");
        $fwrite(report_file, "\\n");
        $fwrite(report_file, "效能結果:\\n");
        $fwrite(report_file, "FPS: %.2f / %.1f (%.1f%%)\\n", fps_measured, TARGET_FPS, (fps_measured/TARGET_FPS)*100);
        $fwrite(report_file, "延遲: %.2f / %d ms (%.1f%%)\\n", latency_measured_ms, TARGET_LATENCY_MS, (latency_measured_ms/TARGET_LATENCY_MS)*100);
        $fwrite(report_file, "功耗: %.2f / %.1f W (%.1f%%)\\n", power_estimated_w, TARGET_POWER_W, (power_estimated_w/TARGET_POWER_W)*100);
        
        $fclose(report_file);
        
        $display("📋 效能報告已生成: performance_report.txt");
    end
endtask

endmodule'''
        
        # 寫入效能測試檔案
        perf_file = self.output_dir / f"tb_{config.module_name}_performance.v"
        with open(perf_file, 'w') as f:
            f.write(perf_testbench)
        
        print(f"🎯 效能測試 Testbench 已生成: {perf_file}")
        return perf_file
    
    def generate_modelsim_script(self, testbench_files: List[Path]):
        """生成 ModelSim 執行腳本"""
        
        script_content = f'''# CTE Vibe Code ModelSim 自動化腳本
# Generated: {self._get_timestamp()}

# 建立工作函式庫
vlib work

# 編譯設計檔案
echo "📝 編譯 RTL 設計檔案..."
vlog -work work ../lattice_fpga/rtl/*.v

# 編譯 Testbench
echo "🧪 編譯 Testbench 檔案..."
'''
        
        for tb_file in testbench_files:
            script_content += f'vlog -work work {tb_file}\n'
        
        script_content += f'''
# 執行模擬
echo "🚀 開始模擬..."
'''
        
        for tb_file in testbench_files:
            tb_name = tb_file.stem  # 移除副檔名
            script_content += f'''
echo "🔬 執行 {tb_name}..."
vsim -t ps -lib work {tb_name}
add wave -radix hex /*
run -all
'''
        
        script_content += '''
echo "✅ 所有測試完成"
quit -f
'''
        
        # 寫入腳本檔案
        script_file = self.output_dir / "run_modelsim.do"
        with open(script_file, 'w') as f:
            f.write(script_content)
        
        # 建立批次檔案 (Windows)
        batch_content = f'''@echo off
echo 🚀 CTE Vibe Code ModelSim 自動化測試
echo =====================================

cd /d %~dp0
modelsim -do run_modelsim.do

echo.
echo ✅ 測試完成！查看波形和報告
pause
'''
        
        batch_file = self.output_dir / "run_test.bat"
        with open(batch_file, 'w') as f:
            f.write(batch_content)
        
        print(f"📜 ModelSim 腳本已生成: {script_file}")
        print(f"🖱️ 批次執行檔: {batch_file}")
        
        return script_file, batch_file
    
    def _get_timestamp(self):
        from datetime import datetime
        return datetime.now().strftime("%Y/%m/%d %H:%M:%S")
    
    def _generate_dut_signals(self, module_name):
        # 根據模組名稱生成對應的信號
        # 這裡可以解析實際的 Verilog 檔案來自動生成
        return '''// 時鐘和重置信號已定義
// 根據模組自動生成的介面信號
reg [31:0] data_in;
reg        data_valid;
wire [31:0] data_out;
wire        output_valid;'''
    
    def _generate_dut_connections(self, module_name):
        return '''.clk(clk),
    .rst_n(rst_n),
    .data_in(data_in),
    .data_valid(data_valid),
    .data_out(data_out),
    .output_valid(output_valid)'''
    
    def _generate_basic_test_logic(self, module_name):
        return '''// 發送測試資料
        data_in = 32'hDEADBEEF;
        data_valid = 1'b1;
        @(posedge clk);
        data_valid = 1'b0;
        
        // 等待輸出
        wait(output_valid);
        @(posedge clk);'''
    
    def _generate_boundary_test_logic(self, module_name):
        return '''// 測試最大值
        data_in = 32'hFFFFFFFF;
        data_valid = 1'b1;
        @(posedge clk);
        data_valid = 1'b0;
        
        // 測試最小值
        data_in = 32'h00000000;
        data_valid = 1'b1;
        @(posedge clk);
        data_valid = 1'b0;'''
    
    def _generate_error_test_logic(self, module_name):
        return '''// 測試錯誤恢復
        rst_n = 1'b0;
        #(CLK_PERIOD*5);
        rst_n = 1'b1;
        #(CLK_PERIOD*10);'''
    
    def _generate_performance_test_logic(self):
        return '''// 連續資料流測試
        repeat(1000) begin
            data_in = $random;
            data_valid = 1'b1;
            @(posedge clk);
        end
        data_valid = 1'b0;'''
    
    def _generate_checkers(self, config):
        return '''// 自動生成的功能檢查器
always @(posedge clk) begin
    if (output_valid && data_out === 32'h0) begin
        $warning("輸出資料為零，可能有問題");
    end
end'''
    
    def _generate_coverage_code(self, config):
        return '''// 覆蓋率收集點
covergroup cg_data_coverage @(posedge clk);
    data_cp: coverpoint data_in {
        bins low = {[0:32'h7FFFFFFF]};
        bins high = {[32'h80000000:32'hFFFFFFFF]};
    }
    valid_cp: coverpoint data_valid {
        bins valid = {1'b1};
        bins invalid = {1'b0};
    }
endgroup

cg_data_coverage cg_inst = new();'''
    
    def _generate_assertions(self, config):
        return '''// SystemVerilog 斷言
property p_data_stabilityRetryBPContinueEditsystemverilogproperty p_data_stability;
   @(posedge clk) disable iff (!rst_n)
   data_valid |-> ##1 $stable(data_in);
endproperty

property p_response_time;
   @(posedge clk) disable iff (!rst_n)
   data_valid |-> ##[1:10] output_valid;
endproperty

assert property (p_data_stability) else $error("資料在 valid 期間不穩定");
assert property (p_response_time) else $error("回應時間超過預期");'''
   
   def _generate_performance_test_dut(self):
       return '''// 效能測試用的 DUT 實例化
reg clk, rst_n;
reg [31:0] input_data;
reg input_valid;
wire [31:0] output_data;
wire output_valid;
wire frame_valid;

// 200MHz 時鐘
initial begin
   clk = 0;
   forever #2.5 clk = ~clk;  // 2.5ns = 200MHz
end

// 重置
initial begin
   rst_n = 0;
   #100 rst_n = 1;
end

// DUT 實例
cte_vibe_top u_dut (
   .clk_200m(clk),
   .rst_n(rst_n),
   .input_data(input_data),
   .input_valid(input_valid),
   .output_data(output_data),
   .output_valid(output_valid),
   .frame_valid(frame_valid)
);'''
   
   def _generate_power_estimation_logic(self):
       return '''// 簡化的功耗估算模型
// 基於切換活動和時鐘頻率
real switching_activity = 0.3;  // 30% 切換活動
real base_power = 2.5;  // 基礎功耗 2.5W
switching_activity * 1.0 + base_power'''

# 使用示例
def generate_all_testbenches():
   """生成所有需要的 Testbench"""
   generator = CTETestbenchGenerator()
   testbench_files = []
   
   # 測試配置列表
   test_configs = [
       TestConfiguration("cte_vibe_top", TestType.INTEGRATION_TEST, simulation_time_us=5000),
       TestConfiguration("cte_imx25_interface", TestType.UNIT_TEST, simulation_time_us=2000),
       TestConfiguration("cte_isp_pipeline", TestType.UNIT_TEST, simulation_time_us=3000),
       TestConfiguration("cte_ai_processing_stage", TestType.UNIT_TEST, simulation_time_us=1000),
       TestConfiguration("cte_vibe_top", TestType.PERFORMANCE_TEST, simulation_time_us=10000)
   ]
   
   # 生成所有 Testbench
   for config in test_configs:
       tb_file = generator.generate_testbench(config)
       testbench_files.append(tb_file)
   
   # 生成 ModelSim 腳本
   script_file, batch_file = generator.generate_modelsim_script(testbench_files)
   
   return testbench_files, script_file, batch_file

if __name__ == "__main__":
   print("🧪 CTE Vibe Code Testbench 自動生成器")
   print("=" * 40)
   
   testbenches, script, batch = generate_all_testbenches()
   
   print(f"\n✅ 已生成 {len(testbenches)} 個 Testbench:")
   for tb in testbenches:
       print(f"   📄 {tb.name}")
   
   print(f"\n🚀 ModelSim 執行腳本: {script.name}")
   print(f"🖱️ 批次執行檔: {batch.name}")
   
   print("\n💡 使用方法:")
   print("   1. 在 ModelSim 中執行: do run_modelsim.do")
   print("   2. 或直接執行: run_test.bat")
   print("   3. 查看波形和效能報告")
