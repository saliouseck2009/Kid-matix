# Dart General Guidelines

## Basic Principles

- Use English for all code and documentation.
- Always declare the type of each variable and function (parameters and return value).
  - Never use `dynamic` unless strictly necessary (e.g., raw JSON parsing); cast immediately after.
  - Create dedicated types instead of relying on primitives.
- No blank lines within a function body.
- One export per file.
- Max line length: **80 characters**.
- Use trailing commas on all multi-line parameter lists.
- Prefer `const` wherever possible — at variable, constructor, and widget level.
- Always use `@override` when overriding a method or getter.
- Mark fields `final` unless mutation is explicitly required.

---

## Nomenclature

- `PascalCase` — classes, enums, typedefs, extensions.
- `camelCase` — variables, functions, methods, parameters.
- `snake_case` — file and directory names.
- `SCREAMING_SNAKE_CASE` — environment variables and top-level constants.
- No magic numbers — define named constants in `core/constants/`.
- Every function name starts with a verb (`fetchUser`, `buildCard`, `validateForm`).
- Boolean variables/getters use prefixes: `is`, `has`, `can`, `should`.
- Full words over abbreviations — exceptions: `API`, `URL`, `i`/`j` (loop indices), `err` (errors), `ctx` (contexts).
- Feature folders use the feature name in singular form (`auth/`, `product/`, `order/`).

---

## Functions

- Single responsibility: <= 20 statements per function.
- Avoid nesting: use early returns and extract helper functions.
- Use higher-order functions (`map`, `where`, `fold`) to avoid nested loops.
- Arrow syntax (`=>`) only for single-expression functions.
- Use default parameter values instead of null-checks.
- For 3+ parameters, group into a typed object (RO-RO pattern).
- Maintain a single level of abstraction per function.
- Never use `Widget _buildXxx()` methods — extract a `StatelessWidget` class instead.
- Break large `build()` methods into small, focused, private widget classes.

---

## Data

- Prefer immutable data: use `final` for every variable that does not change.
- Encapsulate related fields in composite types — avoid primitive obsession.
- Validate data inside class constructors/factories, not in service functions.
- Use `copyWith` on all data/entity classes to support immutable state updates.
- Prefer `sealed` classes (Dart 3+) for exhaustive state/result modelling.

---

## Classes

- Follow SOLID principles.
- Prefer composition over inheritance.
- Use abstract classes to define contracts (interfaces).
- Size limits: <= 200 lines, <= 10 public methods, <= 10 properties.
- Use `const` constructors wherever possible.
- Annotate immutable value objects with `@immutable`.

---

## Error Handling

- Use exceptions only for truly unexpected situations.
- When catching, either fix a recoverable problem, add context before re-throwing, or delegate to a global error handler.
- Wrap all repository calls in `try/catch` and return a `DataState`.
- Never swallow exceptions silently — always log with `log()` and a stack trace.
- Define typed exception classes (`NetworkException`, `CacheException`, `AuthException`) instead of throwing raw `Exception`.

---

## Testing

- **Unit tests** — Arrange, Act, Assert convention.
- **Widget tests** — test widget rendering and interactions in isolation.
- **Integration tests** — cover critical user journeys end-to-end.
- **Acceptance tests** — Given, When, Then convention per feature module.
- Name variables: `inputX`, `mockX`, `actualX`, `expectedX`.
- Write unit tests for every public function using test doubles for dependencies.
- Use `mocktail` (preferred over `mockito`) for mocking.
- Aim for >= 80% coverage on `domain/` and `data/` layers.
- Keep widget tests focused: one behaviour per test.

---

## Serialization

- Use `json_annotation` + `json_serializable` + `build_runner` for all models.
- Never write `fromJson`/`toJson` by hand.
- Use `@JsonKey(name: 'snake_case_key')` to map API field names to Dart names.
- Separate DTOs (`XxxNetworkModel`) from entities (`XxxEntity`).
- Run after every model change:
  `dart run build_runner build --delete-conflicting-outputs`
