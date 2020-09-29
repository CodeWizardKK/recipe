import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:recipe_app/main.dart';
import 'package:recipe_app/services/http/versionCheckService.dart';

/// 強制アップデートダイアログを出す為のダミーに近いStatefulWidget
class updater extends StatefulWidget {
  updater({Key key}) : super(key: key);

  @override
  State<updater> createState() => _updaterState();
}

class _updaterState extends State<updater> {
  @override
  void initState() {
    //appバージョンチェックの呼び出し
    final checker = locator<versionCheckService>();
    checker.versionCheck().then((needUpdate) => _showUpdateDialog(needUpdate));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
    );
  }

  // FIXME ストアにアプリを登録したらurlが入れられる
  static const APP_STORE_URL =
      'https://apps.apple.com/jp/app/id[アプリのApple ID]?mt=8';

  // FIXME ストアにアプリを登録したらurlが入れられる
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=[アプリのパッケージ名]';

  /// 更新版案内ダイアログを表示
  void _showUpdateDialog(bool needUpdate) {
    if (!needUpdate) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final title = "バージョン更新のお知らせ";
        final message = "新しいバージョンのアプリが利用可能です。ストアより更新版を入手して、ご利用下さい。";
        final btnLabel = "今すぐ更新";
        return Platform.isIOS
            ? new CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(
                btnLabel,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _launchURL(APP_STORE_URL),
            ),
          ],
        )
            : new AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(
                btnLabel,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => _launchURL(PLAY_STORE_URL),
            ),
          ],
        );
      },
    );
  }

  /// 指定のURLを起動する. App Store or Play Storeのリンク
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}