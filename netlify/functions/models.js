exports.handler = async (event, context) => {
  const models = {
    models: [
      {
        id: "scene_detector",
        name: "場景檢測器",
        current_version: "2.0.0",
        latest_version: "2.1.0",
        size_mb: 15.2,
        description: "新增霧天和水下場景識別，準確率提升3%",
        update_available: true
      },
      {
        id: "object_tracker",
        name: "物體追蹤器",
        current_version: "1.0.0",
        latest_version: "1.1.0",
        size_mb: 12.5,
        description: "優化多目標追蹤性能，支援最多20個目標",
        update_available: true
      },
      {
        id: "night_mode",
        name: "夜視模式",
        current_version: "1.2.0",
        latest_version: "1.3.0",
        size_mb: 8.7,
        description: "低光環境性能提升30%，降噪算法優化",
        update_available: true
      }
    ],
    last_check: new Date().toISOString()
  };

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*'
    },
    body: JSON.stringify(models)
  };
};
