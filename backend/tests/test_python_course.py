"""Validate trusted, authored teaching snippets, not arbitrary learner code."""
import ast
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import pytest

ROOT = Path(__file__).resolve().parents[2]
COURSE = json.loads((ROOT / 'content/python_course.json').read_text())['lessons']


def test_course_references_and_editorial_contract():
    ids = {f'py-{i:02d}' for i in range(1, 13)} | {lesson['id'] for lesson in COURSE}
    for locale in ('my', 'en'):
        bodies = [lesson['guide'][locale]['body'] for lesson in COURSE]
        assert len(set(bodies)) == len(bodies), 'Duplicated lesson body'
        assert all(len(body) > 650 for body in bodies)
    for lesson in COURSE:
        assert set(lesson['prerequisites']) <= ids
        assert lesson['id'] not in lesson['prerequisites']
        for prior in lesson['prerequisites']:
            assert int(prior[3:]) < int(lesson['id'][3:])
        assert lesson['guide']['reference'].startswith(('https://docs.python.org/3/', 'https://git-scm.com/docs/'))
        for field in ('code', 'solution'):
            ast.parse(lesson[field], filename=lesson['id'] + '.' + field)


@pytest.mark.parametrize('lesson', COURSE, ids=lambda lesson: lesson['id'])
@pytest.mark.parametrize('field,output_field', [('code', 'expected_stdout'), ('solution', 'solution_stdout')])
def test_authored_examples_execute_in_test_child_process(lesson, field, output_field):
    # These are reviewed repository-owned examples. This is not an API code runner.
    # Temporary files stay outside the repository; environment and runtime are bounded.
    with tempfile.TemporaryDirectory() as folder:
        result = subprocess.run([sys.executable, '-I', '-c', lesson[field]], cwd=folder,
            env={'PYTHONIOENCODING': 'utf-8'}, capture_output=True, text=True, encoding='utf-8', timeout=4)
    assert result.returncode == 0, result.stderr
    expected = lesson[output_field]
    if expected is not None:
        assert result.stdout == expected
    elif field == 'code':
        # Interpreter-prefix output is deliberately environment dependent.
        assert result.stdout in ('True\n3\n', 'False\n3\n')
    else:
        assert result.stdout in ('pip metadata available\n', 'pip not installed in this environment\n')


def test_generated_course_and_sql_match_source():
    result = subprocess.run([sys.executable, str(ROOT / 'scripts/build-python-course.py'), '--check'],
        cwd=ROOT, capture_output=True, text=True, timeout=10)
    assert result.returncode == 0, result.stderr + result.stdout
