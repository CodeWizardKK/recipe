
class Format{
  int id;
  String name;

  Format({this.id, this.name});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'id':id,
      'name':name,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Format.fromMap(Map<String,dynamic> map){
    id = map['id'];
    name = map['name'];
  }

}