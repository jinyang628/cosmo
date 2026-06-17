class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    this.resourceName,
    this.formattedAddress,
    this.shortFormattedAddress,
    this.location,
    this.types = const [],
    this.primaryType,
    this.primaryTypeDisplayName,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.priceRange,
    this.googleMapsUri,
    this.websiteUri,
    this.businessStatus,
    this.openNow,
    this.openingHoursWeekdayDescriptions = const [],
    this.accessibilityOptions,
    this.attributions = const [],
    this.movedPlace,
    this.movedPlaceId,
  });

  final String id;
  final String name;
  final String? resourceName;
  final String? formattedAddress;
  final String? shortFormattedAddress;
  final RestaurantLocation? location;
  final List<String> types;
  final String? primaryType;
  final String? primaryTypeDisplayName;
  final double? rating;
  final int? userRatingCount;
  final String? priceLevel;
  final String? priceRange;
  final String? googleMapsUri;
  final String? websiteUri;
  final String? businessStatus;
  final bool? openNow;
  final List<String> openingHoursWeekdayDescriptions;
  final RestaurantAccessibilityOptions? accessibilityOptions;
  final List<RestaurantAttribution> attributions;
  final String? movedPlace;
  final String? movedPlaceId;

  factory Restaurant.fromJson(Map<String, Object?> json) {
    final locationJson = json['location'];
    final accessibilityJson = json['accessibility_options'];
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      resourceName: json['resource_name'] as String?,
      formattedAddress: json['formatted_address'] as String?,
      shortFormattedAddress: json['short_formatted_address'] as String?,
      location: locationJson is Map<String, Object?>
          ? RestaurantLocation.fromJson(locationJson)
          : null,
      types: _stringListFromJson(json['types']),
      primaryType: json['primary_type'] as String?,
      primaryTypeDisplayName: json['primary_type_display_name'] as String?,
      rating: switch (json['rating']) {
        final int value => value.toDouble(),
        final double value => value,
        _ => null,
      },
      userRatingCount: json['user_rating_count'] as int?,
      priceLevel: json['price_level'] as String?,
      priceRange: json['price_range'] as String?,
      googleMapsUri: json['google_maps_uri'] as String?,
      websiteUri: json['website_uri'] as String?,
      businessStatus: json['business_status'] as String?,
      openNow: json['open_now'] as bool?,
      openingHoursWeekdayDescriptions: _stringListFromJson(
        json['opening_hours_weekday_descriptions'],
      ),
      accessibilityOptions: accessibilityJson is Map<String, Object?>
          ? RestaurantAccessibilityOptions.fromJson(accessibilityJson)
          : null,
      attributions: _attributionsFromJson(json['attributions']),
      movedPlace: json['moved_place'] as String?,
      movedPlaceId: json['moved_place_id'] as String?,
    );
  }
}

class RestaurantLocation {
  const RestaurantLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  factory RestaurantLocation.fromJson(Map<String, Object?> json) {
    return RestaurantLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}

class RestaurantAccessibilityOptions {
  const RestaurantAccessibilityOptions({
    this.wheelchairAccessibleParking,
    this.wheelchairAccessibleEntrance,
    this.wheelchairAccessibleRestroom,
    this.wheelchairAccessibleSeating,
  });

  final bool? wheelchairAccessibleParking;
  final bool? wheelchairAccessibleEntrance;
  final bool? wheelchairAccessibleRestroom;
  final bool? wheelchairAccessibleSeating;

  factory RestaurantAccessibilityOptions.fromJson(Map<String, Object?> json) {
    return RestaurantAccessibilityOptions(
      wheelchairAccessibleParking:
          json['wheelchair_accessible_parking'] as bool?,
      wheelchairAccessibleEntrance:
          json['wheelchair_accessible_entrance'] as bool?,
      wheelchairAccessibleRestroom:
          json['wheelchair_accessible_restroom'] as bool?,
      wheelchairAccessibleSeating:
          json['wheelchair_accessible_seating'] as bool?,
    );
  }
}

class RestaurantAttribution {
  const RestaurantAttribution({this.displayName, this.uri, this.photoUri});

  final String? displayName;
  final String? uri;
  final String? photoUri;

  factory RestaurantAttribution.fromJson(Map<String, Object?> json) {
    return RestaurantAttribution(
      displayName: json['display_name'] as String?,
      uri: json['uri'] as String?,
      photoUri: json['photo_uri'] as String?,
    );
  }
}

List<String> _stringListFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return List<String>.unmodifiable(value.whereType<String>());
}

List<RestaurantAttribution> _attributionsFromJson(Object? value) {
  if (value is! List) {
    return const [];
  }

  return List<RestaurantAttribution>.unmodifiable(
    value.whereType<Map<String, Object?>>().map(RestaurantAttribution.fromJson),
  );
}
