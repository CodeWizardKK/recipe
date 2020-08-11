import 'package:recipe_app/model/Tag.dart';
//tag
class Tags{
  int recipi_id;        //外部key
  List<Tag> tags ;       //レシピID別タグリスト
  Tags({this.recipi_id,this.tags});

//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'recipi_id':recipi_id,
//      'mst_tag_id':mst_tag_id,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  Tag.fromMap(Map<String,dynamic> map){
//    id = map['id'];
//    recipi_id = map['recipi_id'];
//    mst_tag_id = map['mst_tag_id'];
//    name = map['name'];
//  }
}