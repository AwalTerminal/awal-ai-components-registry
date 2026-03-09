# Python Patterns

## Type Hints
- Use type hints for all function signatures
- Use `from __future__ import annotations` for forward references
- Use `TypeVar` and `Generic` for reusable typed abstractions
- Prefer `X | None` over `Optional[X]` (Python 3.10+)

## Project Structure
- Use `pyproject.toml` for project metadata and dependencies
- Organize by domain, not by layer
- Use `__init__.py` to control public API surface
- Keep `__main__.py` minimal — delegate to modules

## Error Handling
- Use specific exception types, not bare `except:`
- Create custom exceptions that inherit from domain-specific bases
- Use `contextlib.suppress()` instead of empty `except` blocks
- Log exceptions with `logger.exception()` to capture tracebacks

## Async
- Use `asyncio` for I/O-bound concurrency
- Use `async with` for async context managers (DB connections, HTTP sessions)
- Use `asyncio.gather()` for concurrent independent tasks
- Never mix `asyncio` with threads unless using `run_in_executor()`

## Testing
- Use `pytest` with fixtures for test setup
- Use `pytest.mark.parametrize` for table-driven tests
- Use `pytest-asyncio` for async test functions
- Mock external services at the boundary, not deep internals
