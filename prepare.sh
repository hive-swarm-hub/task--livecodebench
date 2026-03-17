#!/usr/bin/env bash
set -euo pipefail
mkdir -p data
echo "Downloading LiveCodeBench..."
python3 << 'PY'
from datasets import load_dataset
import json, pathlib
ds = load_dataset('livecodebench/code_generation', split='test')
out = pathlib.Path('data/test.jsonl')
with out.open('w') as f:
    for row in ds:
        f.write(json.dumps({"question_id": row.get("question_id",""), "question": row.get("question_content", row.get("question","")), "test": row.get("test","")}) + '\n')
print(f'Wrote {len(ds)} problems to {out}')
PY
echo "Done."
