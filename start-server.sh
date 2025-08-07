#!/bin/bash
echo "🚀 启动 CTE Vibe Code 服务器..."

if pgrep -f "python.*http.server" > /dev/null; then
    echo "✅ 服务器已在运行"
else
    cd public
    python3 -m http.server 8080 &
    echo "🎉 服务器已启动"
fi

echo "🌐 请访问: http://localhost:8080/enhanced-vibe-integration.html"
echo "💡 在网页终端中输入: vibe help"
