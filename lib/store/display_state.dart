import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/Check.dart';
import 'package:recipe_app/model/CheckRecipi.dart';
import 'package:recipe_app/model/VersionCheck.dart';

//表示ステータスの状態クラス
class Display with ChangeNotifier{
  int state = 0;          // 0 :一覧 4:フォルダ別レシピ一覧 9:エラー
  int currentIndex = 0;   //0:ホーム 1:レシピ 2:ご飯日記 3:アルバム 4:フォルダ別レシピ
  List<Myrecipi> recipis = List<Myrecipi>();        //レシピ全件
  List<Myrecipi> searchs = List<Myrecipi>();        //レシピ検索結果
  List<Myrecipi> searchsTX = List<Myrecipi>();      //レシピ検索結果
  List<MstFolder> Mfolders = List<MstFolder>();     //フォルダマスタ
  List<Check> Dfolders = List<Check>();             //レシピIDに紐づくタグリスト　※チェックBox付きで表示する形式
  MstFolder folder;
  VersionCheck versionCheck = VersionCheck();       //バージョン情報チェック
  bool isInitBoot = true;                           //アプリ初期起動時かどうかのチェック
  int versionCheckTime = 0;                         //バージョンチェックした時間を保持
  double appCurrentVersion = 0;                     //アプリのカレントバージョンを保持

  int getVersionCheckTime(){
    return this.versionCheckTime;
  }

  //バージョンチェック時間
  void setVersionCheckTime(int versionCheckTime){
    this.versionCheckTime  = versionCheckTime;
    print('①セットチェック時間${this.versionCheckTime}');
    notifyListeners();
  }

  //appバージョン情報
  void setAppCurrentVersion(double appCurrentVersion){
    this.appCurrentVersion  = appCurrentVersion;
    notifyListeners();
  }

  bool getIsInitBoot(){
    return this.isInitBoot;
  }

  void setIsInitBoot(bool isInitBoot){
    this.isInitBoot  = isInitBoot;
    notifyListeners();
  }

  VersionCheck getVersionCheck(){
    return this.versionCheck;
  }

  void setVersionCheck(VersionCheck versionCheck){
    this.versionCheck  = versionCheck;
    notifyListeners();
  }

  void setFolder(Check folder){
    MstFolder mstFolder = MstFolder(id: folder.id,name:folder.name);
    this.folder = mstFolder;
    notifyListeners();
  }

  MstFolder getFolder(){
    return this.folder;
  }

  //チェックBox付き検索結果リスト
  List<CheckRecipi> createDisplaySearchList(){
    List<CheckRecipi> searchs = [];
    CheckRecipi search;
    for(var i=0; i<this.searchs.length; i++){
      search = CheckRecipi(
          id: this.searchs[i].id,
          type: this.searchs[i].type,
          thumbnail: this.searchs[i].thumbnail,
          title: this.searchs[i].title,
          description: this.searchs[i].description,
          quantity: this.searchs[i].quantity,
          unit: this.searchs[i].unit,
          time: this.searchs[i].time,
          folder_id: this.searchs[i].folder_id,
          isCheck: false
      );
      searchs.add(search);
    }
    return searchs;
  }

  //チェックBox付き検索結果リスト
  List<CheckRecipi> createDisplaySearchListTX(){
    List<CheckRecipi> searchs = [];
    CheckRecipi search;
    for(var i=0; i<this.searchsTX.length; i++){
      search = CheckRecipi(
          id: this.searchsTX[i].id,
          type: this.searchsTX[i].type,
          thumbnail: this.searchsTX[i].thumbnail,
          title: this.searchsTX[i].title,
          description: this.searchsTX[i].description,
          quantity: this.searchsTX[i].quantity,
          unit: this.searchsTX[i].unit,
          time: this.searchsTX[i].time,
          folder_id: this.searchsTX[i].folder_id,
          isCheck: false
      );
      searchs.add(search);
    }
    return searchs;
  }


