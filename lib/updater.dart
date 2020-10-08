import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/Version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import 'package:recipe_app/main.dart';
import 'package:recipe_app/services/http/versionCheckService.dart';
import 'package:recipe_app/services/http/versionCheck.dart';
import 'package:recipe_app/model/VersionCheck.dart';
import 'package:recipe_app/model/Format.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';

/// 強制アップデートダイアログを出す為のStatefulWidget
class updater extends StatefulWidget {
  updater({Key key}) : super(key: key);

  @override
  State<updater> createState() => _updaterState();
}

class _updaterState extends State<updater> {

  DBHelper dbHelper = DBHelper();
  versionCheck _versionCheck = versionCheck();

  @override
  void initState() {
    //mainで登録したオブジェクへアクセス
    final checker = locator<versionCheckService>();
    checker.getCurrentVersion().then((currentVersion) =>
        Provider.of<Display>(context, listen: false).setAppCurrentVersion(currentVersion));
    //appバージョンチェック関数の呼び出し
    checker.versionCheck().then((needUpdate) => _showUpdateDialog(needUpdate));
    //appバージョン以外のバージョンチェックの呼び出し
    this.check();
    super.initState();
  }

  //appバージョン以外のバージョンチェック
  void check() async {
//    print('①11111');
    int datetime = 0;

//    print('チェック時間milliseconds:${DateTime.now().millisecondsSinceEpoch}');
//    print('チェック時間:${DateTime.now()}');
    //アプリ初期起動フラグの取得
    var isInitBoot = Provider.of<Display>(context, listen: false).getIsInitBoot();

    //アプリ初期起動の場合
    if(isInitBoot){
      print('++++++++++++++++++++++++++++++++++');
      print('+++++++++++アプリ初期起動+++++++++++');
      print('++++++++++++++++++++++++++++++++++');
      //ローカルのバージョン情報データの存在有無チェック
      int vLength = await dbHelper.getVersionLength();
      //ローカルにデータが存在しない場合
      if(vLength == 0){
        print('++++++バージョン情報データが存在しない場合++++++');
        //firebase上から取得したデータをinsertする

        //バージョン情報
        Version version = await _versionCheck.getHttpVersion();
        await dbHelper.insertVersion(version);

        //Seasoning情報
        List<Format> seasonings = await _versionCheck.getHttpSeasoning();
        await dbHelper.insertSeasoning(seasonings);
//        seasonings.clear();
//        seasonings = await dbHelper.getSeasoning();
//        Provider.of<Display>(context, listen: false).setSeasonings(seasonings);

        //Quantityunit情報
        List<Format> quantityunits = await _versionCheck.getHttpQuantityunit();
        await dbHelper.insertQuantityunit(quantityunits);
//        quantityunits.clear();
//        quantityunits = await dbHelper.getQuantityUnit();
//        Provider.of<Display>(context, listen: false).setQuantityunits(quantityunits);

        //バージョン情報を取得した時間を取得
        datetime = DateTime.now().millisecondsSinceEpoch;

      } else {
        //ローカルにデータが存在した場合
        print('++++++バージョン情報データが存在する場合++++++');
        //バージョンチェック処理を実行する
        VersionCheck check = await _versionCheck.check();

//        List<Format> seasonings = [];
//        seasonings = await dbHelper.getSeasoning();
//        print('#############seasonings:$seasonings');
//        Provider.of<Display>(context, listen: false).setSeasonings(seasonings);

//        List<Format> quantityunits = await dbHelper.getQuantityUnit();
//        Provider.of<Display>(context, listen: false).setQuantityunits(quantityunits);

        datetime = check.time;
      }
      //アプリ初期起動フラグにfalseをセット
      Provider.of<Display>(context, listen: false).setIsInitBoot(false);
      //バージョンチェック処理が実行された日時をセット
      Provider.of<Display>(context, listen: false).setVersionCheckTime(datetime);

    } else {
      //アプリ初期起動以外の場合
      print('++++++++++++++++++++++++++++++++++');
      print('+++++++++++アプリ初期起動以外+++++++');
      print('++++++++++++++++++++++++++++++++++');
      //バージョンチェック処理が実行された日時を取得
      datetime = Provider.of<Display>(context, listen: false).getVersionCheckTime();
      //現在時刻を取得
      var nowTime = DateTime.now().millisecondsSinceEpoch;
      //現在時刻とバージョン情報をもとに経過時間を取得
      var timeDifference = nowTime - datetime;
      print('###差分:${timeDifference}');
      //経過時間が3600000ミリ秒(1時間)以上の場合
//      if(timeDifference >= 3600000){
      //経過時間が300000ミリ秒(5分)以上の場合
      if(timeDifference >= 300000){
        print('バージョンチェック実施');
        //バージョンチェック処理を実行する
//        datetime = await _versionCheck.check();
        VersionCheck check = await _versionCheck.check();
        //seasoningバージョンチェックにて更新が行われた場合
//        if(check.s){
//          List<Format> seasonings = await dbHelper.getSeasoning();
//          Provider.of<Display>(context, listen: false).setSeasonings(seasonings);
//        }
//        //quantityUnitバージョンチェックにて更新が行われた場合
//        if(check.q){
//          List<Format> quantityunits = await dbHelper.getQuantityUnit();
//          Provider.of<Display>(context, listen: false).setQuantityunits(quantityunits);
//        }
//        if(!check.s && !check.q){
//          print('変更なし');
//        }
        datetime = check.time;
        //バージョンチェック処理が実行された日時をセット
        Provider.of<Display>(context, listen: false).setVersionCheckTime(datetime);
      }else{
        //なにもしない
        print('バージョンチェック処理しない');
      }
    }
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
            ? CupertinoAlertDialog(
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
            : AlertDialog(
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