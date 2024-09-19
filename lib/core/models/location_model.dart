import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String latitude;
  final String longitude;

  const Location({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
