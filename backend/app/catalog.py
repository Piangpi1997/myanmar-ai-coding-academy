"""Versioned, original public learning material. No server grading cases here."""
import json
from pathlib import Path
from typing import Literal
from fastapi import APIRouter
from pydantic import BaseModel, ConfigDict, Field

class Localized(BaseModel):
    model_config = ConfigDict(extra='forbid')
    my: str = Field(min_length=1, max_length=8000)
    en: str = Field(min_length=1, max_length=8000)

class Example(BaseModel):
    stdin: str = Field(max_length=4000)
    stdout: str = Field(max_length=4000)

class Exercise(BaseModel):
    id: str = Field(pattern=r'^[a-z0-9-]{1,64}$')
    lesson_ids: list[str]
    title: Localized
    statement: Localized
    hint: Localized
    starter: str = Field(min_length=1, max_length=16000)
    solution: str = Field(min_length=1, max_length=16000)
    examples: list[Example] = Field(min_length=1, max_length=4)

class ProjectStep(BaseModel):
    id: str
    text: Localized

class Project(BaseModel):
    id: str
    title: Localized
    level: Literal['beginner', 'intermediate', 'advanced']
    language: Literal['python', 'dart', 'text']
    objective: Localized
    requirements: Localized
    architecture: Localized
    steps: list[ProjectStep] = Field(min_length=5)
    testing: Localized
    troubleshooting: Localized
    completion: Localized
    starter: str = Field(min_length=1, max_length=16000)
    lesson_ids: list[str]
    reference: str = Field(pattern=r'^https://')

class StudyPath(BaseModel):
    id: str
    title: Localized
    goal: Localized
    lesson_ids: list[str]
    exercise_ids: list[str]
    project_ids: list[str]

class Catalog(BaseModel):
    schema_version: Literal[1]
    exercises: list[Exercise]
    projects: list[Project]
    paths: list[StudyPath]

catalog = Catalog.model_validate(json.loads((Path(__file__).parent / 'data/learning_catalog.json').read_text()))
router = APIRouter(prefix='/api/v1/learning', tags=['Public learning catalog'])

@router.get('/catalog', response_model=Catalog)
async def get_catalog():
    return catalog
