import 'dart:convert';
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

}
