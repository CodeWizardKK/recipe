import 'package:recipe_app/model/diary/DisplayDiary.dart';


//ごはん日記　Widget展開用
class DisplayDiaryGroupDate{
  int id;
  String month;
  List<DisplayDiary> displayDiarys = List<DisplayDiary>();

  DisplayDiaryGroupDate({this.id, this.month, this.displayDiarys});

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