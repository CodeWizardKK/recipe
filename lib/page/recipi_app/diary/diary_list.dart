import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/store/detail_state.dart';

class DiaryList extends StatefulWidget {

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList>{

  Future<File> imageFile;
  List<Myrecipi> _recipis;                    //DBから取得したレコードを格納
  DBHelper dbHelper;
//  List<Photo> images; //DBから取得したレコードを格納

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    _recipis = [];
    dbHelper = DBHelper();
    //レコードリフレッシュ
    refreshImages();
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {
    //レシピの取得
    await dbHelper.getMyRecipis().then((item){
      setState(() {
        _recipis.clear();
        _recipis.addAll(item);
      });
    });
    //取得したレシピをstoreに保存
    Provider.of<Display>(context, listen: false).setRecipis(_recipis);
  }

  //ナビゲーションバー
  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
  }

  //編集処理
  void _onEdit(int selectedId,BuildContext context){
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    if(selectedId == -1){
      Provider.of<Edit>(context, listen: false).setDate(DateTime.now());
    }
//    //新規投稿以外の場合
//    if(id != -1){
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(2);
//    }else{
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(2);
//    }
  }

  //MYレシピエリア
  Column _onList(){
    List<Widget> column = new List<Widget>();
    //MYレシピを展開する
    for(var i=0; i < this._recipis.length; i++){
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
                    this._recipis[i].thumbnail.isNotEmpty
                        ? SizedBox(
                      height: 100,
                      width: 100,
                      child: Container(
                        child: Image.file(File(this._recipis[i].thumbnail)),
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
                    //タイトル
                    Container(
//                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Text('${this._recipis[i].title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15,
//                                  fontWeight: FontWeight.bold
                              ),),
                          ),
                    ),
                    //日付エリア
                    Container(
//                      color: Colors.orangeAccent,
                      width: MediaQuery.of(context).size.width * 0.2,
                      padding: EdgeInsets.only(top: 10,bottom: 10,left: 5,right: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(
//                              width: MediaQuery.of(context).size.width * 0.15,
                                height: 25,
                                child: Container(
//                          color: Colors.greenAccent,
//                                  padding: EdgeInsets.all(5),
                                  child: Text('11',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold
                                    ),),
                                ),
                              ),
                              SizedBox(
//                              width: MediaQuery.of(context).size.width * 0.15,
                                height: 25,
                                child: Container(
//                          color: Colors.orangeAccent,
                                  padding: EdgeInsets.only(top: 7,right: 5,left: 5),
                                  child: Text('火',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
//                          width: MediaQuery.of(context).size.width * 0.15,
                            height: 30,
                            child: Container(
//                          color: Colors.blue,
                              padding: EdgeInsets.all(5),
                              child:
                              Icon(Icons.wb_sunny,color: Colors.grey,size: 25,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  _onDetail(index: i);
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
  void _onDetail({int index}) async {
    //選択したレシピのindexをsetする
    Provider.of<Detail>(context, listen: false).setRecipi(this._recipis[index]);

    if(this._recipis[index].type == 2){
      var ingredients = await dbHelper.getIngredients(this._recipis[index].id);
      print('①${ingredients.length}');
      Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
      var howTos = await dbHelper.getHowtos(this._recipis[index].id);
      print('②${howTos.length}');
      Provider.of<Detail>(context, listen: false).setHowTos(howTos);
    }else{
      var photos = await dbHelper.getPhotos(this._recipis[index].id);
      Provider.of<Detail>(context, listen: false).setPhotos(photos);
    }
    //2:詳細画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: menuBtn(),
        elevation: 0.0,
        title: Center(
          child: const Text('レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          addBtn(context),
        ],
      ),
      body:scrollArea(),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }

  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: showList(),
                  ),
                ),
              ]
          )
      ),
    );
  }

  //リストページ全体
  Widget showList(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          line(),
          myrecipiArea(), //MYレシピ
          line(),
          myrecipiListArea(), //MYレシピリスト
        ],
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

  //MYレシピ
  Widget myrecipiArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
          return
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.white30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('2020年8月', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ],
                ),
              ),
            );
        }
    );
  }

  //MYレシピリスト
  Widget myrecipiListArea(){
    return Container(
      child: _onList(),
    );
  }

  Widget menuBtn(){
    return IconButton(
      icon: const Icon(Icons.list,color: Colors.white,size:30,),
      onPressed: (){
//        _onList();
      },
    );
  }

  Widget addBtn(BuildContext context){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onEdit(-1,context);
      },
    );
  }

  Widget bottomNavigationBar(BuildContext context){
    return Consumer<Display>(
        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
//      backgroundColor: Colors.redAccent,
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black26,
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                title: const Text('ホーム'),
//          backgroundColor: Colors.redAccent,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts),
                title: const Text('レシピ'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.date_range),
                title: const Text('ごはん日記'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: const Text('アルバム'),
//          backgroundColor: Colors.blue,
              ),
            ],
            onTap: (index){
              _changeBottomNavigation(index,context);
            },
          );
        }
    );
  }
}