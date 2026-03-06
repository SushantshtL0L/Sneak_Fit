import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_model/sensor_view_model.dart';
import '../../../../core/theme/theme_provider.dart';

class SensorLabScreen extends ConsumerWidget {
  const SensorLabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorState = ref.watch(sensorViewModelProvider);
    final themeState = ref.watch(themeViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("SneakFit Sensor Lab"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Theme Control Card
            _sensorCard(
              title: "Auto-Theme (Light Sensor)",
              icon: Icons.brightness_auto,
              color: Colors.amber,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text("Enable Smart Theme"),
                    subtitle: const Text("Stays Bright above 20 Lux"),
                    value: themeState.isAutoThemeEnabled,
                    onChanged: (val) => ref.read(themeViewModelProvider.notifier).toggleAutoTheme(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Current Light: ${sensorState.lux.toStringAsFixed(0)} Lux",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        sensorState.isProximityNear ? Icons.front_hand : Icons.visibility,
                        size: 16,
                        color: sensorState.isProximityNear ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        sensorState.isProximityNear ? "HAND DETECTED! (Dark Mode)" : "No Hand Detected",
                        style: TextStyle(
                          color: sensorState.isProximityNear ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (sensorState.lux == 0 && themeState.isAutoThemeEnabled && !sensorState.isProximityNear)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Waiting for light sensor data...",
                        style: TextStyle(color: Colors.orange, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. Shake Control Card
            _sensorCard(
              title: "Shake Detection (Accelerometer)",
              icon: Icons.vibration,
              color: Colors.blue,
              child: Column(
                children: [
                  const Text("Shake your phone high to see feedback"),
                  const SizedBox(height: 15),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: sensorState.isShakeDetected ? Colors.green : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      sensorState.isShakeDetected ? "SHAKE DETECTED! ⚡" : "Waiting for shake...",
                      style: TextStyle(
                        color: sensorState.isShakeDetected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text("X: ${sensorState.x.toStringAsFixed(2)}, Y: ${sensorState.y.toStringAsFixed(2)}, Z: ${sensorState.z.toStringAsFixed(2)}"),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              "Note: Sensors might not work on all emulators. For best results, test on a physical device.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard({required String title, required IconData icon, required Color color, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
          const Divider(height: 30),
          child,
        ],
      ),
    );
  }
}
