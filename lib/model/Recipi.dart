import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/Myrecipi.dart';

class Recipi{
  Myrecipi recipi;                  //レシピ
  List<Tag> tags;                   //タグリスト
  List<Ingredient> ingredients;     //材料リスト
  List<Photo> photos;               //写真リスト
  List<HowTo> howto;                //作り方リスト

  Recipi(
      {
        this.recipi,
        this.tags,
        this.photos,
        this.ingredients,
        this.howto
      }
  );

//  //DBへ送る形式へ変換
//  Map<String,dynamic> toMap(){
//    var map = <String,dynamic>{
//      'type':type,
//      'thumbnail':thumbnail,
//      'title':title,
//      'description':description,
//      'quantity':quantity,
//      'unit':unit,
//      'time':time,
//      'photos':photos,
//      'ingredients':ingredients,
//      'howto':howto,
//    };
//    var map = new Map<String, dynamic>();
//    map['type'] = type;
//    map['thumbnail'] = thumbnail;
//    map['title'] = title;
//    map['description'] = description;
//    map['quantity'] = quantity;
//    map['unit'] = unit;
//    map['time'] = time;
////    if(photos != null){
//    map['photos'] = photos.map((photo) => photo.toMap()).toList();
////    }
////    if(photos != null){
//    map['ingredients'] = ingredients.map((ingredient) => ingredient.toMap()).toList();
////    }
////    if(photos != null){
//    map['howto'] = howto.map((h) => h.toMap()).toList();
////    }
//
//    return map;
//  }
//
//  //Widgetへ展開する形式へ変換
//  Recipi.fromMap(Map<String,dynamic> map){
//    id = map['id'];
//    type = map['type'];
//    thumbnail = map['thumbnail'];
//    title = map['title'];
//    description = map['description'];
//    quantity = map['quantity'];
//    unit = map['unit'];
//    time = map['time'];
////    photos = map['photos'];
////    ingredients = map['ingredients'];
////    howto = map['howto'];
//
//    if(map['photos'] != null){
//      photos = new List<Photo>();
//      print('fromMap::::${map['photos'].length}');
//      for(var i = 0; i < map['photos'].length; i++){
//        photos.add(new Photo.fromMap(map['photos'][i]));
//      }
//    }
//    if(map['ingredients'] != null){
//      ingredients = new List<Ingredient>();
//      for(var i = 0; i < map['ingredients'].length; i++){
//        ingredients.add(new Ingredient.fromMap(map['ingredients'][i]));
//      }
//    }
//    if(map['howto'] != null){
//      howto = new List<HowTo>();
//      for(var i = 0; i < map['howto'].length; i++){
//        howto.add(new HowTo.fromMap(map['howto'][i]));
//      }
//    }
//    print('id:${id},type:${type},thumbnail:${thumbnail},title:${title},description:${description},quantity:${quantity},unit:${unit},time:${time},photos:${photos},ingredients:${ingredients},howto:${howto}');
//  }

}