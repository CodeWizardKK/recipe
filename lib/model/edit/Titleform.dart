//タイトル欄
class TitleForm{
  String  title;       //タイトル
  String  description; //説明/メモ
  int  quantity;       //分量
  int     unit;        //単位（1：人分、2：個分、3：枚分、4：杯分、5：皿分）
  int     time;        //調理時間

  TitleForm(
      {
        this.title,
        this.description,
        this.quantity,
        this.unit,this.time
      }
      );

  //DBへ送る形式へ変換
  Map<String,dynamic> toMap(){
    var map = <String,dynamic>{
      'title':title,
      'description':description,
      'quantity':quantity,
      'unit':unit,
      'time':time,
    };
    return map;
  }

  //Widgetへ展開する形式へ変換
  TitleForm.fromMap(Map<String,dynamic> map){
    title = map['title'];
    description = map['description'];
    quantity = map['quantity'];
    unit = map['unit'];
    time = map['time'];
  }
}
