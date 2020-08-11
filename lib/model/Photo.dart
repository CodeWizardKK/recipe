//class Photo{
//  int id;
//  String photoName;
//
//  Photo({this.id,this.photoName});
//
//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'photoName':photoName,
//    };
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  Photo.fromMap(Map<String,dynamic> map){
//    id = map['id'];
//    photoName = map['photoName'];
//  }
//}
