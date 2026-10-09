# Code Examples — Flutter/Dart Patterns

## Core — Typed Exception hierarchy

```dart
// core/error/app_exception.dart
sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

final class NetworkException extends AppException {
  const NetworkException(super.message);
}

final class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

final class CacheException extends AppException {
  const CacheException(super.message);
}

final class AuthException extends AppException {
  const AuthException(super.message);
}

final class InternetException extends AppException {
  const InternetException(super.message);
}
```

---

## Core — DataState (sealed, Dart 3)

```dart
// core/error/data_state.dart
sealed class DataState<T> {
  const DataState();
}

final class DataSuccess<T> extends DataState<T> {
  final T data;
  const DataSuccess(this.data);
}

final class DataFailed<T> extends DataState<T> {
  final AppException exception;
  const DataFailed(this.exception);
}
```

Using `sealed` ensures switch expressions are exhaustive — the compiler
enforces handling both cases.

---

## Domain — UseCase base classes

```dart
// core/usecases/usecase.dart
abstract interface class UseCase<Output, Input> {
  Future<Output> call({required Input params});
}

abstract interface class NoParamUseCase<Output> {
  Future<Output> call();
}
```

---

## Domain — Entity conventions

```dart
// features/product/domain/entities/product_entity.dart
@immutable
class ProductEntity {
  final String id;
  final String name;
  final double price;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
  });

  ProductEntity copyWith({String? id, String? name, double? price}) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
```

---

## Data — DTO conventions

```dart
// features/product/data/models/product_network_model.dart
@JsonSerializable()
class ProductNetworkModel {
  @JsonKey(name: 'product_id')
  final String id;
  final String name;
  final double price;

  const ProductNetworkModel({
    required this.id,
    required this.name,
    required this.price,
  });

  factory ProductNetworkModel.fromJson(Map<String, dynamic> json) =>
      _$ProductNetworkModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductNetworkModelToJson(this);

  ProductEntity toEntity() => ProductEntity(
        id: id,
        name: name,
        price: price,
      );
}
```

Rules:
- DTOs live in `data/models/` — named `XxxNetworkModel` (remote) or `XxxLocalModel` (local cache).
- Domain entities live in `domain/entities/` — named `XxxEntity`.
- The mapping method is always `.toEntity()`.

---

## Data — Repository implementation

```dart
// features/product/data/repositories/product_repository_impl.dart
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _networkInfo;

  const ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  @override
  Future<DataState<List<ProductEntity>>> getProducts() async {
    if (!await _networkInfo.isConnected) {
      try {
        final cached = await _local.getCachedProducts();
        return DataSuccess(cached.map((m) => m.toEntity()).toList());
      } catch (_) {
        return const DataFailed(CacheException('No cached data available.'));
      }
    }
    try {
      final models = await _remote.fetchProducts();
      await _local.cacheProducts(models);
      return DataSuccess(models.map((m) => m.toEntity()).toList());
    } on AppException catch (e) {
      return DataFailed(e);
    } catch (e, st) {
      log(st.toString());
      return DataFailed(NetworkException(e.toString()));
    }
  }
}
```

---

## State Management — Sealed States

```dart
// features/product/presentation/bloc/product_state.dart
sealed class ProductState {
  const ProductState();
}

final class ProductInitial extends ProductState {
  const ProductInitial();
}

final class ProductLoading extends ProductState {
  const ProductLoading();
}

final class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductLoaded(this.products);
}

final class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);
}
```

---

## State Management — Shared Flow Bloc Lifetime

This integration excerpt assumes an existing `RegistrationFlowBloc`, its use
cases, and the three registration pages. Page-specific Blocs remain inside their
pages; this example focuses on ownership of the shared Bloc. Configure the router
once in `core/router/`, injecting `SubmitRegistrationUseCase` through its constructor
or factory rather than resolving dependencies inside widgets.

```dart
abstract final class AppRoutes {
  static const home = '/';
  static const registrationIdentity = '/registration';
  static const registrationAddress = '/registration/address';
  static const registrationReview = '/registration/review';
}

GoRouter createAppRouter(SubmitRegistrationUseCase submitRegistration) {
  return GoRouter(
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (_, _) => const HomePage(),
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => RegistrationFlowBloc(
            submitRegistration: submitRegistration,
          ),
          child: child, // The nested Navigator, containing all three steps.
        ),
        routes: [
          GoRoute(
            path: AppRoutes.registrationIdentity,
            builder: (_, _) => const RegistrationIdentityPage(),
          ),
          GoRoute(
            path: AppRoutes.registrationAddress,
            builder: (_, _) => const RegistrationAddressPage(),
          ),
          GoRoute(
            path: AppRoutes.registrationReview,
            builder: (_, _) => const RegistrationReviewPage(),
          ),
        ],
      ),
    ],
  );
}
```

