#!/usr/bin/env python3
"""Netlify 整合監控儀表板"""
import os
import json
import time
import webbrowser
from datetime import datetime

class NetlifyDashboard:
    def __init__(self):
        self.netlify_url = "https://comfy-griffin-7bf94b.netlify.app"
        self.load_status()
    
    def load_status(self):
        """載入狀態"""
        status_file = "ota/netlify_integration/sync/netlify_status.json"
        if os.path.exists(status_file):
            with open(status_file, 'r') as f:
                self.status = json.load(f)
        else:
            self.status = {"status": "未連接"}
    
    def display_dashboard(self):
        """顯示儀表板"""
        os.system('clear')
        
        print("╔═══════════════════════════════════════════════════════════════════════╗")
        print("║               🌐 Netlify AI Agent 整合監控中心                        ║")
        print(f"║  網址: {self.netlify_url:<53} ║")
        print("╚═══════════════════════════════════════════════════════════════════════╝")
        
        # 連接狀態
        print("\n📡 Netlify 連接狀態")
        print("─" * 70)
        print(f"狀態: {self.status.get('status', '未知')}")
        print(f"站點: comfy-griffin-7bf94b.netlify.app")
        print(f"API: /.netlify/functions")
        
        # 同步狀態
        self.display_sync_status()
        
        # 模型狀態
        self.display_model_status()
        
        # 操作選單
        self.display_menu()
    
    def display_sync_status(self):
        """顯示同步狀態"""
        print("\n🔄 同步狀態")
        print("─" * 70)
        
        # 檢查更新隊列
        queue_file = "ota/netlify_integration/sync/update_queue.json"
        if os.path.exists(queue_file):
            with open(queue_file, 'r') as f:
                queue = json.load(f)
                print(f"待處理更新: {len(queue)} 個")
                
                if queue:
                    print("\n最近更新:")
                    for update in queue[-3:]:
                        print(f"  • {update['model']} v{update['version']} - {update['status']}")
        else:
            print("無待處理更新")
    
    def display_model_status(self):
        """顯示模型狀態"""
        print("\n📦 模型同步狀態")
        print("─" * 70)
        
        models = [
            ("場景檢測器", "2.1.0", "✅ 已同步"),
            ("物體追蹤器", "1.0.0", "✅ 已同步"),
            ("夜視模式", "1.3.0", "🔄 同步中"),
            ("HDR融合", "1.5.0", "✅ 已同步")
        ]
        
        for name, version, status in models:
            print(f"{name:<20} v{version:<10} {status}")
    
    def display_menu(self):
        """顯示選單"""
        print("\n" + "─" * 70)
        print("操作選項:")
        print("1. 🌐 在瀏覽器中開啟 Netlify 控制台")
        print("2. 🔄 立即同步")
        print("3. 📊 查看詳細狀態")
        print("4. 📋 查看同步歷史")
        print("5. ⚙️  配置設定")
        print("6. 🧪 測試 API 連接")
        print("7. 🚪 退出")
    
    def open_browser(self):
        """在瀏覽器中開啟"""
        print(f"\n🌐 開啟 {self.netlify_url}")
        webbrowser.open(self.netlify_url)
        input("\n按 Enter 繼續...")
    
    def test_connection(self):
        """測試連接"""
        print("\n🧪 測試 Netlify API 連接...")
        
        import sys
        sys.path.append('ota/netlify_integration/api')
        from netlify_client import NetlifyAIAgentClient
        
        client = NetlifyAIAgentClient()
        
        # 測試各個端點
        tests = [
            ("系統狀態", client.get_system_status),
            ("模型列表", client.check_model_updates),
            ("系統日誌", client.get_logs),
            ("架構信息", client.get_architecture_info)
        ]
        
        for name, test_func in tests:
            print(f"\n測試 {name}...")
            result = test_func()
            if result:
                print(f"✅ {name}: 成功")
            else:
                print(f"❌ {name}: 失敗")
        
        input("\n按 Enter 繼續...")
    
    def run(self):
        """運行儀表板"""
        while True:
            self.display_dashboard()
            
            choice = input("\n選擇操作 (1-7): ")
            
            if choice == '1':
                self.open_browser()
            elif choice == '2':
                self.trigger_sync()
            elif choice == '3':
                self.show_detailed_status()
            elif choice == '4':
                self.show_sync_history()
            elif choice == '5':
                self.configure_settings()
            elif choice == '6':
                self.test_connection()
            elif choice == '7':
                print("\n👋 退出 Netlify 監控")
                break
    
    def trigger_sync(self):
        """觸發同步"""
        print("\n🔄 觸發同步...")
        
        import subprocess
        subprocess.Popen(['python3', 'ota/netlify_integration/sync/polling_sync.py'])
        
        print("✅ 同步服務已啟動")
        input("\n按 Enter 繼續...")
    
    def show_detailed_status(self):
        """顯示詳細狀態"""
        print("\n📊 詳細狀態")
        print("─" * 70)
        
        if os.path.exists("ota/netlify_integration/sync/netlify_status.json"):
            with open("ota/netlify_integration/sync/netlify_status.json", 'r') as f:
                status = json.load(f)
                print(json.dumps(status, indent=2))
        else:
            print("無狀態數據")
        
        input("\n按 Enter 繼續...")
    
    def show_sync_history(self):
        """顯示同步歷史"""
        print("\n📋 同步歷史")
        print("─" * 70)
        
        # 查找日誌文件
        log_dir = "ota/netlify_integration/sync"
        log_files = [f for f in os.listdir(log_dir) if f.startswith("logs_")]
        
        if log_files:
            for log_file in sorted(log_files)[-5:]:
                print(f"📄 {log_file}")
        else:
            print("無同步歷史")
        
        input("\n按 Enter 繼續...")
    
    def configure_settings(self):
        """配置設定"""
        print("\n⚙️ Netlify 整合設定")
        print("─" * 70)
        
        config_file = "ota/netlify_integration/config/netlify_config.json"
        if os.path.exists(config_file):
            with open(config_file, 'r') as f:
                config = json.load(f)
                print(json.dumps(config, indent=2))
        
        modify = input("\n是否修改設定? (y/n): ")
        if modify.lower() == 'y':
            print("請編輯: " + config_file)
        
        input("\n按 Enter 繼續...")

if __name__ == "__main__":
    dashboard = NetlifyDashboard()
    dashboard.run()
