import 'dart:async';
import 'dart:io'; // 追加
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class FileController {

  //現在時刻の取得
  static String timestamp(){
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // ドキュメントのパスを取得
  static Future get localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print('###path:${directory.path}');
    return directory.path;
  }

  // 画像をドキュメントへ保存する。
  // 引数にはカメラ撮影時にreturnされるFileオブジェクトを持たせる。
  static Future saveLocalImage(PickedFile image) async {
    final path = await localPath;
    final imagePath = '$path/${timestamp()}.png';
    File imageFile = File(imagePath);
    // カメラで撮影した画像は撮影時用の一時的フォルダパスに保存されるため、
    // その画像をドキュメントへ保存し直す。
    var savedFile = await imageFile.writeAsBytes(await image.readAsBytes());
    // もしくは
    // var savedFile = await image.copy(imagePath);
    // でもOK

    return savedFile;
  }

  // ドキュメントの画像を取得する。
  static Future loadLocalImage() async {
    final path = await localPath;
    final imagePath = '$path/${timestamp()}.png';
    return File(imagePath);
  }

}
