#!/bin/bash
echo "🚀 增強 Netlify 部署功能..."

# 1. 添加環境變量配置
echo "🔧 配置環境變量..."
cat > .env.example << 'ENV_EOF'
# CTE Vibe Code 環境配置
NODE_ENV=production
NETLIFY_SITE_URL=https://your-site.netlify.app

# GPU 訓練配置
MAX_TRAINING_TIME=72
DEFAULT_BATCH_SIZE=16
SUPPORTED_GPUS=RTX4090,RTX4080,RTX3080,RTX3070

# 資料集配置  
DATASET_BASE_URL=https://datasets.cte.com
ENABLE_DATASET_DOWNLOAD=true
MAX_DATASET_SIZE=2048

# 系統監控
ENABLE_REAL_TIME_MONITORING=true
MONITORING_INTERVAL=2000
LOG_LEVEL=info

# 安全配置
ENABLE_CORS=true
API_RATE_LIMIT=100
SESSION_TIMEOUT=3600
