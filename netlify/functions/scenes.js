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
