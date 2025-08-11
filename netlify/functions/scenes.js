exports.handler = async (event, context) => {
  const scenes = [
    { id: "sunny_city", name: "晴天都市", confidence: 94.2, icon: "🏙️", enabled: true, usage_count: 1245 },
    { id: "night_city", name: "夜間都市", confidence: 12.8, icon: "🌃", enabled: true, usage_count: 867 },
    { id: "landscape", name: "自然風景", confidence: 8.5, icon: "🏔️", enabled: true, usage_count: 2103 },
    { id: "portrait", name: "人像模式", confidence: 85.3, icon: "👤", enabled: true, usage_count: 3456 },
    { id: "macro", name: "微距攝影", confidence: 3.2, icon: "🔍", enabled: true, usage_count: 567 },
    { id: "sports", name: "運動模式", confidence: 15.7, icon: "🏃‍♂️", enabled: true, usage_count: 234 },
    { id: "food", name: "美食攝影", confidence: 45.8, icon: "🍽️", enabled: true, usage_count: 789 },
    { id: "lowlight", name: "低光環境", confidence: 78.9, icon: "🌙", enabled: true, usage_count: 1678 },
    { id: "pet", name: "寵物攝影", confidence: 32.6, icon: "🐕", enabled: true, usage_count: 1234 }
  ];

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify({ scenes, total_scenes: scenes.length })
  };
};
