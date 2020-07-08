import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/recipi/list/Myrecipi.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/services/recipi/file_controller.dart';
import 'package:recipe_app/page/recipi/list/DBHelper.dart';
import 'package:recipe_app/page/recipi/list/Photo.dart';


class RecipiEdit extends StatefulWidget{

  @override
  _RecipiEditState createState() => _RecipiEditState();
}

class _RecipiEditState extends State<RecipiEdit>{

  final _formKey = new GlobalKey<FormState>(); //入力form
  String _title;                //入力値 タイトル
  String _body;                 //入力値　内容
  int _selectedID;              //編集するID
//  bool _isLoading = true;     //通信中:true(円形のグルグルのやつ)
  File topImageFile;            //トップに表示する写真
  List<File> imageFiles = new List<File>(); //詳細の内容の写真(写真を追加欄)
  String _topImageString;       //DB送信用
  DBHelper dbHelper;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
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
    _init();
  }

  //初期化処理
  void _init(){
    //詳細画面 => 編集画面　の画像のみ情報をリセット
    Provider.of<Display>(context, listen: false).resetImages();
    //編集画面 <=>　撮影画面 の画像情報をリセット
    Provider.of<Display>(context, listen: false).resetSelectImage();
    //編集formで使用したレコード情報をリセット
    Provider.of<Display>(context, listen: false).resetSelectItem();
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

  //保存する押下時処理
  void _onSubmit() async {
    Myrecipi myrecipi = Myrecipi(id:-1,topImage:_topImageString);
    await dbHelper.insertMyRecipi(myrecipi);
    //一覧リストへ遷移
    var state = _getBackState();
    Provider.of<Display>(context, listen: false).setState(state);
      //初期化
      _init();
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
          title: const Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('内容が保存されていませんが、よろしいですか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: const Text('OK'),
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
        key: GlobalKey(),
        itemCount: images == null ? 0 :images.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, int index) {
          imagePath = images[index]['path'];
          //新規投稿の場合
          if(imagePath.isEmpty){
            return Container(
              key: GlobalKey(),
              width: 64.0,
//            color: Colors.grey[300],
              child:InkWell(
                child: const Card(
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
              key: GlobalKey(),
              width: 64.0,
              child:InkWell(
                child: Card(
                  child: Container(
                    child: CachedNetworkImage(
                      key: GlobalKey(),
                      imageUrl: '${imagePath}',
                      progressIndicatorBuilder: (context, url, downloadProgress) =>
                          CircularProgressIndicator(value: downloadProgress.progress),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    ),
//                    decoration: BoxDecoration(
//                      image:DecorationImage(
//                        fit:BoxFit.cover,
//                        image:NetworkImage('${imagePath}'),
//                      ),
//                    ),
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
              key: GlobalKey(),
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

  Future<void> _showImgSelectModal(bool topImage) async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
//          message: const Text('Your options are '),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('写真を撮影'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(ImageSource.camera,topImage);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('写真を選択'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(ImageSource.gallery,topImage);
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            )
        );
      },
    );
  }

//  static Future<String> Base64String(Future<Uint8List> data) async{
//    return base64Encode(data);
//  }


  // カメラまたはライブラリから画像を取得
  Future<void> _getAndSaveImageFromDevice(ImageSource source,bool topImage) async {

    // 撮影/選択したFileが返ってくる
    var imageFile = await ImagePicker().getImage(source: source);
    //変換
    var imageByte = await imageFile.readAsBytes();
    String imgString = await base64Encode(imageByte);

    // 撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return;
    }

    //一時的にローカル保存
    var savedFile = await FileController.saveLocalImage(imageFile); //追加

    setState(() {
      _topImageString = imgString;
      if(topImage){
        this.topImageFile = savedFile;
      }else{
        this.imageFiles.add(savedFile);
      }

//      print('###imageByte:${imageByte}');
//      print('###imgString:${imgString}');
//      print('###_topImageString:${_topImageString}');
    });
  }

  Column _createPhotoArea(){
    List<Widget> column = new List<Widget>();
    //追加したイメージを展開する
    for(var i=0; i < imageFiles.length; i++){
      column.add(
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: InkWell(
                  child: Image.memory(imageFiles[i].readAsBytesSync()),
                  onTap: (){
                    print('###tap!!!!${imageFiles[i]}');
//                    _showImgSelectModal(false);
                  }
              ),
            ),
      ));
    }
    // + 写真を追加 ボタン
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('写真を追加',style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
                _showImgSelectModal(false);
              }
          ),
        ),
      ),
    );
