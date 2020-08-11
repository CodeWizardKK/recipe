//tag
class Tag{
  int id;               //タグID
  int recipi_id;        //外部key
  int mst_tag_id;    //タグマスタID
  String name;       //タグ名
  Tag({this.id, this.recipi_id,this.mst_tag_id});

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'recipi_id':recipi_id,
      'mst_tag_id':mst_tag_id,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  Tag.fromMap(Map<String,dynamic> map){
    id = map['id'];
    recipi_id = map['recipi_id'];
    mst_tag_id = map['mst_tag_id'];
    name = map['name'];
  }
}