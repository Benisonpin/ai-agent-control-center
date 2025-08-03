#!/usr/bin/env python3
"""自定義 OTA 監控儀表板"""
import os
import time
import json
from datetime import datetime

class CustomDashboard:
    def __init__(self):
        self.refresh_rate = 5  # 秒
        self.metrics = {
            "system_health": 98.5,
            "active_drones": 127,
            "models_updated_today": 15,
            "avg_update_time": "2m 31s",
            "success_rate": 99.2
        }
        
    def display_header(self):
        os.system('clear')
        print("╔═══════════════════════════════════════════════════════════════════╗")
        print("║             🚁 無人機 OTA 智能監控中心 v2.0                      ║")
        print("╚═══════════════════════════════════════════════════════════════════╝")
        
    def display_metrics(self):
        print(f"\n📊 即時數據監控 | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("─" * 70)
        
        # 系統健康度
        health_bar = "█" * int(self.metrics["system_health"] / 5) + "░" * (20 - int(self.metrics["system_health"] / 5))
        print(f"系統健康度: [{health_bar}] {self.metrics['system_health']}%")
        
        # 關鍵指標卡片
        print("\n┌─────────────┬─────────────┬─────────────┬─────────────┐")
        print(f"│ 活躍無人機  │ 今日更新    │ 平均耗時    │ 成功率      │")
        print(f"│    {self.metrics['active_drones']:^9}│    {self.metrics['models_updated_today']:^9}│  {self.metrics['avg_update_time']:^11}│   {self.metrics['success_rate']:^9.1f}% │")
        print("└─────────────┴─────────────┴─────────────┴─────────────┘")
    
    def display_model_status(self):
        print("\n📦 AI模型更新狀態")
        print("─" * 70)
        
        models = [
            ("場景檢測器", "2.0.0", "2.1.0", "downloading", 67),
            ("物體追蹤器", "1.0.0", "1.0.0", "up_to_date", 100),
            ("夜視模式", "1.2.0", "1.3.0", "ready", 0),
            ("HDR融合", "1.5.0", "1.5.1", "installing", 89)
        ]
        
        for name, current, latest, status, progress in models:
            if status == "downloading":
                status_icon = "⬇️"
                progress_bar = f"[{'█' * (progress // 5)}{'░' * (20 - progress // 5)}] {progress}%"
            elif status == "installing":
                status_icon = "🔧"
                progress_bar = f"[{'█' * (progress // 5)}{'░' * (20 - progress // 5)}] {progress}%"
            elif status == "up_to_date":
                status_icon = "✅"
                progress_bar = "[████████████████████] 100%"
            else:
                status_icon = "🔄"
                progress_bar = "[░░░░░░░░░░░░░░░░░░░░] Ready"
            
            print(f"{status_icon} {name:<15} v{current} → v{latest}  {progress_bar}")
    
    def display_fleet_overview(self):
        print("\n🚁 機隊概覽")
        print("─" * 70)
        print("區域分布:")
        regions = [
            ("北部", 45, "█" * 9),
            ("中部", 38, "█" * 7),
            ("南部", 29, "█" * 5),
            ("東部", 15, "█" * 3)
        ]
        
        for region, count, bar in regions:
            print(f"  {region}: {bar} {count} 架")
    
    def display_alerts(self):
        print("\n⚠️  系統警報")
        print("─" * 70)
        alerts = [
            ("INFO", "🔵", "3架無人機待更新夜視模式 v1.3.0"),
            ("WARN", "🟡", "南部區域網路延遲較高 (>200ms)"),
            ("SUCCESS", "🟢", "農業套件 v3.2.0 部署完成 (15架)")
        ]
        
        for level, icon, message in alerts:
            print(f"{icon} [{level}] {message}")
    
    def run(self):
        try:
            while True:
                self.display_header()
                self.display_metrics()
                self.display_model_status()
                self.display_fleet_overview()
                self.display_alerts()
                
                print("\n" + "─" * 70)
                print("🔄 自動更新中... (按 Ctrl+C 退出)")
                
                # 模擬數據變化
                self.metrics["active_drones"] += (time.time() % 3) - 1
                self.metrics["models_updated_today"] += 1 if time.time() % 10 < 1 else 0
                
                time.sleep(self.refresh_rate)
        except KeyboardInterrupt:
            print("\n\n✅ 監控系統已安全退出")

if __name__ == "__main__":
    dashboard = CustomDashboard()
    dashboard.run()
