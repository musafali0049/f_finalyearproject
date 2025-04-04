// permission_services.dart
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isLimited) {
      final result = await Permission.storage.request();
      return result.isGranted;
    }

    // If permanently denied, open app settings.
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }

    return false;
  }
}
