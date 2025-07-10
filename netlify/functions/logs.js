exports.handler = async (event, context) => {
  const logs = [
    {
      timestamp: new Date().toISOString(),
      level: "INFO",
      message: "系統正常運行"
    }
  ];

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ logs })
  };
};
