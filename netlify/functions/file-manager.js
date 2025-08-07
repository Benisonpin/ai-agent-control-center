exports.handler = async (event, context) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS'
      }
    };
  }

  try {
    const { action, path, content, type } = JSON.parse(event.body || '{}');
    
    // 模擬文件系統結構
    const mockFileSystem = {
      '/project': {
        type: 'directory',
        children: {
          'src': {
            type: 'directory',
            children: {
              'main.v': { type: 'file', language: 'verilog', size: '2.1KB' },
              'isp_pipeline.v': { type: 'file', language: 'verilog', size: '5.3KB' },
              'ai_processor.v': { type: 'file', language: 'verilog', size: '8.7KB' },
              'testbench.v': { type: 'file', language: 'verilog', size: '1.8KB' }
            }
          },
          'python': {
            type: 'directory',
            children: {
              'train.py': { type: 'file', language: 'python', size: '12.4KB' },
              'data_loader.py': { type: 'file', language: 'python', size: '3.2KB' },
              'model.py': { type: 'file', language: 'python', size: '7.8KB' },
              'utils.py': { type: 'file', language: 'python', size: '2.1KB' }
            }
          },
          'config': {
            type: 'directory',
            children: {
              'training_config.yaml': { type: 'file', language: 'yaml', size: '0.8KB' },
              'fpga_constraints.sdc': { type: 'file', language: 'tcl', size: '1.2KB' },
              'synthesis.tcl': { type: 'file', language: 'tcl', size: '0.9KB' }
            }
          },
          'docs': {
            type: 'directory',
            children: {
              'README.md': { type: 'file', language: 'markdown', size: '3.4KB' },
              'API.md': { type: 'file', language: 'markdown', size: '5.1KB' }
            }
          }
        }
      }
    };

    // 模擬文件內容
    const mockFileContents = {
      '/project/src/main.v': `// CTE Vibe Code - Main ISP Module
module cte_isp_main (
    input wire clk,
    input wire rst_n,
    input wire [31:0] image_data,
    output wire [31:0] processed_data,
    output wire processing_done
);

    // AI ISP Pipeline
    wire [31:0] enhanced_data;
    wire [31:0] ai_processed_data;
    
    // Stage 1: Image Enhancement
    isp_enhancer enhancer_inst (
        .clk(clk),
        .rst_n(rst_n),
        .image_in(image_data),
        .enhanced_out(enhanced_data)
    );
    
    // Stage 2: AI Processing
    ai_processor ai_inst (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(enhanced_data),
        .ai_out(ai_processed_data),
        .done(processing_done)
    );
    
    assign processed_data = ai_processed_data;
    
endmodule`,
      
      '/project/python/train.py': `#!/usr/bin/env python3
"""
CTE Vibe Code - AI Training Script
13種場景智能識別訓練程序
"""
import torch
import torch.nn as nn
import torchvision.transforms as transforms
from torch.utils.data import DataLoader
import time
import argparse

class CTESceneNet(nn.Module):
    """13種場景識別網路"""
    def __init__(self, num_classes=13):
        super(CTESceneNet, self).__init__()
        self.backbone = torch.hub.load('ultralytics/yolov8', 'yolov8n')
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool2d((1, 1)),
            nn.Flatten(),
            nn.Linear(1024, 512),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(512, num_classes)
        )
    
    def forward(self, x):
        features = self.backbone.backbone(x)
        return self.classifier(features)

def train_model(config):
    """訓練主函數"""
    device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    print(f"🎮 使用設備: {device}")
    
    # 模型初始化
    model = CTESceneNet(num_classes=13).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=config.learning_rate)
    criterion = nn.CrossEntropyLoss()
    
    print("🚀 開始訓練...")
    for epoch in range(config.epochs):
        # 訓練邏輯...
        print(f"Epoch {epoch+1}/{config.epochs}")
    
    print("✅ 訓練完成！")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--epochs', type=int, default=100)
    parser.add_argument('--lr', type=float, default=0.001)
    args = parser.parse_args()
    
    train_model(args)`,
    
      '/project/config/training_config.yaml': `# CTE Vibe Code Training Configuration

model:
  name: "CTESceneNet"
  num_classes: 13
  backbone: "yolov8n"

training:
  epochs: 100
  batch_size: 16
  learning_rate: 0.001
  optimizer: "adam"
  scheduler: "cosine"

data:
  datasets:
    - "coco"
    - "imagenet" 
    - "open_images"
  augmentation:
    horizontal_flip: 0.5
    rotation: 15
    brightness: 0.2
    contrast: 0.2

scenes:
  - "outdoor"      # 戶外自然
  - "indoor"       # 室內住宅  
  - "urban"        # 城市街道
  - "aerial"       # 航拍風景
  - "night"        # 夜間場景
  - "water"        # 水域海事
  - "forest"       # 森林植被
  - "agriculture"  # 農業場景
  - "industrial"   # 工業場地
  - "beach"        # 海岸沙灘
  - "mountain"     # 山地地形
  - "desert"       # 沙漠乾旱
  - "detection"    # 目標檢測

gpu:
  enable: true
  mixed_precision: true
  distributed: false`
    };

    switch (action) {
      case 'list':
        // 列出文件和目錄
        const targetPath = path || '/project';
        const targetNode = getNodeAtPath(mockFileSystem, targetPath);
        
        if (targetNode && targetNode.type === 'directory') {
          const items = Object.entries(targetNode.children || {}).map(([name, node]) => ({
            name,
            type: node.type,
            language: node.language,
            size: node.size,
            path: `${targetPath}/${name}`.replace('//', '/')
          }));
          
          return {
            statusCode: 200,
            headers: { 'Access-Control-Allow-Origin': '*' },
            body: JSON.stringify({ success: true, items })
          };
        }
        break;
        
      case 'read':
        // 讀取文件內容
        const fileContent = mockFileContents[path] || `// 文件: ${path}\n// 這是一個示例文件\n\nconsole.log("Hello from ${path}");`;
        
        return {
          statusCode: 200,
          headers: { 'Access-Control-Allow-Origin': '*' },
          body: JSON.stringify({ 
            success: true, 
            content: fileContent,
            path: path,
            language: detectLanguage(path)
          })
        };
        
      case 'save':
        // 保存文件
        console.log(`Saving file: ${path}`);
        console.log(`Content length: ${content?.length || 0} characters`);
        
        return {
          statusCode: 200,
          headers: { 'Access-Control-Allow-Origin': '*' },
          body: JSON.stringify({ 
            success: true, 
            message: `文件 ${path} 已保存`,
            timestamp: new Date().toISOString()
          })
        };
        
      case 'create':
        // 創建新文件
        return {
          statusCode: 200,
          headers: { 'Access-Control-Allow-Origin': '*' },
          body: JSON.stringify({ 
            success: true, 
            message: `${type} ${path} 已創建`
          })
        };
        
      default:
        return {
          statusCode: 400,
          headers: { 'Access-Control-Allow-Origin': '*' },
          body: JSON.stringify({ error: 'Invalid action' })
        };
    }

  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: error.message })
    };
  }
};

function getNodeAtPath(fs, path) {
  const parts = path.split('/').filter(p => p);
  let current = fs;
  
  for (const part of parts) {
    if (current && current[part]) {
      current = current[part];
    } else if (current && current.children && current.children[part]) {
      current = current.children[part];
    } else {
      return null;
    }
  }
  
  return current;
}

function detectLanguage(path) {
  const ext = path.split('.').pop();
  const langMap = {
    'v': 'verilog',
    'sv': 'systemverilog', 
    'py': 'python',
    'js': 'javascript',
    'ts': 'typescript',
    'cpp': 'cpp',
    'c': 'c',
    'h': 'c',
    'yaml': 'yaml',
    'yml': 'yaml',
    'json': 'json',
    'md': 'markdown',
    'tcl': 'tcl',
    'sdc': 'tcl'
  };
  return langMap[ext] || 'text';
}
