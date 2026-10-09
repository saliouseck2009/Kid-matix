# Flutter-Specific Guidelines

## Architecture — Feature-first Clean Architecture

Organise code by **feature** first, then by **layer** inside each feature.
Only truly cross-cutting concerns live in `core/`.

```
lib/
├── core/
│   ├── constants/       # AppSizes, AppStrings keys
│   ├── di/              # injection_container.dart — calls each feature's registerXxx()
│   ├── entities/        # entities used by 2+ features (e.g. UserEntity) — pure Dart only
│   ├── error/           # AppException types, DataState, Failure classes
│   ├── extensions/      # BuildContext, String, DateTime extensions
│   ├── network/         # NetworkingService, interceptors, NetworkInfo
│   ├── router/          # AppRouter (go_router), AppRoutes constants
│   ├── services/        # abstract interfaces used by 2+ features (e.g. AuthSessionService)
│   ├── storage/         # SecureStorage, LocalStorage wrappers
│   ├── theme/           # AppTheme, AppTextTheme, AppColors
│   ├── utils/           # Validators, formatters, helpers
│   └── widgets/         # StatelessWidgets used by 2+ features (e.g. PrimaryButton)
│
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/   # remote_datasource.dart, local_datasource.dart
│       │   ├── models/        # XxxNetworkModel (DTO), XxxLocalModel
│       │   └── repositories/  # XxxRepositoryImpl
│       ├── domain/
│       │   ├── entities/      # XxxEntity  (pure Dart, no Flutter imports)
│       │   ├── repositories/  # abstract XxxRepository
│       │   └── usecases/      # GetXxxUseCase, CreateXxxUseCase...
│       ├── presentation/
│       │   ├── bloc/          # xxx_bloc.dart / xxx_cubit.dart + state + event
│       │   ├── pages/         # XxxPage  (route entry points only)
│       │   └── widgets/       # widgets scoped to this feature
│       └── injection.dart     # registerXxxFeature() — called from core/di/injection_container.dart
│
└── main.dart
```

**Layer rules:**

- `domain/` has **zero** Flutter or third-party imports — pure Dart only.
- `data/` depends on `domain/`, never the reverse.
- `presentation/` depends on `domain/` use cases only, never on `data/`.
- Cross-feature navigation goes through `core/router/`, never via direct widget references.
- Never import one feature's `data/`, `domain/`, or `presentation/` from another feature. If code is needed by 2+ features, promote it to `core/` — don't duplicate it and don't create feature-to-feature imports.
- Only promote to `core/` once a second feature actually needs it — don't pre-emptively generalise a feature-specific widget/entity "just in case." `core/` is for proven cross-cutting code, not a default dumping ground.
- Use cases and repositories stay inside their owning feature — never move a use case or a concrete repository into `core/`. If a business *capability* (not just a data shape) is needed by 2+ features, define a narrow abstract interface in `core/services/`, implement it inside the owning feature, and register the implementation against the interface in that feature's `injection.dart`. Other features depend only on the `core/services/` interface, never on the owning feature directly.

---

## State Management — BLoC / Cubit

### When to use what

| Complexity                | Tool    | Example                   |
| ------------------------- | ------- | ------------------------- |
| Simple toggles, counters  | `Cubit` | theme toggle, form field  |
| Event-driven / multi-step | `Bloc`  | auth flow, paginated list |

### BLoC rules

