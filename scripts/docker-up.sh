for dir in /opt/stacks/*; do
  if [ -f "$dir/compose.yml" ]; then
    echo "Starting $dir"
    docker compose -f "$dir/compose.yml" up -d
  fi
done