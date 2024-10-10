import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'location_state.dart';

class LocationCubit extends Cubit<LocationState> {
  final SharedPreferences _prefs;

  static const String _geoKey = 'location';
  static const String _addressKey = 'address';

  LocationCubit(this._prefs) : super(LocationNone()) {
    loadLocation();
  }

  void updateLocation({
    required Location newLocation,
    required String newAddress,
  }) {
    saveLocation(
      location: newLocation,
      address: newAddress,
    );
    emit(LocationHasValue(
      location: newLocation,
      address: newAddress,
    ));
  }

  void clearLocation() async {
    _prefs.remove(_geoKey);
    _prefs.remove(_addressKey);
    emit(LocationNone());
  }

  void geoNotFound() async {
    emit(LocationNone());
  }

  void geoLocateFailed() async {
    emit(LocationHasError());
  }

  void loadLocation() async {
    final locationString = _prefs.getString(_geoKey);
    final locationName = _prefs.getString(_addressKey);

    if (locationString == null || locationName == null) return;

    final json = jsonDecode(locationString);
    final Location location = Location.fromJson(json);

    emit(LocationHasValue(
      location: location,
      address: locationName,
    ));
  }

  Future<void> saveLocation({
    required Location location,
    required String address,
  }) async {
    _prefs.setString(_addressKey, jsonEncode(address));
    _prefs.setString(_geoKey, jsonEncode(location.toJson()));
  }
}
