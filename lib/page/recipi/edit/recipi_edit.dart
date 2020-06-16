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

  String _title;
  String _body;
  int _selectedID;

  @override
  void initState() {
    super.initState();
    //idを取得
    _selectedID = Provider.of<Display>(context, listen: false).getId();
    print('id:${_selectedID}');
    //更新の場合
    if(_selectedID != -1){
      // http.getにて該当レコードの詳細を取得
      print('http.getする!!!');
    }
  }

  //レシピリストへ戻るボタン押下時処理
  void onList(){
    Provider.of<Display>(context, listen: false).setState(0);
    //画像情報リセット
    Provider.of<Display>(context, listen: false).resetImages();
    Provider.of<Display>(context, listen: false).resetSelectImage();

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

  //画像一覧にて表示されている画像アイコンの押下時処理
  void clickImage(image){
    var selectNo = image['no'];
    var selectIndex = selectNo -1;
    var selecedImage = image;
    var imageTap = true;
    Provider.of<Display>(context, listen: false).setSelectImage(selectIndex, selecedImage, imageTap);
    Provider.of<Display>(context, listen: false).setCamera();
  }

  //画像一覧にて表示されているカメラアイコンの押下時処理
  void onCamera(){
    //clickImage時に取得していた選択した画像情報をreset
    Provider.of<Display>(context, listen: false).resetSelectImage();
    //カメラ起動
    Provider.of<Display>(context, listen: false).setCamera();
  }

  //レシピリストへ戻るボタン押下時のダイアログ
  Future<void> _showBackDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('内容が保存されていませんが、よろしいですか？'),
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
                onList();
              },
            ),
          ],
        );
      },
    );
  }

  //内容が更新されたかチェック => true:変更なし false:変更あり
  bool _formCheck() {
    return Provider.of<Display>(context, listen: false).checkImages();
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
            _formCheck()
                ? onList()
                : _showBackDialog();
          },
        ),
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

  //画像
  Widget imageArea(){
    return Consumer<Display>(
        builder: (context,Display,_){
          return Container(
            padding: EdgeInsets.all(20),
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for(var image in Display.images)
                  SizedBox(
                    child:
                    image['path'] == ''
                        ? InkWell(child: Card(color: Colors.white,child:Icon(Icons.camera_alt,)),
                      onTap: (){
                        onCamera();
                      },
                    )
                        : InkWell(child: Image.file(File(image['path'])),
                      onTap: (){
                        clickImage(image);
                      },
                    ) ,
                    width: 64.0,
                    height: 64.0,
                  ),
              ],
            ),
          );
        }
    );
  }

  //タイトル・内容
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

  //保存するボタン
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