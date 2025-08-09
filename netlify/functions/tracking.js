exports.handler = async (event, context) => {
  const trackingData = {
    totalObjects: Math.floor(5 + Math.random() * 10),
    activeTracking: Math.floor(2 + Math.random() * 5),
    accuracy: (90 + Math.random() * 8).toFixed(1),
    averageConfidence: (85 + Math.random() * 10).toFixed(1),
    processingTime: (15 + Math.random() * 10).toFixed(1),
    objects: [
      { id: 1, type: "person", confidence: 95.2, bbox: [120, 80, 200, 300] },
      { id: 2, type: "car", confidence: 88.7, bbox: [300, 150, 150, 100] },
      { id: 3, type: "bicycle", confidence: 76.3, bbox: [50, 200, 80, 120] }
    ]
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(trackingData)
  };
};