- Call only use cases from Blocs/Cubits — no direct repository or service calls.
- A Bloc/Cubit must never be instantiated with GetIt; instantiate only with `BlocProvider`.
- Declare `BlocProvider` at the route/page entry point where the Bloc is first used (including directly inside `MaterialPageRoute` builder).
- Declare above `MaterialApp` only when shared across multiple root-level routes.
- For multi-page flows (page1 -> page2 -> ... -> final recap), use one shared flow Bloc plus one page Bloc per page.
- Each page Bloc handles only page-specific logic and persists step data into the shared flow Bloc.
- Create the shared flow Bloc with `BlocProvider(create: ...)` in a parent container that owns the entire flow (e.g. a dedicated `ShellRoute` wrapping its nested Navigator). Keep that container mounted between steps and remove it on completion or abandonment so the provider closes the Bloc automatically. Do not tie its lifetime to the first or last page. See the shared-flow example in `code-examples.md`.
- Use `BlocBuilder` with `buildWhen` to minimise unnecessary rebuilds.
- Use `BlocListener` for one-time side effects (navigation, snackbars, dialogs).
- Use `BlocConsumer` when both rebuilding and listening are needed.
- Always emit a loading state before every async operation.
- Blocs provided via `BlocProvider(create: ...)` are closed automatically when the provider leaves the widget tree.
- `BlocProvider.value(value: existingBloc)` only exposes an existing Bloc; it does not own or close it. Consuming pages must not close a shared Bloc. Its original owner remains responsible for disposal; when that owner is a `BlocProvider(create: ...)`, disposal is automatic when it leaves the tree.

---

## Dependency Injection — GetIt

**Rules:**

- `registerLazySingleton` for services, repositories, use cases — always bind explicitly against the abstract type (`sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(...))`), never let GetIt infer the concrete implementation type.
- Never register Blocs/Cubits in GetIt.
- `registerSingleton` only for objects required at app startup.
- Never call `sl<T>()` inside widgets — inject via `BlocProvider` or constructor.

---

## Navigation — go_router

**Rules:**

- All route path constants live in `AppRoutes`.
- Use path parameters for entity identifiers; query params for optional filters.
- Implement `redirect` for auth guarding — never guard inside pages.
- Wire `AppRouter`'s `refreshListenable` to the auth state stream (e.g. `core/services/AuthSessionService`) so `redirect` re-evaluates immediately when auth state changes mid-session, not only on the next navigation.
- Pass only primitive identifiers through routes; load full data in the
  destination page's Bloc.

---

## Networking — Dio / NetworkingService

- Use a `NetworkingService` wrapper around `Dio`.
- Set explicit `connectTimeout` / `receiveTimeout` on the `Dio` instance — never rely on platform defaults.
- Register interceptors: `TokenInterceptor` and `CustomHeaderInterceptor`.
- Use `PrettyDioLogger` only in debug builds and exclude exchanges containing sensitive data from logging. `requestHeader` and `requestBody` only enable or disable logging; they do not redact fields. If logging sensitive exchanges is necessary, use a logger that explicitly redacts tokens, passwords, and PII from requests, responses, URLs, and errors before writing any output — see Security.
- Optionally add an `UnsupportedAppVersionInterceptor` to force an update prompt when the backend rejects the app version.
- Check `NetworkInfo.isConnected` in the repository before calling the remote data source; fall back to the local data source when offline (see Local Storage & Caching).
- On a 401 from an authenticated request (`requiresToken: true`), coordinate token renewal through `AuthSessionService`: concurrent requests must await a single shared refresh operation, then retry each original request at most once with the updated token. Exclude login and refresh endpoints from this mechanism to prevent refresh loops. If a delayed 401 belongs to a request sent with an older token that has already been renewed, reuse the current token for the one allowed retry rather than refreshing again.
- Call `AuthSessionService.logout()` only when the backend confirms that the session or refresh token is invalid or revoked, using the API's documented status/error codes; the router's `redirect` then handles navigation. On a temporary refresh failure (network error, timeout, or server unavailability), preserve the session and surface a typed, recoverable error. A second 401 after the allowed retry must be surfaced without another refresh/retry loop; apply logout only when the API contract confirms session invalidation.
- Map all `DioException` types to typed `AppException` subclasses — never fall back to the bare Dart `Exception`, even in generic or unknown-error branches.
- For `DioExceptionType.badResponse`, branch on the HTTP status code below — never return one generic exception for every non-2xx response. Each `AppException` carries the backend's own `message` when present, plus a stable `AppErrorCode`; it never carries a literal display string — only the presentation layer resolves that code to text via `AppLocalizations` (see UI & Styling):

  | Status code | `AppException` subclass    | `AppErrorCode`      |
  | ----------- | --------------------------- | -------------------- |
  | 400 / 422   | `ValidationException`       | `validation` (+ per-field errors when the backend provides them) |
  | 401         | `UnauthorizedException`     | `unauthorized` — apply the conditional refresh/logout policy above; suppress errors recovered by refresh, otherwise let presentation handle the final error (including login failures) |
  | 403         | `ForbiddenException`        | `forbidden`           |
  | 404         | `NotFoundException`         | `notFound`            |
  | 409         | `ConflictException`         | `conflict`            |
  | 429         | `TooManyRequestsException`  | `tooManyRequests`     |
  | 500–599     | `ServerException`           | `server`              |
  | other       | `UnknownException`          | `unknown`             |

