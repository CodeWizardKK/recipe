//材料欄
class Ocr{
  int id;
  int recipi_id;  //外部key
  String path;    //材料名

  Ocr({this.id, this.recipi_id, this.path});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
      'path':path,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Ocr.fromMap(Map<String,dynamic> map){
    id = map['id'];
    recipi_id = map['recipi_id'];
    path = map['path'];
  }
}