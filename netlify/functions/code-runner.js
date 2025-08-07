exports.handler = async (event, context) => {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    const { code, language, action = 'run' } = JSON.parse(event.body || '{}');
    
    // 模擬不同語言的執行結果
    const executionResults = {
      python: {
        stdout: `🐍 Python 執行結果:
GPU 檢測: NVIDIA RTX 4090 (24GB)
PyTorch 版本: 2.1.0
CUDA 可用: True
開始訓練...
Epoch 1/100 - Loss: 0.8543 - Accuracy: 78.2%
Epoch 2/100 - Loss: 0.7234 - Accuracy: 82.1%
Epoch 3/100 - Loss: 0.6891 - Accuracy: 84.7%
✅ 訓練步驟執行成功`,
        stderr: '',
        exitCode: 0,
        executionTime: '2.34s'
      },
      
      verilog: {
        stdout: `🔧 Verilog 編譯結果:
ModelSim 編譯器 2023.4
解析模塊: cte_isp_main
檢查語法: ✅ 通過
檢查時序: ✅ 滿足約束
生成網表: ✅ 成功
資源使用: LUT 76%, BRAM 65%, DSP 45%
最大頻率: 125 MHz
✅ HDL 編譯成功`,
        stderr: '',
        exitCode: 0,
        executionTime: '1.87s'
      },
      
      javascript: {
        stdout: `🌐 JavaScript 執行結果:
Node.js v18.17.0
執行用戶代碼...
API 測試: ✅ 通過
函數測試: ✅ 通過
模組載入: ✅ 成功
✅ JavaScript 執行完成`,
        stderr: '',
        exitCode: 0,
        executionTime: '0.92s'
      }
    };

    // 模擬語法檢查
    if (action === 'lint') {
      const lintResults = {
        python: [
          { line: 15, column: 8, type: 'warning', message: '建議使用 f-string 格式化' },
          { line: 23, column: 1, type: 'info', message: '可以使用 enumerate() 簡化循環' }
        ],
        verilog: [
          { line: 8, column: 12, type: 'warning', message: '信號寬度可以更明確' },
          { line: 20, column: 5, type: 'info', message: '建議添加復位條件' }
        ],
        javascript: [
          { line: 5, column: 10, type: 'warning', message: '未使用的變量' }
        ]
      };
      
      return {
        statusCode: 200,
        headers: { 'Access-Control-Allow-Origin': '*' },
        body: JSON.stringify({
          success: true,
          lintResults: lintResults[language] || [],
          language
        })
      };
    }

    // 執行代碼
    const result = executionResults[language] || {
      stdout: `📝 ${language} 代碼執行:
代碼已處理完成
執行環境: CTE Vibe Code Online Editor
✅ 執行成功`,
      stderr: '',
      exitCode: 0,
      executionTime: '1.00s'
    };

    return {
      statusCode: 200,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({
        success: true,
        ...result,
        language,
        timestamp: new Date().toISOString()
      })
    };

  } catch (error) {
    return {
      statusCode: 500,
      headers: { 'Access-Control-Allow-Origin': '*' },
      body: JSON.stringify({
        error: '代碼執行失敗',
        message: error.message
      })
    };
  }
};
