import ast
import json
from pathlib import Path
from fastapi.testclient import TestClient
from app.catalog import catalog
from app.assessments import EXERCISE_IDS
from app.main import app

def test_catalog_has_original_bilingual_content_and_no_private_cases():
    with TestClient(app) as client:
        result = client.get('/api/v1/learning/catalog')
    assert result.status_code == 200
    data = result.json()
    assert len(data['exercises']) == 6 and len(data['projects']) == 16 and len(data['paths']) == 7
    assert 'code_hash' not in result.text and 'test_cases' not in result.text
    assert {e.id for e in catalog.exercises} == EXERCISE_IDS
    project_ids = {p.id for p in catalog.projects}
    for path in catalog.paths:
        assert set(path.exercise_ids) <= EXERCISE_IDS and set(path.project_ids) <= project_ids
        assert set(path.lesson_ids) <= ({f'py-{n:02}' for n in range(1,13)} | {lesson['id'] for lesson in json.loads((Path(__file__).resolve().parents[2] / 'content/python_course.json').read_text())['lessons']})
    for project in catalog.projects:
        assert len({s.id for s in project.steps}) == len(project.steps)
        assert all(s.text.my and s.text.en for s in project.steps)
        if project.language == 'python': ast.parse(project.starter)
    for exercise in catalog.exercises:
        ast.parse(exercise.starter)
        ast.parse(exercise.solution)

def test_public_catalog_copies_match_source_of_truth():
    root = Path(__file__).resolve().parents[2]
    source = (root / 'content/learning_catalog.json').read_bytes()
    assert source == (root / 'mobile/assets/learning/learning_catalog.json').read_bytes()
    assert source == (root / 'backend/app/data/learning_catalog.json').read_bytes()

def test_authored_solutions_produce_public_and_generated_outputs():
    # These are trusted authored catalog examples, not submitted learner code.
    # They execute in child processes only in tests, with no inherited secrets.
    # Learner execution still exclusively uses the remote sandbox adapter.
    import subprocess
    import sys
    from app.assessments import test_cases
    for exercise in catalog.exercises:
        cases = [(sample.stdin, sample.stdout) for sample in exercise.examples] + test_cases(exercise.id)
        for stdin, expected in cases:
            response = subprocess.run([sys.executable, '-I', '-c', exercise.solution], input=stdin,
                text=True, capture_output=True, timeout=2, env={})
            assert response.returncode == 0 and not response.stderr
            assert response.stdout.rstrip('\n') == expected
