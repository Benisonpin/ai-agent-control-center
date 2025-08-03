import re

# 讀取檔案
with open("index.html", "r", encoding="utf-8") as f:
    content = f.read()

print(f"原始檔案大小: {len(content)} 字元")

# 方法1: 如果有多個 DOCTYPE，只保留第一個完整的 HTML
doctype_positions = [m.start() for m in re.finditer('<!DOCTYPE html>', content)]
print(f"找到 {len(doctype_positions)} 個 DOCTYPE 宣告")

if len(doctype_positions) > 1:
    # 找到第二個 DOCTYPE 的位置，截斷到那裡
    content = content[:doctype_positions[1]]
    print("已移除重複的 HTML 部分")

# 方法2: 確保只有一個 </html> 結尾
html_end_positions = [m.start() for m in re.finditer('</html>', content)]
print(f"找到 {len(html_end_positions)} 個 </html> 標籤")

if len(html_end_positions) > 1:
    # 只保留到第一個 </html>
    content = content[:html_end_positions[0] + 7]  # +7 for "</html>"

# 確保檔案正確結尾
if not content.strip().endswith('</html>'):
    content = content.strip() + '\n</html>'

# 寫入修復的檔案
with open("index_clean.html", "w", encoding="utf-8") as f:
    f.write(content)

print(f"修復後檔案大小: {len(content)} 字元")
print("已儲存為 index_clean.html")

# 驗證修復結果
with open("index_clean.html", "r", encoding="utf-8") as f:
    fixed_content = f.read()
    navbar_count = fixed_content.count("navbar")
    title_count = fixed_content.count("AI Agent 控制中心 - 進階版")
    print(f"\n修復後: navbar 數量 = {navbar_count}, 標題數量 = {title_count}")
