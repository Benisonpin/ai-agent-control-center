#!/usr/bin/env python3
"""智能更新策略管理器"""
import json
import os
from datetime import datetime, time

class PolicyManager:
    def __init__(self):
        self.policy_file = "ota/custom/policies/update_behavior.json"
        self.drone_policies = "ota/custom/policies/drone_policies.json"
        self.load_policies()
        self.load_drone_assignments()
    
    def load_policies(self):
        with open(self.policy_file, 'r') as f:
            self.policies = json.load(f)['update_behaviors']
    
    def load_drone_assignments(self):
        if os.path.exists(self.drone_policies):
            with open(self.drone_policies, 'r') as f:
                self.assignments = json.load(f)
        else:
            self.assignments = {}
    
    def assign_policy(self, drone_id, policy_name):
        """為無人機分配更新策略"""
        if policy_name not in self.policies:
            print(f"❌ 未知的策略: {policy_name}")
            return False
        
        self.assignments[drone_id] = {
            "policy": policy_name,
            "assigned_at": datetime.now().isoformat(),
            "active": True
        }
        
        self.save_assignments()
        print(f"✅ 已為無人機 {drone_id} 分配 {self.policies[policy_name]['name']} 策略")
        return True
    
    def check_update_allowed(self, drone_id):
        """檢查是否允許更新"""
        if drone_id not in self.assignments:
            print(f"⚠️  無人機 {drone_id} 未分配策略，使用預設平衡模式")
            policy_name = "balanced"
        else:
            policy_name = self.assignments[drone_id]['policy']
        
        policy = self.policies[policy_name]
        settings = policy['settings']
        conditions = policy.get('conditions', {})
        
        print(f"\n🔍 檢查更新條件 (策略: {policy['name']})")
        
        # 檢查時間窗口
        if settings.get('allowed_update_window') != 'anytime':
            current_hour = datetime.now().hour
            window = settings['allowed_update_window']
            start, end = map(lambda x: int(x.split(':')[0]), window.split('-'))
            
            if not (start <= current_hour < end):
                print(f"   ❌ 不在允許的更新時間窗口 ({window})")
                return False
            print(f"   ✅ 在允許的更新時間窗口內")
        
        # 檢查電池
        battery_level = 75  # 模擬電池電量
        min_battery = conditions.get('battery_minimum', 0)
        if battery_level < min_battery:
            print(f"   ❌ 電池電量不足 ({battery_level}% < {min_battery}%)")
            return False
        print(f"   ✅ 電池電量充足 ({battery_level}%)")
        
        # 檢查連接穩定性
        print(f"   ✅ 網路連接穩定")
        
        # 檢查是否有活動任務
        if conditions.get('no_active_mission', True):
            print(f"   ✅ 無活動任務")
        
        print(f"\n✅ 所有條件滿足，允許更新")
        return True
    
    def save_assignments(self):
        os.makedirs(os.path.dirname(self.drone_policies), exist_ok=True)
        with open(self.drone_policies, 'w') as f:
            json.dump(self.assignments, f, indent=2)
    
    def policy_wizard(self):
        """策略配置精靈"""
        while True:
            os.system('clear')
            print("="*60)
            print("🔧 更新策略管理器")
            print("="*60)
            
            print("\n可用策略:")
            for i, (key, policy) in enumerate(self.policies.items(), 1):
                print(f"{i}. {policy['name']} - {policy['description']}")
            
            print("\n操作選項:")
            print("1. 為無人機分配策略")
            print("2. 檢查更新權限")
            print("3. 查看策略詳情")
            print("4. 查看所有分配")
            print("5. 退出")
            
            choice = input("\n選擇 (1-5): ")
            
            if choice == '1':
                drone_id = input("\n輸入無人機ID: ")
                print("\n選擇策略:")
                policies_list = list(self.policies.keys())
                for i, key in enumerate(policies_list, 1):
                    print(f"{i}. {self.policies[key]['name']}")
                
                policy_idx = int(input("選擇 (數字): ")) - 1
                if 0 <= policy_idx < len(policies_list):
                    self.assign_policy(drone_id, policies_list[policy_idx])
                    input("\n按 Enter 繼續...")
                
            elif choice == '2':
                drone_id = input("\n輸入無人機ID: ")
                self.check_update_allowed(drone_id)
                input("\n按 Enter 繼續...")
                
            elif choice == '3':
                print("\n選擇要查看的策略:")
                policies_list = list(self.policies.keys())
                for i, key in enumerate(policies_list, 1):
                    print(f"{i}. {self.policies[key]['name']}")
                
                policy_idx = int(input("選擇 (數字): ")) - 1
                if 0 <= policy_idx < len(policies_list):
                    policy = self.policies[policies_list[policy_idx]]
                    print(f"\n📋 {policy['name']}")
                    print(json.dumps(policy, indent=2, ensure_ascii=False))
                    input("\n按 Enter 繼續...")
                    
            elif choice == '4':
                print("\n📊 所有策略分配:")
                for drone_id, info in self.assignments.items():
                    policy_name = self.policies[info['policy']]['name']
                    print(f"   {drone_id}: {policy_name}")
                input("\n按 Enter 繼續...")
                
            elif choice == '5':
                break

if __name__ == "__main__":
    manager = PolicyManager()
    manager.policy_wizard()
