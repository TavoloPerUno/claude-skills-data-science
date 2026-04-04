---
name: coding-standards
description: Enforce Python coding standards for data science projects. Black formatting, NumPy docstrings, doctests, type hints, linter compliance, conventional commits. Use when writing or reviewing Python code.
user-invocable: true
---

# Python Coding Standards

## 1. Black Formatting

All Python code must be formatted with Black. No exceptions, no debates about style.

```toml
# pyproject.toml
[tool.black]
line-length = 88
target-version = ["py310"]
```

Rules:
- Line length: 88 characters (Black default).
- Let Black handle all whitespace, quotes, and trailing commas. Do not override.
- Run `black .` before every commit.
- If a line is too long after Black, break the logic into smaller pieces. Do not disable Black for that line.

```python
# Black will turn this:
result = some_function(argument_one, argument_two, argument_three, argument_four, argument_five)

# Into this:
result = some_function(
    argument_one,
    argument_two,
    argument_three,
    argument_four,
    argument_five,
)
```

When not to format:
- Generated code or vendored dependencies: add to `.blackignore`.
- That is it. Everything else gets formatted.

## 2. Docstrings (NumPy Style)

Every public function, class, and module gets a docstring. Use NumPy style.

### Function docstring

```python
def cap_allocation(
    df: pd.DataFrame,
    max_per_region: int,
    min_count: int = 1,
) -> pd.DataFrame:
    """Cap allocation per region while preserving minimum counts.

    Parameters
    ----------
    df : pd.DataFrame
        Input data with columns 'region' and 'count'.
    max_per_region : int
        Maximum allocation per region.
    min_count : int, optional
        Floor value for any region, by default 1.

    Returns
    -------
    pd.DataFrame
        DataFrame with capped 'count' column.

    Raises
    ------
    ValueError
        If df is empty or missing required columns.

    Examples
    --------
    >>> import pandas as pd
    >>> df = pd.DataFrame({"region": ["A", "B"], "count": [100, 5]})
    >>> cap_allocation(df, max_per_region=50).count.tolist()
    [50, 5]
    """
```

### Rules

- First line: one sentence, imperative mood ("Cap allocation", not "This function caps allocation").
- Parameters: name, type, and one-line description. Mark optional parameters.
- Returns: type and description.
- Raises: list exceptions the caller should expect.
- Examples: add a doctest when the function is pure (no side effects, no I/O).
- Private helpers (`_leading_underscore`): docstring optional for simple ones, required if the logic is not obvious.

### Module docstring

```python
"""Regional allocation optimizer.

Reads constraint files, solves the allocation LP, and writes
capped results to the output directory.
"""
```

One line if the module is simple. A short paragraph if it is not.

## 3. Conventional Commits

All commit messages follow the Conventional Commits standard.

### Format

```
<type>(<scope>): <short summary>

<optional body>
```

### Types

| Type | When to use |
|---|---|
| `feat` | New feature or capability |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or fixing tests |
| `chore` | Build, CI, dependencies, tooling |
| `perf` | Performance improvement |
| `style` | Formatting, whitespace (no logic change) |

### Rules

- Summary line: imperative mood, lowercase, no period, under 72 characters.
- Scope is optional but useful: `feat(allocation): add regional caps`.
- Body: explain why, not what. The diff shows what changed.
- Breaking changes: add `BREAKING CHANGE:` in the body or `!` after the type: `feat!: remove legacy API`.

### Examples

```
feat: add quarterly revenue breakdown to dashboard

fix(export): handle empty DataFrames in CSV writer

docs: update README with install instructions

refactor: extract cap logic into separate module

Moved cap_allocation and related helpers from main.py into
caps.py to reduce file length and improve testability.

chore: upgrade pandas to 2.2
```

## 4. Comments: "Why", Not "What"

Comments explain why, not what. The code shows what; the comment explains the reasoning.

```python
def apply_budget_caps(
    df_spending: pd.DataFrame,
    limits: Dict[str, int],
    floor: int = 1,
) -> pd.DataFrame:
```

- Use typing imports: `Dict`, `List`, `Tuple`, `Set`, `Optional`
- Use `pd.DataFrame`, `np.ndarray` for pandas/numpy types
- Return type is mandatory
- For complex return types, use `Tuple[float, np.ndarray, str]`

**Bad: what**

```python
# Loop through regions and set max budget
for region in limits:
```

**Good: why**

```python
# Caps applied before the adjustment factor inflates them by 1/rate afterward
for region in limits:
```

**Good: why (non-obvious business logic)**

```python
# Protected regions get capped at floor instead of excluded,
# because the leadership team explicitly requested them
if protected:
    cap = max(floor, 1)
```

### When to comment

- Non-obvious business logic
- Workarounds for known issues
- Performance choices ("using dict lookup instead of merge for 10x speedup")
- Constraint interactions ("floor can conflict with max budget cap")

### When not to comment

- Self-explanatory code (`df = df.dropna()`)
- Type information already in hints
- Restating the function name

## 5. Doctests

Add doctests for pure functions and utility helpers:

```python
def normalize_shares(shares: pd.Series) -> pd.Series:
    """Normalize shares to sum to 1.

    Examples
    --------
    >>> import pandas as pd
    >>> s = pd.Series([0.3, 0.5, 0.2])
    >>> normalize_shares(s).sum()
    1.0
    >>> normalize_shares(pd.Series([0.0, 0.0])).sum()
    0.0
    """
    total = shares.sum()
    if total == 0:
        return shares
    return shares / total
```

Run with: `python -m doctest file.py -v`

## 6. Linter Compliance

Code must pass:

- flake8 (or ruff) with default rules
- mypy type checking (optional but encouraged)
- No unused imports
- No bare `except:`
- No mutable default arguments

Common fixes:

```python
# Bad: mutable default
def f(items=[]):

# Good: None sentinel
def f(items=None):
    items = items or []
```

## 7. Naming

- Functions and variables: `snake_case`
- Classes: `PascalCase`
- Constants: `UPPER_SNAKE_CASE`
- Private helpers: `_leading_underscore`
- No single-letter variables except `i`, `j`, `n`, `x`, `y` in tight loops
- Descriptive names: `quarterly_revenue` not `qr`, `budget_limits` not `bl`

## 8. Module Structure

```python
"""Module docstring: one line describing purpose."""

import logging
import math
from typing import Dict, List, Tuple

import numpy as np
import pandas as pd

# Third-party imports grouped separately
from ortools.linear_solver import pywraplp

logger = logging.getLogger(__name__)

# Constants
MAX_RETRIES = 3
GROWTH_RATE = 1.25


def public_function() -> None:
    """Public function docstring."""
    ...


def _private_helper() -> None:
    """Private helper (docstring optional for simple helpers)."""
    ...
```

Import order: stdlib, blank line, third-party, blank line, local.

## 9. Error Handling

- Raise specific exceptions with descriptive messages
- Log before raising (`logger.error` + `raise`)
- Never silence exceptions with bare `except:`
- Use `ValueError` for bad inputs, `RuntimeError` for unexpected state

```python
if len(df) == 0:
    raise ValueError(
        f"Empty DataFrame passed to {func_name}. "
        f"Expected at least one row."
    )
```

## 10. Checklist

Before committing:

1. Black formatted?
2. Every public function has a NumPy docstring?
3. Type hints on all function signatures?
4. Comments explain "why", not "what"?
5. No unused imports?
6. No mutable default arguments?
7. Descriptive variable names?
8. Doctests for pure functions?