Each page accesses the same instance with
`context.read<RegistrationFlowBloc>()`. After validating and saving a step,
advance with `context.go(AppRoutes.registrationAddress)` or
`context.go(AppRoutes.registrationReview)`. These sibling routes share the same
shell and provider. Use explicit previous-step navigation with `context.go(...)`
when needed; this example does not build a back stack between steps.

On cancellation from any step, call `context.go(AppRoutes.home)`. On successful
submission, do the same from a `BlocListener` observing the success state. Home
is outside the shell, so leaving the flow removes its provider and automatically
closes the Bloc. Do not merely `push` Home over the flow: that keeps the flow
mounted. No page calls `close()`, and no `BlocProvider.value` is needed here.

Keep all steps on the shell Navigator; routing a step onto the root Navigator
would place it outside this provider. For direct links to later steps, add a
separate draft-restoration or prerequisite-check policy before displaying them.

---

## Dependency Injection — GetIt

```dart
// core/di/injection_container.dart
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  _registerCore();
  _registerProductFeature();
}

void _registerCore() {
  sl.registerLazySingleton<Dio>(() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  ));
  sl.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<InternetConnectionChecker>()),
  );
  sl.registerLazySingleton<NetworkingService>(
    () => NetworkingService(dio: sl(), prefs: sl()),
  );
}

void _registerProductFeature() {
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(networkingService: sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(storage: sl()),
  );
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remote: sl(),
      local: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<GetProductsUseCase>(() => GetProductsUseCase(sl()));
}
```

Resolve the use case at the composition root after registering dependencies,
then pass it into the router configuration. The route builder passes the captured
use case to `ProductPage`; it does not resolve dependencies inside the widget.

```dart
// At app composition, after configureDependencies():
final getProducts = sl<GetProductsUseCase>();

// In the router's routes list, capturing getProducts:
GoRoute(
  path: AppRoutes.products,
  builder: (_, _) => ProductPage(getProducts: getProducts),
),
```

This excerpt assumes `AppRoutes.products` is defined in the application's route
constants. The feature page owns its Bloc through `BlocProvider`; `ProductBloc`
and `ProductView` are the feature's existing Bloc and content widget.

```dart
class ProductPage extends StatelessWidget {
  const ProductPage({required this.getProducts, super.key});

  final GetProductsUseCase getProducts;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProductBloc(getProducts: getProducts),
      child: const ProductView(),
    );
  }
}
```

Each page instance owns a fresh Bloc, automatically closed when its provider
leaves the tree. GetIt manages the use case, not the Bloc.

---

## Navigation — go_router

```dart
// core/router/app_router.dart
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: kDebugMode,
  redirect: _guardRoute,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.productDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailPage(productId: id);
      },
    ),
  ],
);

// core/router/app_routes.dart
abstract final class AppRoutes {
  static const String home = '/';
  static const String productDetail = '/product/:id';
}
```

---

## Networking — NetworkingService (Dio)

```dart
// core/network/networking_service.dart
class NetworkingService {
  final Dio _dio;
  final SecureStorage _prefs;

  NetworkingService({required Dio dio, required SecureStorage prefs})
      : _dio = dio,
        _prefs = prefs {
    _dio.interceptors.addAll([
      TokenInterceptor(_prefs),
      CustomHeaderInterceptor(),
      if (kDebugMode) PrettyDioLogger(),
    ]);
  }

  Future<Response<T>> get<T>(
    String endpoint, {
    bool requiresToken = false,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        endpoint,
        queryParameters: queryParameters,
        options: _mergeOptions(options, requiresToken),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Request timed out.');
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code == 401) return const AuthException('Unauthorized.');
        if (code == 403) return const AuthException('Forbidden.');
        return ServerException('Server error (code: $code).', statusCode: code);
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return const InternetException('No internet connection.');
        }
        return NetworkException(e.message ?? 'Unknown network error.');
      default:
        return NetworkException(e.message ?? 'Network error.');
    }
  }
}
```

---

## TokenInterceptor

```dart
// core/network/token_interceptor.dart
class TokenInterceptor extends Interceptor {
  final SecureStorage _prefs;
  final String tokenKey;

  TokenInterceptor(this._prefs, {this.tokenKey = SecureStorageKey.token});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final requiresToken = options.extra['requiresToken'] == true;
    if (!requiresToken) return handler.next(options);
    final token = await _prefs.getItem(key: tokenKey);
    if (token == null || token.isEmpty) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          error: 'Missing auth token.',
        ),
      );
    }
    options.headers['Authorization'] = 'Bearer $token';
    return handler.next(options);
  }
}
```

---

## Local Data Source interface

```dart
// features/product/data/datasources/product_local_datasource.dart
abstract interface class ProductLocalDataSource {
  Future<List<ProductLocalModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductNetworkModel> models);
  Future<bool> isCacheValid();
}
```

---

## Logging setup

```dart
// main.dart
void main() {
  if (kDebugMode) Bloc.observer = AppBlocObserver();
  runApp(const App());
}
```
