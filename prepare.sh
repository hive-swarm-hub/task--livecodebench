#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading LiveCodeBench..."
python3 << 'PY'
from datasets import load_dataset
import json, pathlib, random
random.seed(42)
items = list(load_dataset('livecodebench/code_generation', split='test'))
random.shuffle(items)
with pathlib.Path('data/train.jsonl').open('w') as f:
    for row in items[:100]:
        f.write(json.dumps({"question_id": row.get("question_id",""), "question": row.get("question_content", row.get("question","")), "test": row.get("test","")}) + '\n')
with pathlib.Path('data/test.jsonl').open('w') as f:
    for row in items[100:250]:
        f.write(json.dumps({"question_id": row.get("question_id",""), "question": row.get("question_content", row.get("question","")), "test": row.get("test","")}) + '\n')
print(f'Train: 100, Test: {min(len(items)-100, 150)}')
PY
echo "Done."
