document.addEventListener('DOMContentLoaded', function() {
    const navButtons = document.querySelectorAll('.menu-item');
    
    navButtons.forEach(button => {
        button.onclick = function() {
            // 移除所有 active
            navButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // 隱藏所有 section
            document.querySelectorAll('.section').forEach(section => {
                section.style.display = 'none';
            });
            
            // 顯示對應內容
            const text = this.textContent.trim();
            if (text === '系統總覽') {
                const overview = document.getElementById('overview');
                if (overview) overview.style.display = 'block';
            } else {
                // 創建或顯示即將推出頁面
                let coming = document.getElementById('coming-soon');
                if (!coming) {
                    coming = document.createElement('div');
                    coming.id = 'coming-soon';
                    coming.className = 'section';
                    document.querySelector('.container').appendChild(coming);
                }
                coming.innerHTML = `
                    <div style="text-align: center; padding: 100px 20px;">
                        <h1 style="font-size: 48px;">🚀</h1>
                        <h2>${text} 功能</h2>
                        <p style="color: #888;">此功能正在開發中，敬請期待！</p>
                    </div>
                `;
                coming.style.display = 'block';
            }
        };
    });
    
    // OTA 更新按鈕功能
    document.querySelectorAll('.update-button').forEach(button => {
        button.onclick = function() {
            this.textContent = '更新中...';
            this.disabled = true;
            
            setTimeout(() => {
                this.textContent = '已更新';
                this.style.backgroundColor = '#4caf50';
            }, 3000);
        };
    });
});
