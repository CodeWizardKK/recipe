//材料欄
class Ingredient{
  int id;
  int recipi_id;  //外部key
  int no;         //材料の表示順
  String name;    //材料名
  String quantity;//分量

  Ingredient({this.id, this.recipi_id, this.no, this.name, this.quantity});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
      'no':no,
      'name':name,
      'quantity':quantity,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Ingredient.fromMap(Map<String,dynamic> map){
    id = map['id'];
    recipi_id = map['recipi_id'];
    no = map['no'];
    name = map['name'];
    quantity = map['quantity'];
  }
}