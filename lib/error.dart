import 'package:recipe_app/main.dart';
import 'package:recipe_app/services/http/errorService.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class error extends StatefulWidget {
  bool isError;

  error({Key key, @required this.isError}) : super(key: key);

  @override
  State<error> createState() => _errorState();
}

class _errorState extends State<error> {

  @override
  void initState() {
    //mainで登録したオブジェクへアクセス
    final checker = locator<errorService>();
    //appバージョンチェック関数の呼び出し
    checker.getError(widget.isError).then((isError) => _showErrorDialog(isError));
//    _showUpdateDialog();
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 1,
    );
  }

  void _showErrorDialog(bool isError){
    if (!isError) return;

    AwesomeDialog(
      context: context,
//            width: 280,
      dialogType: DialogType.ERROR,
      headerAnimationLoop: false,
      animType: AnimType.TOPSLIDE,
      title: 'エラーが発生しました',
      desc: 'お手数ですが、再度お試しください',
      btnOkOnPress: () {},
//            btnOkColor:
    )..show();
  }

  /// 更新版案内ダイアログを表示
  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final title = "バージョン更新のお知らせ";
        final message = "新しいバージョンのアプリが利用可能です。ストアより更新版を入手して、ご利用下さい。";
        final btnLabel = "今すぐ更新";
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text(
                btnLabel,
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () => {},
            ),
          ],
        );
      },
    );
  }
}