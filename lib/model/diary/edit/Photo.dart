//材料欄
class DPhoto{
  int id;
  int diary_id;   //外部key
  int no;         //写真の表示順
  String path;    //写真のパス

  DPhoto({this.id, this.diary_id, this.no, this.path});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'diary_id':diary_id,
      'no':no,
      'path':path,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  DPhoto.fromMap(Map<String,dynamic> map){
    id = map['id'];
    diary_id = map['diary_id'];
    no = map['no'];
    path = map['path'];
  }
}