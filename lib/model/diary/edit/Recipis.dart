//import 'package:recipe_app/model/diary/edit/Recipi.dart';
//
////料理
//class Recipis{
//  int diary_id;
//  int recipi_id;
//  List<DRecipi> recipis;
//
//  Recipis({this.diary_id, this.recipi_id});
//
//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'diary_id':diary_id,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  Recipis.fromMap(Map<String,dynamic> map){
//    diary_id = map['diary_id'];
//  }
//}