import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:image_picker/image_picker.dart';


class EditHowTo extends StatefulWidget{

  @override
  _EditHowToState createState() => _EditHowToState();
}

class _EditHowToState extends State<EditHowTo>{

  final _memo= TextEditingController();    //作り方
  String _photo = '';                      //写真パス
//  File _photoFile;                         //写真パスのファイル形式
  int _index;                              //選択された作り方のindex番号

  @override
  void initState() {
    super.initState();
    //新規or更新かジャッチする
    _index = Provider.of<Display>(context, listen: false).getEditIndex();
//    print('index:${_index}');
    //更新の場合
    if(_index != -1){
      //選択した材料の取得
      HowTo item = Provider.of<Display>(context, listen: false).getHowTo(_index);
      print('[更新]no:${item.no},memo:${item.memo},photo:${item.photo}');
      this._memo.text = item.memo;
      this._photo = item.photo;
    }
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    HowTo howto;
    //更新の場合
    if(_index != -1){
      howto = HowTo(memo: _memo.text,photo: _photo);
      //選択した材料の更新処理
      Provider.of<Display>(context, listen: false).setHowTo(_index,howto);
      return;
    }
    //入力内容が未入力以外の場合
    if(!_isEmptyCheck()) {
      howto = HowTo(memo: _memo.text,photo: _photo);
      //材料リストへの追加
      Provider.of<Display>(context, listen: false).addHowTo(howto);
    }
  }

  bool _isEmptyCheck(){
    if(this._memo.text.isNotEmpty){
      return false;
    }
    if(this._photo.isNotEmpty){
      return false;
    }
    return true;
  }


  //削除ボタン押下時処理
  void _onDelete(){
    print('####delete');
    //材料リストの取得
    List<HowTo> howtos = Provider.of<Display>(context, listen: false).getHowTos();
    //該当の材料を削除
    howtos.removeAt(_index);
    for(var i = 0; i < howtos.length; i++){
      //noを採番し直す
      howtos[i].no =  i + 1;
      print('no:${howtos[i].no},memo:${howtos[i].memo},photo:${howtos[i].photo}');
    }
    //新しく生成した材料リストをセットする
//    Provider.of<Display>(context, listen: false).setIngredients(ingredients);
  }

  //編集画面の状態の切り替え
  void _changeEditType(editType){
    Provider.of<Display>(context, listen: false).setEditType(editType);
    //
    Provider.of<Display>(context, listen: false).setEditIndex(-1);
  }

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal() async {
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
      _photo = imageFile.path;
    });

    print('###_photo:${_photo}');

  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
        builder: (context, Display, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
              leading: closeBtn(),
              elevation: 0.0,
              title: Center(
                child: Text( Display.id == -1 ? 'レシピを作成' :'レシピを編集',
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
            body: scrollArea(),
          );
        }
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
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            memoArea(),            //メモ
            memoInputArea(),       //メモ、画像入力欄
            line(),
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
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('作り方',style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                  fontWeight: FontWeight.bold
                ),),
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
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          width: 400,
          height: 200,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //作り方エリア
              SizedBox(
                child: Container(
                  width: 250,
//                  height: 250,
                  child: TextField(
                    controller: _memo,
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
              _photo.isEmpty
                ? Card(
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.grey,
                      child: InkWell(
                          child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                          onTap: (){
                            _showImgSelectModal();
                          }
                      ),
                    ),
                  )
                : Card(
                    child: Container(
                      height: 100,
                      width: 100,
                      child: InkWell(
                        child: Image.file(File(_photo)),
                        onTap: (){
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

  //分量
  Widget quantityArea(){
    return
      SizedBox(
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('分量',style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                    fontWeight: FontWeight.bold
                ),),
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
        color: Colors.grey,
        height: 0.5,
        thickness: 0.5,
      );
  }

  //削除ボタン
  Widget deleteButtonArea() {
    return
      _index != -1
          ? Container(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 200,
          height: 50,
          child: RaisedButton.icon(
            icon: Icon(Icons.delete,color: Colors.white,),
            label: Text('作り方を削除する'),
            textColor: Colors.white,
            color: Colors.redAccent,
            onPressed:(){
              _onDelete();
              _changeEditType(0); //編集TOP
            },
          ),
        ),
      )
          : Container();
  }

//保存ボタン
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
          child: Text('保存',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 15,
            ),
          ),
          onPressed: (){
            //入力したdataをstoreへ保存
            _onSubmit();
            _changeEditType(0); //編集TOP
          },
        ),
      ),
    );
  }

  //ｘボタン
  Widget closeBtn(){
    return IconButton(
      icon: const Icon(Icons.close,color: Colors.white,size: 35,),
      onPressed: (){
        _changeEditType(0); //編集TOP
      },
    );
  }
}