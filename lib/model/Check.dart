//材料欄
class Check{
  int id;         //フォルダID
  String name;    //フォルダ名
  bool isCheck;    //true:check状態

  Check({this.id, this.name,this.isCheck});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'name':name,
    };
    return map;
  }


  //Widgetへ展開する形式へ変換
  Check.fromMap(Map<String,dynamic> map){
    id = map['id'];
    name = map['name'];
  }
}