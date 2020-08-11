//材料欄
class HowTo{
  int id;
  int recipi_id;  //外部key
  int no;         //作り方の表示順
  String memo;    //作り方
  String photo;   //写真のパス

  HowTo({this.id, this.recipi_id, this.no, this.memo, this.photo});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
      'no':no,
      'memo':memo,
      'photo':photo,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  HowTo.fromMap(Map<String,dynamic> map){
    id = map['id'];
    recipi_id = map['recipi_id'];
    no = map['no'];
    memo = map['memo'];
    photo = map['photo'];
  }
}