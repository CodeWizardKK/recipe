import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_edit.dart';
import 'package:recipe_app/page/recipi_app/navigation/about.dart';

import 'package:recipe_app/page/recipi_app/recipi/recipi_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_sort.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/updater.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/services/Common.dart';

class HomeList extends StatefulWidget{

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList>{

  Common common;
  final List _type = [
    {
      'title':'写真レシピ',
      'image' :''
    },{
      'title':'MYレシピ',
      'image' :''
    },{
      'title':'スキャンレシピ',
      'image' :''
    },{
      'title':'ごはん日記',
      'image' :''
    }
  ];

  @override
  void initState() {
    super.initState();
    common = Common();
  }

  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
//    //一覧リストへ遷移
//    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit({int selectedId,int type}){
    //編集画面へ遷移
    print('selectId[${selectedId}]');
    //ごはん日記
    if(type == 4){
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      DisplayDiary diary = DisplayDiary(
          id: selectedId
          ,body: ''
          ,date: dateString
          ,category: 1
          ,thumbnail: 1
          ,photos: []
          ,recipis: []
      );
      //編集画面へ遷移
      Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => DiaryEdit(diary: diary),
            fullscreenDialog: true,
          )
      ).then((result) {
      });
     //レシピ
    }else{
      //選択したレシピのindexをsetする
      Myrecipi recipi = Myrecipi
        (
          id: selectedId
          , type: type
          , thumbnail: ''
          , title: ''
          , description: ''
          , quantity: 1
          , unit: 1
          , time: 0
      );
      //編集画面へ遷移
      Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => RecipiEdit(Nrecipi: recipi, Ningredients: [], NhowTos: [], Nphotos: []),
            fullscreenDialog: true,
          )
      ).then((result) {
      });
    }
  }

  //レシピリストのフォルダアイコンtap時処理
  void _onFolderTap({int type}){
    String title = '';
    // 3:フォルダの管理(menu)
    if(type == 3){
      //タイトルセット
      title = 'フォルダの管理';
    }else{
    // 4:タグの管理(menu)
      //タイトルセット
      title = 'タグの管理';
    }
    this._showSort(title: title, type: type);
  }

  //レシピの整理画面へ遷移
  void _showSort({ String title, int type}){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiSort(sortType: type,title: title ),
          fullscreenDialog: true,
        )
    ).then((result) {
    });
  }

  //レシピの整理画面へ遷移
  void _showAbout(){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => About(),
          fullscreenDialog: true,
        )
    ).then((result) {
      print('閉じる');
    });
  }

  //URLのシェア
  void _onShareSave() async {
    //シェア機能の呼び出し
    await common.takeURLScreenShot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        elevation: 0.0,
        title: Center(
          child: const Text('レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          checkBtn(),
          addBtn(),
        ],
      ),
      body: Stack(
        children: <Widget>[
          buildGridView(),
          updater(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(context),
    );
  }

  //リスト
  Widget buildGridView(){
//    return Container();
    return GridView.count(
      crossAxisCount:2,
      crossAxisSpacing: 5.0,
      mainAxisSpacing: 5.0,
      shrinkWrap: true,
      children: List.generate(_type.length, (index){
        return Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
//                  Icon(Icons.camera_alt,color: Colors.white, size: 70),
//                  SizedBox(width: 10,),
                  Column(
//                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('${_type[index]['title']}',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),),
//                      SizedBox(width: 5,),
                      Text('を追加',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20
                        ),),
                    ],
                  ),
                ],
              ),
              onTap:(){
                _onEdit(selectedId:-1,type: index + 1);
              }
          ),
        );
      }),
    );
  }

  //ドロワーナビゲーション
  Widget drawerNavigation(){
    return Consumer<Display>(
        builder: (context,Display,_) {
      return Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              color: Colors.deepOrange[100 * (1 % 9)],
              child: ListTile(
                title: Center(
                  child: Text('設定',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
//              subtitle: Text(''),
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.folder_open, color: Colors.deepOrange[100 * (1 % 9)],),
                title: Text('フォルダの管理',
                  style: TextStyle(
//                fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () {
                  _onFolderTap(type: 3);
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
                title: Text('タグの管理',
                  style: TextStyle(
//                  fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () {
                  _onFolderTap(type: 4);
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
                title: Text('アプリを友達に紹介',
                  style: TextStyle(
//                  fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () {
                  _onShareSave();
                },
              ),
            ),
            Container(
              color: Colors.white,
              child: ListTile(
                leading: Icon(
                  Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
                title: Text('アプリについて',
                  style: TextStyle(
//                  fontWeight: FontWeight.bold
                  ),
                ),
                onTap: () {
                  _showAbout();
                },
              ),
            ),
            Container(
//            color: Colors.deepOrange[100 * (1 % 9)],
              child: ListTile(
                title: Center(
                  child: Text('version${Display.appCurrentVersion}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    );
  }

  Widget checkBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.check_circle_outline),
        onPressed: null,
        disabledColor: Colors.deepOrange[100 * (1 % 9)],
      ),
    );
  }

  Widget addBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        onPressed: null,
        disabledColor: Colors.deepOrange[100 * (1 % 9)],
      ),
    );
  }

  Widget bottomNavigationBar(BuildContext context){
    return Consumer<Display>(
//        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.deepOrange[100 * (2 % 9)],
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
                icon: Icon(Icons.folder_open),
                title: const Text('フォルダ別'),
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