
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';


//表示ステータスの状態クラス
class Edit with ChangeNotifier{

  Diary diary = Diary();                       //選択した日記
  TextEditingController body  = TextEditingController(); //本文
  DateTime date;                          //日付
  int category = 1;                       //分類
  int thumbnail;                          //サムネイル
  List<Recipi> recipis = List<Recipi>();  //料理
  List<Photo> photos = List<Photo>();     //写真
  bool initialDisplay = true;


  bool getInitialDisplay(){
    return this.initialDisplay;
  }

  void setInitialDisplay(bool initialDisplay){
    this.initialDisplay = initialDisplay;
    notifyListeners();
  }

  TextEditingController getBody(){
    return this.body;
  }

  void setBody(TextEditingController body){
    this.body.text = body.text;
    notifyListeners();
  }

  DateTime getDate(){
    return this.date;
  }

  void setDate(DateTime date){
    this.date = date;
    notifyListeners();
  }

  int getCategory(){
    return this.category;
  }

  void setCategory(int category){
    this.category = category;
    notifyListeners();
  }

  List<Recipi> getRecipi(){
    return this.recipis;
  }

  void setRecipi(List<Recipi> recipis){
    this.recipis = recipis;
    notifyListeners();
  }

  List<Photo> getPhotos(){
    return this.photos;
  }

  void setPhotos(List<Photo> photos){
    this.photos = photos;
    notifyListeners();
  }

//  Diary getDiary(){
//    return this.diary;
//  }
//
//  void setDiary(diary){
//    this.diary = Diary(
//        id: diary.id,
//        body: diary.body,
//        date: diary.date,
//        category: diary.category,
//        thumbnail: diary.thumbnail,
//        diary_recipi: diary.diary_recipi,
//        diary_photo: diary.diary_photo
//    );
//    print('------------------------');
//    print('ID:${this.diary.id}');
//    print('内容:${this.diary.body}');
//    print('日付:${this.diary.date}');
//    print('分類:${this.diary.category}');
//    print('リスト表示で表示する画像NO:${this.diary.thumbnail}');
//    for(var i = 0; i < this.diary.diary_recipi.length; i++){
////      print('レシピID[${i}]:${this.diary.diary_recipi[i].recipi_id}');
//    }
//    for(var i = 0; i < this.diary.diary_photo.length; i++){
//      print('写真[${i}]:${this.diary.diary_photo[i].path}');
//    }
//    notifyListeners();
//  }

  void reset(){
    this.body.text = '';
    this.category = 1;
    this.initialDisplay = true;
    this.photos.clear();
    this.recipis.clear();
  }

}