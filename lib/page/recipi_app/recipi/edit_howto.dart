import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:image_picker/image_picker.dart';


class EditHowTo extends StatefulWidget{

  HowTo howTo = HowTo();

  EditHowTo({Key key, @required this.howTo}) : super(key: key);

  @override
  _EditHowToState createState() => _EditHowToState();
}

class _EditHowToState extends State<EditHowTo>{

  HowTo _howTo = HowTo();                  //作り方
  String _imagePath = '';                  //写真のpath
  bool _isNew = false;                     //true:新規
  final _body = TextEditingController();   //本文

  @override
  void initState() {
    super.initState();
    setState(() {
      this._howTo = widget.howTo;
    });
    //新規or更新チェック
    if(this._howTo.id == null){
      setState(() {
        this._isNew = true;
      });
    } else {
      setState(() {
        this._isNew = false;
      });
    }
      //選択した作り方の取得
//      print('[更新]no:${this._howTo.no},memo:${this._howTo.memo},photo:${this._howTo.photo}');
      this._body.text = this._howTo.memo;
      this._imagePath = this._howTo.photo;
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    //更新の場合
    if(!_isNew){
      this._howTo.memo = _body.text;
      this._howTo.photo = this._imagePath;
//      print('id:${this._howTo.id},no:${this._howTo.no},name:${this._howTo.memo},quantity:${this._howTo.photo}');
      Navigator.pop(context,this._howTo);
    //新規の場合
    } else {
      //入力内容が未入力以外の場合
      if(!_isEmptyCheck()) {
        this._howTo.id = -1;
        this._howTo.memo = _body.text;
        this._howTo.photo = this._imagePath;
        Navigator.pop(context,this._howTo);
        //未入力の場合
      } else {
        Navigator.pop(context);
      }
    }
  }

  bool _isEmptyCheck(){
    if(this._body.text.isNotEmpty){
      return false;
    }
    if(this._imagePath.isNotEmpty){
      return false;
    }
    return true;
  }

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('写真を撮影'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(ImageSource.camera);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('写真を選択'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(ImageSource.gallery);
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

  // カメラまたはライブラリから画像を取得
  Future<void> _getAndSaveImageFromDevice(ImageSource source) async {

    // 撮影/選択したFileが返ってくる
    PickedFile imageFile = await ImagePicker().getImage(source: source);
    // 撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return;
    }

    setState(() {
      this._imagePath = imageFile.path;
    });
//    print('###_imagePath:${_imagePath}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        leading: closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text( '作り方',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          completeBtn(),
        ],
      ),
      body: scrollArea(),
    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
//      key: GlobalKey(),
      child: SingleChildScrollView(
//        key: GlobalKey(),
//        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
    return Container(
//      key: GlobalKey(),
      //入力フィールドをformでグループ化し、key:_formKey(グローバルキー)と
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            memoArea(),            //メモ
            memoInputArea(),       //メモ、画像入力欄
//            line(),
            deleteButtonArea(),
          ],
        ),
      ),
    );
  }

  //メモ
  Widget memoArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('作り方',style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
  //                  fontWeight: FontWeight.bold
                  ),),
                ),
              ),
            ],
          ),
        ),
      );
  }

  //メモ、画像入力欄
  Widget memoInputArea(){
    return
        SizedBox(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.98,
          height: MediaQuery.of(context).size.height * 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //作り方エリア
              SizedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
//                  height: 250,
                  child: TextField(
                    controller: _body,
                    autofocus: false,
                    minLines: 10,
                    maxLines: 10,
//                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: '作り方を入力',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              //画像エリア
              _imagePath.isEmpty
                ? Card(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.23,
                      width: MediaQuery.of(context).size.width * 0.23,
                      color: Colors.amber[100 * (1 % 9)],
                      child: InkWell(
                          child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                          onTap: (){
                            FocusScope.of(context).unfocus();
                            _showImgSelectModal();
                          }
                      ),
                    ),
                  )
                : Card(
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.23,
                      width: MediaQuery.of(context).size.width * 0.23,
                      child: InkWell(
                        child: Image.file(File(_imagePath),fit: BoxFit.cover,),
                        onTap: (){
                          FocusScope.of(context).unfocus();
                          _showImgSelectModal();
                        }
                      ),
                    ),
                ),
            ],
          ),
        ),
      );
  }

  //線
  Widget line(){
    return
      Divider(
        color: Colors.deepOrange[100 * (2 % 9)],
        height: 0.5,
        thickness: 0.5,
      );
  }

  //削除ボタン
  Widget deleteButtonArea() {
    return
      !_isNew
          ? Container(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          height: MediaQuery.of(context).size.height * 0.05,
          child: FittedBox(fit:BoxFit.fitWidth,
            child: RaisedButton.icon(
              icon: Icon(Icons.delete,color: Colors.white,),
              label: Text('作り方を削除する'),
              textColor: Colors.white,
              color: Colors.red[100 * (3 % 9)],
              onPressed:(){
                Navigator.pop(context,'delete');
              },
            ),
          ),
        ),
      )
          : Container();
  }

//保存ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FittedBox(fit:BoxFit.fitWidth,
          child: FlatButton(
            color: Colors.white,
  //          shape: RoundedRectangleBorder(
  //            borderRadius: BorderRadius.circular(10.0),
  //          ),
            child: Text('保存',
              style: TextStyle(
                color: Colors.deepOrange[100 * (1 % 9)],
                fontSize: 15,
              ),
            ),
            onPressed: (){
              //入力したdataをstoreへ保存
              _onSubmit();
            },
          ),
        ),
      ),
    );
  }

  //ｘボタン
  Widget closeBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        icon: const Icon(Icons.close,color: Colors.white),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
    );
  }
}