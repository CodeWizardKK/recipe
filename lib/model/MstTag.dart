//材料欄
class MstTag{
  int id;         //フォルダID
  String name;    //フォルダ名

  MstTag({this.id, this.name});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'name':name,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  MstTag.fromMap(Map<String,dynamic> map){
    id = map['id'];
    name = map['name'];
  }
}