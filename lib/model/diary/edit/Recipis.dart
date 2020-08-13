//材料欄
class Recipis{
  int id;
  int diary_id;
  int no;
  int recipi_id;

  Recipis({this.id, this.diary_id, this.no, this.recipi_id});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'diary_id':diary_id,
      'no':no,
      'recipi_id':recipi_id,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Recipis.fromMap(Map<String,dynamic> map){
    id = map['id'];
    diary_id = map['diary_id'];
    no = map['no'];
    recipi_id = map['recipi_id'];
  }
}