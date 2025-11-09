enum BlocStatus { initial, loading, success, failure }

extension BlocStatusX on BlocStatus {
  bool get isLoading => this == BlocStatus.loading;
  bool get isSuccess => this == BlocStatus.success;
  bool get isFailure => this == BlocStatus.failure;
}