//    print('###column:${column}');
    return Column(
      children: column,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text( _selectedID == -1 ? 'レシピを作成' :'レシピを編集',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          completeBtn(),
        ],
      ),
      body: showEdit(),
    );
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
          child: Text('完了',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _onSubmit();
          },
        ),
      ),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return IconButton(
      icon: const Icon(Icons.close,color: Colors.white,size: 35,),
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
      key: GlobalKey(),
      child: SingleChildScrollView(
        key: GlobalKey(),
//        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
        return Container(
          key: GlobalKey(),
          //入力フィールドをformでグループ化し、key:_formKey(グローバルキー)と
          child: Form(
            key: _formKey,
          child: Container(
            alignment: Alignment.center,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                imageArea(), //画像
//                saveButton(),//保存ボタン
//                textArea(),  //テキスト入力欄
                imageFileArea(),      //トップ画像
                textTitleArea(),      //タイトル
                materialArea(),       //材料
                materialInputArea(),  //材料入力欄
                howToArea(),          //作り方
                howToInputArea(),     //作り方入力欄
                photoArea(),          //写真
                photoInputArea(),     //写真入力欄
              ],
            ),
          ),
          ),
        );
  }

  //トップ画像
  Widget imageFileArea(){
    return
          (topImageFile == null)
              ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.grey,
              child: InkWell(
                  child: Icon(Icons.camera_alt,color: Colors.white,size: 100,),
                  onTap: (){
                    _showImgSelectModal(true);
                  }
              ),
            ),
          )
              : SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: InkWell(
                  child: Image.memory(topImageFile.readAsBytesSync()),
                  onTap: (){
                    _showImgSelectModal(true);
                  }
              ),
            ),
    );
  }

  //レシピタイトル
  Widget textTitleArea(){
    return
      SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('タイトルを入力',style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('レシピの説明やメモを入力',style: TextStyle(
                          fontSize: 15,
//                        fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
                  onTap: (){
//                    _showImgSelectModal();
                  }
              ),
            ),
    );
  }

  //材料
  Widget materialArea(){
    return
      SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white30,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('材料',style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('1人分',style: TextStyle(
                          fontSize: 15,
                        fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
            ),
    );
  }

  //材料追加
  Widget materialInputArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('材料を追加',style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
//                    _showImgSelectModal();
              }
          ),
        ),
      );
  }

  //作り方
  Widget howToArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,                    children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('作り方',style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ],
          ),
        ),
      );
  }

  //作り方追加
  Widget howToInputArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.08,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('作り方を追加',style: TextStyle(
                        color: Colors.cyan,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
//                    _showImgSelectModal();
              }
          ),
        ),
      );
  }

  //写真エリア
  Widget photoArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,                    children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('1人分',style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            ),
          ],
          ),
        ),
      );
  }

  //写真追加
  Widget photoInputArea(){
    return Container(
      child: _createPhotoArea(),
    );
  }

  //画像
//  Widget imageArea(){
////    return Consumer<Display>(
////        builder: (context,Display,_) {
//          return Container(
//            key: GlobalKey(),
//            padding: const EdgeInsets.only(left:20,top: 20,right: 20,bottom: 40),
//            child:_createImageAria(),
//          );
////        }
////    );
//  }

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
      key: GlobalKey(),
        padding: const EdgeInsets.only(top:10,right: 220),
        child: const Text('タイトルと説明',
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
    return Consumer<Display>(
      builder: (context,Display,_) {
        return Container(
          key: GlobalKey(),
//          height: 45,
//          padding: EdgeInsets.all(5),
          child: TextFormField(
            style: const TextStyle(
              fontSize: 15.0
            ),
            initialValue: Display.selectItem['title'],
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: const InputDecoration(
              focusColor: Colors.redAccent,
              contentPadding: EdgeInsets.all(10),
              hintText: 'タイトル',
//              border: OutlineInputBorder(
//                  borderSide: BorderSide()
//              ),
//                labelText: 'タイトル(必須)',
            ),
            //入力チェックとなる条件、メッセージを定義
            validator: (value) => value.isEmpty ? 'タイトルを入力してください' : null,
            //_formKey.currentState.save()で呼ばれる
            onSaved: (value) => _title = value.trim(),
          ),
        );
      },
    );
  }

  //内容
  Widget bodyArea(){
    return Consumer<Display>(
      builder: (context,Display,_) {
        return Container(
          key: GlobalKey(),
//          padding: EdgeInsets.all(5),
          child: TextFormField(
            style: const TextStyle(
                fontSize: 15.0
            ),
            initialValue: Display.selectItem['body'],
            minLines: 18,
            maxLines: 50,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(10),
                hintText: 'レシピの説明',
//                border: OutlineInputBorder(
//                    borderSide: BorderSide()
//                ),
//                labelText: '内容(必須)'
            ),
            //入力チェックとなる条件、メッセージを定義
            validator: (value) => value.isEmpty ? '内容を入力してください' : null,
            //_formKey.currentState.save()で呼ばれる
            onSaved: (value) => _body = value.trim(),
          ),
        );
      },
    );
  }

  //保存するボタン
  Widget saveButton() {
    return
      Container(
        key: GlobalKey(),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 100,
          height: 50,
          child: RaisedButton(
            child: const Text('保存する',style: TextStyle(color: Colors.white),),
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