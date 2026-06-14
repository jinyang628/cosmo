import 'package:flutter/material.dart';

import '../location/location_service.dart';
import '../preferences/diet_preference.dart';
import '../restaurants/restaurant.dart';
import '../restaurants/restaurants_api.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    required this.distanceMeters,
    required this.selectedDiets,
    this.locationService = const DeviceLocationService(),
    this.restaurantsApi = const RestaurantsApi(),
    super.key,
  });

  final double distanceMeters;
  final Set<DietPreference> selectedDiets;
  final LocationService locationService;
  final RestaurantsApi restaurantsApi;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  UserLocation? _location;
  List<Restaurant> _restaurants = const [];
  String? _errorMessage;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            'Nearby restaurants',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your location when you are ready to search within ${_formatDistance(widget.distanceMeters)}.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 28),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.my_location, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Current location',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _findNearbyRestaurants,
                    icon: _isLoading
                        ? SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.near_me_outlined),
                    label: Text(
                      _restaurants.isEmpty
                          ? 'Find restaurants nearby'
                          : 'Refresh',
                    ),
                  ),
                  if (_restaurants.isEmpty &&
                      _location != null &&
                      _errorMessage == null &&
                      !_isLoading) ...[
                    const SizedBox(height: 18),
                    Text(
                      'No restaurants found nearby.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (_errorMessage case final errorMessage?) ...[
                    const SizedBox(height: 18),
                    Text(
                      errorMessage,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_restaurants.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text(
              'Restaurants',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            for (final restaurant in _restaurants) ...[
              _RestaurantTile(restaurant: restaurant),
              const SizedBox(height: 10),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _findNearbyRestaurants() async {
    setState(() {
      _isLoading = true;
      _location = null;
      _errorMessage = null;
      _restaurants = const [];
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() => _location = location);

      final restaurants = await widget.restaurantsApi.searchNearby(
        location: location,
        radiusMeters: widget.distanceMeters,
        dietPreferences: widget.selectedDiets,
      );
      if (!mounted) {
        return;
      }

      setState(() => _restaurants = restaurants);
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _errorMessage = error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = 'Could not search nearby restaurants right now.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _RestaurantTile extends StatelessWidget {
  const _RestaurantTile({required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final metadata = [
      if (restaurant.rating case final rating?)
        '${rating.toStringAsFixed(1)} star',
      if (restaurant.userRatingCount case final count?) '$count ratings',
      if (restaurant.priceLevel case final priceLevel?)
        _formatPriceLevel(priceLevel),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                restaurant.name,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (restaurant.formattedAddress case final address?) ...[
                const SizedBox(height: 6),
                Text(
                  address,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in metadata)
                      Chip(
                        label: Text(item),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDistance(double meters) {
  final roundedMeters = meters.round();
  if (roundedMeters < 1000) {
    return '${(roundedMeters / 100).round() * 100}m';
  }

  final kilometers = roundedMeters / 1000;
  if (kilometers == kilometers.roundToDouble()) {
    return '${kilometers.round()}km';
  }

  return '${kilometers.toStringAsFixed(1)}km';
}

String _formatPriceLevel(String priceLevel) {
  return switch (priceLevel) {
    'PRICE_LEVEL_FREE' => 'Free',
    'PRICE_LEVEL_INEXPENSIVE' => r'$',
    'PRICE_LEVEL_MODERATE' => r'$$',
    'PRICE_LEVEL_EXPENSIVE' => r'$$$',
    'PRICE_LEVEL_VERY_EXPENSIVE' => r'$$$$',
    _ => priceLevel,
  };
}