  //チェックBox付きレシピリスト
  List<CheckRecipi> createDisplayRecipiList({bool isFolderIdZero}){
    List<CheckRecipi> recipis = [];
    CheckRecipi recipi;
    if(isFolderIdZero){
      for(var i=0; i<this.recipis.length; i++){
//        if(this.recipis[i].folder_id == 0){
          recipi = CheckRecipi(
              id: this.recipis[i].id,
              type: this.recipis[i].type,
              thumbnail: this.recipis[i].thumbnail,
              title: this.recipis[i].title,
              description: this.recipis[i].description,
              quantity: this.recipis[i].quantity,
              unit: this.recipis[i].unit,
              time: this.recipis[i].time,
              folder_id: this.recipis[i].folder_id,
              isCheck: false
          );
          recipis.add(recipi);
//        }
      }
    }else{
      for(var i=0; i<this.recipis.length; i++){
        recipi = CheckRecipi(
            id: this.recipis[i].id,
            type: this.recipis[i].type,
            thumbnail: this.recipis[i].thumbnail,
            title: this.recipis[i].title,
            description: this.recipis[i].description,
            quantity: this.recipis[i].quantity,
            unit: this.recipis[i].unit,
            time: this.recipis[i].time,
            folder_id: this.recipis[i].folder_id,
            isCheck: false
        );
        recipis.add(recipi);
      }
    }
    return recipis;
  }

  //チェックBox付きフォルダリスト
  List<Check> createFoldersCheck(){
    //フォルダリストの場合
      this.Dfolders = [];
      Check folders;
//      if(this.sortType == 1){
//        folders = Check(id: 0,name: 'フォルダから出す',isCheck: false);
//        this.Dfolders.add(folders);
//      }
      for(var i=0; i<this.Mfolders.length; i++ ){
        bool isCheck = false;
//          if(this.Mfolders[i].id == this.folderId){
//            isCheck = true;
//          }
        folders = Check(id: this.Mfolders[i].id,name: this.Mfolders[i].name,isCheck: isCheck);
        this.Dfolders.add(folders);
      }
      for(var i=0; i<this.Dfolders.length;i++ ){
        print('check[${i}]${this.Dfolders[i].id},${this.Dfolders[i].name},${this.Dfolders[i].isCheck},');
      }
      return Dfolders;
  }

  //検索結果のセット
  void setSearchs(List<Myrecipi> searchs){
//    print('①serchs件数${searchs.length}');
    this.searchs = [];
    for(var i = 0; i < searchs.length; i++){
      this.searchs.add(searchs[i]);
    }
    notifyListeners();
  }

  //検索結果の取得
  List<Myrecipi> getSearchs(){
    return this.searchs;
  }

  //検索結果のセット
  void setSearchsTX(List<Myrecipi> searchsTX){
//    print('①serchs件数${searchs.length}');
    this.searchsTX = [];
    for(var i = 0; i < searchsTX.length; i++){
      this.searchsTX.add(searchsTX[i]);
    }
    notifyListeners();
  }

  //検索結果の取得
  List<Myrecipi> getSearchsTX(){
    return this.searchsTX;
  }

  //レシピのセット
  void setRecipis(List<Myrecipi> recipis){
    this.recipis = [];
    for(var i = 0; i < recipis.length; i++){
      this.recipis.add(recipis[i]);
    }
//    notifyListeners();
  }

  //フォルダマスタをセットする
  void setMstFolder(List<MstFolder> folders){
    this.Mfolders = [];
    for(var i = 0; i < folders.length; i++){
      this.Mfolders.add(folders[i]);
    }
    notifyListeners();
  }

  void setState(state){
    this.state = state;
    notifyListeners();
  }

  void setCurrentIndex(index){
    this.currentIndex = index;
    print('##currentIndex:${this.currentIndex}');
    notifyListeners();
  }
}