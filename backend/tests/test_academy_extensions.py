"""Check trusted authored curriculum and examples; never execute learner input."""
import ast
from collections import Counter
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import pytest

ROOT=Path(__file__).resolve().parents[2]
DATA=json.loads((ROOT/'content/academy_extensions.json').read_text())
LESSONS=DATA['lessons']

def test_catalog_is_120_lessons_with_preserved_python_course():
    old=json.loads((ROOT/'content/python_course.json').read_text())['lessons']
    assert len(old)+12==40
    assert len(LESSONS)+len(old)+12==120
    assert Counter(q['track'] for q in LESSONS)=={'programming':20,'web':20,'linux':20,'security':20}
    assert len({q['id'] for q in LESSONS})==80
    known={f'py-{i:02d}' for i in range(1,41)}
    for q in LESSONS:
        assert q['id'] not in known
        assert set(q['prerequisites'])<=known
        known.add(q['id'])
        assert q['code'] and q['solution']
        for lang in ('my','en'):
            g=q['guide'][lang]
            assert len(g['body'])>650
            assert all(g.get(k) for k in ('objectives','lines','mistake','hint','challenge','question','explanation'))
        assert len(q['guide']['myOptions'])==len(q['guide']['enOptions'])==3
        assert 0<=q['guide']['correct']<3
    for lang in ('my','en'):
        assert len({q['guide'][lang]['body'] for q in LESSONS})==80

@pytest.mark.parametrize('lesson',[q for q in LESSONS if q['language']=='python'],ids=lambda q:q['id'])
@pytest.mark.parametrize('field',['code','solution'])
def test_trusted_python_example_runs(lesson,field):
    ast.parse(lesson[field])
    with tempfile.TemporaryDirectory() as folder:
        result=subprocess.run([sys.executable,'-I','-c',lesson[field]],cwd=folder,env={'PYTHONIOENCODING':'utf-8'},capture_output=True,text=True,timeout=4)
    assert result.returncode==0,result.stderr
    assert result.stdout.strip()

@pytest.mark.parametrize('lesson',[q for q in LESSONS if q['language']=='bash'],ids=lambda q:q['id'])
@pytest.mark.parametrize('field',['code','solution'])
def test_shell_examples_parse_without_executing_commands(lesson,field):
    result=subprocess.run(['bash','-n'],input=lesson[field],capture_output=True,text=True,timeout=3)
    assert result.returncode==0,result.stderr

def test_additive_catalog_does_not_delete_progress_and_matches_build():
    result=subprocess.run([sys.executable,str(ROOT/'scripts/build-academy-catalog.py'),'--check'],capture_output=True,text=True,timeout=10)
    assert result.returncode==0,result.stdout+result.stderr
    migration=(ROOT/'database/migrations/008_academy_tracks.sql').read_text().lower()
    assert 'on conflict(id) do nothing' in migration
    assert 'delete ' not in migration and 'drop ' not in migration and 'truncate ' not in migration
