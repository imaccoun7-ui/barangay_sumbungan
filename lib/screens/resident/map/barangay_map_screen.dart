import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/launchers.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_dialogs.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../models/directory_model.dart';
import '../../../providers/app_scope.dart';

// Re-export SectionHeader, IconTile, ScreenHeading from app_card.dart to avoid ambiguity
import '../../../core/widgets/app_card.dart' show SectionHeader, IconTile;

/// Screen heading with title and subtitle (local to this file to avoid conflicts)
class _ScreenHeading extends StatelessWidget {
  const _ScreenHeading({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Barangay map using OpenStreetMap via flutter_map (free, no API key required).
class BarangayMapScreen extends StatefulWidget {
  const BarangayMapScreen({super.key});

  @override
  State<BarangayMapScreen> createState() => _BarangayMapScreenState();
}

class _BarangayMapScreenState extends State<BarangayMapScreen> {
  String? _selectedId;
  final MapController _mapController = MapController();

  // Default center: Barangay Sumbungan approximate area (adjust as needed)
  static const LatLng _defaultCenter = LatLng(14.5995, 120.9842);
  static const double _defaultZoom = 15.5;

  IconData _icon(String category) {
    switch (category) {
      case 'Barangay Hall':
        return Icons.account_balance_outlined;
      case 'Health Center':
        return Icons.local_hospital_outlined;
      case 'Covered Court':
        return Icons.sports_basketball_outlined;
      case 'School':
        return Icons.school_outlined;
      case 'Evacuation Center':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Color _markerColor(String category) {
    switch (category) {
      case 'Barangay Hall':
        return AppColors.primaryDark;
      case 'Health Center':
        return Colors.redAccent;
      case 'Covered Court':
        return Colors.orange;
      case 'School':
        return Colors.blue;
      case 'Evacuation Center':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  List<Marker> _buildMarkers(
    List<BarangayLocationModel> locations,
    String? selectedId,
    ValueChanged<BarangayLocationModel> onSelect,
  ) {
    return locations
        .where((l) => l.hasCoordinates)
        .map((location) {
          final bool isSelected = location.id == selectedId;
          return Marker(
            point: LatLng(location.latitude, location.longitude),
            width: isSelected ? 48 : 40,
            height: isSelected ? 48 : 40,
            child: GestureDetector(
              onTap: () => onSelect(location),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: isSelected ? 36 : 30,
                    height: isSelected ? 36 : 30,
                    decoration: BoxDecoration(
                      color: _markerColor(location.category),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _icon(location.category),
                      size: isSelected ? 18 : 14,
                      color: Colors.white,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        location.name,
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        })
        .toList();
  }

  Future<void> _directions(BarangayLocationModel location) async {
    final bool opened = await Launchers.openMap(
      label: location.name,
      latitude: location.hasCoordinates ? location.latitude : null,
      longitude: location.hasCoordinates ? location.longitude : null,
      address: location.address,
    );
    if (!mounted) return;
    if (!opened) {
      AppDialogs.toast(
        context,
        'No map application is available on this device.',
        error: true,
      );
    }
  }

  void _centerOnLocation(BarangayLocationModel location) {
    _mapController.move(
      LatLng(location.latitude, location.longitude),
      17.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<BarangayLocationModel> locations = AppScope.of(context)
        .locations
        .where((BarangayLocationModel l) => l.isActive)
        .toList();
    final BarangayLocationModel? selected = locations
        .cast<BarangayLocationModel?>()
        .firstWhere(
          (BarangayLocationModel? l) => l?.id == _selectedId,
          orElse: () => null,
        );

    // Determine initial map center
    LatLng initialCenter = _defaultCenter;
    if (selected != null && selected.hasCoordinates) {
      initialCenter = LatLng(selected.latitude, selected.longitude);
    } else if (locations.isNotEmpty) {
      final withCoords = locations.where((l) => l.hasCoordinates).toList();
      if (withCoords.isNotEmpty) {
        initialCenter = LatLng(withCoords.first.latitude, withCoords.first.longitude);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Barangay Map'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
        ),
        actions: [
          if (locations.any((l) => l.hasCoordinates))
            IconButton(
              tooltip: 'Recenter map',
              onPressed: () {
                if (selected != null && selected.hasCoordinates) {
                  _centerOnLocation(selected);
                } else {
                  final withCoords = locations.where((l) => l.hasCoordinates).toList();
                  if (withCoords.isNotEmpty) {
                    _mapController.move(
                      LatLng(withCoords.first.latitude, withCoords.first.longitude),
                      _defaultZoom,
                    );
                  }
                }
              },
              icon: const Icon(Icons.my_location_outlined),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
          children: <Widget>[
            const _ScreenHeading(
              title: 'Community Map',
              subtitle:
                  'Important barangay facilities. Tap a marker to see details '
                  'and open directions.',
            ),
            const SizedBox(height: 16),
            // Live interactive map
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 320,
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: _defaultZoom,
                    minZoom: 10,
                    maxZoom: 19,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.barangay.sumbungan',
                      maxZoom: 19,
                      // Optional: add subdomains for better tile loading
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: _buildMarkers(
                        locations,
                        _selectedId,
                        (location) => setState(() => _selectedId = location.id),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (selected != null) ...<Widget>[
              const SizedBox(height: 16),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        IconTile(icon: _icon(selected.category), foreground: _markerColor(selected.category)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                selected.name,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                selected.category,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _selectedId = null),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          color: AppColors.textHint,
                        ),
                      ],
                    ),
                    if (selected.address.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.location_on_outlined,
                              size: 15, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              selected.address,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (selected.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        selected.description,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.55,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (selected.hasCoordinates) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(Icons.gps_fixed_outlined,
                              size: 14, color: AppColors.textHint),
                          const SizedBox(width: 6),
                          Text(
                            'Coordinates: ${selected.latitude.toStringAsFixed(6)}, ${selected.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _directions(selected),
                            icon: const Icon(Icons.directions_outlined, size: 17),
                            label: const Text('Open directions'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _centerOnLocation(selected),
                            icon: const Icon(Icons.center_focus_strong_outlined, size: 17),
                            label: const Text('Center map'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const SectionHeader(title: 'Barangay facilities'),
            if (locations.isEmpty)
              const EmptyState(
                icon: Icons.map_outlined,
                title: 'No facilities published',
                message:
                    'The barangay has not published map locations yet. Please '
                    'check back later.',
              )
            else
              ...locations.map(
                (BarangayLocationModel location) => AppCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  onTap: () {
                    setState(() => _selectedId = location.id);
                    if (location.hasCoordinates) {
                      _centerOnLocation(location);
                    }
                  },
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      IconTile(
                        icon: _icon(location.category),
                        size: 40,
                        background: _selectedId == location.id
                            ? AppColors.primarySoftAlt
                            : AppColors.primarySoft,
                        foreground: _markerColor(location.category),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              location.name,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location.address.isEmpty
                                  ? location.category
                                  : location.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (location.hasCoordinates) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.gps_fixed_outlined,
                                    size: 10,
                                    color: AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Has coordinates',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _directions(location),
                        icon: const Icon(Icons.near_me_outlined, size: 18),
                        color: AppColors.primary,
                        tooltip: 'Directions',
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

