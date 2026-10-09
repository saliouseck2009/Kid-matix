/// Contract of a use case that needs input parameters.
abstract interface class UseCase<Output, Input> {
  /// Runs the use case with [params].
  Future<Output> call({required Input params});
}

/// Contract of a use case that needs no input.
abstract interface class NoParamUseCase<Output> {
  /// Runs the use case.
  Future<Output> call();
}
