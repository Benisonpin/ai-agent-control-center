document.addEventListener('DOMContentLoaded', function() {
    const navButtons = document.querySelectorAll('.menu-item');
    
    navButtons.forEach(button => {
        button.addEventListener('click', function() {
            // 移除所有 active
            navButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // 隱藏所有 section
            document.querySelectorAll('.section').forEach(section => {
                section.classList.add('hidden');
            });
            
            // 顯示對應內容
            if (this.textContent.trim() === '系統總覽') {
                document.getElementById('overview').classList.remove('hidden');
            }
        });
    });
});
