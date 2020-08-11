//tag
class TagGroupRecipiId{
  int recipi_id;        //外部key
  TagGroupRecipiId({this.recipi_id});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  TagGroupRecipiId.fromMap(Map<String,dynamic> map){
    recipi_id = map['recipi_id'];
  }
}