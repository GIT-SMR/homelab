#!/usr/bin/env bash
set -euo pipefail

MONITORING_STACK="/opt/stacks/monitoring"
SERVICES=(
  prometheus
  grafana
  cadvisor
  node-exporter
  uptime-kuma
)

echo "Stopping monitoring services for summer mode / low power mode..."
cd "$MONITORING_STACK"

docker compose stop "${SERVICES[@]}"

echo "Monitoring stack status:"
docker compose ps
