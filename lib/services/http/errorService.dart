
class errorService {
//  static const String DEV_VERSION_CONFIG = "dev_app_version";
  static const String APP_VERSION = "app_version";

  /// バージョンチェック関数
  Future<bool> getError(bool isError) async {
    return isError ? true : false;
  }
}