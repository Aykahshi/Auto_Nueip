import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/configs/curl_config.dart';
import 'package:gl_nueip/core/models/location_model.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';

class LocationService {
  final String apiKey = CurlConfig.GOOGLE_API_KEY;
  final LocationCubit _locationCubit = locator<LocationCubit>();

  Future<Location?> convertAddress({required String address}) async {
    final String url =
        '${CurlConfig.GOOGLE_GEOCODING_URL}address=$address&key=$apiKey';
    Response response = await Dio().get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = response.data;

      if (data['status'] == 'OK') {
        final latLng = data['results'][0]['geometry']['location'];
        final Location location = Location(
            latitude: latLng['lat'].toString(),
            longitude: latLng['lng'].toString());

        _locationCubit.saveLocation(location: location, locationName: address);

        return location;
      } else {
        if (kDebugMode) {
          print('Geocoding Error: ${data['status']}');
        }
        _locationCubit.geoNotFound();
        return null;
      }
    } else {
      if (kDebugMode) {
        print('Request failed with status: ${response.statusCode}.');
      }
      _locationCubit.geoLocateFailed();
      return null;
    }
  }
}
