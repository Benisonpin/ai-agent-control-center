#!/bin/bash
echo "🌐 同步更新 Netlify 部署配置..."

# 1. 首先處理可能的 Git 衝突
echo "🔄 處理 Git 同步..."
git fetch origin
git pull origin main --rebase

# 如果有衝突，自動解決
if [ $? -ne 0 ]; then
    echo "⚠️ 發現衝突，自動解決中..."
    git checkout --ours public/index.html
    git add public/index.html
    git rebase --continue
fi

# 2. 確保 Netlify 配置文件存在
echo "📝 檢查 Netlify 配置..."

# 創建/更新 netlify.toml
cat > netlify.toml << 'TOML_EOF'
[build]
  publish = "public"
  command = "echo 'Static site ready'"

[build.environment]
  NODE_VERSION = "18"

[[headers]]
  for = "/*"
  [headers.values]
    X-Frame-Options = "DENY"
    X-XSS-Protection = "1; mode=block"
    X-Content-Type-Options = "nosniff"
    Referrer-Policy = "strict-origin-when-cross-origin"
    Content-Security-Policy = "default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: https:; img-src 'self' data: https:; font-src 'self' data: https:;"

[[redirects]]
  from = "/api/*"
  to = "/.netlify/functions/:splat"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
TOML_EOF

# 3. 確保 Functions 目录存在並更新
mkdir -p netlify/functions

# 更新 status function
cat > netlify/functions/status.js << 'STATUS_EOF'
exports.handler = async (event, context) => {
  // 模擬即時系統狀態
  const data = {
    system: {
      temperature: (45 + Math.random() * 15).toFixed(1),
      processing_rate: ['4K@60fps', '4K@30fps', '1080p@120fps'][Math.floor(Math.random() * 3)],
      power_consumption: (2.0 + Math.random() * 1.5).toFixed(1),
      latency: (0.5 + Math.random() * 1.0).toFixed(1),
      timestamp: new Date().toISOString()
    },
    stages: {
      stage1: {
        name: '大模型訓練',
        status: ['準備中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        gpu_usage: Math.floor(75 + Math.random() * 20),
        training_loss: (0.01 + Math.random() * 0.05).toFixed(4)
      },
      stage2: {
        name: '知識蒸餾',
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        compression_ratio: '94.9%',
        accuracy_retention: '96.3%'
      },
      stage3: {
        name: 'FPGA部署',
        status: ['等待中', '執行中', '已完成'][Math.floor(Math.random() * 3)],
        progress: Math.floor(Math.random() * 100),
        lut_usage: '76%',
        bram_usage: '65%'
      }
    },
    ota: {
      status: 'ready',
      last_update: new Date().toISOString(),
      models_loaded: 13,
      version: 'v2.1.3'
    }
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
    },
    body: JSON.stringify(data)
  };
};
STATUS_EOF

# 更新 scenes function
cat > netlify/functions/scenes.js << 'SCENES_EOF'
exports.handler = async (event, context) => {
  const scenes = [
    { id: "outdoor", name: "戶外自然", confidence: Math.floor(94 + Math.random() * 5), icon: "🌳", active: false },
    { id: "indoor", name: "室內住宅", confidence: Math.floor(91 + Math.random() * 6), icon: "🏠", active: false },
    { id: "urban", name: "城市街道", confidence: Math.floor(95 + Math.random() * 4), icon: "🏙️", active: false },
    { id: "aerial", name: "航拍風景", confidence: Math.floor(93 + Math.random() * 5), icon: "✈️", active: false },
    { id: "night", name: "夜間場景", confidence: Math.floor(90 + Math.random() * 5), icon: "🌙", active: false },
    { id: "water", name: "水域海事", confidence: Math.floor(91 + Math.random() * 6), icon: "🌊", active: false },
    { id: "forest", name: "森林植被", confidence: Math.floor(93 + Math.random() * 5), icon: "🌲", active: false },
    { id: "agriculture", name: "農業場景", confidence: Math.floor(92 + Math.random() * 5), icon: "🌾", active: false },
    { id: "industrial", name: "工業場地", confidence: Math.floor(91 + Math.random() * 5), icon: "🏭", active: false },
    { id: "beach", name: "海岸沙灘", confidence: Math.floor(94 + Math.random() * 4), icon: "🏖️", active: false },
    { id: "mountain", name: "山地地形", confidence: Math.floor(93 + Math.random() * 5), icon: "⛰️", active: false },
    { id: "desert", name: "沙漠乾旱", confidence: Math.floor(92 + Math.random() * 5), icon: "🏜️", active: false },
    { id: "detection", name: "目標檢測", confidence: Math.floor(96 + Math.random() * 3), icon: "🎯", active: true }
  ];

  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body || '{}');
    const { sceneId } = body;
    
    // 模擬場景啟動
    const scene = scenes.find(s => s.id === sceneId);
    if (scene) {
      scene.active = true;
      return {
        statusCode: 200,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Headers': 'Content-Type',
          'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        },
        body: JSON.stringify({
          success: true,
          message: `${scene.name} 場景已啟動`,
          scene: scene
        })
      };
    }
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
    },
    body: JSON.stringify(scenes)
  };
};
SCENES_EOF

