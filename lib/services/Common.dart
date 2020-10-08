import 'dart:io';

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class Common {

  //圧縮して端末の拡張ディスクに保存したimagePathを呼び出す
  String replaceImage(String imagePath){
    String newImagePath = imagePath;
    newImagePath = newImagePath.replaceAll('.JPG','_thumb.JPG');
    newImagePath = newImagePath.replaceAll('.JPEG','_thumb.JPEG');
    newImagePath = newImagePath.replaceAll('.jpg','_thumb.jpg');
    newImagePath = newImagePath.replaceAll('.jpeg','_thumb.jpeg');
    newImagePath = newImagePath.replaceAll('.PNG','_thumb.PNG');
    newImagePath = newImagePath.replaceAll('.png','_thumb.png');
    print('newImagePath:${newImagePath}');
    return newImagePath;
  }

  //圧縮して端末の拡張ディスク(指定)に保存したimagePathを呼び出す
  String replaceImageDiary(String imagePath){
    String newImagePath = imagePath;
    newImagePath = newImagePath.replaceAll('/data/user/0/com.example.recipe_app/cache/file_picker','/storage/emulated/0/Android/data/com.example.recipe_app/files/Pictures');
    newImagePath = newImagePath.replaceAll('.JPG','_thumb.JPG');
    newImagePath = newImagePath.replaceAll('.JPEG','_thumb.JPEG');
    newImagePath = newImagePath.replaceAll('.jpg','_thumb.jpg');
    newImagePath = newImagePath.replaceAll('.jpeg','_thumb.jpeg');
    newImagePath = newImagePath.replaceAll('.PNG','_thumb.PNG');
    newImagePath = newImagePath.replaceAll('.png','_thumb.png');
    print('newImagePath:${newImagePath}');
    return newImagePath;
  }

  //スクリーンショット(詳細画面)のシェア機能
  Future<void> takeWidgetScreenShot(previewContainer) async {
    //Widgetの位置、高さを取得する
    RenderRepaintBoundary boundary = previewContainer.currentContext.findRenderObject();
    //それを元に画像を生成
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    //path,file名を設定
    final directory = (await getApplicationDocumentsDirectory()).path;
    final filename = DateTime.now().millisecondsSinceEpoch;
    //byte型に変換
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
//    print(pngBytes);
    //ファイルの書き込み
    File imgFile = File('$directory/$filename.png');
    await imgFile.writeAsBytes(pngBytes);
//    print('書き込み先：${imgFile.path}');
    //シェア
    await Share.shareFiles([imgFile.path]);
  }

  //スクリーンショット(画像のみ)のシェア機能
  Future<void> takeImageScreenShot(List<String> photos) async {
    //シェア
    await Share.shareFiles(photos);
  }

  //スクリーンショット(URL)のシェア機能
  Future<void> takeURLScreenShot() async {
    String text = 'おすすめレシピアプリ！https://aaaaaa.aaaff/aa/aaaaa';
    //シェア
    await Share.share(text);
  }

  //ネットワーク接続の有無をチェック
  Future<bool> checkNetworkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      //ネットワーク接続有の場合
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      } else {
        return false;
      }
      //ネットワーク接続無の場合
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

}
