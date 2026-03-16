#!/usr/bin/env bash
set -euo pipefail
mkdir -p data

echo "Downloading LiveCodeBench..."
python3 -c "
from datasets import load_dataset
import json, pathlib, random

random.seed(42)
ds = load_dataset('livecodebench/code_generation', split='test')
samples = list(ds)
random.shuffle(samples)
samples = samples[:50]

out = pathlib.Path('data/test.jsonl')
with out.open('w') as f:
    for row in samples:
        # parse test cases from input/output format
        public_tests = []
        if row.get('public_test_cases'):
            try:
                cases = row['public_test_cases'] if isinstance(row['public_test_cases'], list) else json.loads(row['public_test_cases'])
                public_tests = [{'input': c['input'], 'output': c['output']} for c in cases]
            except:
                pass
        private_tests = []
        if row.get('private_test_cases'):
            try:
                cases = row['private_test_cases'] if isinstance(row['private_test_cases'], list) else json.loads(row['private_test_cases'])
                private_tests = [{'input': c['input'], 'output': c['output']} for c in cases]
            except:
                pass
        f.write(json.dumps({
            'question_id': row.get('question_id', ''),
            'question_title': row.get('question_title', ''),
            'question_content': row.get('question_content', ''),
            'difficulty': row.get('difficulty', ''),
            'public_tests': public_tests,
            'private_tests': private_tests,
        }) + '\n')

print(f'Wrote {len(samples)} problems to {out}')
"

echo "Done. $(wc -l < data/test.jsonl) problems in data/test.jsonl"
