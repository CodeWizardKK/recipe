
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';


//表示ステータスの状態クラス
class Edit with ChangeNotifier{

  //diary_list,diary_detail
  DisplayDiary diary = DisplayDiary();                    //選択した日記

  //diary_edit
  TextEditingController body  = TextEditingController();  //本文
  String date = '';                                       //日付(yyyy-MM-dd)
  int category = 1;                                       //分類
  int thumbnail = 1;                                      //サムネイル
  List<DRecipi> recipis = List<DRecipi>();                //料理
  List<DPhoto> photos = List<DPhoto>();                   //写真


  //編集内容をセットして渡す
  Diary getEditForm(){
    Diary diary = Diary(body: this.body.text,date: this.date,category: this.category,thumbnail: this.thumbnail);
    return diary;
  }

  //本文
  TextEditingController getBody(){
    return this.body;
  }

  void setBody(TextEditingController body){
    this.body.text = body.text;
    notifyListeners();
  }

  //日付
  String getDate(){
    return this.date;
  }

  void setDate(String date){
    this.date = date;
    notifyListeners();
  }

  //分類
  int getCategory(){
    return this.category;
  }

  void setCategory(int category){
    this.category = category;
    notifyListeners();
  }

  //サムネイル
  int getThumbnail(){
    return this.thumbnail;
  }

  void setThumbnail(int thumbnail){
    this.thumbnail = thumbnail;
    notifyListeners();
  }

  //料理
  List<DRecipi> getRecipis(){
    return this.recipis;
  }

  void setRecipis(List<DRecipi> recipis){
    this.recipis = recipis;
    notifyListeners();
  }

  //写真
  List<DPhoto> getPhotos(){
    return this.photos;
  }

  void setPhotos(List<DPhoto> photos){
    this.photos = photos;
    notifyListeners();
  }

  //選択したごはん日記
  DisplayDiary getDiary(){
    return this.diary;
  }

  void setDiary(DisplayDiary diary){
    this.diary = diary;
    notifyListeners();
    print('-----------------');
    print('-----------------');
    print('+  選択した日記   +');
    print('-----------------');
    print('-----------------');
    print('id:${diary.id}');
    print('body:${diary.body}');
    print('date:${diary.date}');
    print('category:${diary.category}');
    print('thumbnail:${diary.thumbnail}');
    print('------ phtos ------------------');
    for(var k = 0; k < diary.photos.length; k++){
      print('-- [$k] --');
      print('id:${diary.photos[k].id}');
      print('diary_id:${diary.photos[k].diary_id}');
      print('no:${diary.photos[k].no}');
      print('path:${diary.photos[k].path}');
      print('---------');
    }
    print('------------------------');
    print('------- recipis -----------------');
    for(var k = 0; k < diary.recipis.length; k++){
      print('-- [$k] --');
      print('id:${diary.recipis[k].id}');
      print('diary_id:${diary.recipis[k].diary_id}');
      print('no:${diary.recipis[k].recipi_id}');
      print('---------');
    }
    print('------------------------');
  }

  void reset(){
    this.body.text = '';
    this.category = 1;
//    this.initialDisplay = true;
    this.photos.clear();
    this.recipis.clear();
  }

}