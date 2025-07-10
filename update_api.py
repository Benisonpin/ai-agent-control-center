with open('public/index.html', 'r', encoding='utf-8') as f:
    content = f.read()

# 替換 API 路徑
content = content.replace('/api/status', '/.netlify/functions/status')
content = content.replace('/api/scenes', '/.netlify/functions/scenes')
content = content.replace('/api/logs', '/.netlify/functions/logs')
content = content.replace('/api/tracking', '/.netlify/functions/tracking')
content = content.replace('/api/architecture', '/.netlify/functions/architecture')
content = content.replace('/api/performance', '/.netlify/functions/performance')

with open('public/index.html', 'w', encoding='utf-8') as f:
    f.write(content)

print("API 路徑已更新")
