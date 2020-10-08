import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';

class About extends StatefulWidget{

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About>{

  DBHelper dbHelper;
  Common common;
  String _title = 'アプリについて';            //表示するタイトル


  @override
  void initState() {
    super.initState();
  }

  //一覧リストへ遷移
  void _onClose(){
      Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        leading: leading(),
        elevation: 0.0,
        title: Center(
          child: Text('${_title}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          closeBtn(),
          ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: scrollArea(),),
        ],
      ),
    );
  }

  //閉じるボタン
  Widget leading(){
    return Container();
  }

  //完了ボタン
  Widget closeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: Text('閉じる',
            style: TextStyle(
              color: Colors.deepOrange[100 * (1 % 9)],
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _onClose();
          },
        ),
      ),
    );
  }

  //レシピ編集
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
//      alignment: Alignment.center,
//      child: Column(
//        crossAxisAlignment: CrossAxisAlignment.center,
//        children:
//          _sortType == 1 || _sortType == 3
//          ? <Widget>[
//            //フォルダ整理
//            folderListArea(), //フォルダリストエリア
//          ]
//          : _sortType == 2 || _sortType == 4
//            ? <Widget>[
//            //タグ整理
//              tagListArea(), //タグリストエリア
//            ]
//            : <Widget>[
//              //全て
//              recipiArea(), //選択レシピ表示エリア
//              headerArea(type: 1), //フォルダに移動
//              folderListArea(), //フォルダリストエリア
//              headerArea(type: 2), //タグをつける
//              tagListArea(), //タグリストエリア
//            ]
//      ),
    );
  }
}