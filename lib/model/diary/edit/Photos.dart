//import 'package:recipe_app/model/diary/edit/Photo.dart';
//
////材料欄
//class DPhotos{
//  int diary_id;        //外部key
//  List<DPhoto> photos;
//
//  DPhotos({this.diary_id, this.photos});
//
//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'diary_id':diary_id,
////      'no':no,
////      'path':path,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  DPhotos.fromMap(Map<String,dynamic> map){
//    diary_id = map['diary_id'];
////    no = map['no'];
////    path = map['path'];
//  }
//}