#!/bin/bash
# OTA Background Service
while true; do
    python3 ota/manager/ota_manager.py > ota/logs/ota_service.log 2>&1
    sleep 86400  # Check daily
done
