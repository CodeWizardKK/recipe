//材料欄
class Recipi{
  int id;
  String thumbnail;

  Recipi({this.id, this.thumbnail});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'id':id,
      'thumbnail':thumbnail,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Recipi.fromMap(Map<String,dynamic> map){
    id = map['id'];
    thumbnail = map['thumbnail'];
  }
}