- Use `requiresToken: true` extra flag for authenticated endpoints.

---

## Local Storage & Caching

- Use `flutter_secure_storage` for sensitive data (tokens, credentials).
- Use `shared_preferences` for lightweight non-sensitive preferences.
- Use `hive` or `sqflite` for structured local persistence and offline-first data.
- For `sqflite`, manage schema changes via `openDatabase`'s `version` + `onUpgrade`, with one incremental migration step per version — never a destructive drop/recreate that discards the user's cached data.
- For `hive`, evolve models additively only (new fields nullable or with defaults, `typeId` per adapter kept stable across releases); if a breaking change is unavoidable, store a schema-version key and rebuild the box on mismatch instead of letting deserialization crash.
- Never ship a model/schema change without verifying the upgrade path from the previous released version's local data.
- Never store sensitive data in `SharedPreferences`.
- Wrap all storage access behind an interface (`LocalDataSource`).
- Define cache expiry policies in the data source, not in the repository.

---

## UI & Styling

- Use `ThemeData` for all theming — no hardcoded colors or text styles.
- Use `AppLocalizations` for all user-facing strings — no hardcoded strings.
- Domain/data exceptions carry a stable `AppErrorCode` (enum or const), never a literal display string — `domain`/`data` have zero Flutter imports and cannot call `AppLocalizations`. Only the presentation layer resolves that code to a localized message at the point of display (`BlocListener`, `SnackBar`...); see the Networking error table.
- Use updated text theme API: `titleLarge`, `headlineSmall`, `bodyMedium`, etc.
  (never deprecated `headline6`, `bodyText2`, etc.).
- Implement responsive layouts with `LayoutBuilder` or `MediaQuery`.
- Use `NavigationRail` or `AdaptiveLayout` for tablet/desktop breakpoints.
- Use `AssetImage` for bundled assets; `CachedNetworkImage` for remote images.
- Always provide `errorWidget` and `placeholder` on `CachedNetworkImage` (`errorBuilder` is `Image.network`'s parameter name, not `CachedNetworkImage`'s).
- Use `RefreshIndicator` for pull-to-refresh.
- Set `textCapitalization`, `keyboardType`, and `textInputAction` on all `TextField`s.
- Use `AutofillGroup` with `autofillHints` on login and register forms.

---

## Widgets

- Prefer a `StatelessWidget` driven by a Bloc/Cubit over a `StatefulWidget` for state that represents business/app data (loading, list contents, form validity...) — the Bloc owns that state, not the widget. Reserve `StatefulWidget` for local, ephemeral UI concerns that need a lifecycle hook `StatelessWidget` can't provide: `TextEditingController`, `ScrollController`, `PageController`, `FocusNode`, `AnimationController` (needs `vsync`), or `AutomaticKeepAliveClientMixin` — anything that must be created in `initState()` and released in `dispose()`.
- Prefer `StatelessWidget` classes over build-method helpers.
- Never use `Widget _buildXxx()` — always extract a named `StatelessWidget`.
- Use `const` constructors wherever possible to prevent unnecessary rebuilds.
- Keep widget trees shallow — extract sub-trees when nesting exceeds 3-4 levels.
- Use `BlocBuilder` only for the minimal subtree that depends on state.
- Use `RepaintBoundary` to isolate frequently-updated subtrees (animations, real-time data feeds).
- Provide a stable `Key` (e.g. `ValueKey(item.id)`) for items in `ListView.builder`/`AnimatedList` — without it, reordering or removing an item can cause state loss or visual glitches between list positions.
- Avoid `GlobalKey` unless you genuinely need to reach a `State` across the tree (e.g. `Form` validation) — prefer passing data down via constructor or Bloc otherwise; a duplicated `GlobalKey` in the tree throws at runtime.
- A synchronous state assignment in `initState()` never needs `setState()` — `initState()` always runs before the first `build()`, so a direct field assignment is already reflected.
- Guard a `setState()` called from an async callback started in `initState()` with `if (!mounted) return;` — the widget may already be disposed by the time the `Future` resolves.
- Reserve `WidgetsBinding.instance.addPostFrameCallback` for work that genuinely needs the widget already laid out (reading `context.size`, `Scrollable.ensureVisible`, showing a dialog/snackbar on page open).
- Never reuse a `BuildContext` after an `await` without checking `context.mounted` first — e.g. `Navigator.of(context)`, `ScaffoldMessenger.of(context)` called after an async gap can throw if the widget was disposed during the wait.
- Every controller/listener created in `initState()` (`TextEditingController`, `AnimationController`, `ScrollController`, `FocusNode`...) must be disposed in `dispose()` — a missing `.dispose()` leaks memory and can keep ticking after the widget is gone.

