import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final SharedPreferences _prefs;

  static const String _geoKey = 'location';
  static const String _geoNameKey = 'location_name';

  LocationCubit(this._prefs) : super(LocationNone()) {
    loadLocation();
  }

  void updateLocation({
    required Location newLocation,
    required String newLocationName,
  }) {
    saveLocation(
      location: newLocation,
      locationName: newLocationName,
    );
    emit(LocationHasValue(
      location: newLocation,
      locationName: newLocationName,
    ));
  }

  void geoNotFound() async {
    emit(LocationNone());
  }

  void geoLocateFailed() async {
    emit(LocationHasError());
  }

  void loadLocation() async {
    final locationString = _prefs.getString(_geoKey);
    final locationName = _prefs.getString(_geoNameKey);

    if (locationString == null || locationName == null) return;

    final json = jsonDecode(locationString);
    final Location location = Location.fromJson(json);

    emit(LocationHasValue(
      location: location,
      locationName: locationName,
    ));
  }

  Future<void> saveLocation({
    required Location location,
    required String locationName,
  }) async {
    _prefs.setString(_geoNameKey, jsonEncode(locationName));
    _prefs.setString(_geoKey, jsonEncode(location.toJson()));
  }
}
