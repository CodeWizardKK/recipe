import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';


//ごはん日記　Widget展開用
class DisplayDiary{
  int id;
  String body;
  String date;
  int category;
  int thumbnail;
  List<DPhoto> photos = List<DPhoto>();     //写真
  List<DRecipi> recipis = List<DRecipi>();  //料理


  DisplayDiary({this.id, this.body, this.date, this.category, this.thumbnail, this.photos, this.recipis});

//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'body':body,
//      'date':date,
//      'category':category,
//      'thumbnail':thumbnail,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  DisplayDiary.fromMap(Map<String,dynamic> map){
//    id = map['id'];
//    body = map['body'];
//    date = map['date'];
//    category = map['category'];
//    thumbnail = map['thumbnail'];
//  }
}