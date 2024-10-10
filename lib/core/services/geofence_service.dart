import 'dart:async';
import 'dart:developer';

import 'package:geofence_foreground_service/exports.dart';
import 'package:geofence_foreground_service/geofence_foreground_service.dart';
import 'package:geofence_foreground_service/models/notification_icon_data.dart';
import 'package:geofence_foreground_service/models/zone.dart';
import 'package:gl_nueip/bloc/cubit.dart';
import 'package:gl_nueip/core/utils/injection_container.dart';
import 'package:gl_nueip/main.dart';
import 'package:permission_handler/permission_handler.dart';

class GeofenceService {
  bool _hasServiceStarted = false;

  GeofenceService() {
    initPlatformState();
  }

  Future<void> _createLondonGeofence() async {
    if (!_hasServiceStarted) {
      log('Service has not started yet', name: 'createGeofence');
      return;
    }

    final LocationCubit locationCubit = locator<LocationCubit>();
    var location = (locationCubit.state as LocationHasValue).location;

    LatLng londonCityCenter = LatLng.degree(
      double.parse(location.latitude),
      double.parse(location.longitude),
    );

    await GeofenceForegroundService().addGeofenceZone(
      zone: Zone(
        id: 'zone#1_id',
        radius: 1000, // measured in meters
        coordinates: [londonCityCenter],
        notificationResponsivenessMs: 15 * 1000, // 15 seconds
      ),
    );
  }

  Future<void> initPlatformState() async {
    await Permission.location.request();
    await Permission.locationAlways.request();

    _hasServiceStarted =
        await GeofenceForegroundService().startGeofencingService(
      contentTitle: '自動打卡APP在背景運作',
      contentText: '自動打卡APP正在背景運作',
      notificationChannelId: 'com.app.geofencing_notifications_channel',
      serviceId: 525600,
      notificationIconData: const NotificationIconData(
        resType: ResourceType.drawable,
        resPrefix: ResourcePrefix.img,
        name: 'launcher',
      ),
      callbackDispatcher: callbackDispatcher,
    );

    log(_hasServiceStarted.toString(), name: 'hasServiceStarted');
    await _createLondonGeofence();
  }
}
