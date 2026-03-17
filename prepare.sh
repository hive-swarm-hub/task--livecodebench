#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading LiveCodeBench..."
python3 -c "
from datasets import load_dataset
import json, pathlib, random

random.seed(42)
items = list(load_dataset('livecodebench/code_generation', split='test'))
random.shuffle(items)

n = min(len(items) // 2, 150)

dev_out = pathlib.Path('data/dev.jsonl')
with dev_out.open('w') as f:
    for row in items[:n]:
        f.write(json.dumps({'question_id': row.get('question_id',''), 'question': row.get('question_content', row.get('question','')), 'test': row.get('test','')}) + '
')

test_out = pathlib.Path('data/test.jsonl')
with test_out.open('w') as f:
    for row in items[n:n+min(n,150)]:
        f.write(json.dumps({'question_id': row.get('question_id',''), 'question': row.get('question_content', row.get('question','')), 'test': row.get('test','')}) + '
')

print(f'Dev:  {n} problems -> {dev_out}')
print(f'Test: {min(n,150)} problems -> {test_out}')
"
echo "Done."
