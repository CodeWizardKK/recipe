import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/page/recipi_app/diary/edit_photo.dart';
import 'package:recipe_app/page/recipi_app/diary/edit_recipi.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';


class DiaryEdit extends StatefulWidget{

  DisplayDiary selectedDiary = DisplayDiary();

  DiaryEdit({Key key, @required this.selectedDiary}) : super(key: key);

  @override
  _DiaryEditState createState() => _DiaryEditState();
}

class _DiaryEditState extends State<DiaryEdit>{

  DBHelper dbHelper;
  DisplayDiary _diary = DisplayDiary();                  //ご飯日記
  int _selectedID;                                       //編集するID
  int _selectedCategory = 1;                             //選択した分類（1：指定なし、2：朝食、3：昼食、4：夕食、5：間食）
  final TextEditingController _body  = TextEditingController();//本文

  @override
  void initState() {
    super.initState();
    this._init();
  }

  //初期処理
  void _init(){
    //idを取得
    setState(() {
      this.dbHelper = DBHelper();
      this._selectedID = widget.selectedDiary.id;
      this._diary = DisplayDiary(
            id: widget.selectedDiary.id
          ,body: widget.selectedDiary.body
          ,date: widget.selectedDiary.date
          ,category: widget.selectedDiary.category
          ,thumbnail: widget.selectedDiary.thumbnail
          ,photos: setPhotos(widget.selectedDiary.photos)
          ,recipis: setRecipis(widget.selectedDiary.recipis)
      );
      this._body.text = this._diary.body;
    });
  }

  List<DPhoto> setPhotos(List<DPhoto> p){
    List<DPhoto> photos = [];
    p.forEach((photo) => photos.add(photo));
    return photos;
  }

  List<DRecipi> setRecipis(List<DRecipi> r){
    List<DRecipi> recipis = [];
    r.forEach((recipi) => recipis.add(recipi));
    return recipis;
  }

  //一覧リストへ遷移
  void _onList({int type,DisplayDiary diary}){
    //0: 閉じる(新規投稿)　※何もせず閉じる
    if(type == 0){
      Navigator.pop(context,'newClose');
    }
    //1: 閉じる(更新)　　　※何もせず閉じる
    if(type == 1){
      Navigator.pop(context,'updateClose');
    }
    //2: 新規保存
    if(type == 2){
      Navigator.pop(context,'new');
    }
    //3: 更新
    if(type == 3){
      Navigator.pop(context,diary);
    }
    //4: 削除
    if(type == 4){
      Navigator.pop(context,'delete');
    }
  }

  //保存する押下時処理
  void _onSubmit() async {
    //料理
    List<DRecipi> recipis = this._diary.recipis;
    //写真
    List<DPhoto> photos = this._diary.photos;
    //取得した値でdiaryを生成
    Diary diary = Diary
      (
         id: this._selectedID
        ,body: this._body.text
        ,date: this._diary.date
        ,category: this._diary.category
        ,thumbnail: this._diary.thumbnail
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
      this._onList(type: 2);
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
      this._onList(type: 3,diary: dd);
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

  //該当日記の削除
  void _onDelete() async {
    //日記を削除
    await dbHelper.deleteDiary(this._selectedID);
    //日記IDに紐づくレシピリストを削除する
    await dbHelper.deleteDiaryRecipi(this._selectedID);
    //日記IDに紐づく写真リストを削除する
    await dbHelper.deleteDiaryPhoto(this._selectedID);
    _onList(type: 4);
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
        setState(() {
          this._diary.date = formatter.format(date);
        });
//        print('Date型 $date');
//        print('String型 ${dateString}');
        },
        //デフォルトで表示する日付
        //String　=> Date　変換
        currentTime: DateTime.parse(_diary.date),
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
                height: MediaQuery.of(context).size.height * 0.25,
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
    setState(() {
      this._diary.category = this._selectedCategory;
    });
  }

  //料理、写真ボタン押下時の画面遷移
  void _changeEditType({editType}){
    var root = [EditRecipi(recipis: this._diary.recipis,),EditPhoto(photos: this._diary.photos,)];
    //編集画面へ遷移
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => root[editType],
          fullscreenDialog: true,
        )
    ).then((result) {
      if(result != 'close'){
//        print('###保存');
        if(editType == 0){
          setState(() {
            this._diary.recipis = result;
          });
        } else {
          setState(() {
            this._diary.photos = result;
          });
        }
      } else {
//        print('###クローズ');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
            leading: closeBtn(),
            elevation: 0.0,
            title: Center(
              child: Text( '${(DateFormat('yyyy年MM月dd日')).format(DateTime.parse(this._diary.date))}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
//                  fontWeight: FontWeight.bold,
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

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FittedBox(fit:BoxFit.fitWidth,
        child: FlatButton(
          color: Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
          child: Text('保存',
            style: TextStyle(
              color: Colors.deepOrange[100 * (1 % 9)],
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _onSubmit();
          },
        ),
      ),
      ),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child:IconButton(
        icon: Icon( _selectedID == -1 ? Icons.close : Icons.arrow_back_ios,color: Colors.white),
        onPressed: (){
          _onList(type: _selectedID == -1 ? 0 : 1);
        },
      ),
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
//            line(),
            selectBtnArea(),//日付 分類 料理 写真
//            line(),
          ],
        ),
      ),
    );
  }

