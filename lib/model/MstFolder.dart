//材料欄
class MstFolder{
  int id;         //フォルダID
  String name;    //フォルダ名

  MstFolder({this.id, this.name});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'name':name,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  MstFolder.fromMap(Map<String,dynamic> map){
    id = map['id'];
    name = map['name'];
  }
}