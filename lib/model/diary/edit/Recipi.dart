
class DRecipi{
  int id;
  String image;
  int diary_id;
  int recipi_id;

  DRecipi({this.id, this.image, this.diary_id, this.recipi_id});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
//      'thumbnail':thumbnail,
      'diary_id':diary_id,
      'recipi_id':recipi_id,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  DRecipi.fromMap(Map<String,dynamic> map){
    id = map['id'];
    diary_id = map['diary_id'];
    recipi_id = map['recipi_id'];
    image = map['thumbnail'];
  }
}