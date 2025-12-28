import 'package:path_provider/path_provider.dart';

abstract class PathProviderService {
  Future<String> get getDocumentsAppPath;
}

class PathProviderServiceImpl extends PathProviderService {
  @override
  Future<String> get getDocumentsAppPath =>
      getApplicationDocumentsDirectory().then((value) => value.path);
}
