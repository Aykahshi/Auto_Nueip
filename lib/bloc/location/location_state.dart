part of 'location_cubit.dart';

sealed class LocationState extends Equatable {
  const LocationState();
}

final class LocationNone extends LocationState {
  @override
  List<Object> get props => [];
}

final class LocationHasValue extends LocationState {
  final Location location;
  final String address;

  const LocationHasValue({required this.location, required this.address});

  @override
  List<Object> get props => [location, address];
}

final class LocationHasError extends LocationState {
  @override
  List<Object> get props => [];
}
