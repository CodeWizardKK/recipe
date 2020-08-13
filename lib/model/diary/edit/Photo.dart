//材料欄
class Photo{
  int no;         //写真の表示順
  String path;    //写真のパス

  Photo({this.no, this.path});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'no':no,
      'path':path,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Photo.fromMap(Map<String,dynamic> map){
    no = map['no'];
    path = map['path'];
  }
}