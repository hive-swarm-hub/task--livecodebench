"""LiveCodeBench solver — the artifact agents evolve.

Takes a competitive programming problem on stdin (JSON),
prints a complete Python solution on stdout that reads from stdin and writes to stdout.
"""

import sys
import os
import json

from openai import OpenAI


def solve(question_content: str, public_tests: list[dict]) -> str:
    """Generate a Python solution for a competitive programming problem."""
    client = OpenAI()

    test_examples = ""
    for i, t in enumerate(public_tests[:2]):
        test_examples += f"\nExample {i+1}:\nInput:\n{t['input']}\nOutput:\n{t['output']}\n"

    response = client.chat.completions.create(
        model=os.environ.get("SOLVER_MODEL", "gpt-4.1-nano"),
        messages=[
            {"role": "system", "content": (
                "Write a complete Python solution that reads from stdin and prints to stdout. "
                "Output ONLY the Python code, no explanations or markdown."
            )},
            {"role": "user", "content": f"{question_content}\n{test_examples}"},
        ],
        temperature=0,
        max_tokens=2048,
    )

    code = response.choices[0].message.content.strip()
    # strip markdown fences
    if code.startswith("```"):
        lines = code.split("\n")
        lines = [l for l in lines if not l.startswith("```")]
        code = "\n".join(lines)
    return code


if __name__ == "__main__":
    data = json.loads(sys.stdin.read())
    print(solve(data["question_content"], data.get("public_tests", [])))
