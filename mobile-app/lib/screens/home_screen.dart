import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../services/config_service.dart';
import '../services/websocket_service.dart';
import '../services/zones_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _checkedIn = false;
  DateTime? _clockInTime;
  DateTime? _clockOutTime;
  Position? _currentPosition;
  String _zoneStatus = 'Checking location...';
  bool _isLoading = false;
  String _currentZone = 'Unknown';
  final ConfigService _configService = ConfigService();
  final ZonesService _zonesService = ZonesService();
  final WebSocketService _webSocketService = WebSocketService();
  final List<Zone> _zones = [];
  String? _employeeId;
  String? _companyId;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _configService.initialize();
    _employeeId = await _configService.getEmployeeId();
    _companyId = await _configService.getCompanyId();
    await _loadZones();
    await _getCurrentLocation();
    await _checkAttendanceStatus();
    await _connectWebSocket();
    _startLocationTracking();
  }

  Future<void> _loadZones() async {
    try {
      final zones = _companyId != null
          ? await _zonesService.getCompanyZones(_companyId!)
          : await _zonesService.getAllZones();
      setState(() {
        _zones.clear();
        _zones.addAll(zones);
      });
      await _checkZoneStatus();
    } catch (e) {
      setState(() {
        _zoneStatus = 'Could not load zones';
      });
    }
  }

  Future<void> _connectWebSocket() async {
    await _webSocketService.connect(_employeeId ?? '', (message) {
      switch (message['type']) {
        case 'ATTENDANCE_UPDATE':
          _handleAttendanceUpdate(message);
          break;
        case 'LOCATION_UPDATE':
          _handleLocationUpdate(message);
          break;
        case 'ZONE_ALERT':
          _handleZoneAlert(message);
          break;
      }
    });
  }

  void _startLocationTracking() {
    _locationTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_checkedIn && _currentPosition != null && _webSocketService.isConnected) {
        _webSocketService.sendLocationUpdate(
          _employeeId ?? '',
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          _currentZone,
        );
      }
    });
  }

  void _handleAttendanceUpdate(Map<String, dynamic> message) {
    if (message['employeeId'] == _employeeId) {
      setState(() {
        _checkedIn = message['checkedIn'] ?? false;
        if (message['clockInTime'] != null) {
          _clockInTime = DateTime.parse(message['clockInTime']);
        }
        if (message['clockOutTime'] != null) {
          _clockOutTime = DateTime.parse(message['clockOutTime']);
        }
      });
    }
  }

  void _handleLocationUpdate(Map<String, dynamic> message) {
    // Handle location updates from other sources if needed
  }

  void _handleZoneAlert(Map<String, dynamic> message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message['message'] ?? 'Zone alert'),
        backgroundColor: Colors.orange,
      ),
    );
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
        });
        await _checkZoneStatus();
      } else {
        setState(() {
          _zoneStatus = 'Location permission denied';
        });
      }
    } catch (e) {
      setState(() {
        _zoneStatus = 'Location unavailable';
      });
    }
  }

  Future<void> _checkZoneStatus() async {
    if (_currentPosition == null || _zones.isEmpty) {
      setState(() {
        _zoneStatus = 'No zones configured';
        _currentZone = 'Unknown';
      });
      return;
    }

    Zone? matchedZone;
    double shortestDistance = double.infinity;

    for (var zone in _zones) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        zone.latitude,
        zone.longitude,
      );
      if (distance < shortestDistance) {
        shortestDistance = distance;
        matchedZone = zone;
      }
    }

    if (matchedZone != null) {
      final zoneName = matchedZone.name;
      if (shortestDistance <= matchedZone.radius) {
        setState(() {
          _zoneStatus = 'In zone';
          _currentZone = zoneName;
        });
        return;
      }
      if (shortestDistance <= matchedZone.radius * 2) {
        setState(() {
          _zoneStatus = 'Nearby';
          _currentZone = zoneName;
        });
        return;
      }
    }

    setState(() {
      _zoneStatus = 'Outside zone';
      _currentZone = 'Unknown';
    });
  }

  Future<void> _checkAttendanceStatus() async {
    if (_employeeId == null) {
      setState(() {
        _checkedIn = false;
      });
      return;
    }

    try {
      final apiUrl = await _configService.getApiBaseUrl();
      final token = await _configService.getAuthToken();
      final response = await http.get(
        Uri.parse('$apiUrl/attendance/status/$_employeeId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        setState(() {
          _checkedIn = data['checkedIn'] == true;
          if (data['lastCheckIn'] != null && data['lastCheckIn'].toString().isNotEmpty) {
            _clockInTime = DateTime.parse(data['lastCheckIn']);
          }
          if (data['lastCheckOut'] != null && data['lastCheckOut'].toString().isNotEmpty) {
            _clockOutTime = DateTime.parse(data['lastCheckOut']);
          }
        });
      }
    } catch (_) {
      setState(() {
        _checkedIn = false;
      });
    }
  }

  Future<void> _togglePunch() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final apiUrl = await _configService.getApiBaseUrl();
      final token = await _configService.getAuthToken();
      final employeeId = _employeeId;

      if (employeeId == null) {
        throw Exception('Missing employee credentials');
      }

      final uri = Uri.parse('$apiUrl/attendance/${_checkedIn ? 'punch-out' : 'punch-in'}');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'employeeId': employeeId,
          'latitude': _currentPosition?.latitude,
          'longitude': _currentPosition?.longitude,
          'zoneName': _currentZone,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _checkedIn = !_checkedIn;
          if (_checkedIn) {
            _clockInTime = now;
            _clockOutTime = null;
          } else {
            _clockOutTime = now;
          }
        });

        _webSocketService.sendAttendanceUpdate(
          employeeId,
          _checkedIn ? 'PUNCH_IN' : 'PUNCH_OUT',
          now,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_checkedIn ? 'Successfully punched in!' : 'Successfully punched out!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final error = jsonDecode(response.body)['error']?['message'] ?? 'Unable to update attendance';
        throw Exception(error);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get _statusLabel => _checkedIn ? 'Punched In' : 'Ready to punch in';
  String get _buttonLabel => _checkedIn ? 'PUNCH OUT' : 'PUNCH IN';
  Color get _buttonColor => _checkedIn ? const Color(0xFFDC2626) : const Color(0xFF16A34A);

  String _getElapsedTime() {
    if (!_checkedIn || _clockInTime == null) return '00h 00m';

    final elapsed = DateTime.now().difference(_clockInTime!);
    final hours = elapsed.inHours;
    final minutes = elapsed.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE, d MMMM').format(DateTime.now());
    final checkInText = _clockInTime != null ? DateFormat('hh:mm a').format(_clockInTime!) : '--:-- --';
    final checkOutText = _clockOutTime != null ? DateFormat('hh:mm a').format(_clockOutTime!) : '--:-- --';
    final hours = _getElapsedTime();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good Morning, John 👋',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(date, style: const TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF7C3AED)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _statusLabel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _zoneStatus,
                              style: TextStyle(
                                color: Colors.white.withAlpha(204),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _checkedIn ? Colors.green.withAlpha(51) : Colors.white.withAlpha(51),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _checkedIn ? 'Active' : 'Inactive',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _togglePunch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                _buttonLabel,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem('Check-in', checkInText),
                        _summaryItem('Hours', hours),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem('Zone', _currentZone),
                        _summaryItem('Check-out', checkOutText),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Status: $_zoneStatus',
                      style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (_zoneStatus == 'Outside zone')
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You are outside approved zones. Request location approval if needed.',
                          style: TextStyle(color: Colors.orange.shade800, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to unknown location flow
                        },
                        child: const Text('Request'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF0F172A), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

