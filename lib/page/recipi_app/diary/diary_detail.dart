import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:intl/intl.dart';

class DiaryDetail extends StatefulWidget{

  @override
  _DiaryDetailState createState() => _DiaryDetailState();
}

class _DiaryDetailState extends State<DiaryDetail>{

  DBHelper dbHelper;
  DisplayDiary _diary = DisplayDiary();    //選択したごはん日記
  List<Recipi> _recipis = List<Recipi>();  //選択したごはん日記に紐づくレシピリストを格納
  int _photoIndex = 0;                     //サムネイルで表示する写真のindexを格納
//  int _backScreen = 0;                   //戻る画面を格納[0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面]

  @override
  void initState() {
   super.initState();
    _getItem();
  }

  _getItem() async {
    dbHelper = DBHelper();
    setState(() {
//    //戻る画面を取得
//    this._backScreen = Provider.of<Display>(context, listen: false).getIsFolderBy();
      //選択した日記の取得
      this._diary = Provider.of<Edit>(context, listen: false).getDiary();
    });

    //ご飯日記IDに紐づくレシピの取得
    await dbHelper.getDiaryRecipis(this._diary.id).then((item) {
      setState(() {
        this._diary.recipis.clear();
        this._diary.recipis.addAll(item);
      });
    });
    setState(() {
      //レシピリスト用データクリア
      this._recipis.clear();
    });

    //選択した日記のレシピIDを元に、レシピを取得
    for(var i = 0; i < this._diary.recipis.length; i++){
      //レシピIDを元にレシピを取得
      Myrecipi myrecipi = await dbHelper.getMyRecipi(this._diary.recipis[i].recipi_id);
      //レシピIDを元にタグリストを取得
      List<Tag> tags = await dbHelper.getTags(this._diary.recipis[i].recipi_id);
      //レシピIDを元に材料を取得
      List<Ingredient> ingredients = await dbHelper.getIngredients(this._diary.recipis[i].recipi_id);
      //取得した値
      Recipi recipi = Recipi(recipi: myrecipi,tags: tags,ingredients: ingredients);
      setState(() {
        this._recipis.add(recipi);
      });
    }
    print('ごはん日記に紐づくレシピ件数：${this._recipis.length}');
//    for(var i = 0; i < this._recipis.length; i++){
//      print('------------${i}---------------');
//      print('id:${this._recipis[i].recipi.id}');
//      print('thumbnail:${this._recipis[i].recipi.thumbnail}');
//      print('title${this._recipis[i].recipi.title}');
//      print('description:${this._recipis[i].recipi.description}');
//      print('unit:${this._recipis[i].recipi.unit}');
//      print('time:${this._recipis[i].recipi.time}');
//      print('folder_id:${this._recipis[i].recipi.folder_id}');
//      for(var j = 0; j < this._recipis[i].tags.length; j++){
//        print('recipi_id:${this._recipis[i].tags[j].recipi_id}');
//        print('id:${this._recipis[i].tags[j].id}');
//        print('name:${this._recipis[i].tags[j].name}');
//      }
//      for(var j = 0; j < this._recipis[i].ingredients.length; j++){
//        print('recipi_id:${this._recipis[i].ingredients[j].recipi_id}');
//        print('id:${this._recipis[i].ingredients[j].id}');
//        print('name${this._recipis[i].ingredients[j].name}');
//        print('quantity:${this._recipis[i].ingredients[j].quantity}');
//      }
//    }
//    this._ingredients = [];
//    this._howTos = [];
//    this._photos = [];
//    //選択したrecipiを取得
//    setState((){
//      this._recipi = Provider.of<Detail>(context, listen: false).getRecipi();
//    });
  }

