import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:proximity_sensor/proximity_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';

class SensorState {
  final double lux;
  final bool isShakeDetected;
  final bool isProximityNear;
  final double x;
  final double y;
  final double z;

  SensorState({
    this.lux = 0,
    this.isShakeDetected = false,
    this.isProximityNear = false,
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });

  SensorState copyWith({
    double? lux,
    bool? isShakeDetected,
    bool? isProximityNear,
    double? x,
    double? y,
    double? z,
  }) {
    return SensorState(
      lux: lux ?? this.lux,
      isShakeDetected: isShakeDetected ?? this.isShakeDetected,
      isProximityNear: isProximityNear ?? this.isProximityNear,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }
}

class SensorViewModel extends StateNotifier<SensorState> with WidgetsBindingObserver {
  final Ref _ref;
  StreamSubscription<int>? _lightSubscription;
  StreamSubscription<dynamic>? _proximitySubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  SensorViewModel(this._ref) : super(SensorState()) {
    _initSensors();
    WidgetsBinding.instance.addObserver(this);
    
    // Listen to Auth State - Stop sensors if unauthenticated to prevent background spam
    _ref.listen(authViewModelProvider, (previous, next) {
      if (next.authEntity == null) {
        debugPrint("User unauthenticated, stopping sensors...");
        _stopSensors();
      } else if (previous?.authEntity == null && next.authEntity != null) {
        debugPrint("User authenticated, restarting sensors...");
        _initSensors();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      debugPrint("App ${state.name}, pausing sensors...");
      _stopSensors();
    } else if (state == AppLifecycleState.resumed) {
       // Only restart if user is authenticated
      if (_ref.read(authViewModelProvider).authEntity != null) {
        debugPrint("App resumed, restarting sensors...");
        _initSensors();
      }
    }
  }

  void _stopSensors() {
    _lightSubscription?.cancel();
    _proximitySubscription?.cancel();
    _accelSubscription?.cancel();
    _lightSubscription = null;
    _proximitySubscription = null;
    _accelSubscription = null;
  }

  DateTime _lastLightUpdate = DateTime.now();

  void _initSensors() {
    if (_lightSubscription != null) return; // Already running
    debugPrint("Initializing Sensors (Stable Mode)...");
    
    // 1. Light Sensor Logic with Throttling and Smoothing
    try {
      _lightSubscription = LightSensor.luxStream().listen((int lux) {
        final now = DateTime.now();
        
        // Throttling: Only process if lux changed significantly (>= 5) OR 2 seconds have passed
        // This stops console spam and reduces unnecessary UI rebuilds
        if ((lux - state.lux).abs() < 5 && now.difference(_lastLightUpdate).inMilliseconds < 2000) {
          return;
        }
        _lastLightUpdate = now;

        // debugPrint deleted to stop spamming the console
        state = state.copyWith(lux: lux.toDouble());
        
        if (_ref.read(themeViewModelProvider).isAutoThemeEnabled && !state.isProximityNear) {
          // Trigger Dark Mode only if extremely dark
          if (lux < 5) { 
            if (!_ref.read(themeViewModelProvider).isDarkMode) {
              debugPrint("Theme Switch: Dark Mode Detected ($lux Lux)");
              _ref.read(themeViewModelProvider.notifier).setDarkMode(true);
            }
          } 
          // Trigger Light Mode earlier 
          else if (lux >= 20) { 
            if (_ref.read(themeViewModelProvider).isDarkMode) {
              debugPrint("Theme Switch: Light Mode Detected ($lux Lux)");
              _ref.read(themeViewModelProvider.notifier).setDarkMode(false);
            }
          }
        }
      }, onError: (error) => debugPrint("Light Sensor Error: $error"));
    } catch (e) {
      debugPrint("Light Sensor Exception: $e");
    }

    // 2. Proximity Sensor Logic (Hand over camera)
    try {
      _proximitySubscription = ProximitySensor.events.listen((int event) {
        final isNear = event > 0;
        debugPrint("Proximity Sensor Update: ${isNear ? "NEAR" : "FAR"}");
        state = state.copyWith(isProximityNear: isNear);

        if (_ref.read(themeViewModelProvider).isAutoThemeEnabled) {
          if (isNear) {
            _ref.read(themeViewModelProvider.notifier).setDarkMode(true);
          } else {
            // When cleared, use the new easier "Bright" threshold
            if (state.lux >= 20) {
              _ref.read(themeViewModelProvider.notifier).setDarkMode(false);
            } else if (state.lux < 5) {
              _ref.read(themeViewModelProvider.notifier).setDarkMode(true);
            }
          }
        }
      });
    } catch (e) {
      debugPrint("Proximity Sensor Exception: $e");
    }

    // 3. Accelerometer Logic
    DateTime lastUpdate = DateTime.now();
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      final now = DateTime.now();

      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        if (!state.isShakeDetected) {
          state = state.copyWith(isShakeDetected: true, x: event.x, y: event.y, z: event.z);
          Future.delayed(const Duration(seconds: 1), () {
            state = state.copyWith(isShakeDetected: false);
          });
          return;
        }
      }

      if (now.difference(lastUpdate).inMilliseconds > 100) {
        state = state.copyWith(x: event.x, y: event.y, z: event.z);
        lastUpdate = now;
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopSensors();
    super.dispose();
  }
}

final sensorViewModelProvider = StateNotifierProvider<SensorViewModel, SensorState>((ref) {
  return SensorViewModel(ref);
});
