import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/edit/Titleform.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/Check.dart';
import 'package:recipe_app/model/CheckRecipi.dart';

//表示ステータスの状態クラス
class Display with ChangeNotifier{
  int type = 0;           //レシピ種別 1:写真レシピ 2:MYレシピ
  int state = 0;          // 0 :一覧 1:詳細 2:編集 3:レシピの整理 4:フォルダ別レシピ一覧 9:エラー
  int currentIndex = 0;   //0:ホーム 1:レシピ 2:ご飯日記 3:アルバム
  int editType = 0;       //0:編集画面TOP 1:タイトル編集欄 2:材料編集欄 3:作り方編集欄
  bool isHome = false;    //true:ホーム画面に戻る
  List<Myrecipi> recipis = List<Myrecipi>();     //レシピ全件
  List<Myrecipi> searchs = List<Myrecipi>();     //レシピ検索結果
  List<Myrecipi> searchsTX = List<Myrecipi>();     //レシピ検索結果

  List<MstFolder> Mfolders = List<MstFolder>();     //フォルダマスタ
  List<MstTag> Mtags = List<MstTag>();              //タグマスタ

  //////////////
  //レシピの整理//
  //////////////
  String ingredientsTX ='';                 //レシピIDに紐づく材料リストを文字列で格納
  List<Tag> tags = List<Tag>();             //レシピIDに紐づくタグリスト
  List<Check> default_tags = List<Check>(); //レシピIDに紐づくタグリスト　※チェックBox付きで表示する形式
  List<Check> Dtags = List<Check>();        //レシピIDに紐づくタグリスト　※チェックBox付きで表示する形式
  int folderId = -1;                        //レシピIDに紐づくフォルダID
  List<Check> Dfolders = List<Check>();     //レシピIDに紐づくタグリスト　※チェックBox付きで表示する形式
  int sortType = 0;                         //レシピの整理 0:全て表示 1:フォルダのみ 2:タグのみ
  List ids = [];                            //レシピリストにてチェックしたレシピIDを格納

  /////////////////////
  //フォルダ別レシピ一覧//
  /////////////////////
  MstFolder folder;
  bool isFolderBy = false;                 //true:フォルダ別レシピ一覧表示



  /////////////////////////////////
  //ここから下は別ファイルに記載する //
  ////////////////////////////////
  int editIndex = -1;     //-1:新規 -1以外:更新 //材料編集欄、作り方編集欄の新規か更新ジャッジ
  int id = -1;            // -1:新規 1以上:更新 //編集画面TOPの新規or更新ジャッジ
  String thumbnail = '';                              //サムネイル(編集用)
  TitleForm titleForm;                                //タイトル編集欄(編集用)
  List<Ingredient> ingredients =  List<Ingredient>(); //材料リスト(編集用)
  List<HowTo> howTos =  List<HowTo>();                //作り方リスト(編集用)
  List<Photo> photos = List<Photo>();                //詳細の内容の写真(写真を追加欄)(編集用)



  void setIsHome(bool isHome){
    this.isHome = isHome;
    notifyListeners();
  }

  bool getIsHome(){
    return this.isHome;
  }

  void setIsFolderBy(bool isFolderBy){
    this.isFolderBy = isFolderBy;
    notifyListeners();
  }

  bool getIsFolderBy(){
    return this.isFolderBy;
  }

  void setFolder(Check folder){
    MstFolder mstFolder = MstFolder(id: folder.id,name:folder.name);
    this.folder = mstFolder;
    notifyListeners();
  }

  MstFolder getFolder(){
    return this.folder;
  }

  void setIds(List ids){
    this.ids = ids;
    notifyListeners();
  }

  List getIds(){
    return this.ids;
  }

  void setSortType(int sortType){
    this.sortType = sortType;
    notifyListeners();
  }

  int getSortType(){
    return this.sortType;
  }

  void setFolderId(int folderId){
    this.folderId = folderId;
  }

  int getFolderId(){
    return this.folderId;
  }

  void setIngredientTX(String ingredientsTX){
    this.ingredientsTX = ingredientsTX;
    notifyListeners();
  }

  String getIngredientTX(){
    return this.ingredientsTX;
  }

  void setTags(List<Tag> tags){
    this.tags.clear();
    this.tags = tags;
    notifyListeners();
  }