  //レシピリストエリア
  Column _onList(){
    List<Widget> column = new List<Widget>();
    //MYレシピを展開する
    for(var i=0; i < this._recipis.length; i++){
      List ingredients = [];
      String ingredientsTX = '';

      //レシピIDに紐づく材料を取得する
      for(var k = 0;k < this._recipis[i].ingredients.length;k++){
          ingredients.add(this._recipis[i].ingredients[k].name);
      }
      //配列の全要素を順に連結した文字列を作成
      ingredientsTX = ingredients.join(',');

      column.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
            child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //サムネイルエリア
                    this._recipis[i].recipi.thumbnail.isNotEmpty
                        ? SizedBox(
                      height: 100,
                      width: 100,
                      child: Container(
                        child: Image.file(File(this._recipis[i].recipi.thumbnail)),
                      ),
                    )
                        : SizedBox(
                      height: 100,
                      width: 100,
                      child: Container(
                        color: Colors.grey,
                        child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                      ),
                    ),
                    //タイトル、材料、タグエリア
                    Container(
//                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //タイトル
                          Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Text('${this._recipis[i].recipi.title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),),
                          ),
                          //材料
                          Container(
                            height: 40,
                            padding: EdgeInsets.all(5),
//                            child: Text('${ingredients.join(',')}',
                            child: Text('${ingredientsTX}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),),
                          ),
                          //タグ
                          if(this._recipis[i].tags.length > 0)
                            Container(
//                              width: MediaQuery.of(context).size.width * 0.5,
//                              color: Colors.grey,
                              height: 30,
                              padding: EdgeInsets.only(left: 5,right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //タグicon
                                  Container(
                                    child: Icon(Icons.local_offer,size: 15,color: Colors.brown,),
                                  ),
                                  //タグ名　最大5件まで
                                  for(var k = 0; k<this._recipis[i].tags.length;k++)
                                    Container(
                                      padding: EdgeInsets.all(2),
                                      child: SizedBox(
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          color: Colors.brown,

                                          child: Text('${this._recipis[i].tags[k].name}',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.white
                                            ),
                                            maxLines: 1,),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          //フォルダicon
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  print('recipiID:${this._recipis[i].recipi.id},thumbnail:${this._recipis[i].recipi.thumbnail}');
                  _onRecipiDetail(index: i);
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
    return Column(
      children: column,
    );
  }

  //レシピを選択時処理
  void _onRecipiDetail({int index}) async {
    //選択したレシピのindexをsetする
    Provider.of<Detail>(context, listen: false).setRecipi(this._recipis[index].recipi);

    //MYレシピの場合
    if(this._recipis[index].recipi.type == 2){
      //材料をセットする
      Provider.of<Detail>(context, listen: false).setIngredients(this._recipis[index].ingredients);
      //作り方を取得する
      var howTos = await dbHelper.getHowtos(this._recipis[index].recipi.id);
//      print('②${howTos.length}');
      //作り方をセットする
      setState(() {
        this._recipis[index].howto = howTos;
      });
      Provider.of<Detail>(context, listen: false).setHowTos(this._recipis[index].howto);

    //写真レシピの場合
    }else{
      //写真リストを取得する
      var photos = await dbHelper.getRecipiPhotos(this._recipis[index].recipi.id);
      print('②${photos.length}');
      setState(() {
        this._recipis[index].photos = photos;
      });
      //写真リストをセットする
      Provider.of<Detail>(context, listen: false).setPhotos(this._recipis[index].photos);
    }
    //1:レシピへ遷移
    Provider.of<Display>(context, listen: false).setCurrentIndex(1);
  }

  //ごはん日記リストへ戻るボタン押下時処理
  void _onBack(){
//    if(this._backScreen == 1) {
//      //フォルダ別一覧リストへ遷移
//      Provider.of<Display>(context, listen: false).setState(4);
//    }else if(this._backScreen == 2){
//      //2:ごはん日記へ遷移
//      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
//    }else if(this._backScreen == 3){
//      //ホーム画面へ遷移
//      Provider.of<Display>(context, listen: false).setCurrentIndex(0);
//    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
//    }
//    _init();
  }

  void _init(){
  }

  //ごはん日記の編集ボタン押下時処理
  void _onEdit(){
    //日記IDをセットする
    Provider.of<Display>(context, listen: false).setId(this._diary.id);
    //本文
    TextEditingController body  = TextEditingController();
    body.text = this._diary.body;
    Provider.of<Edit>(context, listen: false).setBody(body);
    //日付
    Provider.of<Edit>(context, listen: false).setDate(this._diary.date);
    //分類
    Provider.of<Edit>(context, listen: false).setCategory(this._diary.category);
    //サムネイル
    Provider.of<Edit>(context, listen: false).setThumbnail(this._diary.thumbnail);
    //料理
    Provider.of<Edit>(context, listen: false).setRecipis(this._diary.recipis);
    //写真
    Provider.of<Edit>(context, listen: false).setPhotos(this._diary.photos);
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(2);
  }

  //分類
  String _displayCategory(int category){
    if(category == 2){
      return '朝食';
    }
    if(category == 3){
      return '昼食';
    }
    if(category == 4){
      return '夕食';
    }
    if(category == 5){
      return '間食';
    }
  }

  //曜日
  String _displayWeekday(weekday){
    if(weekday == 1){
      return '月';
    }
    if(weekday == 2){
      return '火';
    }
    if(weekday == 3){
      return '水';
    }
    if(weekday == 4){
      return '木';
    }
    if(weekday == 5){
      return '金';
    }
    if(weekday == 6){
      return '土';
    }
    if(weekday == 7){
      return '日';
    }
  }

  //日付
  String _displayDate(String date){
    DateTime Ddate = DateTime.parse(date);
    String weekday = '${_displayWeekday(Ddate.weekday)}曜日';
    DateFormat formatter = DateFormat('yyyy年MM月dd日');
    String newDate = '${formatter.format(Ddate)} ${weekday}';
    return newDate;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: backBtn(),
        elevation: 0.0,
        title: Center(
          child: Text('日記',
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
          _onBack();
        },
    );
  }

  //レシピ詳細
  Widget scrollArea(){
    return Container(
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
               <Widget>[
                 line(),
                 dateCategoryArea(),   //日付 分類
                 thumbnailArea(),     //選択した画像
                 photosArea(),        //写真リスト
                 bodyArea(),          //本文
                 recipiArea(),
                 recipiListArea(),
//                 line(),
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

  //サムネイルエリア
  Widget thumbnailArea(){
    return
      _diary.photos.length == 0
          ? Container()
          : SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: Image.file((File(_diary.photos[_photoIndex].path))),
          ),
        );
  }

  //選択レシピリスト
  Widget photosArea(){
    return
      _diary.photos.length == 0
          ? Container()
          : Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0,vertical: 5.0),
        height: MediaQuery.of(context).size.height * 0.1,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _diary.photos.length,
            itemBuilder: (context,index){
              return InkWell(
                onTap: (){
                  setState(() {
                    _photoIndex = index;
                  });
                },
                child:Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Stack(
                      children: <Widget>[
                        Card(
//                    color: Colors.blue,
                            child:
                            index == _photoIndex
                                ? Container(
                              width: 100,
                              height: 100,
                              child: Image.file(File(_diary.photos[index].path),),
                              decoration: (
                                  BoxDecoration(
                                      border: Border.all(
                                          color: Colors.orangeAccent,
                                          width: 3.0
                                      ),
                                      borderRadius: BorderRadius.circular(4)
                                  )
                              ),
                            )
                                : Container(
                              width: 100,
                              height: 100,
                              child: Image.file(File(_diary.photos[index].path),),
                            )
                        ),
                      ],
                    )
                ),
              );
            }
        ),
      );
  }

  //本文
  Widget bodyArea(){
    return
      _diary.body.isEmpty
      ? Container()
      : SizedBox(
//      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${_diary.body}',
//                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
              ),
            ],
          ),
      ),
    );
  }

  //日付、カテゴリエリア
  Widget dateCategoryArea(){
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
              child: Text('${_displayDate(_diary.date)}', style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child:
              _diary.category == 1
                ? Container()
                : Text('${_displayCategory(_diary.category)}', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
            ),
          ],
        ),
      ),
    );
  }

  //レシピタイトル
  Widget recipiArea(){
    return
    _diary.recipis.length == 0
      ? Container()
      : Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width,
          child: Container(
              color: Colors.white30,
              padding: EdgeInsets.all(15),
              child: Text('レシピ', style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
              ),),
          ),
        ),
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      ],
    );
  }

  //レシピリスト
  Widget recipiListArea(){
    return Container(
      child: _onList(),
    );
  }
}