  //ボタンエリア
  Widget selectBtnArea(){
          return SizedBox(
            child: Container(
              color: Colors.white,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  //日付
                  SizedBox(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
//                      height: MediaQuery.of(context).size.width * 0.1,
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: RaisedButton.icon(
                            color: Colors.white,
                            icon: Icon(
                                Icons.calendar_today,
  //                              size: 25,
                                color: _diary.date.isEmpty
                                      ? Colors.grey
                                      : Colors.deepOrange[100 * (1 % 9)]
                            ),
                            label: Text('日付',
                              style: TextStyle(
                                color: _diary.date.isEmpty
                                    ? Colors.grey
                                    : Colors.deepOrange[100 * (1 % 9)],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),),
                            shape: Border(
                              top: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
                              bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
                              right: BorderSide(
                                  color: Colors.grey,
                                  width: 0.25
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
                  ),
                  //分類
                  SizedBox(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
//                      height: MediaQuery.of(context).size.width * 0.1,
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: RaisedButton.icon(
                            color: Colors.white,
                            icon: Icon(
                              Icons.access_time,
  //                            size: 25,
                              color: _diary.category == 1
                                  ? Colors.grey
                                  : Colors.deepOrange[100 * (1 % 9)],
                            ),
                            label: Text('分類',
                              style: TextStyle(
                                color: _diary.category == 1
                                    ? Colors.grey
                                    : Colors.deepOrange[100 * (1 % 9)],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),),
                            shape: Border(
                              top: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
                              bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
                              right: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
  //                            left: BorderSide(
  //                                color: Colors.grey,
  //                                width: 0.5
  //                            ),
                            ),
                            onPressed:(){
                              setState(() {
                                this._selectedCategory = _diary.category;
                              });
                              this._changeCategory();
                            }
                        ),
                      ),
                    ),
                  ),
                  //料理
                  SizedBox(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
//                      height: MediaQuery.of(context).size.width * 0.1,
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: RaisedButton.icon(
                          color: Colors.white,
                          icon: Icon(
                            Icons.restaurant,
//                            size: 25,
                            color: _diary.recipis.length == 0
                                ? Colors.grey
                                : Colors.deepOrange[100 * (1 % 9)],
                          ),
                          label: Text('料理',
                            style: TextStyle(
                              color: _diary.recipis.length == 0
                                  ? Colors.grey
                                  : Colors.deepOrange[100 * (1 % 9)],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),),
                          shape: Border(
                            top: BorderSide(
                                color: Colors.grey,
                                width: 0.5
                            ),
                            bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5
                            ),
  //                          right: BorderSide(
  //                              color: Colors.grey,
  //                              width: 0.5
  //                          ),
  //                          left: BorderSide(
  //                              color: Colors.grey,
  //                              width: 0.5
  //                          ),
                          ),
                          onPressed:(){
                            _changeEditType(editType: 0);
                          },

                        ),
                      ),
                    ),
                  ),
                  //写真
                  SizedBox(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
//                      height: MediaQuery.of(context).size.width * 0.1,
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: RaisedButton.icon(
                            color: Colors.white,
                            icon: Icon(
                              Icons.camera_alt,
//                              size: 25,
                              color: _diary.photos.length == 0
                                  ? Colors.grey
                                  : Colors.deepOrange[100 * (1 % 9)],
                            ),
                            label: Text('写真',
                              style: TextStyle(
                                color: _diary.photos.length == 0
                                    ? Colors.grey
                                    : Colors.deepOrange[100 * (1 % 9)],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),),
                            shape: Border(
                              top: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
                              bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5
                              ),
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
                              _changeEditType(editType: 1);
                            }
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  //本文,削除ボタン
  Widget bodyArea(){
        return Stack(
          children: <Widget>[
            SizedBox(
                child: Center(
                  child: Container(
                    color: Colors.white,
                    width: MediaQuery.of(context).size.width * 0.98,
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: TextField(
                      controller: _body,
                      autofocus: false,
                      minLines: 14,
                      maxLines: 14,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
              )
            ),
            _selectedID != -1
              ? Positioned(
                bottom: 10,
                right: 10,
                width: MediaQuery.of(context).size.width * 0.25,
//                height: MediaQuery.of(context).size.height * 0.02,
                child: Container(
                  child: FittedBox(fit:BoxFit.fitWidth,
                  child: RaisedButton.icon(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.black54,
//                      size: 13,
                    ),
                    label: Text('日記を削除',
//                      style: TextStyle(fontSize: 10),
                    ),
                    textColor: Colors.black54,
                    onPressed:(){
                      _deleteModal();
                    } ,
                  ),
                ),
                ),
              )
              : Container(),
          ],
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