// 等待 DOM 完全載入
document.addEventListener('DOMContentLoaded', function() {
    // 獲取所有導航按鈕
    const navButtons = document.querySelectorAll('.menu-item');
    const sections = document.querySelectorAll('.section');
    
    // 為每個導航按鈕添加點擊事件
    navButtons.forEach(button => {
        button.addEventListener('click', () => {
            // 移除所有按鈕的 active 類
            navButtons.forEach(btn => btn.classList.remove('active'));
            // 添加 active 類到當前按鈕
            button.classList.add('active');
            
            // 隱藏所有部分
            sections.forEach(section => section.classList.add('hidden'));
            
            // 根據按鈕文字顯示對應的部分
            const buttonText = button.textContent.trim();
            
            switch(buttonText) {
                case '系統總覽':
                    document.getElementById('overview').classList.remove('hidden');
                    break;
                case '場景識別':
                    showComingSoon('場景識別');
                    break;
                case '物件追蹤':
                    showComingSoon('物件追蹤');
                    break;
                case '系統架構':
                    showComingSoon('系統架構');
                    break;
                case '記憶體優化':
                    showComingSoon('記憶體優化');
                    break;
                case 'HDR 控制':
                    showComingSoon('HDR 控制');
                    break;
                case '效能分析':
                    showComingSoon('效能分析');
                    break;
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
                th
