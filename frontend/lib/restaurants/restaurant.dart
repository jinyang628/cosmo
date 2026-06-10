class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    this.formattedAddress,
    this.location,
    this.rating,
    this.userRatingCount,
    this.priceLevel,
    this.googleMapsUri,
    this.businessStatus,
  });

  final String id;
  final String name;
  final String? formattedAddress;
  final RestaurantLocation? location;
  final double? rating;
  final int? userRatingCount;
  final String? priceLevel;
  final String? googleMapsUri;
  final String? businessStatus;

  factory Restaurant.fromJson(Map<String, Object?> json) {
    final locationJson = json['location'];
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      formattedAddress: json['formatted_address'] as String?,
      location: locationJson is Map<String, Object?>
          ? RestaurantLocation.fromJson(locationJson)
          : null,
      rating: switch (json['rating']) {
        final int value => value.toDouble(),
        final double value => value,
        _ => null,
      },
      userRatingCount: json['user_rating_count'] as int?,
      priceLevel: json['price_level'] as String?,
      googleMapsUri: json['google_maps_uri'] as String?,
      businessStatus: json['business_status'] as String?,
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