  List<Tag> getTags(){
    return this.tags;
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

//  //フォルダID=0のチェックBox付きレシピリスト
//  List<CheckRecipi> createDisplayRecipiList(){
//    List<CheckRecipi> recipis = [];
//    CheckRecipi recipi;
//    for(var i=0; i<this.recipis.length; i++){
//      recipi = CheckRecipi(
//          id: this.recipis[i].id,
//          type: this.recipis[i].type,
//          thumbnail: this.recipis[i].thumbnail,
//          title: this.recipis[i].title,
//          description: this.recipis[i].description,
//          quantity: this.recipis[i].quantity,
//          unit: this.recipis[i].unit,
//          time: this.recipis[i].time,
//          folder_id: this.recipis[i].folder_id,
//          isCheck: false
//      );
//      recipis.add(recipi);
//    }
//    return recipis;
//  }

  //チェックBox付きレシピリスト
  List<CheckRecipi> createDisplayRecipiList({bool isFolderIdZero}){
    List<CheckRecipi> recipis = [];
    CheckRecipi recipi;
    if(isFolderIdZero){
      for(var i=0; i<this.recipis.length; i++){
        if(this.recipis[i].folder_id == 0){
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

  //チェックBox付きタグリスト type:1(フォルダ) type:2(タグ)
  List<Check> createCheckList({int type}){
    //フォルダリストの場合
    if(type == 1){
      this.Dfolders = [];
      Check folders;
      if(this.sortType == 1){
        folders = Check(id: 0,name: 'フォルダから出す',isCheck: false);
        this.Dfolders.add(folders);
      }
      for(var i=0; i<this.Mfolders.length; i++ ){
        bool isCheck = false;
          if(this.Mfolders[i].id == this.folderId){
            isCheck = true;
          }
        folders = Check(id: this.Mfolders[i].id,name: this.Mfolders[i].name,isCheck: isCheck);
        this.Dfolders.add(folders);
      }
      for(var i=0; i<this.Dfolders.length;i++ ){
        print('check[${i}]${this.Dfolders[i].id},${this.Dfolders[i].name},${this.Dfolders[i].isCheck},');
      }
      return Dfolders;

    //タグリスト
    }else{
      this.Dtags = [];
      Check tag;
      for(var i=0; i<this.Mtags.length;i++ ){
        bool isCheck = false;
        for(var k=0; k < this.tags.length; k++){
          if(this.Mtags[i].id == this.tags[k].mst_tag_id){
            isCheck = true;
            break;
          }
        }
        tag = Check(id: this.Mtags[i].id,name: this.Mtags[i].name,isCheck: isCheck);
        this.Dtags.add(tag);
      }
      for(var i=0; i<this.Dtags.length;i++ ){
//        print('check[${i}]${this.Dtags[i].id},${this.Dtags[i].name},${this.Dtags[i].isCheck},');
      }
      return Dtags;
    }
  }

  //初期表示時のチェックBox付きタグリスト type:1(フォルダ) type:2(タグ)
  List<Check> createDefaultCheckList({int type}){
    //フォルダリストの場合
    if(type == 1){
      //タグリスト
    }else{
      this.default_tags = [];
      Check tag;
      for(var i=0; i<this.Mtags.length;i++ ){
        bool isCheck = false;
        for(var k=0; k < this.tags.length; k++){
          if(this.Mtags[i].id == this.tags[k].mst_tag_id){
            isCheck = true;
            break;
          }
        }
        tag = Check(id: this.Mtags[i].id,name: this.Mtags[i].name,isCheck: isCheck);
        this.default_tags.add(tag);
      }
      for(var i=0; i<this.default_tags.length;i++ ){
//        print('check[${i}]${this.default_tags[i].id},${this.default_tags[i].name},${this.default_tags[i].isCheck},');
      }
      return this.default_tags;
    }
  }

  List<Check> getDisplayCheck({int type}){
    if(type == 1){
      return this.Dfolders;
    }else{
      return this.Dtags;
    }
  }


  void setCheck({int index,bool isCheck,int type}){
    //フォルダリスト
    if(type == 1){
      this.Dfolders[index].isCheck = isCheck;
    //タグリスト
    }else{
      this.Dtags[index].isCheck = isCheck;

    }
  }

  void addDisplayCheck({Check check,int type}){
    //フォルダリスト
    if(type == 1){
      //フォルダは複数選択不可なので、全てfalseに変更する
      for(var i = 0; i< this.Dfolders.length; i++){
        this.Dfolders[i].isCheck = false;
      }
      this.Dfolders.add(check);
    //タグリスト
    }else{
      this.Dtags.add(check);
    }
  }

  void addefaultDisplayCheck({Check check,int type}){
    //フォルダリスト
    if(type == 1){
    //タグリスト
    }else{
      this.default_tags.add(check);
    }
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

  //レシピの取得
  List<Myrecipi> getRecipis(){
    return this.recipis;
  }

  //フォルダマスタをセットする
  void setMstFolder(List<MstFolder> folders){
    this.Mfolders = [];
    for(var i = 0; i < folders.length; i++){
      this.Mfolders.add(folders[i]);
    }
    notifyListeners();
  }

  //フォルダマスタを取得する
  List<MstFolder> getMstFolder(){
    return this.Mfolders;
  }

  //タグマスタをセットする
  void setMstTag(List<MstTag> Mtags){
    this.Mtags = [];
    for(var i = 0; i < Mtags.length; i++){
      this.Mtags.add(Mtags[i]);
    }
    notifyListeners();
  }

  //タグマスタを取得する
  List<MstTag> getMstTag(){
    return this.Mtags;
  }

  //レシピ種別をセット
  void setType(int type){
    this.type = type;
  }

  int getType(){
    return this.type;
  }

  //サムネイル画像のセット
  void setThumbnail(String thumbnail){
    this.thumbnail = thumbnail;
  }

  void sortReset(){
    this.ingredientsTX = '';
    this.tags = [];
    this.folderId = -1;
    this.Dfolders = [];
    this.Dtags = [];
    this.default_tags = [];
  }

  //リセット
  void reset(){
    this.thumbnail = '';
    this.titleForm = TitleForm(title:'',description:'',unit:1,quantity: 1,time: 0);
    this.photos.clear();
    this.ingredients.clear();
    this.howTos.clear();
    this.id = -1;
    this.setIsHome(false);
  }

  //サムネイル画像の取得
  String getThumbnail(){
    return this.thumbnail;
  }

  void setRecipiId(int rid){
    for(var i = 0; i < this.photos.length; i++){
      this.photos[i].recipi_id = rid;
//      print('[photo][${i}]${this.photos[i]}');
    }
  }

  //写真リストへの追加
  void addPhoto(Photo photo){
    var no = this.photos.length + 1;
    Photo item  = Photo(no:no,path: photo.path);
    this.photos.add(item);
    for(var i = 0;i < this.photos.length; i++){
//      print('###[photo]no:${this.photos[i].no},path:${this.photos[i].path}');
    }
  }

  //写真リストの取得
  List<Photo> getPhotos(){
    return this.photos;
  }

  //写真の更新
  void setPhoto(int index,Photo photo){
    this.photos[index].path = photo.path;
//    print('no:${this.photos[index].no},path:${this.photos[index].path}');
  }

  //写真リストの更新
  void setPhotos(List<Photo> photos){
    //現状の材料リストをクリア
    this.photos.clear();
    //再セット
    for(var i = 0; i < photos.length; i++){
      this.photos.add(photos[i]);
    }
    for(var i = 0; i < this.photos.length; i++){
//      print('[store]no:${this.photos[i].no},path:${this.photos[i].path}');
    }
    notifyListeners();
  }

  //作り方リストへの追加
  void addHowTo(HowTo howto){
    var no = this.howTos.length + 1;
    HowTo item  = HowTo(no: no,memo: howto.memo,photo: howto.photo);
    this.howTos.add(item);
    for(var i = 0; i < this.howTos.length; i++){
//      print('no:${this.howTos[i].no},memo:${this.howTos[i].memo},photo:${this.howTos[i].photo}');
    }
  }

  //作り方リストの取得
  List<HowTo> getHowTos(){
    return this.howTos;
  }

  //選択した作り方の取得
  HowTo getHowTo(int index){
    return this.howTos[index];
  }

  //選択した作り方の更新
  void setHowTo(int index,HowTo howto){
    this.howTos[index].memo = howto.memo;
    this.howTos[index].photo = howto.photo;
//    print('no:${this.howTos[index].no},memo:${this.howTos[index].memo},photo:${this.howTos[index].photo}');
  }

  //材料リストへの追加
  void addIngredient(Ingredient ingredient){
    var no = this.ingredients.length + 1;
//    print('${this.ingredients.length}');
//    print('${ingredient.name}');
//    print('${ingredient.quantity}');
    Ingredient item  = Ingredient(no: no,name: ingredient.name,quantity: ingredient.quantity);
    this.ingredients.add(item);
    for(var i = 0; i < this.ingredients.length; i++){
//      print('no:${this.ingredients[i].no},name:${this.ingredients[i].name},quantity:${this.ingredients[i].quantity}');
    }
  }

  //材料リストの取得
  List<Ingredient> getIngredients(){
    return this.ingredients;
  }

  //材料リストをセット
  void setIngredients(List<Ingredient> ingredients){
//    print('reset!!!');
//    print('${ingredients.length}');
    //現状の材料リストをクリア
    this.ingredients.clear();
    //再セット
    for(var i = 0; i < ingredients.length; i++){
      this.ingredients.add(ingredients[i]);
    }
    for(var i = 0; i < this.ingredients.length; i++){
//      print('[store]id:${this.ingredients[i].id},recipi_id:${this.ingredients[i].recipi_id},no:${this.ingredients[i].no},name:${this.ingredients[i].name},quantity:${this.ingredients[i].quantity}');
    }
    notifyListeners();
  }

  void resetIngredients(){
    //現状の材料リストをクリア
    this.ingredients.clear();
    notifyListeners();
  }

  //材料リストをセット
  void setHowTos(List<HowTo> howtos){
//    print('reset!!!');
//    print('${howtos.length}');
    //現状の材料リストをクリア
    this.howTos.clear();
    //再セット
    for(var i = 0; i < howtos.length; i++){
      this.howTos.add(howtos[i]);
    }
    for(var i = 0; i < this.howTos.length; i++){
//      print('[store]id:${this.howTos[i].id},recipi_id:${this.howTos[i].recipi_id},no:${this.howTos[i].no},name:${this.howTos[i].memo},quantity:${this.howTos[i].photo}');
    }
    notifyListeners();
  }

  //選択した材料の取得
  Ingredient getIngredient(index){
    return this.ingredients[index];
  }

  //選択した材料の更新
  void setIngredient(index,ingredient){
    this.ingredients[index].name = ingredient.name;
    this.ingredients[index].quantity = ingredient.quantity;
//    print('no:${this.ingredients[index].no},name:${this.ingredients[index].name},quantity:${this.ingredients[index].quantity}');
  }


  //タイトル欄のセット
  void setTitleForm(TitleForm editForm){
    this.titleForm = TitleForm(
      title: editForm.title,
      description: editForm.description,
      quantity: editForm.quantity,
      unit: editForm.unit,
      time: editForm.time,
    );
//    print('###setしたよ');
//    print('title:${this.titleForm.title}');
//    print('description:${this.titleForm.description}');
//    print('quantity:${this.titleForm.quantity}');
//    print('unit:${this.titleForm.unit}');
//    print('time:${this.titleForm.time}');
//    notifyListeners();
  }

  //タイトル欄の取得
  TitleForm getTitleForm(){
    return this.titleForm;
  }
  //タイトル欄の取得
  bool IsEmptyTitleForm(){
    if(this.titleForm.title.isNotEmpty){
      return false;
    }
    if(this.titleForm.description.isNotEmpty){
      return false;
    }
    if(this.titleForm.unit != 1){
      return false;
    }
    if(this.titleForm.quantity != 1){
      return false;
    }
    if(this.titleForm.time != 0){
      return false;
    }
    return true;
  }

  void setState(state){
//    print('${this.state}');
//    print('${state}');
    this.state = state;
//    print('state:${this.state}');
    notifyListeners();
  }

  int getState(){
    return this.state;
  }

  void setEditType(editType){
//    print('${this.state}');
//    print('${state}');
    this.editType = editType;
//    print('state:${this.state}');
    notifyListeners();
  }

  int getEditType(){
    return this.editType;
  }

  void setEditIndex(index){
//    print('${this.state}');
//    print('${state}');
    this.editIndex = index;
//    print('state:${this.state}');
    notifyListeners();
  }

  int getEditIndex(){
    return this.editIndex;
  }

  void setId(id){
    this.id = id;
    notifyListeners();
  }

  int getId(){
    return this.id;
  }

  void setCurrentIndex(index){
    this.currentIndex = index;
    print('##currentIndex:${this.currentIndex}');
    notifyListeners();
  }

  int getCurrentIndex(){
    return this.currentIndex;
  }
}