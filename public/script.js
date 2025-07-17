document.addEventListener('DOMContentLoaded', function() {
    // 初始化 - 只顯示系統總覽
    document.querySelectorAll('.section').forEach(section => {
        section.style.display = 'none';
    });
    const overview = document.getElementById('overview');
    if (overview) overview.style.display = 'block';
    
    // 導航功能
    const menuItems = document.querySelectorAll('.menu-item');
    const sectionIds = [
        'overview',
        'scene-recognition', 
        'object-tracking',
        'system-architecture',
        'memory-optimization',
        'hdr-control',
        'performance-analysis'
    ];
    
    menuItems.forEach((button, index) => {
        button.onclick = function() {
            // 更新 active 狀態
            menuItems.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // 隱藏所有 sections
            document.querySelectorAll('.section').forEach(s => {
                s.style.display = 'none';
            });
            
            // 顯示對應的 section
            const targetId = sectionIds[index];
            if (targetId) {
                const target = document.getElementById(targetId);
                if (target) {
                    target.style.display = 'block';
                }
            }
        };
    });
    
    // OTA 更新按鈕
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
    
    // 場景模式按鈕（如果存在）
    const sceneModeButtons = document.querySelectorAll('.scene-mode-btn');
    if (sceneModeButtons.length > 0) {
        sceneModeButtons.forEach(button => {
            button.onclick = function() {
                sceneModeButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
            };
        });
    }
    
    // HDR 開關（如果存在）
    const toggleButtons = document.querySelectorAll('.toggle-btn');
    if (toggleButtons.length > 0) {
        toggleButtons.forEach(button => {
            button.onclick = function() {
                const group = button.parentElement;
                if (group) {
                    group.querySelectorAll('.toggle-btn').forEach(btn => {
                        btn.classList.remove('active');
                    });
                }
                this.classList.add('active');
            };
        });
    }
    
    // 記憶體優化按鈕（如果存在）
    const optButtons = document.querySelectorAll('.opt-button');
    if (optButtons.length > 0) {
        optButtons.forEach(button => {
            button.onclick = function() {
                const originalText = this.textContent;
                this.textContent = '處理中...';
                this.disabled = true;
                
                setTimeout(() => {
                    this.textContent = '✓ 完成';
                    this.style.backgroundColor = '#10b981';
                    
                    setTimeout(() => {
                        this.textContent = originalText;
                        this.style.backgroundColor = '';
                        this.disabled = false;
                    }, 2000);
                }, 1500);
            };
        });
    }
});
