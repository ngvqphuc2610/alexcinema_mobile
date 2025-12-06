import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

/// Service for managing Socket.IO connection for real-time seat locking
class SocketService {
  IO.Socket? _socket;
  String? _currentSessionId;

  final void Function(int seatId, String sessionId)? onSeatLocked;
  final void Function(int seatId)? onSeatUnlocked;
  final void Function()? onConnected;
  final void Function()? onDisconnected;
  final void Function(String error)? onError;

  SocketService({
    this.onSeatLocked,
    this.onSeatUnlocked,
    this.onConnected,
    this.onDisconnected,
    this.onError,
  });

  /// Connect to Socket.IO server
  void connect(String baseUrl) {
    if (_socket != null && _socket!.connected) {
      debugPrint('🔌 Already connected to Socket.IO');
      return;
    }

    debugPrint('🔌 Connecting to Socket.IO: $baseUrl/seats');

    _socket = IO.io(
      '$baseUrl/seats',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableForceNew()
          .setExtraHeaders({'foo': 'bar'}) // Optional headers
          .build(),
    );

    _setupEventListeners();
    _socket!.connect();
  }

  /// Setup event listeners for Socket.IO events
  void _setupEventListeners() {
    _socket!.on('connect', (_) {
      debugPrint('✅ Connected to Socket.IO');
      _currentSessionId = _socket!.id;
      debugPrint('📱 Session ID: $_currentSessionId');
      onConnected?.call();
    });

    _socket!.on('disconnect', (_) {
      debugPrint('❌ Disconnected from Socket.IO');
      onDisconnected?.call();
    });

    _socket!.on('connect_error', (error) {
      debugPrint('⚠️ Connection error: $error');
      onError?.call(error.toString());
    });

    _socket!.on('error', (error) {
      debugPrint('⚠️ Socket error: $error');
      onError?.call(error.toString());
    });

    // Listen for seat locked event from other users
    _socket!.on('seatLocked', (data) {
      debugPrint('🔒 Seat locked event: $data');
      if (data is Map) {
        final seatId = data['seatId'] as int?;
        final sessionId = data['sessionId'] as String?;

        if (seatId != null &&
            sessionId != null &&
            sessionId != _currentSessionId) {
          // Only trigger if locked by someone else
          onSeatLocked?.call(seatId, sessionId);
        }
      }
    });

    // Listen for seat unlocked event
    _socket!.on('seatUnlocked', (data) {
      debugPrint('🔓 Seat unlocked event: $data');
      if (data is Map) {
        final seatId = data['seatId'] as int?;
        if (seatId != null) {
          onSeatUnlocked?.call(seatId);
        }
      }
    });
  }

  /// Join a showtime room to receive real-time updates
  Future<List<Map<String, dynamic>>> joinShowtime(int showtimeId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    debugPrint('📺 Joining showtime room: $showtimeId');

    final completer = Completer<List<Map<String, dynamic>>>();

    _socket!.emitWithAck(
      'joinShowtime',
      {'showtimeId': showtimeId},
      ack: (response) {
        debugPrint('📋 Join showtime response: $response');

        if (response is Map) {
          if (response['success'] == true && response['lockedSeats'] != null) {
            final lockedSeats = (response['lockedSeats'] as List)
                .map((seat) => Map<String, dynamic>.from(seat as Map))
                .toList();
            completer.complete(lockedSeats);
          } else {
            completer.completeError(
              response['error'] ?? 'Failed to join showtime',
            );
          }
        } else {
          completer.completeError('Invalid response format');
        }
      },
    );

    return completer.future;
  }

  /// Lock a seat
  Future<bool> lockSeat(int showtimeId, int seatId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    debugPrint('🔒 Locking seat: $seatId for showtime: $showtimeId');

    final completer = Completer<bool>();

    _socket!.emitWithAck(
      'lockSeat',
      {'showtimeId': showtimeId, 'seatId': seatId},
      ack: (response) {
        debugPrint('🔒 Lock seat response: $response');

        if (response is Map) {
          if (response['success'] == true) {
            completer.complete(true);
          } else {
            completer.completeError(response['error'] ?? 'Failed to lock seat');
          }
        } else {
          completer.completeError('Invalid response format');
        }
      },
    );

    return completer.future;
  }

  /// Unlock a seat
  Future<bool> unlockSeat(int showtimeId, int seatId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    debugPrint('🔓 Unlocking seat: $seatId for showtime: $showtimeId');

    final completer = Completer<bool>();

    _socket!.emitWithAck(
      'unlockSeat',
      {'showtimeId': showtimeId, 'seatId': seatId},
      ack: (response) {
        debugPrint('🔓 Unlock seat response: $response');

        if (response is Map) {
          if (response['success'] == true) {
            completer.complete(true);
          } else {
            completer.completeError(
              response['error'] ?? 'Failed to unlock seat',
            );
          }
        } else {
          completer.completeError('Invalid response format');
        }
      },
    );

    return completer.future;
  }

  /// Get currently locked seats for a showtime
  Future<List<Map<String, dynamic>>> getLockedSeats(int showtimeId) async {
    if (_socket == null || !_socket!.connected) {
      throw Exception('Socket not connected');
    }

    debugPrint('📋 Getting locked seats for showtime: $showtimeId');

    final completer = Completer<List<Map<String, dynamic>>>();

    _socket!.emitWithAck(
      'getLockedSeats',
      {'showtimeId': showtimeId},
      ack: (response) {
        debugPrint('📋 Get locked seats response: $response');

        if (response is Map) {
          if (response['success'] == true && response['lockedSeats'] != null) {
            final lockedSeats = (response['lockedSeats'] as List)
                .map((seat) => Map<String, dynamic>.from(seat as Map))
                .toList();
            completer.complete(lockedSeats);
          } else {
            completer.completeError(
              response['error'] ?? 'Failed to get locked seats',
            );
          }
        } else {
          completer.completeError('Invalid response format');
        }
      },
    );

    return completer.future;
  }

  /// Check if connected
  bool get isConnected => _socket?.connected ?? false;

  /// Get current session ID
  String? get sessionId => _currentSessionId;

  /// Disconnect from Socket.IO
  void disconnect() {
    if (_socket != null) {
      debugPrint('🔌 Disconnecting from Socket.IO');
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _currentSessionId = null;
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }
}
