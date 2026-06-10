import 'package:flutter/material.dart';

import '../location/location_service.dart';
import 'location_detail.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({
    this.locationService = const DeviceLocationService(),
    super.key,
  });

  final LocationService locationService;

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  UserLocation? _location;
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
            'Share your location when you are ready to search around you.',
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
                    onPressed: _isLoading ? null : _getCurrentLocation,
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
                      _location == null ? 'Use current location' : 'Refresh',
                    ),
                  ),
                  if (_location case final location?) ...[
                    const SizedBox(height: 18),
                    LocationDetail(
                      label: 'Latitude',
                      value: location.latitude.toStringAsFixed(6),
                    ),
                    const SizedBox(height: 8),
                    LocationDetail(
                      label: 'Longitude',
                      value: location.longitude.toStringAsFixed(6),
                    ),
                    if (location.accuracyMeters case final accuracy?) ...[
                      const SizedBox(height: 8),
                      LocationDetail(
                        label: 'Accuracy',
                        value: '${accuracy.round()}m',
                      ),
                    ],
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
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final location = await widget.locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() => _location = location);
    } on LocationException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _errorMessage = error.message);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