---

## Performance — Mobile-specific

- Avoid the `Opacity` widget for animations — use `FadeTransition` when driven by an explicit `AnimationController` (the usual Bloc/Cubit-driven case), `AnimatedOpacity` for a simple implicit fade with no controller, and `FadeInImage` for fading in images specifically (GPU shader, cheaper than wrapping an `Image` in `Opacity`).
- Prefer `BoxDecoration(borderRadius: ...)` over `ClipRRect` for rounded corners — clipping is cheaper than `Opacity` but still costly; never clip an image mid-animation, pre-clip the asset instead. Avoid `Clip.antiAliasWithSaveLayer` — it triggers `saveLayer()`.
- Watch for hidden `saveLayer()` calls (offscreen buffer + GPU render-target switch): `ShaderMask`, `ColorFilter`, `Chip` with `disabledColorAlpha != 0xff`, `Text` with an overflow shader. Check DevTools → Performance → "checkerboard offscreen layers" when frames are slow.
- Never override `operator ==`/`hashCode` on a `Widget` subclass — it defeats the framework's O(1) widget-comparison fast path and can degrade to O(N²) on large trees; cache the widget instance instead if you need to skip a rebuild.
- Avoid `IntrinsicHeight`/`IntrinsicWidth` in lists/grids — they force a layout pass across every cell (not just visible ones) to compute a uniform size, then a second pass to apply it; fix the size upfront instead.
- Use `StringBuffer` (not `+`/`+=`) when building a string in a loop — each `+` allocates a new `String` object.
- Always use `ListView.builder` / `SliverList` — never `ListView` with children.
- Never combine `ListView.builder`/`SliverList` with `shrinkWrap: true` — it forces eager layout of every item, defeating lazy building; use slivers inside a `CustomScrollView` for nested scrollables instead.
- Provide `itemExtent` (or `prototypeItem`) on `ListView.builder` when item height is fixed/known — lets Flutter compute scroll metrics without laying out off-screen items.
- Decode images at their display size, not their native resolution: `memCacheWidth`/`memCacheHeight` on `CachedNetworkImage`, `cacheWidth`/`cacheHeight` on `Image` — a large image displayed small otherwise wastes decode memory.
- Use `AutomaticKeepAliveClientMixin` for tabs that must not be rebuilt on switch.
- Use `compute()` for CPU-heavy work (large JSON parsing, image processing) to keep the UI thread free — it spawns a new isolate (tens of ms of fixed overhead), so reserve it for genuinely heavy work, not small payloads where the spawn cost outweighs the parsing time.
- Avoid `setState` that rebuilds large trees — scope rebuilds to small Cubits.
- Use `BlocSelector` instead of `BlocBuilder` when only a derived value from the state matters — it skips rebuilds where the state changed but the selected value didn't.
- For search-as-you-type, apply an explicit debounce with a delay suited to the UI (e.g. 300 ms). Only publish results for the latest search: use an appropriate event transformer for Bloc or a request identifier for Cubit, invalidating obsolete results as soon as the query changes, including when it is cleared. `bloc_concurrency` manages event concurrency; it does not provide temporal debounce/throttle. `restartable` cancels previous event handlers, not automatically the underlying HTTP requests; propagate cancellation separately when needed.
- Never do filtering/sorting/formatting of large collections inside `build()` — compute it once in the Bloc/Cubit and expose the result via state, not recompute it on every rebuild.
- Pass the static part of an animated subtree via `AnimatedBuilder`'s `child` parameter, not inside `builder` — `builder` reruns every animation tick, `child` does not.
- Keep `main()` minimal before `runApp()` — defer non-critical async initialization so the first frame isn't delayed by cold-start work.
- Use `precacheImage()` for images known to appear on the next screen.
- Profile in **profile mode** (never debug mode — its numbers are significantly slower and not representative) on the lowest-end device you target, using Flutter DevTools — never optimise by assumption.

