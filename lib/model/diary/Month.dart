class Month{
//  int id;
  String month;


  Month({this.month,});

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
  //Widgetへ展開する形式へ変換
  Month.fromMap(Map<String,dynamic> map){
    month = map['month'];
  }
}