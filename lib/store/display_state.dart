import 'package:flutter/cupertino.dart';

//表示ステータスの状態クラス
class Display with ChangeNotifier{
  var state = 0; // 0:一覧 1:編集 2:カメラ起動 9:error
  var id = -1; //-1:新規 1以上:更新
  var cameraStartUp = false;

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
}