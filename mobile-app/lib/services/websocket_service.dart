import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import '../services/config_service.dart';

class WebSocketService {
  IOWebSocketChannel? _channel;
  Function(Map<String, dynamic>)? _onMessageReceived;
  bool _isConnected = false;
  final ConfigService _configService = ConfigService();

  Future<void> connect(String employeeId, Function(Map<String, dynamic>) onMessageReceived) async {
    _onMessageReceived = onMessageReceived;
    await _configService.initialize();
    final wsUrl = await _configService.getWsBaseUrl();
    final token = await _configService.getAuthToken();

    try {
      final headers = <String, dynamic>{};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: headers.isEmpty ? null : headers,
      );

      _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message);
            _onMessageReceived?.call(data);
          } catch (e) {
            print('Error parsing WebSocket message: $e');
          }
        },
        onDone: () {
          _isConnected = false;
          print('WebSocket connection closed');
        },
        onError: (error) {
          _isConnected = false;
          print('WebSocket error: $error');
        },
      );

      _sendMessage({
        'type': 'SUBSCRIBE',
        'employeeId': employeeId,
      });

      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      print('Failed to connect to WebSocket: $e');
    }
  }

  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_isConnected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void sendLocationUpdate(String employeeId, double latitude, double longitude, String zoneName) {
    _sendMessage({
      'type': 'LOCATION_UPDATE',
      'employeeId': employeeId,
      'latitude': latitude,
      'longitude': longitude,
      'zoneName': zoneName,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void sendAttendanceUpdate(String employeeId, String action, DateTime timestamp) {
    _sendMessage({
      'type': 'ATTENDANCE_UPDATE',
      'employeeId': employeeId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    });
  }

  bool get isConnected => _isConnected;
}