import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:light_sensor/light_sensor.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';

class SensorState {
  final double lux;
  final bool isShakeDetected;
  final double x;
  final double y;
  final double z;

  SensorState({
    this.lux = 0,
    this.isShakeDetected = false,
    this.x = 0,
    this.y = 0,
    this.z = 0,
  });

  SensorState copyWith({
    double? lux,
    bool? isShakeDetected,
    double? x,
    double? y,
    double? z,
  }) {
    return SensorState(
      lux: lux ?? this.lux,
      isShakeDetected: isShakeDetected ?? this.isShakeDetected,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }
}

class SensorViewModel extends StateNotifier<SensorState> {
  final Ref _ref;
  StreamSubscription<int>? _lightSubscription;
  StreamSubscription<AccelerometerEvent>? _accelSubscription;

  SensorViewModel(this._ref) : super(SensorState()) {
    _initSensors();
  }

  void _initSensors() {
    // 1. Light Sensor Logic (from light_sensor_screen.dart)
    _lightSubscription = LightSensor.luxStream().listen((int lux) {
      state = state.copyWith(lux: lux.toDouble());
      
      // Auto-theme logic: If lux is low (< 10), switch to dark mode
      // This makes the app feel "smart"
      if (_ref.read(themeViewModelProvider).isAutoThemeEnabled) {
        if (lux < 10) {
          _ref.read(themeViewModelProvider.notifier).setDarkMode(true);
        } else if (lux > 30) {
          _ref.read(themeViewModelProvider.notifier).setDarkMode(false);
        }
      }
    });

    // 2. Accelerometer Logic with throttling
    DateTime lastUpdate = DateTime.now();
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      final now = DateTime.now();

      // Shake detection (Keep this instant for responsiveness)
      if (event.x.abs() > 15 || event.y.abs() > 15 || event.z.abs() > 15) {
        if (!state.isShakeDetected) {
          state = state.copyWith(isShakeDetected: true, x: event.x, y: event.y, z: event.z);
          Future.delayed(const Duration(seconds: 1), () {
            state = state.copyWith(isShakeDetected: false);
          });
          return;
        }
      }

      // Throttle coordinate updates to ~10Hz to save CPU
      if (now.difference(lastUpdate).inMilliseconds > 100) {
        state = state.copyWith(x: event.x, y: event.y, z: event.z);
        lastUpdate = now;
      }
    });
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }
}

final sensorViewModelProvider = StateNotifierProvider<SensorViewModel, SensorState>((ref) {
  return SensorViewModel(ref);
});
