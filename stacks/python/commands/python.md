# Python Commands

## Run

- `python -m module_name` -- run a module as a script
- `python script.py` -- run a script directly

## Package Management

- `uv pip install -r requirements.txt` -- install deps (fast, uv)
- `uv pip install -e ".[dev]"` -- editable install with dev extras
- `pip install -e ".[dev]"` -- editable install (pip fallback)
- `poetry install` -- install from poetry lockfile
- `uv venv && source .venv/bin/activate` -- create and activate virtualenv

## Test

- `pytest` -- run all tests
- `pytest tests/test_auth.py` -- run specific file
- `pytest -k "test_login"` -- run tests matching keyword
- `pytest -x` -- stop on first failure
- `pytest --tb=short` -- shorter tracebacks
- `pytest -n auto` -- parallel tests (requires pytest-xdist)
- `pytest --cov=src --cov-report=html` -- coverage report

## Lint

- `ruff check .` -- lint all files
- `ruff check --fix .` -- auto-fix lint violations
- `ruff check --select ALL .` -- enable all rules for audit

## Format

- `ruff format .` -- format all files
- `ruff format --check .` -- check without modifying

## Type Check

- `mypy src/` -- type check with mypy
- `mypy --strict src/` -- strict mode
- `pyright` -- alternative type checker (faster, stricter)

## Profile

- `python -m cProfile -o output.prof script.py` -- function-level profiling
- `python -m pstats output.prof` -- analyze profile data
- `python -m timeit "expression"` -- micro-benchmark

## Build and Publish

- `python -m build` -- build sdist and wheel
- `twine upload dist/*` -- publish to PyPI
- `twine check dist/*` -- validate package before upload
