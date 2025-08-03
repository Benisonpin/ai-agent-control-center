#!/usr/bin/env python3
"""訂閱方案管理系統"""
import json
import os
from datetime import datetime, timedelta

class SubscriptionManager:
    def __init__(self):
        self.config_file = "ota/custom/subscriptions/custom_plans.json"
        self.user_file = "ota/custom/subscriptions/user_subscriptions.json"
        self.load_plans()
        self.load_users()
    
    def load_plans(self):
        with open(self.config_file, 'r') as f:
            self.plans = json.load(f)['subscription_plans']
    
    def load_users(self):
        if os.path.exists(self.user_file):
            with open(self.user_file, 'r') as f:
                self.users = json.load(f)
        else:
            self.users = {}
    
    def display_plans(self):
        print("\n💎 可用訂閱方案")
        print("=" * 80)
        
        for plan_id, plan in self.plans.items():
            print(f"\n📦 {plan['name']} ({plan_id.upper()})")
            print(f"   💰 價格: ", end="")
            if plan['price']['monthly'] == 0:
                print("免費")
            elif plan['price']['monthly'] == "custom":
                print("聯繫銷售")
            else:
                print(f"${plan['price']['monthly']}/月 或 ${plan['price']['yearly']}/年")
            
            print(f"   ✨ 功能特點:")
            for key, value in plan['features'].items():
                print(f"      • {key}: {value}")
            
            if 'limitations' in plan:
                print(f"   ⚠️  限制:")
                for key, value in plan['limitations'].items():
                    print(f"      • {key}: {value}")
    
    def subscribe_user(self, user_id, plan_id):
        """訂閱用戶到指定方案"""
        if plan_id not in self.plans:
            print(f"❌ 錯誤：找不到方案 {plan_id}")
            return False
        
        self.users[user_id] = {
            "plan": plan_id,
            "subscribed_at": datetime.now().isoformat(),
            "expires_at": (datetime.now() + timedelta(days=30)).isoformat(),
            "status": "active"
        }
        
        self.save_users()
        print(f"✅ 用戶 {user_id} 已成功訂閱 {self.plans[plan_id]['name']}")
        return True
    
    def check_user_access(self, user_id, feature):
        """檢查用戶是否可以使用特定功能"""
        if user_id not in self.users:
            print(f"❌ 用戶 {user_id} 未訂閱")
            return False
        
        user_plan = self.users[user_id]['plan']
        plan_features = self.plans[user_plan]['features']
        
        # 檢查功能訪問權限
        if feature in plan_features:
            return True
        
        # 企業版有所有功能
        if user_plan == 'enterprise':
            return True
        
        return False
    
    def save_users(self):
        with open(self.user_file, 'w') as f:
            json.dump(self.users, f, indent=2)
    
    def interactive_demo(self):
        """互動式演示"""
        while True:
            print("\n" + "="*50)
            print("🎯 訂閱管理系統")
            print("="*50)
            print("1. 查看所有方案")
            print("2. 訂閱新用戶")
            print("3. 檢查用戶權限")
            print("4. 查看用戶狀態")
            print("5. 退出")
            
            choice = input("\n選擇操作 (1-5): ")
            
            if choice == '1':
                self.display_plans()
            elif choice == '2':
                user_id = input("輸入用戶ID: ")
                print("\n可用方案: starter, hobbyist, professional, enterprise")
                plan_id = input("選擇方案: ")
                self.subscribe_user(user_id, plan_id)
            elif choice == '3':
                user_id = input("輸入用戶ID: ")
                feature = input("輸入功能名稱 (如: beta_access): ")
                if self.check_user_access(user_id, feature):
                    print(f"✅ 用戶 {user_id} 可以使用 {feature}")
                else:
                    print(f"❌ 用戶 {user_id} 無權使用 {feature}")
            elif choice == '4':
                print("\n📊 所有用戶狀態:")
                for uid, info in self.users.items():
                    print(f"   {uid}: {info['plan']} ({info['status']})")
            elif choice == '5':
                break

if __name__ == "__main__":
    manager = SubscriptionManager()
    manager.interactive_demo()
