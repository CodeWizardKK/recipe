import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/edit/Titleform.dart';

class RecipiDetail extends StatefulWidget{

  @override
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{

  DBHelper dbHelper;
  Myrecipi _recipi = Myrecipi();
  List<Ingredient> _ingredients;      //レシピIDに紐づく材料リスト
  List<HowTo> _howTos;                //レシピIDに紐づく作り方リスト
  List<Photo> _photos;                //レシピIDに紐づく写真
  int _backScreen = 0;        //0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面


  @override
  void initState() {
   super.initState();
    _getItem();
  }

  _getItem() async {
    dbHelper = DBHelper();
    this._ingredients = [];
    this._howTos = [];
    this._photos = [];
    //選択したrecipiを取得
    setState((){
      this._recipi = Provider.of<Detail>(context, listen: false).getRecipi();
    });
    //戻る画面を取得
    this._backScreen = Provider.of<Display>(context, listen: false).getBackScreen();
  }

  //レシピリストへ戻るボタン押下時処理
  void _onList(){
    //レシピ
    if(this._backScreen == 1) {
      //フォルダ別一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(4);
    //ごはん日記または、アルバム
    }else if(this._backScreen == 2 || this._backScreen == 4 ){
      //2:ごはん日記へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
//      //1:日記詳細レシピ一覧
//      Provider.of<Display>(context, listen: false).setState(1);
    //ホーム
    }else if(this._backScreen == 3){
      //ホーム画面へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(0);
    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }
    _init();
  }

  void _init(){
    Provider.of<Detail>(context, listen: false).reset();
  }

  //レシピの編集ボタン押下時処理
  void _onEdit(){
    //レシピIDをセットする
    Provider.of<Display>(context, listen: false).setId(this._recipi.id);
    //レシピ種別をセットする
    Provider.of<Display>(context, listen: false).setType(this._recipi.type);
    //サムネイル画像をセットする
    Provider.of<Display>(context, listen: false).setThumbnail(this._recipi.thumbnail);
    //タイトル、メモ、分量、調理時間をセットする
    TitleForm titleForm = TitleForm(title: this._recipi.title, description: this._recipi.description, unit: this._recipi.unit, quantity: this._recipi.quantity, time: this._recipi.time);
    Provider.of<Display>(context, listen: false).setTitleForm(titleForm);
    //材料、作り方、写真エリアをセットする
    if(this._recipi.type == 2){
      //MYレシピの場合
      Provider.of<Display>(context, listen: false).setIngredients(this._ingredients);
      Provider.of<Display>(context, listen: false).setHowTos(this._howTos);
    }else{
      //写真レシピの場合
      Provider.of<Display>(context, listen: false).setPhotos(this._photos);
    }
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(2);
  }

  //材料編集エリア
  Column _addIngredient(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._ingredients = Provider.of<Detail>(context, listen: false).getIngredients();
    });
    //材料リストを展開する
    for(var i=0; i < this._ingredients.length; i++){
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${_ingredients[i].name}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                        ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${this._ingredients[i].quantity}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                        ),),
                    ),
                  ],
                ),
          ),
        ),
      );
      column.add(
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      );
    }
    // 空
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
    return Column(
      children: column,
    );
  }

  //作り方編集エリア
  Column _addHowTo(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._howTos = Provider.of<Detail>(context, listen: false).getHowTos();
    });
    //作り方リストを展開する
    for(var i=0; i < this._howTos.length; i++){
      column.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      child: Container(
                        width: 250,
                        child: Text('${_howTos[i].memo}',
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: 15,
                          ),),
                      ),
                    ),
                    _howTos[i].photo.isNotEmpty
                        ? Card(
                      child: Container(
                        height: 100,
                        width: 100,
                          child: Image.file(File(_howTos[i].photo),fit: BoxFit.cover,),
                      ),
                    )
                        : Container(),
                  ],
                ),
          ),
        ),
      );
      //線
      column.add(
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      );
    }
    // 空
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
    return Column(
      children: column,
    );
  }

  //写真編集エリア
  Column _addPhoto(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._photos = Provider.of<Detail>(context, listen: false).getPhotos();
    });
    //追加したイメージを展開する
    for(var i=0; i < _photos.length; i++){
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: InkWell(
                child: Image.file(File(_photos[i].path),fit: BoxFit.cover,),
                onTap: (){
//                  print('###tap!!!!');
//                  print('no:${_photos[i].no},path:${_photos[i].path}');
//                  _showImgSelectModal(thumbnail: false,edit: true,photo: _photos[i],index: i);
                }
            ),
          ),
        ),
      );
      //線
      column.add(
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      );
    }
    // 空
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
        ),
      ),
    );
    return Column(
      children: column,
    );
  }

  //単位 表示用
  String _displayUnit(unit){
    if(unit == 1){
      return '人分';
    }
    if(unit == 2){
      return '個分';
    }
    if(unit == 3){
      return '枚分';
    }
    if(unit == 4){
      return '杯分';
    }
    if(unit == 5){
      return '皿分';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: backBtn(),
        elevation: 0.0,
        title: Center(
          child: Text('レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          shareBtn(),
          editBtn(),
        ],
      ),
      body: scrollArea(),
    );
  }

  //シェアボタン
  Widget shareBtn() {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.white, size: 30,),
      onPressed: () {
//        _onList();
      },
    );
  }

  //編集ボタン
  Widget editBtn(){
    return IconButton(
      icon: const Icon(Icons.edit,color: Colors.white,size: 30,),
      onPressed: (){
        _onEdit();
      },
    );
  }

  //戻るボタン
  Widget backBtn(){
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 30,),
        onPressed: (){
          _onList();
        },
    );
  }

  //レシピ詳細
  Widget scrollArea(){
    return Container(
      key: GlobalKey(),
      child: SingleChildScrollView(
        key: GlobalKey(),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
    return Container(
      alignment: Alignment.center,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
            _recipi.type == 2
              ? <Widget>[
                thumbnailArea(), //トップ画像
                titleArea(), //タイトル
                line(),
                ingredientArea(), //材料
                line(),
                ingredientAddArea(), //材料入力欄
                line(),
                howToArea(), //作り方
                line(),
                howToAddArea(), //作り方入力欄
                line(),
              ]
              : <Widget>[
                thumbnailArea(), //トップ画像
                titleArea(), //タイトル
                line(),
                photoArea(), //写真
                line(),
                photoAddArea(), //写真入力欄
                line(),
              ]
      ),
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

  //トップ画像
  Widget thumbnailArea(){
          return
            _recipi.thumbnail.isEmpty
                ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    color: Colors.grey,
                        child: Icon(Icons.camera_alt,color: Colors.white,size: 100,),
                  ),
                  )
                : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.40,
                  width: MediaQuery.of(context).size.width,
                  child: Container(
                    child: InkWell(
                    child: Image.file(File(_recipi.thumbnail),fit: BoxFit.cover,),
                    onTap: (){
//                      _showImgSelectModal(thumbnail: true);
                    }
                ),
              ),
            );
  }

  //レシピタイトル
  Widget titleArea(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${_recipi.title}',
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${_recipi.description}',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                  ),),
              ),
            ],
          ),
      ),
    );
  }

  //材料
  Widget ingredientArea(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('材料', style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text('${_recipi.quantity}${_displayUnit(_recipi.unit)}', style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ],
        ),
      ),
    );
  }

  //材料追加
  Widget ingredientAddArea(){
    return Container(
      child: _addIngredient(),
    );
  }

  //作り方
  Widget howToArea(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white30,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('作り方',style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
            _recipi.time != 0
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Text('${_recipi.time}分', style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                )
              : Container()
          ],
        ),
      ),
    );
  }

  //材料追加
  Widget howToAddArea(){
    return Container(
      child: _addHowTo(),
    );
  }

  //写真エリア
  Widget photoArea(){
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${_recipi.quantity}${_displayUnit(_recipi.unit)}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              _recipi.time != 0
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Text('${_recipi.time}分', style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),),
                  )
                : Container()
            ],
          ),
        ),
      );
  }

  //写真追加
  Widget photoAddArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
    return
      Container(
        child: _addPhoto(),
      );
//    });
  }
}