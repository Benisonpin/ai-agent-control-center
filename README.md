# 🎵 CTE Vibe Code - 完整開發平台整合

[![Netlify Status](https://api.netlify.com/api/v1/badges/your-badge-id/deploy-status)](https://app.netlify.com/sites/cte-vibe-code/deploys)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/Benisonpin/ai-agent-control-center)

> AI Image Drone Chip 開發平台 - 整合 OTA 更新、Radiant FPGA、ModelSim 模擬、13種場景AI 的完整解決方案

## 🚀 線上體驗

**正式版本**: [https://cte-vibe-code.netlify.app](https://cte-vibe-code.netlify.app)

## ✨ 核心特色

### 📡 **OTA 更新系統**
- ✅ 13種場景AI模型熱插拔部署
- ✅ 99.5% 更新成功率
- ✅ <3分鐘快速部署
- ✅ 版本回滾支援

### 🔧 **Lattice Radiant FPGA 完整整合**
- ✅ AI ISP SoC RTL設計與源碼管理
- ✅ 自動化邏輯綜合與優化
- ✅ 佈局佈線 (Place & Route)
- ✅ 時序分析 (185MHz@200MHz目標)
- ✅ 功耗分析 (3.5W預估)
- ✅ 位元流生成與部署

### 📊 **ModelSim 模擬環境完整整合**
- ✅ RTL功能模擬與驗證
- ✅ 後端時序模擬
- ✅ 95.3% 代碼覆蓋率分析
- ✅ GTKWave 波形查看整合
- ✅ 4K@32.5fps 性能驗證
- ✅ NPU 2 TOPS 運算驗證

### 🎨 **13種場景AI識別**
- 🌳 戶外自然 (96.8%) 🏠 室內住宅 (94.2%) 🏙️ 城市街道 (97.5%)
- ✈️ 航拍風景 (95.3%) 🌙 夜間場景 (92.7%) 🌊 水域海事 (93.9%)
- 🌲 森林植被 (95.8%) 🌾 農業場景 (94.1%) 🏭 工業場地 (93.4%)#!/bin/bash
# CTE Vibe Code - Netlify 完整部署脚本

echo "🚀 准备 CTE Vibe Code Netlify 部署..."

# 1. 创建项目目录结构
echo "📁 创建目录结构..."
mkdir -p netlify-deploy/{public,functions}
cd netlify-deploy

# 2. 创建主页面文件
echo "📄 创建主页面..."
cat > public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>CTE Vibe Code - 完整開發平台整合</title>
    <meta name="description" content="AI Image Drone Chip 開發平台 - 整合 OTA 更新、Radiant FPGA、ModelSim 模擬、13種場景AI">
    <meta name="keywords" content="AI, ISP, SoC, FPGA, Radiant, ModelSim, OTA, 無人機, 場景識別">
    
    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://cte-vibe-code.netlify.app/">
    <meta property="og:title" content="CTE Vibe Code - AI開發平台">
    <meta property="og:description" content="完整整合 OTA 更新、Radiant FPGA、ModelSim 模擬的 AI ISP SoC 開發平台">
    
    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image">
    <meta property="twitter:url" content="https://cte-vibe-code.netlify.app/">
    <meta property="twitter:title" content="CTE Vibe Code - AI開發平台">
    
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            background: linear-gradient(135deg, #0a0a0a, #1a1a2e, #16213e);
            color: #fff;
            min-height: 100vh;
            overflow-x: hidden;
        }
        
        .loading-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #0a0a0a, #1a1a2e);
            display: flex;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            transition: opacity 0.5s ease;
        }
        
        .loading-content {
            text-align: center;
        }
        
        .loading-logo {
            font-size: 4rem;
            margin-bottom: 1rem;
            animation: pulse 2s infinite;
        }
        
        .loading-text {
            font-size: 1.5rem;
            color: #00d2ff;
            margin-bottom: 2rem;
        }
        
        .loading-bar {
            width: 300px;
            height: 4px;
            background: rgba(255,255,255,0.1);
            border-radius: 2px;
            overflow: hidden;
            margin: 0 auto;
        }
        
        .loading-progress {
            height: 100%;
            background: linear-gradient(90deg, #00d2ff, #3a7bd5);
            width: 0%;
            animation: loading 3s ease-out forwards;
        }
        
        @keyframes pulse {
            0%, 100% { transform: scale(1); opacity: 1; }
            50% { transform: scale(1.1); opacity: 0.8; }
        }
        
        @keyframes loading {
            0% { width: 0%; }
            100% { width: 100%; }
        }
        
        .header {
            text-align: center;
            padding: 3rem 2rem;
            background: linear-gradient(135deg, rgba(26, 26, 46, 0.9), rgba(22, 33, 62, 0.9));
            backdrop-filter: blur(20px);
        }
        
        .header h1 {
            font-size: 3.5rem;
            font-weight: 700;
            background: linear-gradient(45deg, #00d2ff, #3a7bd5, #f093fb);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 1rem;
            text-shadow: 0 0 50px rgba(0, 210, 255, 0.3);
        }
        
        .header .subtitle {
            font-size: 1.5rem;
            color: #a0a0a0;
            margin-bottom: 2rem;
        }
        
        .integration-badge {
            display: inline-block;
            background: linear-gradient(45deg, #ff6b6b, #ffa500);
            padding: 0.8rem 2rem;
            border-radius: 30px;
            font-weight: bold;
            font-size: 1.1rem;
            box-shadow: 0 10px 30px rgba(255, 107, 107, 0.3);
            animation: pulse-badge 2s infinite;
        }
        
        @keyframes pulse-badge {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        
        .main-container {
            max-width: 1600px;
            margin: 0 auto;
            padding: 2rem;
            opacity: 0;
            transform: translateY(50px);
            transition: all 0.8s ease;
        }
        
        .main-container.loaded {
            opacity: 1;
            transform: translateY(0);
        }
        
        .integration-overview {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(350px, 1fr));
            gap: 2rem;
            margin-bottom: 3rem;
        }
        
        .tool-card {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 2rem;
            transition: all 0.4s ease;
            position: relative;
            overflow: hidden;
            opacity: 0;
            transform: translateY(30px);
        }
        
        .tool-card.animate {
            opacity: 1;
            transform: translateY(0);
        }
        
        .tool-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.1), transparent);
            transition: left 0.6s;
        }
        
        .tool-card:hover::before {
            left: 100%;
        }
        
        .tool-card:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(0,0,0,0.4);
            border-color: var(--accent-color);
        }
        
        .tool-card.ota-card {
            --accent-color: #3498db;
        }
        
        .tool-card.radiant-card {
            --accent-color: #e67e22;
        }
        
        .tool-card.modelsim-card {
            --accent-color: #9b59b6;
        }
        
        .tool-card.scenes-card {
            --accent-color: #2ecc71;
        }
        
        .tool-icon {
            font-size: 4rem;
            margin-bottom: 1.5rem;
            display: block;
            text-align: center;
            filter: drop-shadow(0 0 20px rgba(255,255,255,0.3));
        }
        
        .tool-card h3 {
            font-size: 1.8rem;
            margin-bottom: 1rem;
            color: var(--accent-color, #fff);
            text-align: center;
        }
        
        .tool-card .description {
            color: #b0b0b0;
            margin-bottom: 1.5rem;
            line-height: 1.6;
            text-align: center;
        }
        
        .tool-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }
        
        .stat-item {
            background: rgba(0,0,0,0.3);
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            border: 1px solid rgba(255,255,255,0.1);
            transition: all 0.3s ease;
        }
        
        .stat-item:hover {
            background: rgba(0,0,0,0.5);
            transform: scale(1.05);
        }
        
        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: var(--accent-color, #fff);
            display: block;
        }
        
        .stat-label {
            font-size: 0.9rem;
            color: #999;
            margin-top: 0.5rem;
        }
        
        .scenes-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 1rem;
            margin-top: 1.5rem;
        }
        
        .scene-item {
            background: rgba(46, 204, 113, 0.1);
            border: 1px solid #2ecc71;
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .scene-item:hover {
            background: rgba(46, 204, 113, 0.2);
            transform: scale(1.05);
            box-shadow: 0 5px 15px rgba(46, 204, 113, 0.3);
        }
        
        .scene-icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        
        .scene-name {
            font-weight: bold;
            margin-bottom: 0.3rem;
        }
        
        .scene-accuracy {
            color: #2ecc71;
            font-size: 0.9rem;
            font-weight: bold;
        }
        
        .integration-status {
            background: linear-gradient(135deg, rgba(46, 204, 113, 0.1), rgba(39, 174, 96, 0.1));
            border: 1px solid #2ecc71;
            padding: 1.5rem;
            border-radius: 15px;
            margin-top: 2rem;
            text-align: center;
        }
        
        .status-indicator {
            display: inline-block;
            width: 15px;
            height: 15px;
            background: #2ecc71;
            border-radius: 50%;
            margin-right: 1rem;
            animation: pulse-green 2s infinite;
        }
        
        @keyframes pulse-green {
            0%, 100% { box-shadow: 0 0 0 0 rgba(46, 204, 113, 0.7); }
            50% { box-shadow: 0 0 0 15px rgba(46, 204, 113, 0); }
        }
        
        .soc-architecture {
            background: linear-gradient(135deg, rgba(26, 26, 46, 0.9), rgba(22, 33, 62, 0.9));
            border-radius: 20px;
            padding: 3rem;
            margin: 3rem 0;
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .soc-title {
            text-align: center;
            font-size: 2.5rem;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, #00d2ff, #3a7bd5);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        
        .soc-subtitle {
            text-align: center;
            color: #888;
            margin-bottom: 3rem;
            font-size: 1.2rem;
        }
        
        .performance-metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 2rem;
            margin-top: 3rem;
        }
        
        .metric-card {
            background: linear-gradient(135deg, rgba(255, 255, 255, 0.1), rgba(255, 255, 255, 0.05));
            padding: 2rem;
            border-radius: 20px;
            text-align: center;
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 40px rgba(0,0,0,0.3);
        }
        
        .metric-value {
            font-size: 3rem;
            font-weight: bold;
            color: #00d2ff;
            margin-bottom: 0.5rem;
        }
        
        .metric-unit {
            font-size: 1.2rem;
            color: #999;
            margin-bottom: 1rem;
        }
        
        .metric-label {
            color: #ccc;
            font-size: 0.9rem;
        }
        
        .cta-section {
            text-align: center;
            margin: 4rem 0;
            padding: 3rem;
            background: linear-gradient(135deg, rgba(52, 152, 219, 0.1), rgba(155, 89, 182, 0.1));
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .cta-title {
            font-size: 2rem;
            margin-bottom: 1rem;
            color: #fff;
        }
        
        .cta-description {
            color: #bbb;
            margin-bottom: 2rem;
            font-size: 1.1rem;
            max-width: 600px;
            margin-left: auto;
            margin-right: auto;
        }
        
        .cta-button {
            display: inline-block;
            background: linear-gradient(45deg, #3498db, #9b59b6);
            color: white;
            padding: 1rem 3rem;
            border-radius: 50px;
            text-decoration: none;
            font-weight: bold;
            font-size: 1.2rem;
            margin: 1rem;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(52, 152, 219, 0.3);
            border: none;
            cursor: pointer;
        }
        
        .cta-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(52, 152, 219, 0.4);
        }
        
        .cta-button.secondary {
            background: linear-gradient(45deg, #2ecc71, #27ae60);
            box-shadow: 0 10px 30px rgba(46, 204, 113, 0.3);
        }
        
        .cta-button.secondary:hover {
            box-shadow: 0 15px 40px rgba(46, 204, 113, 0.4);
        }
        
        .footer {
            background: rgba(0,0,0,0.5);
            padding: 2rem;
            text-align: center;
            color: #888;
            border-top: 1px solid rgba(255,255,255,0.1);
        }
        
        .footer p {
            margin-bottom: 1rem;
        }
        
        .footer-links {
            display: flex;
            justify-content: center;
            gap: 2rem;
            margin-top: 1rem;
        }
        
        .footer-links a {
            color: #3498db;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        
        .footer-links a:hover {
            color: #00d2ff;
        }
        
        @media (max-width: 768px) {
            .header h1 {
                font-size: 2.5rem;
            }
            
            .integration-overview {
                grid-template-columns: 1fr;
            }
            
            .scenes-grid {
                grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            }
            
            .performance-metrics {
                grid-template-columns: repeat(2, 1fr);
            }
            
            .footer-links {
                flex-direction: column;
                gap: 1rem;
            }
        }
    </style>
</head>
<body>
    <!-- Loading Screen -->
    <div class="loading-screen" id="loadingScreen">
        <div class="loading-content">
            <div class="loading-logo">🎵</div>
            <div class="loading-text">CTE Vibe Code 載入中...</div>
            <div class="loading-bar">
                <div class="loading-progress"></div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <div class="header">
        <h1>🎵 CTE Vibe Code</h1>
        <div class="subtitle">AI Image Drone Chip 開發平台 - 完整的軟硬體整合解決方案</div>
        <div class="integration-badge">✨ 完整整合版 - Radiant + ModelSim + OTA + 13種場景AI</div>
    </div>

    <div class="main-container" id="mainContainer">
        <!-- 整合工具總覽 -->
        <div class="integration-overview">
            <div class="tool-card ota-card">
                <div class="tool-icon">📡</div>
                <h3>OTA 更新系統</h3>
                <div class="description">Over-The-Air 模型更新，支援13種場景AI模型的熱插拔部署</div>
                <div class="tool-stats">
                    <div class="stat-item">
                        <span class="stat-value">13</span>
                        <div class="stat-label">場景模型</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">99.5%</span>
                        <div class="stat-label">成功率</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">&lt;3</span>
                        <div class="stat-label">分鐘部署</div>
                    </div>
                </div>
                <div class="integration-status">
                    <span class="status-indicator"></span>
                    已整合 - 支援即時模型切換
                </div>
            </div>

            <div class="tool-card radiant-card">
                <div class="tool-icon">🔧</div>
                <h3>Lattice Radiant FPGA</h3>
                <div class="description">完整的FPGA開發工具鏈，專為AI ISP SoC設計優化</div>
                <div class="tool-stats">
                    <div class="stat-item">
                        <span class="stat-value">28nm</span>
                        <div class="stat-label">台積電製程</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">49mm²</span>
                        <div class="stat-label">晶片面積</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">484</span>
                        <div class="stat-label">PIN BGA</div>
                    </div>
                </div>
                <div class="integration-status">
                    <span class="status-indicator"></span>
                    已整合 - RTL綜合、佈局佈線、時序分析
                </div>
            </div>

            <div class="tool-card modelsim-card">
                <div class="tool-icon">📊</div>
                <h3>ModelSim 模擬環境</h3>
                <div class="description">進階HDL模擬與驗證，支援4K@32.5fps性能測試</div>
                <div class="tool-stats">
                    <div class="stat-item">
                        <span class="stat-value">95.3%</span>
                        <div class="stat-label">覆蓋率</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">12K</span>
                        <div class="stat-label">Events/sec</div>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value">4K</span>
                        <div class="stat-label">模擬解析度</div>
                    </div>
                </div>
                <div class="integration-status">
                    <span class="status-indicator"></span>
                    已整合 - 功能驗證、時序模擬、波形分析
                </div>
            </div>

            <div class="tool-card scenes-card">
                <div class="tool-icon">🎨</div>
                <h3>13種場景AI識別</h3>
                <div class="description">專為無人機應用設計的多場景自動識別系統</div>
                <div class="scenes-grid">
                    <div class="scene-item" onclick="showSceneDetails('outdoor')">
                        <div class="scene-icon">🌳</div>
                        <div class="scene-name">戶外自然</div>
                        <div class="scene-accuracy">96.8%</div>
                    </div>
                    <div class="scene-item" onclick="showSceneDetails('indoor')">
                        <div class="scene-icon">🏠</div>
                        <div class="scene-name">室內住宅</div>
                        <div class="scene-accuracy">94.2%</div>
                    </div>
                    <div class="scene-item" onclick="showSceneDetails('urban')">
                        <div class="scene-icon">🏙️</div>
                        <div class="scene-name">城市街道</div>
                        <div class="scene-accuracy">97.5%</div>
                    </div>
                    <div class="scene-item" onclick="showSceneDetails('aerial')">
                        <div class="scene-icon">✈️</div>
                        <div class="scene-name">航拍風景</div>
                        <div class="scene-accuracy">95.3%</div>
                    </div>
                    <div class="scene-item" onclick="showSceneDetails('night')">
                        <div class="scene-icon">🌙</div>
                        <div class="scene-name">夜間場景</div>
                        <div class="scene-accuracy">92.7%</div>
                    </div>
                    <div class="scene-item" onclick="showSceneDetails('water')">
                        <div class="scene-icon">🌊</div>
                        <div class="scene-name">水域海事</div>
                        <div class="scene-accuracy">93.9%</div>
                    </div>
                </div>
                <div class="integration-status">
                    <span class="status-indicator"></span>
                    已整合 - 即時場景切換、準確率優化
                </div>
            </div>
        </div>

        <!-- AI ISP SoC 架構 -->
        <div class="soc-architecture">
            <h2 class="soc-title">AI ISP SoC 晶片架構</h2>
            <div class="soc-subtitle">台積電 28nm HPC+ 製程 | 49mm² 晶片面積 | 484-pin BGA 封裝</div>
            
            <div class="performance-metrics">
                <div class="metric-card" onclick="showMetricDetails('fps')">
                    <div class="metric-value" id="fpsValue">32.5</div>
                    <div class="metric-unit">FPS (4K)</div>
                    <div class="metric-label">實測性能</div>
                </div>
                <div class="metric-card" onclick="showMetricDetails('latency')">
                    <div class="metric-value" id="latencyValue">28</div>
                    <div class="metric-unit">延遲 (ms)</div>
                    <div class="metric-label">端到端</div>
                </div>
                <div class="metric-card" onclick="showMetricDetails('power')">
                    <div class="metric-value" id="powerValue">3.5</div>
                    <div class="metric-unit">功耗 (W)</div>
                    <div class="metric-label">總功耗</div>
                </div>
                <div class="metric-card" onclick="showMetricDetails('accuracy')">
                    <div class="metric-value" id="accuracyValue">95.2</div>
                    <div class="metric-unit">準確率 (%)</div>
                    <div class="metric-label">平均準確率</div>
                </div>
            </div>
        </div>

        <!-- 呼籲行動 -->
        <div class="cta-section">
            <h2 class="cta-title">🚀 立即體驗完整整合開發平台</h2>
            <div class="cta-description">
                一站式解決方案：OTA更新 + Radiant FPGA + ModelSim 模擬 + 13種場景AI<br>
                專為無人機 AI ISP SoC 開發而設計的完整工具鏈
            </div>
            <button class="cta-button" onclick="startIntegratedPlatform()">🎵 啟動 CTE Vibe Code</button>
            <a href="https://github.com/Benisonpin/ai-agent-control-center" class="cta-button secondary" target="_blank">📂 查看源碼</a>
        </div>
    </div>

    <!-- Footer -->
    <div class="footer">
        <p>&copy; 2024 CTE Vibe Code. All rights reserved.</p>
        <p>AI Image Drone Chip 開發平台 - 完整的軟硬體整合解決方案</p>
        <div class="footer-links">
            <a href="#" onclick="showDocumentation()">📚 技術文檔</a>
            <a href="#" onclick="showAPIReference()">🔧 API 參考</a>
            <a href="https://github.com/Benisonpin/ai-agent-control-center" target="_blank">💻 GitHub</a>
            <a href="#" onclick="contactSupport()">📧 技術支援</a>
        </div>
    </div>

    <script src="js/main.js"></script>
</body>
</html>
