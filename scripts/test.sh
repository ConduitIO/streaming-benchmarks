for w in workloads/*.sh; do
  if [[ "$w" == *"helper"* ]]; then
    continue
  fi
  echo $w
done
