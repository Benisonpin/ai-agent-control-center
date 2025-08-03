#!/usr/bin/env python3
"""UI 主題編輯器"""
import json
import os
from modern_ui import ModernUI

class ThemeEditor:
    def __init__(self):
        self.themes_file = "ota/custom/ui/themes.json"
        self.load_themes()
        self.ui = ModernUI()
    
    def load_themes(self):
        if os.path.exists(self.themes_file):
            with open(self.themes_file, 'r') as f:
                self.themes = json.load(f)
        else:
            self.themes = {
                "default": {
                    "name": "預設主題",
                    "colors": {
                        "primary": "39",
                        "secondary": "214",
                        "success": "82",
                        "warning": "226",
                        "error": "196"
                    }
                },
                "night": {
                    "name": "夜間模式",
                    "colors": {
                        "primary": "33",
                        "secondary": "99",
                        "success": "46",
                        "warning": "178",
                        "error": "160"
                    }
                },
                "cyberpunk": {
                    "name": "賽博朋克",
                    "colors": {
                        "primary": "201",
                        "secondary": "165",
                        "success": "118",
                        "warning": "220",
                        "error": "197"
                    }
                }
            }
            self.save_themes()
    
    def save_themes(self):
        os.makedirs(os.path.dirname(self.themes_file), exist_ok=True)
        with open(self.themes_file, 'w') as f:
            json.dump(self.themes, f, indent=2)
    
    def preview_theme(self, theme_name):
        """預覽主題"""
        if theme_name not in self.themes:
            print(f"❌ 找不到主題: {theme_name}")
            return
        
        theme = self.themes[theme_name]
        colors = theme['colors']
        
        os.system('clear')
        print(f"\n🎨 預覽主題: {theme['name']}")
        print("="*50)
        
        # 使用主題顏色顯示範例
        for color_type, color_code in colors.items():
            color = f"\033[38;5;{color_code}m"
            reset = "\033[0m"
            print(f"{color}■■■■■{reset} {color_type}: {color}這是{color_type}顏色的範例文字{reset}")
        
        # 顯示範例UI元素
        print("\n📦 範例UI元素:")
        print(f"\033[38;5;{colors['primary']}m╔══════════════════════════╗\033[0m")
        print(f"\033[38;5;{colors['primary']}m║  🚁 無人機控制面板      ║\033[0m")
        print(f"\033[38;5;{colors['primary']}m╚══════════════════════════╝\033[0m")
        
        print(f"\n\033[38;5;{colors['success']}m✅ 操作成功\033[0m")
        print(f"\033[38;5;{colors['warning']}m⚠️  警告訊息\033[0m")
        print(f"\033[38;5;{colors['error']}m❌ 錯誤訊息\033[0m")
    
    def create_custom_theme(self):
        """創建自定義主題"""
        print("\n🎨 創建自定義主題")
        print("="*50)
        
        theme_id = input("主題ID (英文): ")
        theme_name = input("主題名稱: ")
        
        print("\n設置顏色 (輸入 0-255 的數字):")
        print("參考: https://i.stack.imgur.com/KTSQa.png")
        
        colors = {}
        color_types = ["primary", "secondary", "success", "warning", "error"]
        
        for color_type in color_types:
            while True:
                try:
                    color_code = input(f"{color_type} 顏色代碼: ")
                    if 0 <= int(color_code) <= 255:
                        colors[color_type] = color_code
                        break
                    else:
                        print("請輸入 0-255 之間的數字")
                except:
                    print("無效輸入，請輸入數字")
        
        self.themes[theme_id] = {
            "name": theme_name,
            "colors": colors
        }
        
        self.save_themes()
        print(f"\n✅ 主題 '{theme_name}' 已創建")
        
        preview = input("\n是否預覽新主題? (y/n): ")
        if preview.lower() == 'y':
            self.preview_theme(theme_id)
    
    def theme_manager(self):
        """主題管理器"""
        while True:
            os.system('clear')
            print("="*60)
            print("🎨 UI 主題管理器")
            print("="*60)
            
            print("\n可用主題:")
            for i, (theme_id, theme) in enumerate(self.themes.items(), 1):
                print(f"{i}. {theme['name']} ({theme_id})")
            
            print("\n操作選項:")
            print("1. 預覽主題")
            print("2. 創建新主題")
            print("3. 編輯主題")
            print("4. 刪除主題")
            print("5. 匯出主題")
            print("6. 退出")
            
            choice = input("\n選擇 (1-6): ")
            
            if choice == '1':
                theme_list = list(self.themes.keys())
                print("\n選擇要預覽的主題:")
                for i, tid in enumerate(theme_list, 1):
                    print(f"{i}. {self.themes[tid]['name']}")
                
                idx = int(input("選擇 (數字): ")) - 1
                if 0 <= idx < len(theme_list):
                    self.preview_theme(theme_list[idx])
                    input("\n按 Enter 繼續...")
                    
            elif choice == '2':
                self.create_custom_theme()
                input("\n按 Enter 繼續...")
                
            elif choice == '3':
                print("編輯功能開發中...")
                input("\n按 Enter 繼續...")
                
            elif choice == '4':
                theme_list = list(self.themes.keys())
                print("\n選擇要刪除的主題:")
                for i, tid in enumerate(theme_list, 1):
                    print(f"{i}. {self.themes[tid]['name']}")
                
                idx = int(input("選擇 (數字): ")) - 1
                if 0 <= idx < len(theme_list) and theme_list[idx] != 'default':
                    del self.themes[theme_list[idx]]
                    self.save_themes()
                    print("✅ 主題已刪除")
                    input("\n按 Enter 繼續...")
                    
            elif choice == '5':
                export_file = f"ota/custom/ui/theme_export_{datetime.now().strftime('%Y%m%d')}.json"
                with open(export_file, 'w') as f:
                    json.dump(self.themes, f, indent=2)
                print(f"✅ 主題已匯出到: {export_file}")
                input("\n按 Enter 繼續...")
                
            elif choice == '6':
                break

from datetime import datetime

if __name__ == "__main__":
    editor = ThemeEditor()
    editor.theme_manager()
