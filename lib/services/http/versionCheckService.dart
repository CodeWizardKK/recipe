import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';

class versionCheckService {
//  static const String DEV_VERSION_CONFIG = "dev_app_version";
  static const String APP_VERSION = "app_version";

  /// バージョンチェック関数
  Future<bool> versionCheck() async {
    // 現在のバージョン情報を取得
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion = double.parse(info.buildNumber);
//    print('appName:${info.appName}');
//    print('packageName:${info.packageName}');
//    print('version:${info.version}');
//    print('buildNumber:${info.buildNumber}');
    print('[APP]currentVersion:${currentVersion}');

//    // releaseビルドかどうかで取得するconfig名を変更
//    final configName = bool.fromEnvironment('dart.vm.product')
//        ? APP_VERSION
//        : DEV_VERSION_CONFIG;

    //最新のバージョン情報を取得
    // remote config
    final RemoteConfig remoteConfig = await RemoteConfig.instance;

    try {
      // 常にサーバーから取得するようにするため期限を最小限にセット
      await remoteConfig.fetch(expiration: const Duration(seconds: 0));
      await remoteConfig.activateFetched();
      String newVersionStr = remoteConfig.getString(APP_VERSION);
//      print('newVersionSTR:${newVersionStr}');
      double newVersion = double.parse(newVersionStr);
      print('[APP]newVersion:${newVersion}');
      if (newVersion > currentVersion) {
        return true;
      }
    } on FetchThrottledException catch (exception) {
      // Fetch throttled.
      print(exception);
    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return false;
  }
  //現在のバージョン情報を取得
  Future<double> getCurrentVersion() async {
    // 現在のバージョン情報を取得
    final PackageInfo info = await PackageInfo.fromPlatform();
    double currentVersion = double.parse(info.buildNumber);
    return currentVersion;
  }
}