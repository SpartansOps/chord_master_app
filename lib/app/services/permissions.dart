import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<PermissionStatus> requestPermissionStorage();
  Future<PermissionStatus> get permissionStorageStatus;

  Future<PermissionStatus> requestPermissionPhotos();
  Future<PermissionStatus> get permissionStoragePhotos;

  Future<PermissionStatus> requestPermissionAudio();
  Future<PermissionStatus> get permissionStorageAudio;

  Future<PermissionStatus> requestPermissionVideos();
  Future<PermissionStatus> get permissionStorageVideos;
}

class PermissionServiceImpl extends PermissionService {
  @override
  Future<PermissionStatus> requestPermissionStorage() async {
    await Permission.storage.request();
    if (await permissionStorageStatus == PermissionStatus.denied) {
      await Permission.storage.request();
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
  Future<PermissionStatus> requestPermissionAudio() {
    // TODO: implement requestPermissionAudio
    throw UnimplementedError();
  }

  @override
  Future<PermissionStatus> requestPermissionPhotos() {
    // TODO: implement requestPermissionPhotos
    throw UnimplementedError();
  }

  @override
  Future<PermissionStatus> requestPermissionVideos() {
    // TODO: implement requestPermissionVideos
    throw UnimplementedError();
  }

  @override
  Future<PermissionStatus> get permissionStorageStatus async =>
      await Permission.storage.status;

  @override
  Future<PermissionStatus> get permissionStorageAudio async =>
      await Permission.audio.status;

  @override
  Future<PermissionStatus> get permissionStoragePhotos async =>
      await Permission.photos.status;

  @override
  Future<PermissionStatus> get permissionStorageVideos async =>
      await Permission.videos.status;
}
