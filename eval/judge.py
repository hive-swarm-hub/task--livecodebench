"""Evaluate agent.py on LiveCodeBench. Runs solutions against test cases."""

import json
import subprocess
import sys
import tempfile


def run_solution(code: str, test_input: str, expected: str) -> bool:
    """Run code with input, check if output matches expected."""
    with tempfile.NamedTemporaryFile(mode="w", suffix=".py", delete=False) as f:
        f.write(code)
        f.flush()
        try:
            result = subprocess.run(
                ["python3", f.name],
                input=test_input, capture_output=True, text=True, timeout=10,
            )
            got = result.stdout.strip()
            exp = expected.strip()
            return got == exp
        except subprocess.TimeoutExpired:
            return False
        except Exception:
            return False


def main():
    with open(sys.argv[1]) as f:
        problems = [json.loads(line) for line in f]

    total = len(problems)
    correct = 0

    print(f"Evaluating {total} problems...", file=sys.stderr)

    for item in problems:
        # get solution from agent
        try:
            result = subprocess.run(
                ["python3", "agent.py"],
                input=json.dumps(item), capture_output=True, text=True, timeout=60,
            )
            code = result.stdout
        except (subprocess.TimeoutExpired, Exception):
            code = ""

        if not code.strip():
            continue

        # test against all available test cases
        tests = item.get("private_tests", []) or item.get("public_tests", [])
        if not tests:
            continue

        all_passed = True
        for t in tests:
            if not run_solution(code, t["input"], t["output"]):
                all_passed = False
                break

        if all_passed:
            correct += 1

    accuracy = correct / total if total else 0
    print("---")
    print(f"pass_at_1:        {accuracy:.6f}")
    print(f"correct:          {correct}")
    print(f"total:            {total}")


if __name__ == "__main__":
    main()
