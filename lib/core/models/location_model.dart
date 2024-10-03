import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final String latitude;
  final String longitude;

  const Location({required this.latitude, required this.longitude});

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude];
}
