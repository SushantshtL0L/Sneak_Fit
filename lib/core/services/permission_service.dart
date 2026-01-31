import 'package:permission_handler/permission_handler.dart' as handler;

class PermissionService {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    var status = await handler.Permission.camera.status;
    if (status.isDenied) {
      status = await handler.Permission.camera.request();
    }
    return status.isGranted;
  }

  /// Request microphone (video) permission
  static Future<bool> requestMicrophonePermission() async {
    var status = await handler.Permission.microphone.status;
    if (status.isDenied) {
      status = await handler.Permission.microphone.request();
    }
    return status.isGranted;
  }

  /// Request storage/gallery permission
  static Future<bool> requestStoragePermission() async {
    var status = await handler.Permission.photos.status;
    if (status.isDenied) {
      status = await handler.Permission.photos.request();
    }
    return status.isGranted;
  }

  /// Request multiple permissions for video recording (Camera + Mic)
  static Future<bool> requestCameraAndMicrophone() async {
    Map<handler.Permission, handler.PermissionStatus> statuses = await [
      handler.Permission.camera,
      handler.Permission.microphone,
    ].request();

    return statuses[handler.Permission.camera]!.isGranted &&
        statuses[handler.Permission.microphone]!.isGranted;
  }

  /// Open app settings if permission is permanently denied
  static Future<bool> openSettings() async {
    return await handler.openAppSettings();
  }
}
