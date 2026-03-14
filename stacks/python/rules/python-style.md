# Python Style Rules

## Naming

- Modules and packages: `snake_case` (`data_loader`, `auth_utils`)
- Classes: `UpperCamelCase` (`UserProfile`, `HTTPClient`)
- Functions and variables: `snake_case` (`get_user`, `total_count`)
- Constants: `SCREAMING_SNAKE_CASE` (`MAX_RETRIES`, `DEFAULT_TIMEOUT`)
- Private: single leading underscore (`_internal_helper`); name-mangled: double underscore (`__private`)
- Dunder methods: `__init__`, `__repr__`, `__eq__` -- never invent new ones
- Type variables: `UpperCamelCase` (`T`, `KeyType`, `ResponseT`)
- Boolean variables: read as predicates (`is_valid`, `has_permission`, `can_retry`)

## File Structure

- `src/package_name/` layout (src layout) for libraries; flat layout for small projects
- `__init__.py` in every package; use it to control public API via `__all__`
- `__main__.py` for packages that are runnable with `python -m package`
- `py.typed` marker file for PEP 561 typed packages
- Tests in `tests/` directory mirroring the source structure

## Module Organization

- Group imports: stdlib, then third-party, then local (separated by blank lines)
- Use absolute imports; relative imports only within a package (`from . import utils`)
- Avoid star imports (`from module import *`) -- they pollute the namespace
- Export public API explicitly with `__all__` in `__init__.py`
- Circular imports: restructure or use late imports inside functions

## Type Hints

- Type-hint all public function signatures (parameters and return type)
- Use `from __future__ import annotations` for forward references (until Python 3.14)
- Use `X | None` over `Optional[X]` (Python 3.10+)
- Use `Protocol` for structural typing instead of ABCs when possible
- Run `mypy --strict` or `pyright` in CI

## Error Handling

- Catch specific exceptions, never bare `except:`
- Use custom exception hierarchies rooted in a base exception for your package
- Add context when re-raising: `raise ProcessingError("step failed") from original`
- Use `logging.exception()` to capture tracebacks
- Reserve `SystemExit` and `KeyboardInterrupt` -- never catch `BaseException`

## Testing

- Use `pytest` as the test runner; avoid `unittest` for new tests
- Name test files `test_*.py`; name test functions `test_<thing>_<scenario>_<expected>`
- Use `@pytest.mark.parametrize` for data-driven tests
- Use fixtures (`@pytest.fixture`) for setup/teardown; prefer them over `setUp`/`tearDown`
- Use `pytest-asyncio` with `@pytest.mark.asyncio` for async tests
- Use `unittest.mock.patch` at the boundary, not on internals
- Aim for fast tests; mark slow tests with `@pytest.mark.slow`

## Documentation

- All public modules, classes, and functions must have docstrings
- Use Google or NumPy docstring style consistently (not mixed)
- Include type information in docstrings only when type hints are absent
- Use `"""Triple double quotes"""` for all docstrings, even one-liners

## Formatting

- Use `ruff` for linting and formatting (replaces flake8, isort, black)
- Maximum line length: 88 characters (ruff/black default)
- Use trailing commas in multi-line collections and function signatures
- No trailing whitespace; files end with a single newline
- Use f-strings for interpolation; avoid `.format()` and `%` formatting

## Code Style

- Prefer list/dict/set comprehensions over `map`/`filter` with lambdas
- Use `pathlib.Path` over `os.path` for filesystem operations
- Use `dataclasses` or `attrs` for data containers; avoid plain dicts for structured data
- Use `enum.Enum` for fixed sets of constants
- Use `with` statements for all resource management
- Avoid global mutable state; pass dependencies explicitly
