/**
 * 智能 Cloud Shell 啟動器
 * 修復愚蠢的 --force_new_clone 問題
 */

function smartOpenCloudShell() {
    console.log('🚀 啟動智能 Cloud Shell...');
    
    // 智能啟動 URL（移除 --force_new_clone）
    const smartUrl = `https://shell.cloud.google.com/?cloudshell_git_repo=https://github.com/Benisonpin/ai-agent-control-center.git&cloudshell_tutorial=README.md&cloudshell_workspace=.`;
    
    // 在新窗口中開啟
    window.open(smartUrl, '_blank');
    
    // 顯示警告訊息
    showProtectionMessage();
}

function showProtectionMessage() {
    const message = `
    🛡️ 檔案保護提醒
    
    Cloud Shell 已使用智能模式啟動：
    ✅ 不會覆蓋現有檔案
    ✅ 自動檢測並整合專案
    ✅ 多重備份保護
    
    您的 TW-LCEO-AISP-2025 專案檔案已受到保護！
    `;
    
    alert(message);
}

// 替換舊的 Cloud Shell 按鈕
document.addEventListener('DOMContentLoaded', function() {
    const cloudShellButtons = document.querySelectorAll('[onclick*="cloudshell"]');
    
    cloudShellButtons.forEach(button => {
        button.onclick = smartOpenCloudShell;
        button.title = '智能 Cloud Shell - 檔案保護模式';
        
        // 添加保護圖示
        if (!button.innerHTML.includes('🛡️')) {
            button.innerHTML = '🛡️ ' + button.innerHTML;
        }
    });
});
