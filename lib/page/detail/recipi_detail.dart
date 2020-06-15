import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';

class RecipiDetail extends StatefulWidget{
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{


  //レシピリストへ戻るボタン押下時処理
  void onList(){
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //削除処理
  void onDelete(){
   //該当レコード削除処理(IDをpushする)

   //レシピリストへ戻る
   this.onList();
  }

  //レシピの編集ボタン押下時処理
  void onEdit(){
//    print('selectId[${id}]');
//    //idをset
//    Provider.of<Display>(context, listen: false).setId(id);
//    //新規投稿以外の場合
//    if(id != -1){
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(2);
//    }else{
      //編集画面へ遷移
      Provider.of<Display>(context, listen: false).setState(1);
//    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('削除してもよろしいですか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title:FlatButton(
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_back_ios,color: Colors.grey,),
                Text('レシピリスト',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
              ],
            ),
            onPressed: (){
              onList();
            },
          ),
      ),
      //フッター
      persistentFooterButtons: <Widget>[
        //削除アイコン
        Padding(
          padding: EdgeInsets.only(right: 150),
          child: IconButton(icon:Icon(Icons.delete,size: 30,),
            onPressed: (){
              _showDeleteDialog();
            },),
        ),
        //レシピを編集ボタン
        Padding(
          padding: EdgeInsets.only(right: 10),
          child:
          FlatButton(
            color: Colors.redAccent,
            child: Text('レシピの編集',
              style: TextStyle(color: Colors.white),),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: (){
              onEdit();
            },
          )
        ),],
      body:
//      Center(
//        child:
      ScrollArea(),
//      ),
    );
  }

  Widget showDetail(){
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ScrollArea(),
        footerArea(),
      ],
    );
  }

  Widget ScrollArea(){
    return Container(
      child:SingleChildScrollView(
        child:Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            imageArea(),
            titleArea(),
            line(),
            ContentArea(),
          ],
        ),
        ),
      ),
    );
  }

  Widget footerArea(){
    return Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Icon(Icons.camera_alt)
          ],
        ),
      ),
    );
  }

  Widget imageArea(){
    return SizedBox(
//      child: Image.network('https://s3.amazonaws.com/uifaces/faces/twitter/follettkyle/128.jpg'),
      child: Card(color: Colors.grey),
      height: 400,
      width: 350,
    );
  }

  Widget titleArea(){
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: Text('鹿ラグーとバターとゴマのパスタパスタ',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue
        ),
      ),
    );
  }

  Widget ContentArea(){
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          child: Text('レシピmemo',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          child:Text('テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。')
        ),
      ],
    );
  }

  Widget line(){
    return Divider(
        color: Colors.grey
    );
  }
}