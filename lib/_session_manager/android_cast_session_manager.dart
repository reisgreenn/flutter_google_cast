import 'package:flutter/services.dart';
import 'package:google_cast/enums/connection_satate.dart';
import 'package:google_cast/entities/cast_session.dart';
import 'package:google_cast/entities/cast_device.dart';
import 'package:google_cast/models/android/cast_device.dart';
import 'package:google_cast/models/android/cast_session.dart';
import 'package:rxdart/subjects.dart';

import 'cast_session_manager_platform.dart';

class GoogleCastSessionManagerAndroidMethodChannel
    implements GoogleCastSessionManagerPlatformInterface {
  GoogleCastSessionManagerAndroidMethodChannel() {
    _channel.setMethodCallHandler(_onMethodCallHandler);
  }
  final _channel =
      const MethodChannel('com.felnanuke.google_cast.session_manager');

  final _currentSessionStreamController = BehaviorSubject<GoogleCastSession?>()
    ..add(null);

  @override
  GoogleCastConnectState get connectionState =>
      _currentSessionStreamController.value?.connectionState ??
      GoogleCastConnectState.ConnectionStateDisconnected;

  @override
  GoogleCastSession? get currentSession =>
      _currentSessionStreamController.value;

  @override
  Stream<GoogleCastSession?> get currentSessionStream =>
      _currentSessionStreamController.stream;

  @override
  Future<bool> endSession() async {
    return await _channel.invokeMethod('endSession');
  }

  @override
  Future<bool> endSessionAndStopCasting() async {
    return await _channel.invokeMethod('endSessionAndStopCasting');
  }

  @override
  bool get hasConnectedSession =>
      _currentSessionStreamController.value?.connectionState ==
      GoogleCastConnectState.ConnectionStateConnected;

  @override
  Future<void> setDefaultSessionOptions() {
    throw UnimplementedError('Only works in IOS');
  }

  @override
  Future<bool> startSessionWithDevice(GoogleCastDevice device) async {
    device as GoogleCastAndroidDevice;
    return (await _channel.invokeMethod(
          'startSessionWithDeviceId',
          device.deviceID,
        )) ==
        true;
  }

  @override
  Future<bool> startSessionWithOpenURLOptions() {
    // TODO: implement startSessionWithOpenURLOptions
    throw UnimplementedError();
  }

  @override
  Future<bool> suspendSessionWithReason() {
    // TODO: implement suspendSessionWithReason
    throw UnimplementedError();
  }

  Future _onMethodCallHandler(MethodCall call) async {
    switch (call.method) {
      case "onSessionChanged":
        _onSessionChanged(call.arguments);
        return;
      default:
    }
  }

  void _onSessionChanged(arguments) {
    if (arguments == null) {
      _currentSessionStreamController.add(null);
      return;
    }
    final map = Map<String, dynamic>.from(arguments);
    final session = GoogleCastSessionAndroid.fromMap(map);
    _currentSessionStreamController.add(session);
  }

  @override
  void setDeviceVolume(double value) {
    _channel.invokeMethod('setStreamVolume', value);
  }
}
