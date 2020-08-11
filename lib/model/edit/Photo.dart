//材料欄
class Photo{
  int id;
  int recipi_id;        //外部key
  int no;         //写真の表示順
  String path;    //写真のパス

  Photo({this.id, this.recipi_id, this.no, this.path});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
      'no':no,
      'path':path,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Photo.fromMap(Map<String,dynamic> map){
    id = map['id'];
    recipi_id = map['recipi_id'];
    no = map['no'];
    path = map['path'];
  }
}