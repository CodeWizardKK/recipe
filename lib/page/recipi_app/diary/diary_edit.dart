import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/edit/Titleform.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker/multi_image_picker.dart';


class DiaryEdit extends StatefulWidget{

  @override
  _DiaryEditState createState() => _DiaryEditState();
}

class _DiaryEditState extends State<DiaryEdit>{

  DBHelper dbHelper;
  int _selectedID;              //編集するID
//  String _thumbnail;            //サムネイル DB送信用
  int _type;                      //レシピ種別
  List<Ingredient> _ingredients;  //材料リスト
  List<HowTo> _howTos;            //作り方リスト
  List<Photo> _photos;            //詳細の内容の写真(写真を追加欄)
//  List<File> imageFiles = new List<File>(); //詳細の内容の写真(写真を追加欄)
//  bool _isFolderBy = false;       //true:フォルダ別レシピ一覧へ遷移
  bool _isHome = false;       //true:フォルダ別レシピ一覧へ遷移

  int _selectedCategory = 1;               //分類（1：指定なし、2：朝食、3：昼食、4：夕食、5：間食）


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    //戻る画面を取得
//    this._isFolderBy = Provider.of<Display>(context, listen: false).getIsFolderBy();
    this._isHome = Provider.of<Display>(context, listen: false).getIsHome();
    //idを取得
    _selectedID = Provider.of<Display>(context, listen: false).getId();
    print('ID:${_selectedID}');
//    //レシピ種別を取得
//    this._type = Provider.of<Display>(context, listen: false).getType();
//    print('レシピ種別:${this._type}');
    //新規投稿の場合
    if(_selectedID == -1){
      print('新規作成');
      bool initialDisplay = Provider.of<Edit>(context, listen: false).getInitialDisplay();
      //初めて開かれた場合
      if(initialDisplay){
        print('初期表示');
      }else{
        print('２回目以降');
      }
    }else{
      //更新の場合
      print('更新');
//      //選択した日記の内容を取得
//      HowTo item = Provider.of<Display>(context, listen: false).getHowTo(_selectedID);
//      this._body.text = item.memo;
    }
  }

  //一覧リストへ遷移
  void _onList(){
    if(this._isHome){
      //ホーム画面へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(0);
    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }
    _init();
  }

  //初期化処理
  void _init(){
    //リセット処理
    Provider.of<Edit>(context, listen: false).reset(); //編集フォーム
//    Provider.of<Display>(context, listen: false).reset(); //編集フォーム
//    Provider.of<Detail>(context, listen: false).reset();  //詳細フォーム
  }

  //保存する押下時処理
  void _onSubmit() async {
    String thumbnail = Provider.of<Display>(context, listen: false).getThumbnail();
    //新規登録の場合
    if(_selectedID == -1){
//      //日付が当日で且つ分類が1(指定なし)の場合
//      if(          ) {
//        //DBに登録せず、一覧リストへ戻る
//            _onList();
//            return;
//        }
//      //内容が入力されている場合
//      TitleForm titleForm = Provider.of<Display>(context, listen: false).getTitleForm();
//      //ごはん日記テーブルへ登録
//      Myrecipi myrecipi = Myrecipi
//        (
//          id: this._selectedID
//          ,type: this._type
//          ,thumbnail: thumbnail
//          ,title: titleForm.title
//          ,description: titleForm.description
//          ,quantity: titleForm.quantity
//          ,unit: titleForm.unit
//          ,time: titleForm.time
//          ,folder_id: 0
//      );
//      Myrecipi result = await dbHelper.insertMyRecipi(myrecipi);
//      //登録した日記IDを取得
//      var recipi_id = result.id;
//      //料理がセットされている場合
//        if(this._ingredients.length != 0){
//          //レシピリスト
//          for(var i = 0; i < this._ingredients.length; i++){
//            //日記IDをセットする
//            this._ingredients[i].recipi_id = recipi_id;
//          }
//          //diary_recipiテーブルへ登録
//          await dbHelper.insertRecipiIngredient(this._ingredients);
//        }
//        //写真がセットされている場合
//        if(this._howTos.length != 0) {
//          //写真リスト
//          for (var i = 0; i < this._howTos.length; i++) {
//            //日記IDをセットする
//            this._howTos[i].recipi_id = recipi_id;
//          }
//          //diary_photoテーブルへ登録
//          await dbHelper.insertRecipiHowto(this._howTos);
//        }
      _onList();

      //更新の場合
    }else{
      //フォルダーIDを取得
      Myrecipi recipi = Provider.of<Detail>(context, listen: false).getRecipi();
      //タイトル、説明、分量、単位、調理時間
      TitleForm titleForm = Provider.of<Display>(context, listen: false).getTitleForm();
      //myrecipiテーブルへ更新
      Myrecipi myrecipi = Myrecipi
        (
          id: this._selectedID
          ,type: this._type
          ,thumbnail: thumbnail
          ,title: titleForm.title
          ,description: titleForm.description
          ,quantity: titleForm.quantity
          ,unit: titleForm.unit
          ,time: titleForm.time
          ,folder_id: recipi.folder_id
      );
      await dbHelper.updateMyRecipi(myrecipi);
      //MYレシピの場合
      if(this._type == 2){
        //変更前の材料リストを削除
        await dbHelper.deleteRecipiIngredient(_selectedID);
        //変更した材料リストをセット
        if(this._ingredients.length != 0){
          for(var i = 0; i < this._ingredients.length; i++){
            //レシピIDをセットする
            this._ingredients[i].recipi_id = this._selectedID;
          }
          //recipi_ingredientテーブルへ登録
          await dbHelper.insertRecipiIngredient(this._ingredients);
        }
        //変更前の作り方リストを削除
        await dbHelper.deleteRecipiHowto(_selectedID);
        //変更した作り方リストをセット
        if(this._howTos.length != 0){
          //作り方
          for(var i = 0; i < this._howTos.length; i++){
            //レシピIDをセットする
            this._howTos[i].recipi_id = _selectedID;
          }
          //recipi_howtoテーブルへ更新
          await dbHelper.insertRecipiHowto(this._howTos);
        }
      }else{
        //変更前の写真リストを削除
        await dbHelper.deleteRecipiPhoto(_selectedID);
        if(this._photos.length != 0){
          //写真
          for(var i = 0; i < this._photos.length; i++){
            //レシピIDをセットする
            this._photos[i].recipi_id = this._selectedID;
          }
          //recipi_photoテーブルへ登録
          await dbHelper.insertPhoto(this._photos);
        }
      }
      //更新したレシピIDの最新情報の取得し、詳細フォームへ反映させる
      //recipiをselectし、set
      var newMyrecipi = await dbHelper.getMyRecipi(_selectedID);
      Provider.of<Detail>(context, listen: false).setRecipi(newMyrecipi);
      //MYレシピの場合
      if (this._type == 2) {
        //recipi_ingredientテーブルをselectし、set
        var ingredients = await dbHelper.getIngredients(_selectedID);
        Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
        //recipi_howtoテーブルをselectし、set
        var howTos = await dbHelper.getHowtos(_selectedID);
        Provider.of<Detail>(context, listen: false).setHowTos(howTos);
        //写真レシピの場合
      } else {
        //recipi_photoテーブルをselectし、set
        var photos = await dbHelper.getPhotos(_selectedID);
        Provider.of<Detail>(context, listen: false).setPhotos(photos);
      }
      //詳細画面へ遷移
      Provider.of<Display>(context, listen: false).setState(1);
      //初期化
      Provider.of<Display>(context, listen: false).reset(); //編集フォーム
    }
  }

  //削除モーダルの表示
  Future<void> _deleteModal() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
            message: const Text('この日記を削除しますか?'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('削除する',
                  style: TextStyle(
                    color: Colors.red
                  ),),
                onPressed: () {
                  Navigator.pop(context);
                  _onDelete();
                },
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            )
        );
      },
    );
  }

  //該当日記削除
  void _onDelete() async {
    //日記を削除
    await dbHelper.deleteMyRecipi(this._selectedID);
    //日記IDに紐づく写真リストを削除する
    //日記IDに紐づくレシピリストを削除する
    _onList();
  }

  //日付の変更処理
  void _changeDate(){
    DatePicker.showDatePicker(
        context,
        showTitleActions: true,
        //選択の度に呼び出される
        onChanged: (date){
//          print('change $date}');
        DateTime datetime = new DateTime(date.year,date.month,date.day);
        print('${datetime}');
        },
        //選択完了後に呼び出される
        onConfirm: (date){
          Provider.of<Edit>(context, listen: false).setDate(date);
//            print('set $date');
        },
        //datepickerのデフォルトで表示する日付
        currentTime: Provider.of<Edit>(context, listen: false).getDate(),
        locale: LocaleType.jp
    );
  }

  //分類の変更処理
  Future<void> _changeCategory(){
    return showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 0.0,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      child: Text('キャンセル',style: TextStyle(
                        color: Colors.grey
                      ),),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                    ),
                    CupertinoButton(
                      child: Text('完了'),
                      onPressed: (){
                        this._setCategory();
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 200.0,
                color: Colors.white,
                child: CupertinoPicker(
                  onSelectedItemChanged: (value) {
                    setState(() {
                      this._selectedCategory = ++value;
//                      print(this._selectedCategory);
                    });
                  },
                  itemExtent: 40.0,
                  children: <Widget>[
                    Center(child: Text("指定なし")),
                    Center(child: Text("朝食")),
                    Center(child: Text("昼食")),
                    Center(child: Text("夕食")),
                    Center(child: Text("間食")),
                  ],
                  scrollController: FixedExtentScrollController(initialItem: this._selectedCategory - 1),
                ),
              ),
            ],
          );
        });
  }

  //カテゴリをsetする
  void _setCategory(){
    Provider.of<Edit>(context, listen: false).setCategory(this._selectedCategory);
  }

  //各エリアの追加ボタン押下
  void _changeEditType({editType}){
    Provider.of<Display>(context, listen: false).setEditType(editType);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Edit>(
      builder: (context,Edit,_){
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.cyan,
            leading: closeBtn(),
            elevation: 0.0,
            title: Center(
              child: Text( '${(DateFormat('yyyy年MM月dd日')).format(Edit.date)}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            actions: <Widget>[
              completeBtn(),
            ],
          ),
          body: scrollArea(),
        );
      }
    );
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
          child: Text('保存',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _onSubmit();
          },
        ),
      ),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return IconButton(
      icon: Icon( _selectedID == -1 ? Icons.close : Icons.arrow_back_ios,color: Colors.white,size: 30,),
      onPressed: (){
        _onList();
      },
    );
  }

  //スクロール
  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
    return Container(
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            bodyArea(),//本文 削除ボタン
            line(),
            selectBtnArea(),//日付 分類 料理 写真
            line(),
          ],
        ),
      ),
    );
  }

  //ボタンエリア
  Widget selectBtnArea(){
    return Consumer<Edit>(
        builder: (context,Edit,_){
          return SizedBox(
            child: Container(
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //日付
                  SizedBox(
                    child: Container(
                      width: 100,
                      height: 40,
                      child: RaisedButton.icon(
                          color: Colors.white,
                          icon: Icon(
                              Icons.calendar_today,
                              size: 25,
                              color: Edit.date == null
                                    ? Colors.grey
                                    : Colors.cyan
                          ),
                          label: Text('日付',
                            style: TextStyle(
                              color: Edit.date == null
                                  ? Colors.grey
                                  : Colors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                          shape: Border(
                            right: BorderSide(
                                color: Colors.grey,
                                width: 0.5
                            ),
                            left: BorderSide(
                                color: Colors.grey,
                                width: 0.5
                            ),
                          ),
                          onPressed:(){
                            this._changeDate();
                          }
                      ),
                    ),
                  ),
                  //分類
                  SizedBox(
                    child: Container(
                      width: 100,
                      height: 40,
                      child: RaisedButton.icon(
                          color: Colors.white,
                          icon: Icon(
                            Icons.access_time,
                            size: 25,
                            color: Edit.category == 1
                                ? Colors.grey
                                : Colors.cyan,
                          ),
                          label: Text('分類',
                            style: TextStyle(
                              color: Edit.category == 1
                                  ? Colors.grey
                                  : Colors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                          shape: Border(
                              right: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              )
                          ),
                          onPressed:(){
                            setState(() {
                              this._selectedCategory = Edit.category;
                            });
                            this._changeCategory();
                          }
                      ),
                    ),
                  ),
                  //料理
                  SizedBox(
                    child: Container(
                      width: 100,
                      height: 40,
                      child: RaisedButton.icon(
                        color: Colors.white,
                        icon: Icon(
                          Icons.restaurant,
                          size: 25,
                          color: Edit.recipis.length == 0
                              ? Colors.grey
                              : Colors.cyan,
                        ),
                        label: Text('料理',
                          style: TextStyle(
                            color: Edit.recipis.length == 0
                                ? Colors.grey
                                : Colors.cyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),),
                        shape: Border(
                            right: BorderSide(
                                color: Colors.grey,
                                width: 0.5
                            )
                        ),
                        onPressed:(){
                          print('料理');
                          _changeEditType(editType: 1);
                        },

                      ),
                    ),
                  ),
                  //写真
                  SizedBox(
                    child: Container(
                      width: 100,
                      height: 40,
                      child: RaisedButton.icon(
                          color: Colors.white,
                          icon: Icon(
                            Icons.camera_alt,
                            size: 25,
                            color: Edit.photos.length == 0
                                ? Colors.grey
                                : Colors.cyan,
                          ),
                          label: Text('写真',
                            style: TextStyle(
                              color: Edit.photos.length == 0
                                  ? Colors.grey
                                  : Colors.cyan,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                          shape: Border(
                              right: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              )
                          ),
                          onPressed:(){
                            print('写真');
                            _changeEditType(editType: 2);
                          }
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //本文,削除ボタン
  Widget bodyArea(){
    return Consumer<Edit>(
      builder: (context,Edit,_){
        return Stack(
          children: <Widget>[
            SizedBox(
              child: Container(
                width: 400,
                height: 300,
                child: TextField(
                  controller: Edit.body,
                  autofocus: false,
                  minLines: 14,
                  maxLines: 14,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            _selectedID != -1
              ? Positioned(
                bottom: 10,
                right: 10,
                width: 100,
                height: 20,
                child: Container(
                  child: RaisedButton.icon(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.black54,
                      size: 13,
                    ),
                    label: Text('日記を削除',
                      style: TextStyle(fontSize: 10),
                    ),
                    textColor: Colors.black54,
                    onPressed:(){
                      _deleteModal();
                    } ,
                  ),
                ),
              )
              : Container(),
          ],
        );
      },
    );
  }

  //線
  Widget line(){
    return Divider(
      color: Colors.grey,
      height: 0.5,
      thickness: 0.5,
    );
  }
}