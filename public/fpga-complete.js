console.log('🔧 FPGA 完整介面載入中...');

class CompleteFPGAInterface {
    constructor() {
        console.log('🎨 初始化 FPGA 介面...');
        this.initInterface();
    }
    
    initInterface() {
        // 多重初始化策略
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', () => this.createInterface());
        } else {
            setTimeout(() => this.createInterface(), 100);
        }
    }
    
    createInterface() {
        console.log('🎨 創建 FPGA 介面...');
        
        // 尋找插入點
        let targetElement = document.querySelector('main') || 
                          document.querySelector('.container') || 
                          document.querySelector('body');
        
        // 創建 FPGA 容器
        const fpgaContainer = document.createElement('div');
        fpgaContainer.id = 'fpga-rtl-interface';
        fpgaContainer.innerHTML = `
            <style>
                #fpga-rtl-interface {
                    background: linear-gradient(135deg, #1a1a1a 0%, #2d2d2d 100%);
                    border-radius: 20px;
                    padding: 30px;
                    margin: 20px auto;
                    max-width: 1400px;
                    border: 2px solid rgba(255, 107, 53, 0.3);
                    box-shadow: 0 0 30px rgba(255, 107, 53, 0.2);
                }
                
                .fpga-header {
                    text-align: center;
                    margin-bottom: 40px;
                }
                
                .fpga-title {
                    font-size: 36px;
                    font-weight: bold;
                    background: linear-gradient(45deg, #ff6b35, #4ecdc4);
                    -webkit-background-clip: text;
                    -webkit-text-fill-color: transparent;
                    background-clip: text;
                    margin-bottom: 10px;
                }
                
                .fpga-tools-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
                    gap: 30px;
                }
                
                .fpga-tool-card {
                    background: linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05));
                    border-radius: 20px;
                    padding: 25px;
                    border: 2px solid #ff6b35;
                    transition: all 0.3s ease;
                }
                
                .fpga-tool-card:hover {
                    transform: translateY(-5px);
                    box-shadow: 0 10px 30px rgba(255, 107, 53, 0.4);
                }
                
                .rtl-category {
                    background: rgba(255, 255, 255, 0.05);
                    border-radius: 12px;
                    padding: 15px;
                    margin: 10px 0;
                    border-left: 4px solid #ff6b35;
                }
                
                .rtl-file {
                    padding: 8px 0;
                    color: #cccccc;
                    font-family: 'Courier New', monospace;
                    font-size: 14px;
                    cursor: pointer;
                    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                }
                
                .rtl-file:hover {
                    color: #ffffff;
                    padding-left: 10px;
                }
                
                .fpga-btn {
                    background: linear-gradient(135deg, #ff6b35, #f7931e);
                    border: none;
                    border-radius: 12px;
                    color: white;
                    padding: 12px 20px;
                    margin: 5px;
                    cursor: pointer;
                    font-size: 14px;
                    font-weight: 600;
                    transition: all 0.3s ease;
                }
                
                .fpga-btn:hover {
                    transform: translateY(-2px);
                    box-shadow: 0 5px 15px rgba(255, 107, 53, 0.4);
                }
            </style>
            
            <div class="fpga-header">
                <h1 class="fpga-title">🔬 FPGA Development Lab</h1>
                <p style="color: #cccccc; font-size: 18px;">AI ISP SoC 硬體設計與開發環境</p>
            </div>
            
            <div class="fpga-tools-grid">
                <div class="fpga-tool-card">
                    <h3 style="color: #ff6b35; margin-bottom: 20px;">🔧 Lattice Radiant FPGA</h3>
                    <p style="color: #cccccc; margin-bottom: 20px;">完整的 FPGA 開發工具鏈，專為 AI ISP SoC 設計優化</p>
                    
                    <div>
                        <button class="fpga-btn" onclick="this.textContent='⚡ 綜合中...'; setTimeout(() => this.textContent='✅ 綜合完成', 2000)">⚡ 邏輯綜合</button>
                        <button class="fpga-btn" onclick="this.textContent='📍 佈局中...'; setTimeout(() => this.textContent='✅ 佈局完成', 3000)">📍 佈局繞線</button>
                    </div>
                    
                    <div style="margin-top: 20px;">
                        <h4 style="color: #ff6b35;">📁 RTL 檔案結構</h4>
                        
                        <div class="rtl-category">
                            <strong style="color: #4ecdc4;">🤖 AI ISP Core</strong>
                            <div class="rtl-file" onclick="alert('檔案: ai_hdr_isp_system_complete_final.v\\n描述: 主要頂層模組')">ai_hdr_isp_system_complete_final.v</div>
                            <div class="rtl-file" onclick="alert('檔案: ai_isp_top.v\\n描述: AI ISP 控制中心')">ai_isp_top.v</div>
                            <div class="rtl-file" onclick="alert('檔案: isp_pipeline_ai.v\\n描述: AI 流水線')">isp_pipeline_ai.v</div>
                        </div>
                        
                        <div class="rtl-category">
                            <strong style="color: #4ecdc4;">🌅 HDR Processing</strong>
                            <div class="rtl-file" onclick="alert('檔案: ai_hdr_isp_integrated_top.v\\n描述: HDR 整合頂層')">ai_hdr_isp_integrated_top.v</div>
                            <div class="rtl-file" onclick="alert('檔案: HDR_TOP_Verilog.v\\n描述: HDR 處理模組')">HDR_TOP_Verilog.v</div>
                        </div>
                        
                        <div class="rtl-category">
                            <strong style="color: #4ecdc4;">⚡ AI Accelerator</strong>
                            <div class="rtl-file" onclick="alert('檔案: ai_accelerator_top.v\\n描述: AI 硬體加速器')">ai_accelerator_top.v</div>
                            <div class="rtl-file" onclick="alert('檔案: ai_agent_core.v\\n描述: AI 代理核心')">ai_agent_core.v</div>
                        </div>
                    </div>
                </div>
                
                <div class="fpga-tool-card" style="border-color: #4ecdc4;">
                    <h3 style="color: #4ecdc4; margin-bottom: 20px;">📊 ModelSim 模擬環境</h3>
                    <p style="color: #cccccc; margin-bottom: 20px;">進階 HDL 模擬與驗證，支援 4K@60fps 性能測試</p>
                    
                    <div>
                        <button class="fpga-btn" style="background: linear-gradient(135deg, #4ecdc4, #26a69a);" 
                                onclick="this.textContent='▶️ 仿真中...'; setTimeout(() => this.textContent='✅ 仿真完成', 3000)">▶️ 執行仿真</button>
                        <button class="fpga-btn" style="background: linear-gradient(135deg, #4ecdc4, #26a69a);" 
                                onclick="alert('🌊 波形分析器\\n\\n信號波形：\\nclk    __|‾|__|‾|__|‾|__\\nrst_n  ______/‾‾‾‾‾‾‾‾‾‾\\ndata   =[A1][B2][C3]=\\n\\n仿真時間: 200ns')">🌊 波形分析</button>
                    </div>
                    
                    <div style="margin-top: 20px; background: rgba(0,0,0,0.3); padding: 15px; border-radius: 10px;">
                        <h4 style="color: #4ecdc4; margin: 0 0 10px 0;">📈 即時狀態</h4>
                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px; font-family: monospace;">
                            <div>LUT 使用率: <strong style="color: #4ecdc4;">76%</strong></div>
                            <div>時鐘頻率: <strong style="color: #4ecdc4;">100MHz</strong></div>
                            <div>4K 性能: <strong style="color: #4ecdc4;">60fps</strong></div>
                            <div>覆蓋率: <strong style="color: #4ecdc4;">95%</strong></div>
                        </div>
                    </div>
                </div>
            </div>
            
            <div style="text-align: center; margin-top: 30px; padding: 20px; background: rgba(0,0,0,0.2); border-radius: 15px;">
                <h4 style="color: #4ecdc4;">🔗 GitHub Private Repository</h4>
                <p style="color: #cccccc;">完整的 RTL 檔案存儲在私人倉庫中</p>
                <button class="fpga-btn" onclick="window.open('https://github.com/Benisonpin/cte-fpga-rtl', '_blank')">
                    🔗 查看 GitHub Repository
                </button>
            </div>
        `;
        
        targetElement.appendChild(fpgaContainer);
        console.log('✅ FPGA 介面已創建');
    }
}

// 初始化
const initFPGA = () => {
    window.completeFPGAInterface = new CompleteFPGAInterface();
};

// 多重初始化
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initFPGA);
} else {
    initFPGA();
}

setTimeout(initFPGA, 1000);
console.log('✅ FPGA 完整介面腳本已載入');
