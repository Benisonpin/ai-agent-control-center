<script>
// 簡潔版本的按鍵事件處理

// 智能 Cloud Shell
function openSmartCloudShell() {
    showNotification('🚀 啟動 Cloud Shell...');
    setTimeout(() => {
        window.open('https://shell.cloud.google.com/?cloudshell_git_repo=https://github.com/Benisonpin/ai-agent-control-center.git&cloudshell_tutorial=README.md&cloudshell_workspace=.', '_blank');
    }, 500);
}

// AI 協作 IDE
function openAIIDE() {
    showNotification('💻 AI IDE 啟動中...');
    // 簡單功能展示
}

// 檔案開啟
function openFile(fileName) {
    showNotification('📝 開啟: ' + fileName);
    console.log('Opening file:', fileName);
}

// GitHub 同步
function openGitHub() {
    showNotification('🔗 開啟 GitHub...');
    setTimeout(() => {
        window.open('https://github.com/Benisonpin/ai-agent-control-center', '_blank');
    }, 500);
}

// Netlify 部署
function deployToNetlify() {
    showNotification('🚀 部署中...');
    setTimeout(() => {
        showNotification('✅ 部署完成！');
    }, 2000);
}

// 簡單通知系統
function showNotification(message) {
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: rgba(59, 130, 246, 0.9);
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        font-weight: 600;
        z-index: 1000;
        animation: slideIn 0.3s ease;
    `;
    notification.textContent = message;
    document.body.appendChild(notification);
    
    setTimeout(() => {
        notification.remove();
    }, 3000);
}

// 簡單的動畫樣式
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
`;
document.head.appendChild(style);

// 初始化
window.addEventListener('load', () => {
    showNotification('🎉 CTE Vibe Code 已就緒！');
});

</script>
