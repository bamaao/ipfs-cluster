#!/bin/bash

# Run tests
cd "$(dirname "$0")"
status=0
for i in t0*.sh;
do
    echo "*** $i ***"
    ./$i
    status=$((status + $?))
done

# Aggregate Results
echo "Aggregating..."
for f in test-results/*.counts; do
    echo "$f";
done | bash lib/sharness/aggregate-results.sh

# Cleanup results
rm -rf test-results

# Exit with error if any test has failed
if [ $status -gt 0 ]; then
    exit 1
fi
