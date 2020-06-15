import 'package:flutter/cupertino.dart';

//表示ステータスの状態クラス
class Display with ChangeNotifier{
  var state = 0;        // 0 :一覧 1:編集 2:詳細 9:エラー
  var id = -1;          // -1:新規 1以上:更新
  var isCamera = false; // true:カメラ起動状態 //false:カメラ未起動状態
  var images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];
  var selectImage = { //編集画面より選択した画像情報を格納
    'index':-1,
    'item':{},
    'tap':false,
  };


  void setState(state){
    this.state = state;
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