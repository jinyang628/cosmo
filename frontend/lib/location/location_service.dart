import 'dart:async';

import 'package:geolocator/geolocator.dart';

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class LocationException implements Exception {
  const LocationException(this.reason, this.message);

  final LocationFailureReason reason;
  final String message;

  @override
  String toString() => message;
}

abstract class LocationService {
  Future<UserLocation> getCurrentLocation();
}

class DeviceLocationService implements LocationService {
  const DeviceLocationService();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
  );

  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw const LocationException(
          LocationFailureReason.serviceDisabled,
          'Location services are turned off.',
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw const LocationException(
          LocationFailureReason.permissionDenied,
          'Location permission was denied.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(
          LocationFailureReason.permissionDeniedForever,
          'Location permission is permanently denied.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } on LocationException {
      rethrow;
    } on TimeoutException {
      throw const LocationException(
        LocationFailureReason.unavailable,
        'Could not get your location before the request timed out.',
      );
    } catch (_) {
      throw const LocationException(
        LocationFailureReason.unavailable,
        'Could not get your location right now.',
      );
    }
  }
}
