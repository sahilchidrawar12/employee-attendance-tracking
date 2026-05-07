import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config_service.dart';

class Zone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String type;
  final String status;
  final int radius;

  Zone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.type,
    required this.status,
    required this.radius,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      type: json['type'] ?? 'office',
      status: json['status'] ?? 'active',
      radius: json['radius'] ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'type': type,
      'status': status,
      'radius': radius,
    };
  }

  Map<String, dynamic> toDynamicMap() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }
}

class ZonesService {
  final ConfigService _configService = ConfigService();

  Future<List<Zone>> getCompanyZones(String companyId) async {
    try {
      final apiUrl = await _configService.getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiUrl/locations/zones/$companyId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((zone) => Zone.fromJson(zone)).toList();
      } else {
        print('Failed to fetch zones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching zones: $e');
      return [];
    }
  }

  Future<List<Zone>> getAllZones() async {
    try {
      final apiUrl = await _configService.getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiUrl/locations/zones'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((zone) => Zone.fromJson(zone)).toList();
      } else {
        print('Failed to fetch zones: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching all zones: $e');
      return [];
    }
  }

  Future<Zone?> getZoneDetails(String zoneId) async {
    try {
      final apiUrl = await _configService.getApiBaseUrl();
      final response = await http.get(
        Uri.parse('$apiUrl/locations/$zoneId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Zone.fromJson(data);
      } else {
        print('Failed to fetch zone details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching zone details: $e');
      return null;
    }
  }

  Future<Zone?> createZone(Zone zone) async {
    try {
      final apiUrl = await _configService.getApiBaseUrl();
      final token = await _configService.getAuthToken();

      final response = await http.post(
        Uri.parse('$apiUrl/locations/zones'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(zone.toJson()),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return Zone.fromJson(jsonDecode(response.body));
      } else {
        print('Failed to create zone: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error creating zone: $e');
      return null;
    }
  }
}
