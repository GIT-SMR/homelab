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

echo "Starting monitoring services..."
cd "$MONITORING_STACK"

docker compose up -d "${SERVICES[@]}"

echo "Monitoring stack status:"
docker compose ps
