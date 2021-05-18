//材料欄
class BlockLine{
  int id;
  double boundingBoxLEFT;
  double boundingBoxTOP;
  double boundingBoxRIGHT;
  double boundingBoxBOTTOM;
  String text;         //材料の表示順

  BlockLine({this.id, this.boundingBoxLEFT, this.boundingBoxTOP, this.boundingBoxRIGHT, this.boundingBoxBOTTOM, this.text});

  // //DBへ送る形式へ変換
  // Map<String,dynamic> toMap(){
  //   var map = <String,dynamic>{
  //     'no':no,
  //     'name':name,
  //   };
  //   return map;
  // }

  // //Widgetへ展開する形式へ変換
  // IngredientOCR.fromMap(Map<String,dynamic> map){
  //   id = map['id'];
  //   no = map['no'];
  //   name = map['name'];
  // }
}