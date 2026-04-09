#!/bin/bash
export YC_CLI_INITIALIZATION_SILENCE=true
export YC_CLI_INITIALIZATION_SILENCE=true
export YC_CLI_INITIALIZATION_SILENCE=true
echo 'export YC_CLI_INITIALIZATION_SILENCE=true' | sed -i '2i\export YC_CLI_INITIALIZATION_SILENCE=true' ./check_lb.sh


LB_NAME="dima-lb"
TG_ID=$(yc load-balancer network-load-balancer get --name $LB_NAME --format json | jq -r '.attached_target_groups[0].target_group_id')

echo "☁️  Балансировщик: $LB_NAME"
echo "📅 Создан: $(yc load-balancer network-load-balancer get --name $LB_NAME --format json | jq -r '.created_at')"
echo "🌍 Регион: $(yc load-balancer network-load-balancer get --name $LB_NAME --format json | jq -r '.region_id')"
echo "🌐 Внешний IP: $(yc load-balancer network-load-balancer get --name $LB_NAME --format json | jq -r '.listeners[0].address | if type=="object" then .external_ip_address // .address else . end')"
echo "🎯 Целевая группа: $TG_ID"
echo "🖥️  Бэкенды:"
yc load-balancer target-group get --id $TG_ID --format json | jq -r '.targets[] | "   • \(.address) (\(.zone))"'