import 'package:recipe_app/model/diary_sv/edit/Photo.dart';

//材料欄
class Photos{
  int id;
  int diary_id;        //外部key
  List<Photo> photos;

  Photos({this.id, this.diary_id, this.photos});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'diary_id':diary_id,
//      'no':no,
//      'path':path,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Photos.fromMap(Map<String,dynamic> map){
    id = map['id'];
    diary_id = map['diary_id'];
//    no = map['no'];
//    path = map['path'];
  }
}