// 等待 DOM 完全載入
document.addEventListener('DOMContentLoaded', function() {
    // 獲取所有導航項目（根據實際的 HTML 結構調整選擇器）
    const navItems = document.querySelectorAll('.sidebar nav > *'); // 或其他合適的選擇器
    const sections = document.querySelectorAll('.section');

    // 為每個導航項目添加點擊事件
    navItems.forEach(item => {
        item.addEventListener('click', function() {
            // 移除所有項目的 active 類
            navItems.forEach(nav => nav.classList.remove('active'));
            // 添加 active 類到當前項目
            this.classList.add('active');
            
            // 隱藏所有部分
            sections.forEach(section => section.classList.add('hidden'));
            
            // 獲取點擊項目的文字
            const itemText = this.textContent.trim();
            console.log('Clicked:', itemText); // 調試用
            
            switch(itemText) {
                case '系統總覽':
                    const overview = document.getElementById('overview');
                    if (overview) overview.classList.remove('hidden');
                    break;
                case '場景識別':
                case '物件追蹤':
                case '系統架構':
                case '記憶體優化':
                case 'HDR 控制':
                case '效能分析':
                    showComingSoon(itemText);
                    break;
                default:
                    console.log('Unknown item:', itemText);
            }
        });
    });

    // 顯示"即將推出"消息的函數
    function showComingSoon(feature) {
        // 隱藏所有部分
        const allSections = document.querySelectorAll('.section');
        allSections.forEach(section => section.classList.add('hidden'));
        
        // 創建或更新即將推出的部分
        let comingSoonSection = document.getElementById('coming-soon');
        if (!comingSoonSection) {
            comingSoonSection = document.createElement('div');
            comingSoonSection.id = 'coming-soon';
            comingSoonSection.className = 'section';
            document.querySelector('.container').appendChild(comingSoonSection);
        }
        
        comingSoonSection.innerHTML = `
            <div style="text-align: center; padding: 100px 20px;">
                <h2 style="font-size: 48px; margin-bottom: 20px;">🚀</h2>
                <h2>${feature} 功能</h2>
                <p style="color: #888; margin-top: 20px;">此功能正在開發中，敬請期待！</p>
            </div>
        `;
        
        comingSoonSection.classList.remove('hidden');
    }

    // OTA 更新功能
    const updateButtons = document.querySelectorAll('.update-button');
    updateButtons.forEach(button => {
        button.addEventListener('click', function() {
            const card = this.closest('.ota-card');
            const deviceName = card.querySelector('h3').textContent;
            
            if (confirm(`確定要更新 ${deviceName} 嗎？`)) {
                this.textContent = '更新中...';
                this.disabled = true;
                
                // 模擬更新過程
                setTimeout(() => {
                    this.textContent = '已更新';
                    this.style.backgroundColor = '#4caf50';
                }, 3000);
            }
        });
    });

    // 系統狀態更新
    function updateSystemStatus() {
        // 這裡可以添加實時更新系統狀態的代碼
        console.log('System status updated');
    }

    // 每5秒更新一次狀態
    setInterval(updateSystemStatus, 5000);
});
