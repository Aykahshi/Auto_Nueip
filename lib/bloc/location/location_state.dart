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
  final String locationName;

  const LocationHasValue({required this.location, required this.locationName});

  @override
  List<Object> get props => [location];
}

final class LocationHasError extends LocationState {
  @override
  List<Object> get props => [];
}
