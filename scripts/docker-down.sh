for dir in /opt/stacks/*; do
  if [ -f "$dir/compose.yml" ]; then
    echo "Stopping $dir"
    docker compose -f "$dir/compose.yml" down
  fi
done