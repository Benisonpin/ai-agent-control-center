class UpdatePolicy:
    """自定義更新策略"""
    
    def __init__(self):
        self.policies = {
            "conservative": {
                "auto_update": False,
                "require_approval": True,
                "backup_before_update": True,
                "test_duration_hours": 48
            },
            "balanced": {
                "auto_update": True,
                "require_approval": False,
                "backup_before_update": True,
                "test_duration_hours": 24,
                "skip_minor_updates": False
            },
            "aggressive": {
                "auto_update": True,
                "require_approval": False,
                "backup_before_update": False,
                "test_duration_hours": 0,
                "install_beta": True
            }
        }
    
    def get_policy(self, name):
        return self.policies.get(name, self.policies["balanced"])
