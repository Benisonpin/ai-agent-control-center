exports.handler = async (event, context) => {
  if (event.httpMethod !== 'POST') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' })
    };
  }

  try {
    const { name, email, company, message, interest } = JSON.parse(event.body);
    
    // 基本驗證
    if (!name || !email || !message) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: '請填寫所有必填欄位' })
      };
    }

    // 在實際環境中，這裡會發送郵件或保存到資料庫
    console.log('New contact form submission:', { name, email, company, interest });

    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*'
      },
      body: JSON.stringify({
        success: true,
        message: '感謝您的訊息！我們會盡快回覆。',
        timestamp: new Date().toISOString()
      })
    };
  } catch (error) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: '請求格式錯誤' })
    };
  }
};
