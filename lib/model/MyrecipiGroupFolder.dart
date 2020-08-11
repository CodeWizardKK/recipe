import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';

class MyrecipiGroupFolder{
  int folder_id;          //フォルダID
  String name;            //フォルダ名
  int count;              //フォルダID別件数

  MyrecipiGroupFolder(
      {
        this.folder_id,
        this.name,
        this.count,
      }
  );

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'folder_id':folder_id,
      'name':name,
      'count':count,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  MyrecipiGroupFolder.fromMap(Map<String,dynamic> map){
    folder_id = map['folder_id'];
    name = map['name'];
    count = map['COUNT(recipi.folder_id)'];
  }

}