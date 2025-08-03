// 修復 JavaScript 錯誤腳本
const fs = require('fs');

// 讀取 index.html
let html = fs.readFileSync('public/index.html', 'utf8');

// 修復 showSection 函數
const fixedShowSection = `
        // 顯示不同區塊 (修復版本)
        function showSection(section) {
            // 隱藏所有內容區域
            document.querySelectorAll('.content-area').forEach(area => {
                area.classList.remove('active');
            });
            
            // 顯示指定區域
            const targetSection = document.getElementById(section);
            if (targetSection) {
                targetSection.classList.add('active');
            }
            
            // 更新導航標籤
            document.querySelectorAll('.nav-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // 添加 active 到點擊的標籤
            const clickedTab = event ? event.currentTarget : null;
            if (clickedTab) {
                clickedTab.classList.add('active');
            }
        }
`;

// 修復 showLayer 函數
const fixedShowLayer = `
        // 顯示圖層 (修復版本)
        function showLayer(layerName) {
            // 隱藏所有圖層
            document.querySelectorAll('.layer-content').forEach(layer => {
                layer.style.display = 'none';
            });
            
            // 顯示指定圖層
            const targetLayer = document.getElementById(layerName + '-layer');
            if (targetLayer) {
                targetLayer.style.display = 'block';
            }
            
            // 更新按鈕狀態
            document.querySelectorAll('.layer-btn').forEach(btn => {
                btn.classList.remove('active');
            });
            
            const clickedBtn = event ? event.currentTarget : null;
            if (clickedBtn) {
                clickedBtn.classList.add('active');
            }
        }
`;

// 替換原有的錯誤函數
html = html.replace(/function showSection\([^}]+\}/g, fixedShowSection.trim());
html = html.replace(/function showLayer\([^}]+\}/g, fixedShowLayer.trim());

// 修復任何語法錯誤的冒號
html = html.replace(/:\s*:\s*/g, ':');

// 寫回檔案
fs.writeFileSync('public/index.html', html);
console.log('✅ JavaScript 錯誤已修復');
