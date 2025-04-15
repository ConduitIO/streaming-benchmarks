#!/bin/bash
exit_code=0

for path in ./benchmarks/*/; do
  cd "$path" || continue
  echo "Linting $path ..."
  dir=$(basename "$path")
  out=$(find . -type f -exec grep -H '/benchmarks/' {} \; | grep -v "/benchmarks/$dir")
  if [ -n "$out" ]; then
    echo "$out"
    exit_code=1
  fi
  cd - >/dev/null || exit 1
done

exit $exit_code
