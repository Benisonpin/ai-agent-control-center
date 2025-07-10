exports.handler = async (event, context) => {
  const scenes = [
    { id: "indoor", name: "室內", confidence: Math.floor(90 + Math.random() * 8), icon: "🏠" },
    { id: "outdoor", name: "室外", confidence: Math.floor(2 + Math.random() * 8), icon: "🌳" },
    { id: "day", name: "日間", confidence: Math.floor(80 + Math.random() * 10), icon: "☀️" },
    { id: "night", name: "夜間", confidence: Math.floor(10 + Math.random() * 10), icon: "🌙" }
  ];

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ scenes })
  };
};
