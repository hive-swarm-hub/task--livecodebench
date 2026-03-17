#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading LiveCodeBench..."
python3 -c "
from datasets import load_dataset
import json, pathlib

ds = load_dataset('livecodebench/code_generation', split='test')
ds = ds.shuffle(seed=42)
items = list(ds)
n = int(len(items) * 0.8)

dev_out = pathlib.Path('data/dev.jsonl')
with dev_out.open('w') as f:
    for row in items[:n]:
        f.write(json.dumps({'question_id': row.get('question_id',''), 'question': row.get('question_content', row.get('question','')), 'test': row.get('test','')}) + '\n')

test_out = pathlib.Path('data/test.jsonl')
with test_out.open('w') as f:
    for row in items[n:]:
        f.write(json.dumps({'question_id': row.get('question_id',''), 'question': row.get('question_content', row.get('question','')), 'test': row.get('test','')}) + '\n')

print(f'Dev:  {n} problems -> {dev_out}')
print(f'Test: {len(items)-n} problems -> {test_out}')
"
echo "Done."
