import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';


//表示ステータスの状態クラス
class Detail with ChangeNotifier{

  Myrecipi recipi = Myrecipi();                       //選択したレシピ
  List<Ingredient> ingredients =  List<Ingredient>(); //レシピIDに紐づく材料リスト(詳細表示用)※変更は加えない
//  String ingredientsTX ='';                         //レシピIDに紐づく材料リストを文字列で格納
  List<HowTo> howTos =  List<HowTo>();                //レシピIDに紐づく作り方リスト(詳細表示用)※変更は加えない
  List<Photo> photos = List<Photo>();                 //レシピIDに紐づく写真リスト(詳細表示用)※変更は加えない

  void reset(){
//    this.recipi = Myrecipi();
    this.ingredients.clear();
    this.howTos.clear();
    this.photos.clear();
  }

//  void setIngredientTX(String ingredientsTX){
//    this.ingredientsTX = ingredientsTX;
//    notifyListeners();
//  }

//  String getIngredientTX(){
//    return this.ingredientsTX;
//  }


  void setIngredients(List<Ingredient> ingredients){
    this.ingredients.clear();
//    this.ingredients = [];
    for(var i = 0; i< ingredients.length;i++){
      this.ingredients.add(ingredients[i]);
    }
    print('セットしたよingredientlength:${this.ingredients.length}');
    notifyListeners();
  }

  List<Ingredient> getIngredients(){
    return this.ingredients;
  }

  void setHowTos(List<HowTo> howtos){
    this.howTos.clear();
//    this.howTos = [];
    for(var i = 0; i< howtos.length;i++){
      this.howTos.add(howtos[i]);
    }
    print('セットしたよhowToslength:${this.howTos.length}');
    notifyListeners();
  }

  List<HowTo> getHowTos(){
    return this.howTos;
  }

  void setPhotos(List<Photo> photos){
    this.photos.clear();
//    this.photos = [];
    for(var i = 0; i< photos.length;i++){
      this.photos.add(photos[i]);
    }
    print('photoslength:${this.photos.length}');
    notifyListeners();
  }

  List<Photo> getPhotos(){
    return this.photos;
  }

  Myrecipi getRecipi(){
//    return this.recipis[index];
    return this.recipi;
  }

  void setRecipi(recipi){
    this.recipi.id = recipi.id;
    this.recipi.type = recipi.type;
    this.recipi.thumbnail = recipi.thumbnail;
    this.recipi.title = recipi.title;
    this.recipi.description = recipi.description;
    this.recipi.quantity = recipi.quantity;
    this.recipi.unit = recipi.unit;
    this.recipi.time = recipi.time;
    this.recipi.folder_id = recipi.folder_id;
    print('------------------------');
    print('ID:${this.recipi.id}');
    print('種別:${this.recipi.type}');
    print('サムネイルパス:${this.recipi.thumbnail}');
    print('タイトル:${this.recipi.title}');
    print('説明:${this.recipi.description}');
    print('分量${this.recipi.quantity}');
    print('単位:${this.recipi.unit}');
    print('調理時間:${this.recipi.time}');
    print('フォルダーID:${this.recipi.folder_id}');
    print('------------------------');
    notifyListeners();
  }

}