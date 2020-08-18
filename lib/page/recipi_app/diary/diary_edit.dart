import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


class DiaryEdit extends StatefulWidget{

  @override
  _DiaryEditState createState() => _DiaryEditState();
}

class _DiaryEditState extends State<DiaryEdit>{

  DBHelper dbHelper;
  int _selectedID;              //編集するID
  int _selectedCategory = 1;    //分類（1：指定なし、2：朝食、3：昼食、4：夕食、5：間食）
  int _backScreen = 0;          //戻る画面を格納[0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面]
  bool _isDelete = false;       //true:削除ボタン押下時

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    //戻る画面を取得
    this._backScreen = Provider.of<Display>(context, listen: false).getBackScreen();
    //idを取得
    this._selectedID = Provider.of<Display>(context, listen: false).getId();
  }

  //一覧リストへ遷移
  void _onList(){
    //レシピ
    if(this._backScreen == 1) {
      //フォルダ別一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(4);

    //ごはん日記
    }else if(this._backScreen == 2){
      if(this._isDelete){
        //一覧リストへ遷移
        Provider.of<Display>(context, listen: false).setState(0);
      }else{
        if(this._selectedID == -1){
          //一覧リストへ遷移
          Provider.of<Display>(context, listen: false).setState(0);
        }else{
          //詳細リストへ遷移
          Provider.of<Display>(context, listen: false).setState(1);
        }
      }

    //ホーム
    }else if(this._backScreen == 3){
      //ホーム画面へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(0);

    //アルバム
    }else if(this._backScreen == 4){
      if(this._isDelete){
        //一覧リストへ遷移
        Provider.of<Display>(context, listen: false).setState(0);
        //4:アルバムへ遷移
        Provider.of<Display>(context, listen: false).setCurrentIndex(3);
      }else{
        if(this._selectedID == -1){
          //4:アルバムへ遷移
          Provider.of<Display>(context, listen: false).setCurrentIndex(3);
        }else{
          //詳細リストへ遷移
          Provider.of<Display>(context, listen: false).setState(1);
        }
      }
    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }
  }

  //初期化処理
  void _init(){
    //リセット処理
    Provider.of<Edit>(context, listen: false).reset(); //編集フォーム
  }

  //保存する押下時処理
  void _onSubmit() async {
    //storeから内容を取得
    //内容、日付、分類、サムネイル
    Diary item = Provider.of<Edit>(context, listen: false).getEditForm();
    //料理
    List<DRecipi> recipis = Provider.of<Edit>(context, listen: false).getRecipis();
    //写真
    List<DPhoto> photos = Provider.of<Edit>(context, listen: false).getPhotos();
    //取得した値でdiaryを生成
    Diary diary = Diary
      (
         id: this._selectedID
        ,body: item.body
        ,date: item.date
        ,category: item.category
        ,thumbnail: item.thumbnail
      );

    //新規登録の場合
    if(this._selectedID == -1){
      //ごはん日記テーブルへ登録
      Diary result = await dbHelper.insertDiary(diary);
      //登録した日記IDを取得
      var diary_id = result.id;
      //料理がセットされている場合
      if(recipis.length != 0){
        //レシピリスト
        for(var i = 0; i < recipis.length; i++){
          //IDをセットする
          recipis[i].id = this._selectedID;
          //日記IDをセットする
          recipis[i].diary_id = diary_id;
        }
        //diary_recipiテーブルへ登録
        await dbHelper.insertDiaryRecipi(recipis);
      }

      //写真がセットされている場合
      if(photos.length != 0){
        //写真リスト
        for(var i = 0; i < photos.length; i++){
          //IDをセットする
          photos[i].id = this._selectedID;
          //日記IDをセットする
          photos[i].diary_id = diary_id;
        }
        //diary_recipiテーブルへ登録
        await dbHelper.insertDiaryPhoto(photos);
      }

      //更新の場合
    }else{
      //ごはん日記テーブルへ更新
      await dbHelper.updateDiary(diary);
      //変更前の料理リストを削除
      await dbHelper.deleteDiaryRecipi(this._selectedID);
      //変更前の写真リストを削除
      await dbHelper.deleteDiaryPhoto(this._selectedID);

      //料理がセットされている場合
      if(recipis.length != 0){
        //レシピリスト
        for(var i = 0; i < recipis.length; i++){
          //IDをセットする
          recipis[i].id = -1;
          //日記IDをセットする
          recipis[i].diary_id = this._selectedID;
        }
        //diary_recipiテーブルへ登録
        await dbHelper.insertDiaryRecipi(recipis);
      }

      //写真がセットされている場合
      if(photos.length != 0){
        //写真リスト
        for(var i = 0; i < photos.length; i++){
          //IDをセットする
          photos[i].id = -1;
          //日記IDをセットする
          photos[i].diary_id = this._selectedID;
        }
        //diary_recipiテーブルへ登録
        await dbHelper.insertDiaryPhoto(photos);
      }

      //更新した日記IDの最新情報の取得し、詳細フォームへ反映させる
      Diary newDiary = await dbHelper.getDiary(this._selectedID);
      List<DRecipi> newRecipis = await dbHelper.getDiaryRecipis(this._selectedID);
      List<DPhoto>  newPhotos  = await dbHelper.getDiaryPhotos(this._selectedID);
      DisplayDiary dd = DisplayDiary
        (
        id: newDiary.id,
        body: newDiary.body,
        date: newDiary.date,
        category: newDiary.category,
        thumbnail: newDiary.thumbnail,
        recipis: newRecipis,
        photos: newPhotos,
        );
      //更新した日記の内容をセットする
      Provider.of<Edit>(context, listen: false).setDiary(dd);
    }
    this._onList();
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

  //該当日記の削除
  void _onDelete() async {
    //日記を削除
    await dbHelper.deleteDiary(this._selectedID);
    //日記IDに紐づくレシピリストを削除する
    await dbHelper.deleteDiaryRecipi(this._selectedID);
    //日記IDに紐づく写真リストを削除する
    await dbHelper.deleteDiaryPhoto(this._selectedID);
    setState(() {
      this._isDelete = true;
    });
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
        },
        //選択完了後に呼び出される
        onConfirm: (date){
        //Date　=> String　変換
        DateFormat formatter = DateFormat('yyyy-MM-dd');
        String dateString = formatter.format(date);
        Provider.of<Edit>(context, listen: false).setDate(dateString);
//        print('Date型 $date');
//        print('String型 ${dateString}');
        },
        //デフォルトで表示する日付
        //String　=> Date　変換
        currentTime: DateTime.parse(Provider.of<Edit>(context, listen: false).getDate()),
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
                  scrollController: FixedExtentScrollController(
                      //デフォルト値
                      initialItem: this._selectedCategory - 1,
                  ),
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

  //料理、写真ボタン押下時の画面遷移
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
              child: Text( '${(DateFormat('yyyy年MM月dd日')).format(DateTime.parse(Edit.date))}',
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
                              color: Edit.date.isEmpty
                                    ? Colors.grey
                                    : Colors.cyan
                          ),
                          label: Text('日付',
                            style: TextStyle(
                              color: Edit.date.isEmpty
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