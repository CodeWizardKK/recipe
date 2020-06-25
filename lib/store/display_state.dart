import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//表示ステータスの状態クラス
class Display with ChangeNotifier{
  var state = 0;        // 0 :一覧 1:詳細 2:編集 9:エラー
  var id = -1;          // -1:新規 1以上:更新
  var isCamera = false; // true:カメラ起動状態 //false:カメラ未起動状態
  var images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];
  var selectImage = { //編集画面にてクリックした画像情報を格納
    'index':-1,
    'item':{},
    'tap':false,
  };

  var selectItem = { //リストから選択されたレコードを格納
    'id':-1,
    'email':'',
    'first_name':'',
    'last_name':-1,
    'avatar': '',
  };


  void setSelectItem(selectedItem){
//    print('③取得したitem:${selectedItem}');
    this.selectItem['id'] = selectedItem['id'];
    this.selectItem['email'] = selectedItem['email'];
    this.selectItem['first_name'] = selectedItem['first_name'];
    this.selectItem['last_name'] = selectedItem['last_name'];
    this.selectItem['avatar'] = selectedItem['avatar'];
//    print('セットしたよ${this.selectItem}');
  }

  Map<dynamic,dynamic> getSelectItem(){
    return selectItem;
  }

  void setState(state){
    print('${this.state}');
    print('${state}');
    this.state += state;
    print('state:${this.state}');
    notifyListeners();
  }

  int getState(){
    return this.state;
  }

  void setId(id){
    this.id = id;
    notifyListeners();
  }

  int getId(){
    return this.id;
  }

  void setCamera(){
    this.isCamera = !isCamera;
    notifyListeners();
  }

  bool getCamera(){
    return this.isCamera;
  }

  void setImages(images){
    for(var i=0; i < images.length; i++){
      this.images[i]['path'] = images[i]['path'];
    }
    print('===============選択した画像===================');
    print(this.images);
    print('=============================================');
  }

  void setDetailImages(images){
    for(var i=0; i < this.images.length; i++){
      this.images[i]['path'] = images[i]['avatar'];
    }
  }

  void resetImages(){
    for(var i=0; i < this.images.length; i++){
      this.images[i]['path'] = '';
    }
  }

  //imagesが空かどうかチェック
  bool checkImages(){
    for(var i=0; i < this.images.length; i++){
      if(this.images[i]['path'] != ''){
        return false;
      }
    }
    return true;
  }

  List<Map<String,Object>> getImages(){
    return this.images;
  }

  void setSelectImage(index,item,tap){
    this.selectImage['index'] = index;
    this.selectImage['item'] = item;
    this.selectImage['tap'] = tap;
  }

  void resetSelectImage(){
    this.selectImage['index'] = -1;
    this.selectImage['item'] = {};
    this.selectImage['tap'] = false;
  }

  Map<String,Object> getSelectImage(){
    return this.selectImage;
  }
}