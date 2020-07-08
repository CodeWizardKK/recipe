class Myrecipi{
  int id;
  String topImage;

  Myrecipi({this.id,this.topImage});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'topImage':topImage,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Myrecipi.fromMap(Map<String,dynamic> map){
    id = map['id'];
    topImage = map['topImage'];
  }

}