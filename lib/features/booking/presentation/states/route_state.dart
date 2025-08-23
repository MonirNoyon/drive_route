import '../../domain/entities/route_option.dart';

class RouteState {
  final bool loading;
  final List<RouteOption> routes;
  final int? selectedIndex;
  final String? error;

  const RouteState({
    required this.loading,
    required this.routes,
    required this.selectedIndex,
    required this.error,
  });

  factory RouteState.initial() =>
      const RouteState(loading: false, routes: [], selectedIndex: null, error: null);

  RouteState copyWith({
    bool? loading,
    List<RouteOption>? routes,
    int? selectedIndex,
    String? error,
  }) {
    return RouteState(
      loading: loading ?? this.loading,
      routes: routes ?? this.routes,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      error: error,
    );
  }
}