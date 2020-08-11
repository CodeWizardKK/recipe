import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';

class CheckRecipi{
  int id;               //レシピID
  int type;             //レシピ種別（1：写真レシピ、2：Myレシピ）
  String thumbnail;     //サムネイルパス
  String title;         //タイトル
  String description;   //説明/メモ
  int quantity;         //分量
  int unit;             //単位（1：人分、2：個分、3：枚分、4：杯分、5：皿分）
  int time;             //調理時間
  int folder_id;        //フォルダID
  bool isCheck;         //true:check状態

  CheckRecipi(
      {
        this.id,
        this.type,
        this.thumbnail,
        this.title,
        this.description,
        this.quantity,
        this.unit,
        this.time,
        this.folder_id,
        this.isCheck,
      }
  );

//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'type':type,
//      'thumbnail':thumbnail,
//      'title':title,
//      'description':description,
//      'quantity':quantity,
//      'unit':unit,
//      'time':time,
//      'folder_id':folder_id,
//      'folder_id':folder_id,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  CheckRecipi.fromMap(Map<String,dynamic> map){
//    id = map['id'];
//    type = map['type'];
//    thumbnail = map['thumbnail'];
//    title = map['title'];
//    description = map['description'];
//    quantity = map['quantity'];
//    unit = map['unit'];
//    time = map['time'];
//    folder_id = map['folder_id'];
//  }

}