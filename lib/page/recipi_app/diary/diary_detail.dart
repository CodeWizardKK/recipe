import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:image_pickers/image_pickers.dart';

import 'package:recipe_app/page/recipi_app/diary/diary_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_edit.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';

class DiaryDetail extends StatefulWidget{

  DisplayDiary diary = DisplayDiary();
  DPhoto selectedPhoto = DPhoto();

  DiaryDetail({Key key, @required this.diary, @required this.selectedPhoto}) : super(key: key);

  @override
  _DiaryDetailState createState() => _DiaryDetailState();
}

class _DiaryDetailState extends State<DiaryDetail>{

  DBHelper dbHelper;
  Common common;
  DisplayDiary _diary = DisplayDiary();    //選択したごはん日記
  List<Recipi> _recipis = List<Recipi>();  //選択したごはん日記に紐づくレシピリストを格納
  int _photoIndex = 0;                     //サムネイルで表示する写真のindexを格納
  int _current = 0;

  final int increment = 10;                   //読み込み件数
  static GlobalKey previewContainer = GlobalKey();
  bool _isUpdate = false;
  List<Media> _listImagePaths = List();

  @override
  void initState() {
    init();
   super.initState();
  }

  void init() async {
    await this._getItem();
  }


  _getItem() async {
    dbHelper = DBHelper();
    common = Common();
    setState(() {
      //選択した日記の取得
      this._diary = widget.diary;
      //アルバムから遷移してきた場合、tapした画像を選択状態にセット
      if(widget.selectedPhoto.id != -1){
       DPhoto photo = widget.selectedPhoto;
       for(var i = 0; i < this._diary.photos.length; i++){
         if(this._diary.photos[i].no == photo.no && this._diary.photos[i].path == photo.path ){
           this._photoIndex = i;
           this._current = i;
         }
       }
      }
    });

    //previewImagesByMedia用にセット
    this._listImagePaths.clear();
    this._diary.photos.forEach((photo) {
      Media media = Media();
      media.path = photo.path;
      setState(() {
        this._listImagePaths.add(media);
      });
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
      Recipi recipi = Recipi(recipi: myrecipi,tags: tags,ingredients: ingredients,howto: [],photos: []);
      setState(() {
        this._recipis.add(recipi);
      });
    }
    print('ごはん日記に紐づくレシピ件数：${this._recipis.length}');
  }

  //レシピを選択時処理
  void _onRecipiDetail({int index}) async {
    //MYレシピの場合
    if(this._recipis[index].recipi.type == 2){
      //作り方を取得する
      List<HowTo> howTos = await dbHelper.getHowtos(this._recipis[index].recipi.id);
      //作り方をセットする
      setState(() {
        this._recipis[index].howto = howTos;
      });
    //写真レシピ、スキャンレシピの場合
    }else{
      //写真リストを取得する
      List<Photo> photos = await dbHelper.getRecipiPhotos(this._recipis[index].recipi.id);
      setState(() {
        this._recipis[index].photos = photos;
      });
    }
    //レシピの詳細画面遷移処理の呼び出し
    this._showDetail(recipi: this._recipis[index].recipi, ingredients: this._recipis[index].ingredients,howTos: this._recipis[index].howto,photos: this._recipis[index].photos);
  }

  //レシピの詳細画面へ遷移
  void _showDetail({ Myrecipi recipi, List<Ingredient> ingredients, List<HowTo> howTos, List<Photo> photos }){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiEdit(Nrecipi: recipi,Ningredients: ingredients,NhowTos: howTos,Nphotos: photos,),
          fullscreenDialog: true,
        )
    ).then((result) {
      //最新のリストを取得し展開する
      this._getItem();
    });
  }

  //ごはん日記リストへ戻るボタン押下時処理
  void _onBack(){
    if(this._isUpdate){
      Navigator.pop(context,'update');
    } else {
      Navigator.pop(context);

    }
  }

  //ごはん日記の編集ボタン押下時処理
  void _onEdit(){
    this._showEdit(diary: this._diary);
  }

  void _showEdit({DisplayDiary diary}){
    //編集画面へ遷移
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => DiaryEdit(diary: diary,),
          fullscreenDialog: true,
        )
    ).then((result) {
      if(result == 'delete'){
        Navigator.pop(context,result);
      } else if(result == 'updateClose'){
      } else {
        setState(() {
          this._isUpdate = true;
          widget.diary = result;
        });
        //最新のリストを取得し展開する
        this._getItem();
      }
    });
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
    return
      RepaintBoundary(
      key: previewContainer,
      child:
      Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange[100 * (1 % 9)],
          leading: backBtn(),
          elevation: 0.0,
          title: Center(
            child: Text('日記',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
//                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          actions: <Widget>[
            shareBtn(),
            editBtn(),
          ],
        ),
        body: scrollArea()
      ),
    );
  }

  //シェアボタン
  Widget shareBtn() {
    return FittedBox(fit:BoxFit.fitWidth,
      child:IconButton(
        icon: const Icon(Icons.share, color: Colors.white),
        onPressed: () {
          common.takeWidgetScreenShot(previewContainer);
        },
      ),
    );
  }

  //編集ボタン
  Widget editBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child:IconButton(
        icon: const Icon(Icons.edit,color: Colors.white),
        onPressed: (){
          _onEdit();
        },
      ),
    );
  }

  //戻るボタン
  Widget backBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child:IconButton(
        icon: const Icon(Icons.arrow_back_ios,color: Colors.white),
        onPressed: (){
          _onBack();
        },
      ),
    );
  }

  //レシピ詳細
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
      alignment: Alignment.center,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
             dateCategoryArea(),   //日付 分類
             imageArea(),          //写真
             bodyArea(),          //本文
             recipiArea(),        //レシピ
             recipiListArea(),    //レシピリスト
          ]
      ),
    );
  }

  //写真エリア
  Widget imageArea(){
    return
      _diary.photos.length == 0
      ? Container()
      : _diary.photos.length == 1
        ? Container(
          margin: EdgeInsets.all(10.0),
            child : SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: InkWell(
                  child: Image.file(File(_diary.photos[0].path),fit: BoxFit.cover),
                  onTap: (){
                    ImagePickers.previewImage(_diary.photos[0].path);
                  }
                ),
              ),
            )
          )
        : Container(
          child: Column(
            children: [
              CarouselSlider(
                items: _diary.photos.map((item) => GestureDetector(
                  onTap: (){
                    ImagePickers.previewImagesByMedia(_listImagePaths,item.no - 1);
                  },
                  child: Container(
                    margin: EdgeInsets.all(10.0),
                    child:
                      ClipRRect(
//                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        child:
                          Stack(
                          children: <Widget>[
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.40,
                              child: Image.file(File(item.path),fit: BoxFit.cover,width: 400),
                            )
                          ],
                        )
                    ),
                  ),
                )).toList(),
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height * 0.40,
                  initialPage: _photoIndex,
//                  scrollDirection: Axis.horizontal,
//                    autoPlay: true,
//                    enlargeCenterPage: true,
                  aspectRatio: 2.0,
                  onPageChanged: (index, reason) {
                    print(inspect(this));
                    setState(() {
                      this._current = index;
                    });
                  }
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _diary.photos.map((photo) {
                  int no = _diary.photos.indexOf(photo);
                  print('index②:${no}');
                  return Container(
                    width: MediaQuery.of(context).size.width * 0.015,
                    height: MediaQuery.of(context).size.width * 0.015,
                    margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: this._current == no
                          ? Color.fromRGBO(0, 0, 0, 0.9)
                          : Color.fromRGBO(0, 0, 0, 0.4),
                    ),
                  );
                }).toList(),
              ),
            ]
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
        color: Colors.deepOrange[100 * (2 % 9)],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10,right: 10),
              child: FittedBox(fit:BoxFit.fitWidth,
                child: Text('${_displayDate(_diary.date)}', style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
  //                  fontWeight: FontWeight.bold
                ),),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10,right: 10),
              child:
              _diary.category == 1
                ? Container()
                : FittedBox(fit:BoxFit.fitWidth,
                    child: Text('${_displayCategory(_diary.category)}', style: TextStyle(
                      color: Colors.white,
                        fontSize: 15,
//                    fontWeight: FontWeight.bold
                    ),),
                  ),
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
      : SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('レシピ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  }

  //レシピリスト
  Widget recipiListArea(){
    return
      _diary.recipis.length == 0
        ? Container()
        : Column(
          children: [
            for(var i = 0; i < _recipis.length; i++)
              createRecipi(i)
          ],
        );
  }

    //レシピリストの生成
  Widget createRecipi(int index){

      List ingredients = [];
      String ingredientsTX = '';

      //レシピIDに紐づく材料が存在した場合
      if(this._recipis[index].ingredients.length > 0){
        //nameのみ取得し配列を生成
        this._recipis[index].ingredients.forEach((ingredient) => ingredients.add(ingredient.name));
        //上記の配列の全要素を順に連結した文字列を作成
        ingredientsTX = ingredients.join(',');
      }

      return
        SizedBox(
          width: MediaQuery.of(context).size.width,
//          height: MediaQuery.of(context).size.height * 0.16,
          child: Container(
            color: Colors.white,
//            padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
            padding: EdgeInsets.all(5),
            child: InkWell(
              child: FittedBox(fit:BoxFit.fitWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //サムネイルエリア
                    this._recipis[index].recipi.thumbnail.isNotEmpty
                        ? SizedBox(
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                        child: Image.file(File(this._recipis[index].recipi.thumbnail),fit: BoxFit.cover,),
                      ),
                    )
                        : SizedBox(
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                        color: Colors.amber[100 * (1 % 9)],
                        child: Icon(Icons.restaurant,color: Colors.white,size: 50,),
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
//                            height: MediaQuery.of(context).size.height * 0.045,
                            padding: EdgeInsets.all(5),
                            child: Text('${this._recipis[index].recipi.title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),),
                          ),
                          //材料
                          Container(
//                            height: MediaQuery.of(context).size.height * 0.04,
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
                          if(this._recipis[index].tags.length > 0)
                            Container(
//                              width: MediaQuery.of(context).size.width * 0.5,
//                              color: Colors.grey,
                              height: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 0.08 : MediaQuery.of(context).size.height * 0.06,
                              padding: EdgeInsets.only(left: 5,right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //タグicon
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.03,
                                    child: Icon(Icons.local_offer,color: Colors.yellow[100 * (1 % 9)]),
                                  ),
                                  Container(
//                                    color: Colors.brown,
                                    width: MediaQuery.of(context).size.width * 0.64,
                                    child: MultiSelectChipDisplay(
                                      chipColor: Colors.yellow,
                                      onTap: null,
                                      items: this._recipis[index].tags
                                          .map((e) => MultiSelectItem<Tag>(e, e.name))
                                          .toList(),
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
                ),
                onTap: (){
                  print('recipiID:${this._recipis[index].recipi.id},thumbnail:${this._recipis[index].recipi.thumbnail}');
                  _onRecipiDetail(index: index);
                }
            ),
          ),
      );
  }
}




