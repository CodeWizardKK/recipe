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

  final _formKey = new GlobalKey<FormState>(); //入力form
  String _title;                //入力値 タイトル
  String _body;                 //入力値　内容
  int _selectedID;              //編集するID
//  bool _isLoading = true;    //通信中:true(円形のグルグルのやつ)

  @override
  void initState() {
    super.initState();
    //idを取得
    _selectedID = Provider.of<Display>(context, listen: false).getId();
    print('ID:${_selectedID}');
    //新規投稿の場合
    if(_selectedID == -1){
      print('新規投稿');
      return;
    }
    print('更新');
    // http.getにて該当レコードの詳細を取得
//    setState(() {
//      _isLoading = false;
//    });
  }

  //閉じるボタン押下 => ダイアロクのOKボタン押下時処理
  void _onList(){
    var state = _getBackState();
    Provider.of<Display>(context, listen: false).setState(state);
    //初期化
    _init();
  }

  void _init(){
    //画像情報リセット
    Provider.of<Display>(context, listen: false).resetImages();
    Provider.of<Display>(context, listen: false).resetSelectImage();
  }

  //戻り先の状態を取得
  int _getBackState(){
    //新規投稿の場合
    if(_selectedID == -1){
      return -2;
    //更新の場合
    }else{
      return -1;
    }
  }

  //入力チェック
  bool _validateAndSave() {
    //formが有効かどうかを確認
    if (_formKey.currentState.validate()) {
      //true => エラーなし
      _formKey.currentState.save(); //onSaved 関数が呼ばれる
      return true;
    }
    return false;
  }

  //保存する押下時処理
  void _validateAndSubmit() async {
    //入力チェックでエラーにならなかった場合
    if (_validateAndSave()) {
      //エラーとならなかった場合
      var state = _getBackState();
      Provider.of<Display>(context, listen: false).setState(state);
      print('タイトル：${_title}');
      print('内容：${_body}');
      //初期化
      _init();
    }
  }

  //画像一覧にて表示されている画像アイコンの押下時処理
  void _clickImage(int index,Map<String,dynamic> item){
    var selected = new Map<String,dynamic>();
    selected['index'] = index;
    selected['item'] = item;
    selected['tap'] = true;

    Provider.of<Display>(context, listen: false).setSelectImage(selected['index'], selected['item'], selected['tap']);
    Provider.of<Display>(context, listen: false).setCamera();
  }

  //画像一覧にて表示されているカメラアイコンの押下時処理
  void _onCamera(){
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
                _onList();
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

  //画像エリアを生成し、返す
  SizedBox _createImageAria(){
    var images = Provider.of<Display>(context, listen: false).getImages();
    var imagePath;
    return SizedBox(
      height: 64.0,
      child: ListView.builder(
        itemCount: images == null ? 0 :images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, int index) {
          imagePath = images[index]['path'];
          //新規投稿の場合
          if(imagePath.isEmpty){
            return Container(
              width: 64.0,
//            color: Colors.grey[300],
              child:InkWell(
                child: Card(
                  color: Colors.white,
                  child: Icon(Icons.camera_alt),
                ),
                onTap: (){
                  _onCamera();
                },
              ),
            );
          //事前読み込み画像ありの場合
          }else if(imagePath.startsWith('http')){
            return Container(
              width: 64.0,
              child:InkWell(
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      image:DecorationImage(
                        fit:BoxFit.cover,
                        image:NetworkImage('${imagePath}'),
                      ),
                    ),
                  ),
                ),
                onTap: (){
                  _clickImage(index,images[index]);
                },
              ),
            );
        //事前読み込みなしアップロード画像ありの場合
          }else{
            return Container(
              width: 64.0,
              child:InkWell(
                child: Card(
                  child: Image.file(File(imagePath)),
                ),
                onTap: (){
                  _clickImage(index,images[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: closeBtn(),
        elevation: 0.0,
//        title:backBtn(),
      ),
      body: showEdit(),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return IconButton(
      icon: Icon(Icons.close,color: Colors.grey,size: 35,),
      onPressed: (){
        _formCheck()
            ? _onList()
            : _showBackDialog();
      },
    );
  }

  //ページ全体
  Widget showEdit(){
    return Stack(
      children: <Widget>[
        scrollArea(),            //レシピ編集全体
//        showCircularProgress(),  //アクティビティインジケータ
      ],
    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
        return Container(
          //入力フィールドをformでグループ化し、key:_formKey(グローバルキー)と
          child: Form(
            key: _formKey,
//          child: Center(
            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageArea(), //画像
                textArea(),  //テキスト入力欄
                saveButton(),//保存ボタン
              ],
            ),
//          ),
          ),
        );
  }

  //画像
  Widget imageArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
          return Container(
            padding: EdgeInsets.only(left:20,top: 20,right: 20,bottom: 40),
            child:_createImageAria(),
          );
//        }
//    );
  }

  //タイトル・内容
  Widget textArea(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        detail(),    //レシピ詳細
        titleArea(), //タイトル
        bodyArea(),  //内容
      ],
    );
  }

  //レシピ詳細
  Widget detail(){
    return Container(
        padding: EdgeInsets.only(right: 250),
        child: Text('レシピ詳細',
          style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.bold
          ),
        ),
      );
  }

  //タイトル
  Widget titleArea(){
    return Container(
      padding: EdgeInsets.all(5),
      child: TextFormField(
//            initialValue: UserStore.address,
        maxLines: 1,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide()),
            labelText: 'タイトル(必須)'
        ),
        //入力チェックとなる条件、メッセージを定義
        validator: (value) => value.isEmpty ? 'タイトルを入力してください' : null,
        //_formKey.currentState.save()で呼ばれる
        onSaved: (value) => _title = value.trim(),
      ),
    );
  }

  //内容
  Widget bodyArea(){
    return Container(
      padding: EdgeInsets.all(5),
      child: TextFormField(
//            initialValue: UserStore.address,
        minLines: 18,
        maxLines: 50,
        keyboardType: TextInputType.text,
        autofocus: false,
        decoration: InputDecoration(
            border: OutlineInputBorder(borderSide: BorderSide()),
            labelText: '内容(必須)'
        ),
        //入力チェックとなる条件、メッセージを定義
        validator: (value) => value.isEmpty ? '内容を入力してください' : null,
        //_formKey.currentState.save()で呼ばれる
        onSaved: (value) => _body = value.trim(),
      ),
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
            onPressed: _validateAndSubmit,
          ),
        ),
      );
  }

  //アクティビティインジケータ
//  Widget showCircularProgress() {
//    return
//      //通信中の場合
//      _isLoading
//      //CircularProgressIndicator() => 円形にグルグル回るタイプのやつ
//          ? Center(child: CircularProgressIndicator())
//      //上記以外の場合
//          : Container(height: 0.0,width: 0.0,);
//  }

}