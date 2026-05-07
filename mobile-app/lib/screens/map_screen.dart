import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/config_service.dart';
import '../services/zones_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ConfigService _configService = ConfigService();
  final ZonesService _zonesService = ZonesService();
  Position? _currentPosition;
  bool _isLoading = true;
  String _errorMessage = '';
  List<Zone> _zones = [];
  String? _companyId;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _configService.initialize();
    _companyId = await _configService.getCompanyId();
    await _getCurrentLocation();
    await _loadZones();
  }

  Future<void> _loadZones() async {
    try {
      final zones = _companyId != null
          ? await _zonesService.getCompanyZones(_companyId!)
          : await _zonesService.getAllZones();
      setState(() {
        _zones = zones;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load zones: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not determine location';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Nearby zones',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'See approved zones around you',
                    style: TextStyle(color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Container(
                      height: 280,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                ),
                              )
                            : _currentPosition == null
                                ? Center(child: Text(_errorMessage.isEmpty ? 'Location required' : _errorMessage))
                                : GoogleMap(
                                    initialCameraPosition: CameraPosition(
                                      target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                      zoom: 13,
                                    ),
                                    myLocationEnabled: true,
                                    myLocationButtonEnabled: true,
                                    onMapCreated: (_) {},
                                    markers: _createMarkers(),
                                    circles: _createCircles(),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _zones.isEmpty
                          ? Center(child: Text(_errorMessage.isEmpty ? 'No zones available yet' : _errorMessage))
                          : ListView.builder(
                              itemCount: _zones.length,
                              itemBuilder: (context, index) {
                                final zone = _zones[index];
                                final distance = _currentPosition != null
                                    ? Geolocator.distanceBetween(
                                        _currentPosition!.latitude,
                                        _currentPosition!.longitude,
                                        zone.latitude,
                                        zone.longitude,
                                      )
                                    : 0.0;
                                return _zoneCard(
                                  zone.name,
                                  zone.status,
                                  _statusColor(zone.status),
                                  distance / 1000,
                                );
                              },
                            ),
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

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    for (var zone in _zones) {
      markers.add(
        Marker(
          markerId: MarkerId('zone_${zone.id}'),
          position: LatLng(zone.latitude, zone.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(_markerHue(zone.status)),
          infoWindow: InfoWindow(title: zone.name),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _createCircles() {
    final circles = <Circle>{};

    for (var zone in _zones) {
      circles.add(
        Circle(
          circleId: CircleId('zone_circle_${zone.id}'),
          center: LatLng(zone.latitude, zone.longitude),
          radius: zone.radius.toDouble(),
          fillColor: _statusColor(zone.status).withValues(alpha: 0.15),
          strokeColor: _statusColor(zone.status),
          strokeWidth: 2,
        ),
      );
    }

    return circles;
  }

  double _markerHue(String status) {
    if (status == 'active') return BitmapDescriptor.hueGreen;
    if (status == 'nearby') return BitmapDescriptor.hueYellow;
    return BitmapDescriptor.hueRed;
  }

  Color _statusColor(String status) {
    if (status == 'active') return Colors.green;
    if (status == 'nearby') return Colors.amber;
    return Colors.red;
  }

  Widget _zoneCard(String name, String status, Color color, double distanceKm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(status, style: TextStyle(fontSize: 14, color: color)),
            ],
          ),
          Text('${distanceKm.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 14, color: Color(0xFF64748B))),
        ],
      ),
    );
  }
}