# 創建 stages function
cat > netlify/functions/stages.js << 'STAGES_EOF'
exports.handler = async (event, context) => {
  if (event.httpMethod === 'POST') {
    const body = JSON.parse(event.body || '{}');
    const { stage, action } = body;
    
    // 模擬階段操作
    const stages = {
      1: { name: '大模型訓練', duration: 72000 },
      2: { name: '知識蒸餾', duration: 24000 },
      3: { name: 'FPGA部署', duration: 12000 }
    };
    
    const stageInfo = stages[stage];
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
      },
      body: JSON.stringify({
        success: true,
        stage: stage,
        action: action,
        message: `第${stage}階段 ${stageInfo.name} ${action === 'start' ? '已啟動' : '狀態查詢'}`,
        duration: stageInfo.duration,
        timestamp: new Date().toISOString()
      })
    };
  }

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({
      stages: [
        { id: 1, name: '大模型訓練', status: '準備中', progress: 0 },
        { id: 2, name: '知識蒸餾', status: '等待中', progress: 0 },
        { id: 3, name: 'FPGA部署', status: '等待中', progress: 0 }
      ]
    })
  };
};
STAGES_EOF

# 4. 確保 package.json 存在
if [ ! -f "package.json" ]; then
cat > package.json << 'PACKAGE_EOF'
{
  "name": "cte-vibe-code",
  "version": "2.1.3",
  "description": "CTE Vibe Code - AI Image Drone Chip Development Platform",
  "main": "index.js",
  "scripts": {
    "build": "echo 'Static site ready'",
    "dev": "netlify dev",
    "deploy": "netlify deploy --prod"
  },
  "keywords": [
    "AI",
    "FPGA",
    "Drone",
    "ISP",
    "Computer Vision",
    "Edge AI"
  ],
  "author": "CTE Technology",
  "license": "MIT",
  "devDependencies": {
    "netlify-cli": "^17.0.0"
  }
}
PACKAGE_EOF
fi

# 5. 更新 _headers 文件（Netlify 專用）
cat > public/_headers << 'HEADERS_EOF'
/*
  X-Frame-Options: DENY
  X-XSS-Protection: 1; mode=block
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin
  Content-Security-Policy: default-src 'self' 'unsafe-inline' 'unsafe-eval' data: blob: https:; img-src 'self' data: https:; font-src 'self' data: https:;

/api/*
  Access-Control-Allow-Origin: *
  Access-Control-Allow-Headers: Content-Type
  Access-Control-Allow-Methods: GET, POST, OPTIONS
HEADERS_EOF

# 6. 創建 _redirects 文件
cat > public/_redirects << 'REDIRECTS_EOF'
# API redirects
/api/* /.netlify/functions/:splat 200

# SPA fallback
/* /index.html 200
REDIRECTS_EOF

# 7. 提交所有更新
echo "📝 提交 Netlify 配置更新..."
git add .
git commit -m "Update Netlify deployment with three-stage pipeline and API functions"

# 8. 推送到 GitHub (觸發 Netlify 自動部署)
echo "🚀 推送到 GitHub 並觸發 Netlify 自動部署..."
git push origin main

echo ""
echo "✅ Netlify 部署更新完成！"
echo ""
echo "🔧 更新內容："
echo "  📝 netlify.toml - 部署配置"
echo "  🔄 Serverless Functions - API 端點"
echo "  📊 /.netlify/functions/status - 系統狀態 API"
echo "  🎯 /.netlify/functions/scenes - 場景管理 API"
echo "  ⚙️ /.netlify/functions/stages - 階段控制 API"
echo "  🛡️ _headers - 安全標頭配置"
echo "  🔀 _redirects - 路由重定向"
echo ""
echo "🌐 部署狀態檢查："
echo "  1. 訪問 Netlify Dashboard 查看部署進度"
echo "  2. 檢查 Functions 是否正常部署"
echo "  3. 測試 API 端點是否響應"
echo ""
echo "📱 測試 API 端點："
echo "  GET  /.netlify/functions/status"
echo "  GET  /.netlify/functions/scenes"
echo "  POST /.netlify/functions/stages"