---

## Accessibility

- Wrap interactive widgets with `Semantics` when the default label is unclear.
- Ensure all tappable targets are >= 48x48 logical pixels.
- Use `ExcludeSemantics` for purely decorative widgets.
- Never rely on colour alone to convey meaning.
- Never disable text scaling (`TextScaler.noScaling`) or hardcode font sizes that ignore the system setting — test the UI at a high text-scale factor (1.3x–2.0x) for overflow.
- Always set `tooltip` on icon-only `IconButton`s — it feeds `Semantics` directly, not just the visual tooltip; without it, a screen reader announces nothing but "Button".
- Every text/background color pair in `AppColors` must meet WCAG AA contrast: 4.5:1 for normal text, 3:1 for large text (18pt+/14pt bold+) and UI components.
- Respect `MediaQuery.of(context).disableAnimations` (system "reduce motion") — skip or shorten non-essential animations when it's true.
- Wrap dynamically-appearing status text (form validation errors, inline status messages) in `Semantics(liveRegion: true)` so assistive tech announces the change without the user having to move focus.
- Test with TalkBack (Android) and VoiceOver (iOS) for all critical flows.

---

## Security

- Never log tokens, passwords, or PII — not even in debug builds.
- Use `flutter_secure_storage` with platform-appropriate options
  (`iOSOptions`, `AndroidOptions` with encrypted prefs).
- Obfuscate release builds:
  `flutter build apk --obfuscate --split-debug-info=build/debug-info`
- Validate all data arriving from the server before rendering it.
- Use `obscureText: true` and `enableSuggestions: false` on password fields.
- Always use parameterized `sqflite` queries (`where: 'id = ?', whereArgs: [value]`) — never interpolate user input directly into a SQL string.
- Never commit secrets to source control or embed privileged secrets (private keys, server API credentials) in the application; keep them on the backend. Use `--dart-define` or configuration files for environment-specific values, not as secret protection: values included in the distributed app remain extractable, even with obfuscation. Public configuration such as an API base URL and keys explicitly intended for client applications may be embedded, with the provider's appropriate restrictions applied to client keys.
- Disallow cleartext (HTTP) traffic in release builds — Android network security config and iOS ATS must reject non-HTTPS endpoints.
- On `AuthSessionService.logout()`, clear `flutter_secure_storage` and any locally cached user data (`sqflite`/`hive`) tied to that session — not just the in-memory Bloc state.

---

## Logging & Debugging

- Use `log()` from `dart:developer` — never `print()`.
- Wrap `log()` in `kDebugMode` guards in hot-path code.
- Register `AppBlocObserver` in all build modes: `onError` always reports to the crash-reporting service (Crashlytics/Sentry); `onEvent`/`onChange`/`onTransition` verbose logging stays gated behind `kDebugMode`.
- Wire `FlutterError.onError` and `PlatformDispatcher.instance.onError` to the crash-reporting service in `main()` before `runApp()` — uncaught framework and async errors must be captured in production, not just printed to console.
- Document non-obvious logic with inline comments (`//`).
- Document all public APIs with doc comments (`///`).
- Use `assert()` for invariants that must never be violated in development.
