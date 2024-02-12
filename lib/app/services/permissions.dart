import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<PermissionStatus> requestPermissionStorage();
  Future<PermissionStatus> get permissionStorageStatus;
}

class PermissionServiceImpl extends PermissionService {
  @override
  Future<PermissionStatus> requestPermissionStorage() async {
    await Permission.manageExternalStorage.request();
    if (await permissionStorageStatus == PermissionStatus.denied) {
      await Permission.manageExternalStorage.request();
      if (await permissionStorageStatus == PermissionStatus.granted) {
        return await permissionStorageStatus;
      }
      return await permissionStorageStatus;
    } else if (await permissionStorageStatus ==
        PermissionStatus.permanentlyDenied) {
      await openAppSettings();
    }
    return await permissionStorageStatus;
  }

  @override
  Future<PermissionStatus> get permissionStorageStatus async =>
      await Permission.manageExternalStorage.status;
}
