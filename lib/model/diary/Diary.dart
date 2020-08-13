//材料欄
class Diary{
  int id;
  String body;
  String date;
  int category;
  int thumbnail;

  Diary({this.id, this.body, this.date, this.category, this.thumbnail});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'body':body,
      'date':date,
      'category':category,
      'thumbnail':thumbnail,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Diary.fromMap(Map<String,dynamic> map){
    id = map['id'];
    body = map['body'];
    date = map['date'];
    category = map['category'];
    thumbnail = map['thumbnail'];
  }
}