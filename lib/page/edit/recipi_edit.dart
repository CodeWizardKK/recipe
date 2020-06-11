import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';

class RecipiEdit extends StatefulWidget{

  @override
  _RecipiEditState createState() => _RecipiEditState();
}

class _RecipiEditState extends State<RecipiEdit>{

  final _formKey = new GlobalKey<FormState>();

  var images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];

  String _title;
  String _body;

  @override
  void initState() {
    super.initState();
    //一覧情報取得処理の呼び出し
    var id = Provider.of<Display>(context, listen: false).getId();
    print('id:${id}');
  }

  void onList(){
    Provider.of<Display>(context, listen: false).setState(0);
  }

  void onCamera(){
    Provider.of<Display>(context, listen: false).setState(2);
  }

  //入力チェック
  bool validateAndSave() {
    //formが有効かどうかを確認
    if (_formKey.currentState.validate()) {
      //true => エラーなし
      _formKey.currentState.save(); //onSaved 関数が呼ばれる
      return true;
    }
    return false;
  }

  //保存する押下時処理
  void validateAndSubmit() async {
    //入力チェックでエラーにならなかった場合
    if (validateAndSave()) {
      //エラーとならなかった場合
      Provider.of<Display>(context, listen: false).setState(0);
      print('タイトル：${_title}');
      print('内容：${_body}');
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.grey,
              ),
              onPressed: () {
                onList();
              },
            ),
            Text('レシピリスト',
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15
              ),
            ),
          ],
        )
      ),
      body: showForm(),
    );
  }

  Widget showForm(){
    return Container(
//        padding: EdgeInsets.all(16.0),
        //入力フィールドをformでグループ化し、key:_formKey(グローバルキー)と
        child: Form(
          key: _formKey,
//          child: Center(
            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageArea(),
                textArea(),
                saveButton(),
              ],
            ),
//          ),
        ),
    );
  }

  Widget imageArea(){
    return Container(
      padding: EdgeInsets.all(20),
      child:Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for(var image in images)
          SizedBox(
            child:
            image['path'] == ''
                ? InkWell(child: Card(color: Colors.white,child:Icon(Icons.camera_alt,)),
                          onTap: (){
                            print('cameraiconClick!!');
                            onCamera();
                          },
            )
                : InkWell(child: Image.network(image['path']),
                          onTap: (){
                            print('imageClick!!');
                          },
            ) ,
            width: 64.0,
            height: 64.0,
          ),
      ],
    ),
    );
  }

  Widget textArea(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(right: 250),
          child: Text('レシピ詳細',
            style: TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.bold

            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child:
          TextFormField(
//            initialValue: UserStore.address,
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide()),
                labelText: 'タイトル'
            ),
            //入力チェックとなる条件、メッセージを定義
            validator: (value) => value.isEmpty ? 'タイトルを入力してください' : null,
            //_formKey.currentState.save()で呼ばれる
            onSaved: (value) => _title = value.trim(),
          ),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child:
          TextFormField(
//            initialValue: UserStore.address,
            minLines: 10,
            maxLines: 20,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: InputDecoration(
                border: OutlineInputBorder(borderSide: BorderSide()),
                labelText: '内容'
            ),
            //入力チェックとなる条件、メッセージを定義
            validator: (value) => value.isEmpty ? '内容を入力してください' : null,
            //_formKey.currentState.save()で呼ばれる
            onSaved: (value) => _body = value.trim(),
          ),
        ),
      ],
    );
  }

  Widget saveButton() {
    return
      Container(
        padding: EdgeInsets.all(10),
        child:
        SizedBox(
          width: 100,
          height: 50,
          child: RaisedButton(
            child: Text('保存する',style: TextStyle(color: Colors.white),),
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: validateAndSubmit,
          ),
        ),
      );
  }
}