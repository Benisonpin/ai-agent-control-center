#!/usr/bin/env python3
"""統一 OTA 系統監控面板"""
import os
import time

class UnifiedDashboard:
    def __init__(self):
        self.systems = {
            "local": "本地 OTA 系統",
            "cte": "CTE AI Agent 平台",
            "netlify": "Netlify 控制中心"
        }
    
    def display(self):
        while True:
            os.system('clear')
            
            print("╔═══════════════════════════════════════════════════════════════════════╗")
            print("║                    🎯 統一 OTA 系統監控中心                           ║")
            print("╚═══════════════════════════════════════════════════════════════════════╝")
            
            print("\n系統狀態總覽:")
            print("─" * 70)
            print("🏠 本地 OTA 系統      : ✅ 運行中")
            print("🌐 CTE AI Platform   : ✅ 已連接")
            print("☁️  Netlify 控制中心  : ✅ 在線 (comfy-griffin-7bf94b.netlify.app)")
            
            print("\n功能模組:")
            print("─" * 70)
            print("1. 📦 OTA 更新管理")
            print("2. 🔄 系統同步狀態")
            print("3. 📊 性能監控")
            print("4. 🎨 自定義功能")
            print("5. 🌐 Netlify 整合")
            print("6. 🔌 CTE 整合")
            print("7. 📝 查看日誌")
            print("8. 🚪 退出")
            
            choice = input("\n選擇功能 (1-8): ")
            
            if choice == '1':
                os.system('./test_ota_update.sh')
            elif choice == '2':
                os.system('python3 ota/netlify_integration/integration_bridge.py')
            elif choice == '3':
                os.system('python3 ota/custom/dashboard/custom_dashboard.py')
            elif choice == '4':
                os.system('python3 ota_control_center.py')
            elif choice == '5':
                os.system('./start_netlify_integration.sh')
            elif choice == '6':
                os.system('./start_cte_integration.sh')
            elif choice == '7':
                self.show_logs()
            elif choice == '8':
                print("\n👋 再見！")
                break
            
            input("\n按 Enter 返回主選單...")
    
    def show_logs(self):
        print("\n📝 系統日誌")
        print("─" * 70)
        
        log_files = [
            "ota/ota_update.log",
            "ota/netlify_integration/sync/sync_log.json",
            "ota/cte_integration/sync/sync_log.json"
        ]
        
        for log_file in log_files:
            if os.path.exists(log_file):
                print(f"\n📄 {log_file}:")
                with open(log_file, 'r') as f:
                    lines = f.readlines()
                    for line in lines[-5:]:  # 顯示最後 5 行
                        print(f"   {line.strip()}")

if __name__ == "__main__":
    dashboard = UnifiedDashboard()
    dashboard.display()
