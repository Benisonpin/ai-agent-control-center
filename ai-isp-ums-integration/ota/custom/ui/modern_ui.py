#!/usr/bin/env python3
"""現代化 OTA 使用者介面"""
import os
import sys
import time
from datetime import datetime

class ModernUI:
    def __init__(self):
        # 顏色配置
        self.colors = {
            'primary': '\033[38;5;39m',    # 亮藍色
            'secondary': '\033[38;5;214m',  # 橙色
            'success': '\033[38;5;82m',     # 綠色
            'warning': '\033[38;5;226m',    # 黃色
            'error': '\033[38;5;196m',      # 紅色
            'info': '\033[38;5;45m',        # 青色
            'reset': '\033[0m',
            'bold': '\033[1m',
            'dim': '\033[2m'
        }
        
    def gradient_text(self, text, start_color=39, end_color=45):
        """創建漸變文字效果"""
        result = ""
        length = len(text)
        for i, char in enumerate(text):
            color = start_color + int((end_color - start_color) * i / length)
            result += f"\033[38;5;{color}m{char}"
        return result + self.colors['reset']
    
    def animated_logo(self):
        """動畫 LOGO"""
        logo = [
            "     ╭─────────────────────────────╮     ",
            "     │      🚁 DRONE OTA 2.0       │     ",
            "     ╰─────────────────────────────╯     "
        ]
        
        for line in logo:
            print(self.gradient_text(line.center(70)))
            time.sleep(0.1)
    
    def progress_bar_advanced(self, current, total, label=""):
        """進階進度條"""
        percent = current / total
        bar_length = 40
        filled = int(bar_length * percent)
        
        # 漸變色進度條
        bar = ""
        for i in range(bar_length):
            if i < filled:
                color_index = 82 + int((196 - 82) * i / bar_length)
                bar += f"\033[38;5;{color_index}m█"
            else:
                bar += f"{self.colors['dim']}░"
        
        # 百分比和標籤
        percentage = f"{percent*100:.1f}%"
        print(f"\r{label:<20} [{bar}{self.colors['reset']}] {self.colors['bold']}{percentage}{self.colors['reset']}", end='')
    
    def card(self, title, content, color='primary'):
        """創建卡片式顯示"""
        c = self.colors[color]
        print(f"\n{c}╔═══════════════════════════════════════╗{self.colors['reset']}")
        print(f"{c}║{self.colors['reset']} {self.colors['bold']}{title.center(37)}{self.colors['reset']} {c}║{self.colors['reset']}")
        print(f"{c}╠═══════════════════════════════════════╣{self.colors['reset']}")
        
        for line in content:
            if isinstance(line, tuple):
                key, value = line
                formatted = f"{key}: {self.colors['bold']}{value}{self.colors['reset']}"
                print(f"{c}║{self.colors['reset']} {formatted:<45} {c}║{self.colors['reset']}")
            else:
                print(f"{c}║{self.colors['reset']} {line:<37} {c}║{self.colors['reset']}")
        
        print(f"{c}╚═══════════════════════════════════════╝{self.colors['reset']}")
    
    def status_indicator(self, status):
        """狀態指示器"""
        indicators = {
            'online': (self.colors['success'] + '●', '線上'),
            'offline': (self.colors['error'] + '●', '離線'),
            'updating': (self.colors['warning'] + '◐', '更新中'),
            'idle': (self.colors['info'] + '○', '閒置')
        }
        
        icon, text = indicators.get(status, ('?', '未知'))
        return f"{icon} {text}{self.colors['reset']}"
    
    def menu_modern(self, options):
        """現代化選單"""
        print(f"\n{self.colors['primary']}╭──────────────────────────────────────╮{self.colors['reset']}")
        print(f"{self.colors['primary']}│{self.colors['reset']}         {self.colors['bold']}選擇操作{self.colors['reset']}                    {self.colors['primary']}│{self.colors['reset']}")
        print(f"{self.colors['primary']}├──────────────────────────────────────┤{self.colors['reset']}")
        
        for i, (key, desc) in enumerate(options.items(), 1):
            icon = "🎯" if i == 1 else "📦" if i == 2 else "📊" if i == 3 else "⚙️" if i == 4 else "🚪"
            print(f"{self.colors['primary']}│{self.colors['reset']} {icon}  {self.colors['bold']}{i}{self.colors['reset']}. {desc:<30} {self.colors['primary']}│{self.colors['reset']}")
        
        print(f"{self.colors['primary']}╰──────────────────────────────────────╯{self.colors['reset']}")
    
    def notification(self, type, message):
        """通知訊息"""
        icons = {
            'success': '✅',
            'error': '❌',
            'warning': '⚠️',
            'info': 'ℹ️'
        }
        
        colors = {
            'success': self.colors['success'],
            'error': self.colors['error'],
            'warning': self.colors['warning'],
            'info': self.colors['info']
        }
        
        icon = icons.get(type, '📢')
        color = colors.get(type, self.colors['reset'])
        
        print(f"\n{color}┌─────────────────────────────────────────┐{self.colors['reset']}")
        print(f"{color}│ {icon}  {message:<35} │{self.colors['reset']}")
        print(f"{color}└─────────────────────────────────────────┘{self.colors['reset']}")
    
    def demo(self):
        """UI 展示"""
        os.system('clear')
        self.animated_logo()
        
        # 顯示系統狀態卡片
        self.card("系統狀態", [
            ("無人機連接", self.status_indicator('online')),
            ("雲端服務", self.status_indicator('online')),
            ("自動更新", "已啟用"),
            ("訂閱等級", "專業版")
        ], 'info')
        
        # 顯示更新進度
        print("\n" + self.colors['bold'] + "更新進度:" + self.colors['reset'])
        for i in range(101):
            self.progress_bar_advanced(i, 100, "場景檢測器 v2.1.0")
            time.sleep(0.02)
        print()
        
        # 顯示選單
        self.menu_modern({
            "1": "檢查更新",
            "2": "查看機隊狀態",
            "3": "性能分析",
            "4": "系統設定",
            "5": "退出"
        })
        
        # 顯示通知
        self.notification('success', "場景檢測器更新完成！")

if __name__ == "__main__":
    ui = ModernUI()
    ui.demo()
