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
  final String _title = 'アプリについて';            //表示するタイトル


  @override
  void initState() {
    super.initState();
    setState(() {
      //初期化
      this.dbHelper = DBHelper();
      this.common = Common();
    });
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

  //左上ボタン
  Widget leading(){
    return Container();
  }

  //閉じるボタン
  Widget closeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: FittedBox(fit:BoxFit.fitWidth,
            child: Text('閉じる',
              style: TextStyle(
                color: Colors.deepOrange[100 * (1 % 9)],
                fontSize: 15,
              ),
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
    return Container();
  }
}