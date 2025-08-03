exports.handler = async (event, context) => {
  if (event.httpMethod === 'OPTIONS') {
    return {
      statusCode: 200,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
      },
      body: ''
    };
  }

  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    const { prompt, language = 'python', framework = 'none' } = JSON.parse(event.body);
    
    // 模擬 AI 程式碼生成
    const generatedCode = generateCode(prompt, language, framework);
    
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        status: 'success',
        data: {
          code: generatedCode,
          language: language,
          framework: framework,
          timestamp: new Date().toISOString()
        }
      })
    };
    
  } catch (error) {
    return {
      statusCode: 500,
      headers: {
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        status: 'error',
        message: error.message
      })
    };
  }
};

function generateCode(prompt, language, framework) {
  const templates = {
    python: `# AI 生成的 Python 程式碼
# 描述: ${prompt}
# 框架: ${framework}

def main():
    """主函數"""
    print("程式開始執行...")
    
    # TODO: 實現功能 - ${prompt}
    
    print("程式執行完成")

if __name__ == "__main__":
    main()`,
    
    javascript: `// AI 生成的 JavaScript 程式碼
// 描述: ${prompt}
// 框架: ${framework}

function main() {
    console.log('程式開始執行...');
    
    // TODO: 實現功能 - ${prompt}
    
    console.log('程式執行完成');
}

main();`
  };
  
  return templates[language] || templates.python;
}
