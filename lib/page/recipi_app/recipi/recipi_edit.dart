import 'dart:io';
import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:image_pickers/image_pickers.dart';
//import 'package:path_provider/path_provider.dart';


import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_howto.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_ingredient.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_title.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/edit/Titleform.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/edit/Howto.dart';


class RecipiEdit extends StatefulWidget{

  Myrecipi Nrecipi = Myrecipi();
  List<Ingredient> Ningredients = [];      //レシピIDに紐づく材料リスト
  List<HowTo> NhowTos = [];                //レシピIDに紐づく作り方リスト
  List<Photo> Nphotos = [];                //レシピIDに紐づく写真

  RecipiEdit({Key key, @required this.Nrecipi,@required this.Ningredients,@required this.NhowTos,@required this.Nphotos,}) : super(key: key);

  @override
  _RecipiEditState createState() => _RecipiEditState();
}

class _RecipiEditState extends State<RecipiEdit>{

  DBHelper dbHelper;
  Common common;
  int _selectedID;                //編集するID
//  String _thumbnail;            //サムネイル DB送信用
  int _type;                      //レシピ種別 1:写真レシピ 2:MYレシピ 3:テキストレシピ
  Myrecipi _recipi = Myrecipi();
  List<Ingredient> _ingredients;  //材料リスト
  List<HowTo> _howTos;            //作り方リスト
  List<Photo> _photos;            //詳細の内容の写真(写真を追加欄)
//  List<File> imageFiles = new List<File>(); //詳細の内容の写真(写真を追加欄)

  final _stateController = TextEditingController();
  final _visionTextController = TextEditingController();
  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
  bool _isError = false;
  bool _isDescriptionEdit = false;
  bool _isLoading = false;
  bool _isEdit = false;

  TitleForm _titleForm = TitleForm();
  static GlobalKey previewContainer = GlobalKey();


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    common = Common();
    setState(() {
      this._howTos = [];
      this._ingredients = [];
      this._photos = [];
      print('recipi:${widget.Nrecipi.id}');
      print('hotos:${widget.NhowTos.length}');
      print('ingredient:${widget.Ningredients.length}');
      print('photo:${widget.Nphotos.length}');
      this._recipi = widget.Nrecipi;
      widget.NhowTos.forEach((howto) => this._howTos.add(howto));
      widget.Ningredients.forEach((ingredient) => this._ingredients.add(ingredient));
      widget.Nphotos.forEach((photo) => this._photos.add(photo));
      //idを取得
      this._selectedID = _recipi.id;
      print('ID:${_selectedID}');
      //レシピ種別を取得
      this._type = _recipi.type;
      print('レシピ種別:${this._type}');
      //タイトル編集欄をセット
      this._titleForm = TitleForm(title: _recipi.title,description: _recipi.description,quantity: _recipi.quantity,unit: _recipi.unit,time: _recipi.time);
      if(this._type == 3){
        //説明をセットする
        this._visionTextController.text = this._titleForm.description;
      }
      if(this._selectedID == -1){
        this._isEdit = true;
      }
    });
  }

  @override
  void dispose() {
    this._stateController.dispose();
    this._visionTextController.dispose();
    super.dispose();
  }

  //単位 表示用
  String _displayUnit(unit){
    if(unit == 1){
      return '人分';
    }
    if(unit == 2){
      return '個分';
    }
    if(unit == 3){
      return '枚分';
    }
    if(unit == 4){
      return '杯分';
    }
    if(unit == 5){
      return '皿分';
    }
  }

  //一覧リストへ遷移
  void _onList(){
    Navigator.pop(context);
//    //新規作成の場合は詳細画面も閉じる
//    if(this._selectedID == -1){
//      Navigator.pop(context);
//    }
  }

//  //初期化処理
//  void _init(){
//    //リセット処理
//    Provider.of<Display>(context, listen: false).reset(); //編集フォーム
//    Provider.of<Detail>(context, listen: false).reset();  //詳細フォーム
//  }

  //戻り先の状態を取得
//  int _getBackState(){
//    //新規投稿の場合
//    if(_selectedID == -1){
//      return -2;
//    //更新の場合
//    }else{
//      return -1;
//    }
//  }

  //タイトル欄の取得
  bool IsEmptyTitleForm(){
    if(this._titleForm.title.isNotEmpty){
      return false;
    }
    if(this._titleForm.description.isNotEmpty){
      return false;
    }
    if(this._titleForm.unit != 1){
      return false;
    }
    if(this._titleForm.quantity != 1){
      return false;
    }
    if(this._titleForm.time != 0){
      return false;
    }
    return true;
  }

  bool lengthCheck(){
    if(this._ingredients.length != 0){
      return false;
    }
    if(this._howTos.length != 0){
      return false;
    }
    if(this._photos.length != 0){
      return false;
    }
    return true;
  }

  //保存する押下時処理
  void _onSubmit() async {
    String thumbnail = this._recipi.thumbnail;
    //新規登録の場合
    if(_selectedID == -1){
      //サムネイル
      var titleIsEmpty = IsEmptyTitleForm();
      //内容が未入力の場合
      if(thumbnail.isEmpty && titleIsEmpty) {
        //DBに登録せず、一覧リストへ戻る
        if(this.lengthCheck()){
          print('登録しない');
          _onList();
          return;
        }
//        if (_type == 2) {
//          if (this._ingredients.length == 0 && this._howTos.length == 0) {
////            print('2:空');
//          _onList();
//            return;
//          }
//        } else {
//          if (this._photos.length == 0) {
////            print('1:空');
//          _onList();
//            return;
//          }
//        }
      }
      //内容のいずれかが入力されている場合
      //タイトル、説明、分量、単位、調理時間
      TitleForm titleForm = this._titleForm;
      //myrecipiテーブルへ登録
      Myrecipi myrecipi = Myrecipi
        (
          id: this._selectedID
          ,type: this._type
          ,thumbnail: thumbnail
          ,title: titleForm.title
          ,description: titleForm.description
          ,quantity: titleForm.quantity
          ,unit: titleForm.unit
          ,time: titleForm.time
          ,folder_id: 0
      );
      Myrecipi result = await dbHelper.insertMyRecipi(myrecipi);
      //登録したレシピIDを取得
      var recipi_id = result.id;
      if(this._type == 2){
        if(this._ingredients.length != 0){
          //材料
          for(var i = 0; i < this._ingredients.length; i++){
            //レシピIDをセットする
            this._ingredients[i].recipi_id = recipi_id;
          }
          //recipi_ingredientテーブルへ登録
          await dbHelper.insertRecipiIngredient(this._ingredients);
        }
        if(this._howTos.length != 0){
          //作り方
          for(var i = 0; i < this._howTos.length; i++){
            //レシピIDをセットする
            this._howTos[i].recipi_id = recipi_id;
          }
          //recipi_howtoテーブルへ登録
          await dbHelper.insertRecipiHowto(this._howTos);
        }
      }else{
        if(this._photos.length != 0){
          //写真
          for(var i = 0; i < this._photos.length; i++){
            //レシピIDをセットする
            this._photos[i].recipi_id = recipi_id;
          }
          //recipi_photoテーブルへ登録
          await dbHelper.insertPhoto(this._photos);
        }
      }
      _onList();

    //更新の場合
    }else{
      //フォルダーIDを取得
      Myrecipi recipi = this._recipi;
      //タイトル、説明、分量、単位、調理時間
      TitleForm titleForm = this._titleForm;
      //myrecipiテーブルへ更新
      Myrecipi myrecipi = Myrecipi
        (
          id: this._selectedID
          ,type: this._type
          ,thumbnail: thumbnail
          ,title: titleForm.title
          ,description: titleForm.description
          ,quantity: titleForm.quantity
          ,unit: titleForm.unit
          ,time: titleForm.time
          ,folder_id: recipi.folder_id
      );
      await dbHelper.updateMyRecipi(myrecipi);
      //MYレシピの場合
      if(this._type == 2){
          //変更前の材料リストを削除
          await dbHelper.deleteRecipiIngredient(_selectedID);
          //変更した材料リストをセット
          if(this._ingredients.length != 0){
            for(var i = 0; i < this._ingredients.length; i++){
              //レシピIDをセットする
              this._ingredients[i].recipi_id = this._selectedID;
            }
            //recipi_ingredientテーブルへ登録
            await dbHelper.insertRecipiIngredient(this._ingredients);
          }
        //変更前の作り方リストを削除
        await dbHelper.deleteRecipiHowto(_selectedID);
        //変更した作り方リストをセット
        if(this._howTos.length != 0){
          //作り方
          for(var i = 0; i < this._howTos.length; i++){
            //レシピIDをセットする
            this._howTos[i].recipi_id = _selectedID;
          }
          //recipi_howtoテーブルへ更新
          await dbHelper.insertRecipiHowto(this._howTos);
        }
      }else{
        //変更前の写真リストを削除
        await dbHelper.deleteRecipiPhoto(_selectedID);
        if(this._photos.length != 0){
          //写真
          for(var i = 0; i < this._photos.length; i++){
            //レシピIDをセットする
            this._photos[i].recipi_id = this._selectedID;
          }
          //recipi_photoテーブルへ登録
          await dbHelper.insertPhoto(this._photos);
        }
      }
      setState(() {
        this._isEdit = !this._isEdit;
      });
    }
  }

  //写真削除処理
  void _onPhotoDelete(int index) async {
    print('####delete');
    //該当の写真を削除
    setState(() {
      this._photos.removeAt(index);
      for(var i = 0; i < this._photos.length; i++){
        //noを採番し直す
        this._photos[i].no =  i + 1;
      }
    });
  }

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal({bool thumbnail,bool edit,Photo photo,int index}) async {
    //サムネイル且つ、スキャンカメラの場合
    if(thumbnail && _type == 3){
      //ネットワーク接続チェック処理の呼び出し
      var result = await common.checkNetworkConnection();
      if(!result){
        return
          AwesomeDialog(
            context: context,
//            width: 280,
            dialogType: DialogType.WARNING,
            headerAnimationLoop: false,
            animType: AnimType.TOPSLIDE,
            title: 'インターネットに接続されていません',
            desc: 'スキャンレシピを利用する場合は、インターネットに接続してください。',
            btnOkOnPress: () {},
//            btnOkColor:
          )..show();
      }
    }
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
//          message: const Text('Your options are '),
            actions: <Widget>[
              !thumbnail //サムネイル画像以外の場合
              ? edit     //かつ、セットした写真をtapした場合
                  ? CupertinoActionSheetAction(
                      child: const Text('手順を削除'),
                      onPressed: () {
                        Navigator.pop(context);
                        _onPhotoDelete(index);
                      },
                    )
                  : Container()
              : Container(),
              CupertinoActionSheetAction(
                child: const Text('写真を撮影'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(source: ImageSource.camera,thumbnail: thumbnail,edit: edit,photo: photo,index: index);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('写真を選択'),
                onPressed: () {
                  Navigator.pop(context);
                  _getAndSaveImageFromDevice(source: ImageSource.gallery,thumbnail: thumbnail,edit: edit,photo: photo,index: index);
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
  Future<void> _getAndSaveImageFromDevice({ImageSource source,bool thumbnail,bool edit,Photo photo,int index}) async {

    // 撮影/選択したFileが返ってくる
    PickedFile imageFile = await ImagePicker().getImage(source: source);

    // 画像が選択されなかった場合はスキップ
    if (imageFile == null) {
      return;
    }
    print('###setしたimagepath:${imageFile.path}');

    File thumbnailfile = File(imageFile.path);
    //サムネイル用にファイル名を変更
    String thumbnailPath = common.replaceImage(thumbnailfile.path);

    // flutter_image_compressで指定サイズ／品質に圧縮
    List<int> thumbnailresult = await FlutterImageCompress.compressWithFile(
      thumbnailfile.absolute.path,
      minWidth: 200,
      minHeight: 200,
      quality: 50,
    );

    // 圧縮したファイルを端末の拡張ディスクに保存
    File saveFile = File(thumbnailPath);
    await saveFile.writeAsBytesSync(thumbnailresult, flush: true, mode: FileMode.write);
    print('saveFile:${saveFile.path}');

    //サムネイル画像の場合
    if(thumbnail){
      //スキャンレシピの場合
      if(_type == 3 ){
        //写真のトリミング処理の呼び出し
        var isNull = await this._cropImage(imageFile: File(imageFile.path));
        //トリミング処理にてXまたは<ボタン押下時
        if(isNull){
          //編集画面へ戻る
          return;
        }
        //文字変換処理の呼び出し
        await this._vision();
      }else{
        setState(() {
          //セット
          this._recipi.thumbnail = imageFile.path;
        });
      }
    //写真エリアの場合
    }else{
      Photo photo = Photo(path: imageFile.path);
        //写真追加の場合
        if(!edit){
          setState(() {
            var no = this._photos.length + 1;
            Photo item  = Photo(no:no,path: photo.path);
            this._photos.add(item);
          });
        //写真変更の場合
        }else{
          setState(() {
            this._photos[index].path = photo.path;
          });
        }
    }
  }

  //写真のトリミング処理
  Future<bool> _cropImage({File imageFile}) async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    print('croppedFile:${croppedFile}');
    if (croppedFile != null) {
        File image = croppedFile;
        //セット
        setState(() {
          this._recipi.thumbnail = image.path;
        });
        //サムネイル用にファイル名を変更
        String thumbnailPath = common.replaceImage(image.path);
        // flutter_image_compressで指定サイズ／品質に圧縮
        List<int> thumbnailresult = await FlutterImageCompress.compressWithFile(
          image.absolute.path,
          minWidth: 200,
          minHeight: 200,
          quality: 50,
        );
        // 圧縮したファイルを端末の拡張ディスクに保存
        File saveFile = File(thumbnailPath);
        await saveFile.writeAsBytesSync(thumbnailresult, flush: true, mode: FileMode.write);
        print('#########saveFile:${saveFile.path}');
        return false;
    } else {
        return true;
    }
  }

  //材料編集エリア
  Column _addIngredient(){
    List<Widget> column = new List<Widget>();
    //材料リストを展開する
    for(var i=0; i < this._ingredients.length; i++){
      column.add(
          SizedBox(
//            height: MediaQuery.of(context).size.height * 0.07,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.only(left: 10,top: 20,right: 10,bottom: 20),
              color: Colors.white,
              child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
//                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child:
                        Container(
//                          color: Colors.redAccent,
                            child: Text('${_ingredients[i].name}',
                              maxLines: 5,
                              style: TextStyle(
                                fontSize: 15,
//                              fontWeight: FontWeight.bold
                              ),),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child:
                        Container(
                            child: Text('${this._ingredients[i].quantity}',
                              maxLines: 5,
                              style: TextStyle(
                                fontSize: 15,
//                        fontWeight: FontWeight.bold
                              ),),
                        ),
                      ),
                    ],
                  ),
//                  child: Image.memory(imageFiles[i].readAsBytesSync()),
                  onTap: !_isEdit ? null :(){
                    print('材料編集');
                    _changeEditType(editType: 1,index: i,); //材料
                  }
              ),
            ),
          ),
      );
      column.add(
        Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
        ),
      );
    }
    if(_isEdit){
      // + 材料を追加 ボタン
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
//            padding: EdgeInsets.only(left: 10,top: 20,right: 10,bottom: 20),
            color: Colors.white,
            child: InkWell(
                child: Row(
  //                crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
  //                    padding: EdgeInsets.all(10),
                      child: Icon(Icons.add_circle_outline,color: Colors.deepOrange[100 * (1 % 9)],)
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: Text('材料を追加',style: TextStyle(
                            color: Colors.deepOrange[100 * (1 % 9)],
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  print('材料追加');
                  _changeEditType(editType: 1,index: -1); //材料
                }
            ),
          ),
        ),
      );
    } else {
      // 空
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
          ),
        ),
      );
    }
//    print('###column:${column}');
    return Column(
      children: column,
    );
  }

  //作り方編集エリア
  Column _addHowTo(){
    List<Widget> column = List<Widget>();
    //作り方リストを展開する
    for(var i=0; i < this._howTos.length; i++){
      column.add(
          SizedBox(
            width: MediaQuery.of(context).size.width,
//            height: MediaQuery.of(context).size.height * 0.18,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(left: 10,top: 20,right: 10,bottom: 20),
              child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _isEdit
                      ? Container()
                      : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                        width: MediaQuery.of(context).size.height * 0.025,
                        child: Container(
                          color: Colors.grey,
                          child: Center(
                            child: FittedBox(fit:BoxFit.fitWidth,
                              child: Text('${this._howTos[i].no}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        child: Container(
                          width: _isEdit ? MediaQuery.of(context).size.width * 0.7 : MediaQuery.of(context).size.width * 0.55,
//                          padding: EdgeInsets.all(10),
                          child: Text('${_howTos[i].memo}',
//                            maxLines: 10,
                            style: TextStyle(
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                            ),),
                        ),
                      ),
                      _howTos[i].photo.isNotEmpty
                        ? SizedBox(
                        height: MediaQuery.of(context).size.width * 0.23,
                        width: MediaQuery.of(context).size.width * 0.23,
                            child: Container(
//                              color: Colors.redAccent,
                              child: InkWell(
                                child: Image.file(File(_howTos[i].photo),fit: BoxFit.cover,),
                                  onTap: _isEdit ? null : (){
                                    ImagePickers.previewImage(_howTos[i].photo);
                                  }
                              ),
                            ),
                          )
                        : SizedBox(
                        height: MediaQuery.of(context).size.width * 0.23,
                        width: MediaQuery.of(context).size.width * 0.23,
                        child: Container(
                        ),
                        ),
                    ],
                  ),
                  onTap: !_isEdit ? null :(){
                    print('作り方編集');
                    _changeEditType(editType: 2,index: i,); //作り方
                  }
              ),
            ),
          ),
      );
      //線
      column.add(
        Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
        ),
      );
    }
    if(_isEdit){
      // + 作り方を追加 ボタン
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
//            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: InkWell(
                child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
//                    padding: EdgeInsets.all(10),
                        child: Icon(Icons.add_circle_outline,color: Colors.deepOrange[100 * (1 % 9)],)
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: Text('作り方を追加',style: TextStyle(
                            color: Colors.deepOrange[100 * (1 % 9)],
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  print('作り方を追加');
                  _changeEditType(editType: 2,index: -1); //作り方
                }
            ),
          ),
        ),
      );
    } else {
      // 空
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
          ),
        ),
      );
    }
//    print('###column:${column}');
    return Column(
      children: column,
    );
  }

  //写真編集エリア
  Column _addPhoto(){
    List<Widget> column = List<Widget>();
    //追加したイメージを展開する
    for(var i=0; i < _photos.length; i++){
      column.add(
          SizedBox(
//            height: 200,
//            width: 400,
            child: Container(
              child: InkWell(
                  child: Image.file(File(_photos[i].path),fit: BoxFit.cover,),
                  onTap: (){
                  _isDescriptionEdit || !_isEdit
                  ? ImagePickers.previewImage(_photos[i].path)
                  : _showImgSelectModal(thumbnail: false,edit: true,photo: _photos[i],index: i);
                    print('###tap!!!!');
                    print('no:${_photos[i].no},path:${_photos[i].path}');

                  }
              ),
            ),
          ),
      );
      //線
      column.add(
        Divider(
          color: Colors.grey,
//          height: 0.5,
          thickness: 0.5,
        ),
      );
    }
    // + 写真を追加 ボタン
    if(!_isDescriptionEdit && _isEdit){
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          child: Container(
//            padding: EdgeInsets.all(10),
            color: Colors.white,
            child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        child: Icon(Icons.add_circle_outline,color: Colors.deepOrange[100 * (1 % 9)],)
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: Text('写真を追加',style: TextStyle(
                            color: Colors.deepOrange[100 * (1 % 9)],
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ],
                ),
                onTap: (){
                  _showImgSelectModal(thumbnail: false,edit: false);
                }
            ),
          ),
        ),
    );
    }
    if(!_isEdit){
      // 空
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
          ),
        ),
      );
    }
//    print('###column:${column}');
    return Column(
      children: column,
    );
  }

  //各エリアの追加ボタン押下
  void _changeEditType({editType,index}){
    TitleForm titleForm;
    Ingredient ingredient;
    HowTo howTo;

    //タイトル編集欄
    if(editType == 0){
      titleForm = this._titleForm;
    }
    //材料編集欄
    if(editType == 1){
      //追加の場合
      if(index == -1){
        ingredient = Ingredient(no: this._ingredients.length + 1,name: '',quantity: '');
      //変更の場合
      } else {
        ingredient = this._ingredients[index];
      }
    }
    //作り方編集欄
    if(editType == 2){
      //追加の場合
      if(index == -1){
        howTo = HowTo(no: this._howTos.length + 1, memo: '', photo: '');
      //変更の場合
      } else {
        howTo = this._howTos[index];
      }
    }

    var root = <Widget>[ EditTitle(titleForm: titleForm, type: this._recipi.type), EditIngredient(ingredient: ingredient), EditHowTo(howTo: howTo)];
     Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => root[editType],
  //          MaterialPageRoute(builder: (context) => EditIngredient(ingredient: ingredient),
          fullscreenDialog: true,
        )
    ).then((result) {
      if(result == null){
        print('何もしない');
      } else if(result == 'delete') {
        //削除ボタン押下時
        setState(() {
          if(editType == 1){
            //該当の材料を削除
            this._ingredients.removeAt(index);
            //noの採番し直す
            for(var i = 0; i < this._ingredients.length; i++){
              this._ingredients[i].no = i + 1;
            }
          }
          if(editType == 2){
            //該当の作り方を削除
            this._howTos.removeAt(index);
            //noの採番し直す
            for(var i = 0; i < this._howTos.length; i++){
              this._howTos[i].no = i + 1;
            }
          }
        });
      } else {
      //値がセットされている場合
        //タイトル編集画面の場合
        if(editType == 0){
          setState(() {
            this._titleForm = result;
          });
        } else {
        //それ以外の編集画面の場合
          //追加の場合
          if(index == -1){
            setState(() {
              //材料編集画面の場合
              if(editType == 1){
                this._ingredients.add(result);
              }
              //作り方編集画面の場合
              if(editType == 2){
                this._howTos.add(result);
              }
            });
          } else {
          //更新の場合
            setState(() {
              //材料編集画面の場合
              if(editType == 1){
                this._ingredients[index].name = result.name;
                this._ingredients[index].quantity = result.quantity;
              }
              //作り方編集画面の場合
              if(editType == 2){
                this._howTos[index].memo = result.memo;
                this._howTos[index].photo = result.photo;
              }
            });
          }
        }
      }
     });
  }

  //削除モーダルの表示
  Future<void> _deleteModal() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
          message: const Text('このレシピを削除しますか?'),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('削除する',
                  style: TextStyle(
                      color: Colors.red
                  ),),
                onPressed: () {
                  Navigator.pop(context);
//                  _onDelete();
                  Navigator.pop(context,'delete');

                },
              ),
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

  //該当レシピ削除
  void _onDelete() async {
    //レシピを削除
    await dbHelper.deleteMyRecipi(this._selectedID);
    //レシピIDに紐づくタグを削除する
    await dbHelper.deleteTagRecipiId(this._selectedID);
    //レシピIDに紐づくごはん日記のレシピリストを削除する
    await dbHelper.deleteDiaryRecipibyRecipiID(this._selectedID);
    //MYレシピの場合
    if(this._type == 2){
      //材料リストを削除
      await dbHelper.deleteRecipiIngredient(this._selectedID);
      //作り方リストを削除
      await dbHelper.deleteRecipiHowto(this._selectedID);
    }else{
      //変更前の写真リストを削除
      await dbHelper.deleteRecipiPhoto(this._selectedID);
    }
    _onList();
  }

  //文字変換処理
  Future<void> _vision() async {
    print('文字変換処理');
    this._setIsLoading();

    VisionText visionText;
    String thumbnail = this._recipi.thumbnail;

    this._isError = false;
    //imageが選択されてる場合
    if (thumbnail.isNotEmpty) {
      //imageをセットする
      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(File(thumbnail));
      try{
        //OCR(文字認識)処理
        visionText = await _textRecognizer.processImage(visionImage);
      }catch(e){
        //エラー処理
        print('Error: ${e}');
        print('visionText: ${visionText}');
        setState(() {
          this._visionTextController.text = '';
          this._isError = !this._isError;
        });
        this._setIsLoading();
        //エラーポップアップを表示する
      }
      //OCR(文字認識)処理にてエラーとならなかった場合
      if(!this._isError){
        String text = visionText.text;
        //コンソール出力
        print('visionText.blocks:${visionText.blocks.length}');
        print('visionText.text:${text}');

        var buf = StringBuffer();
        for (TextBlock block in visionText.blocks) {
          final Rect boundingBox = block.boundingBox;
          final List<Offset> cornerPoints = block.cornerPoints;
          final String text = block.text;
//        print('block.text${text}');
          final List<RecognizedLanguage> languages = block.recognizedLanguages;
//        print(languages);
//        buf.write("=====================\n");
          print('テキストlength：${block.lines.length}');
          for (TextLine line in block.lines) {
            print('--------------------------');
            print('テキスト：${line.text}');
            print('boundingBox：${line.boundingBox}');
            print('confidence：${line.confidence}');
            print('cornerPoints：${line.cornerPoints}');
            // Same getters as TextBlock
            buf.write("${line.text}\n");
//            for (Offset cornerPoint in line.cornerPoints) {
//              Offset c = cornerPoint;
//              print('cornerPoint:${c}');
//              // Same getters as TextBlock
//            }
//            for (TextElement element in line.elements) {
//              TextElement e = element;
//              print('element:${e.text}');
//              print('boundingBox:${e.boundingBox}');
//              print('cornerPoints:${e.cornerPoints}');
//              print('confidence:${e.confidence}');
//              // Same getters as TextBlock
//            }
          }
        }
        //入力フォームへ反映させる
        this._setDescription(buf.toString());
        this._setIsLoading();
      }
    }
  }

  void _setIsLoading(){
    setState(() {
      this._isLoading = !this._isLoading;
    });
  }

  void _setDescription(String text){
    setState(() {
      //入力フォームへ反映させる
      this._visionTextController.text = text;
      this._titleForm.description = this._visionTextController.text;
    });
  }

  //レシピの編集ボタン押下時処理
  void _onEdit(){
    setState(() {
      this._isEdit = !this._isEdit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
        key: previewContainer,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
            leading: _isDescriptionEdit ? Container() : closeBtn(),
            elevation: 0.0,
            title: Center(
                child: Text( _isEdit ? _selectedID == -1 ? 'レシピを作成' :'レシピを編集'
                                     : 'レシピ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
//              fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            actions: <Widget>[
              shareBtn(),
              editBtn(),
              completeBtn(),
            ],
          ),
          body: ModalProgressHUD(
              opacity: 0.5,
              color: Colors.grey,
              progressIndicator: CircularProgressIndicator(),
              child: scrollArea(),
              inAsyncCall: _isLoading
          ),
        ),
    );
  }

  //シェアボタン
  Widget shareBtn() {
    return
    _isEdit
      ? Container()
      : FittedBox(fit:BoxFit.fitWidth,
          child:IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              common.takeWidgetScreenShot(previewContainer);
            },
          ),
        );
  }

  //編集ボタン
  Widget editBtn(){
    return
      _isEdit
        ? Container()
          : FittedBox(fit:BoxFit.fitWidth,
            child:IconButton(
              icon: const Icon(Icons.edit,color: Colors.white),
              onPressed: (){
                _onEdit();
              },
            ),
          );
  }

  //完了ボタン
  Widget completeBtn(){
    return
     _isEdit
      ? Container(
       width: MediaQuery.of(context).size.width * 0.25,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: FittedBox(fit:BoxFit.fitWidth,
            child: FlatButton(
              color: _isDescriptionEdit ? Colors.deepOrange[100 * (1 % 9)] : Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
              child: Text('完了',
                style: TextStyle(
                  color: _isDescriptionEdit ? Colors.deepOrange[100 * (1 % 9)] : Colors.deepOrange[100 * (1 % 9)],
                  fontSize: 15,
                ),
              ),
              onPressed:
              _isDescriptionEdit
                  ? null
                  :(){
                    _onSubmit();
                  },
            ),
          ),
        ),
      )
      : Container();
  }

  //閉じるボタン
  Widget closeBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
        child: IconButton(
          icon: Icon( _selectedID == -1 ? Icons.close : Icons.arrow_back_ios,color: Colors.white),
          onPressed: (){
            _onList();
          },
        ),
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
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
            _type == 1 || _type == 3
            ? _type == 1
                ? <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(), //タイトル
//                  line(),
                  photoArea(), //写真
//                  line(),
                  photoAddArea(), //写真入力欄
//                  line(),
                  deleteButtonArea(),//削除ボタン
               ]
                : <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(),     //タイトル
                  DescriptionTitleArea(),
                  ocrTextArea(),   //文字変換
//                  line(),
                  photoArea(), //写真
//                  line(),
                  photoAddArea(), //写真入力欄
//                  line(),
                  deleteButtonArea(), //削除ボタン
              ]
             : <Widget>[
              thumbnailArea(), //トップ画像
              titleArea(), //タイトル
//              line(),
              ingredientArea(), //材料
//              line(),
              ingredientAddArea(), //材料入力欄
//              line(),
              howToArea(), //作り方
//              line(),
              howToAddArea(), //作り方入力欄
//              line(),
              deleteButtonArea(),//削除ボタン
             ]
          ),
      );
  }

  //線
  Widget line(){
    return Divider(
      color: Colors.grey,
      height: 0.5,
      thickness: 0.5,
    );
  }

  //トップ画像
  Widget thumbnailArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
    return
      _isEdit
      ? _recipi.thumbnail.isEmpty
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white30,
              child: InkWell(
                child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(child: Icon(Icons.camera_alt,color: Colors.grey,size: 100,),),
                        Center(child: Text(_type == 3 ? 'スキャンする写真を登録' : '写真を登録', style: TextStyle(fontSize: 20,color: Colors.grey),)),
                      ],
                    ),
                    editMsgArea(),
                ]),
                onTap: _isDescriptionEdit ? null : (){
                  _showImgSelectModal(thumbnail: true);
                }
              ),
            ),
        )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Center(child: Image.file(File(_recipi.thumbnail)),),
//                    child: Image.file(File(Display.thumbnail),fit: BoxFit.cover,),
                      editMsgArea(),
                    ]
                  ),
                  onTap: _isDescriptionEdit ? null : (){
                    _showImgSelectModal(thumbnail: true);
                  }
              ),
            ),
        )
      //詳細画面の場合
      : _recipi.thumbnail.isEmpty
          //サムネイル画像が未登録の場合
          ? SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.amber[100 * (1 % 9)],
                child: Icon(Icons.restaurant,color: Colors.white,size: 100,),
              ),
            )
          //サムネイル画像が登録済みの場合
          : SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
              width: MediaQuery.of(context).size.width,
              child: Container(
                child: InkWell(
                    child: Image.file(File(_recipi.thumbnail),fit: BoxFit.cover),
                    onTap: (){
                      ImagePickers.previewImage(_recipi.thumbnail);
                    }
                ),
              ),
          );
//        }
//    );
  }

  //トップ画像に表示する文言
  Widget editMsgArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.04,
//        width: MediaQuery.of(context).size.width,
        child: Container(
            color: Colors.black26,
            child: Center(
              child: Text('各項目をタップして編集できます',
                style: TextStyle(color: Colors.white,fontSize: 15),
              ),
            )
        ),
      );
  }

  //レシピタイトル
  Widget titleArea(){
    return
      _isEdit
      //編集画面の場合
      ? SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                      child: Text(_titleForm.title.isEmpty ? 'タイトルを入力' :'${_titleForm.title}',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                  ),
                  _type == 3
                  ? Container()
                  : Container(
                    padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                      child: Text(_titleForm.description.isEmpty ?'レシピの説明やメモを入力' :'${_titleForm.description}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                  ),
                ],
              ),
              onTap: _isDescriptionEdit ? null : () {
                print('タイトル');
                _changeEditType(editType: 0); //タイトル
              }
          ),
        ),
      )

      //詳細画面の場合
      : SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                child: Text('${_titleForm.title}',
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
              ),
              _type == 3
              ? Container(
                )
              : Container(
                  padding: EdgeInsets.only(left: 10,top: 10,right: 10,bottom: 10),
                  child: Text('${_titleForm.description}',
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15,
                    ),),
                ),
            ],
          ),
        ),
      );
  }

  //材料
  Widget ingredientArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FittedBox(fit:BoxFit.fitWidth,
                    child:
                    Text('材料',style: TextStyle(
                      color: Colors.white,
//                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),)
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('${_titleForm.quantity}${_displayUnit(_titleForm.unit)}', style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
//                    fontWeight: FontWeight.bold
                  ),),
                ),
              ),
            ],
          ),
        ),
      );
  }

  //材料追加
  Widget ingredientAddArea(){
    return Container(
      child: _addIngredient(),
    );
  }

  //作り方
  Widget howToArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,                    children: <Widget>[
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
            _titleForm.time != 0
            ? Container(
              padding: EdgeInsets.only(left: 10,right: 10),
              child: FittedBox(fit:BoxFit.fitWidth,
                child: Text('${_titleForm.time}分', style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                  fontWeight: FontWeight.bold
                ),),
              ),
            )
            : Container()
          ],
          ),
        ),
      );
  }

  //作り方追加
  Widget howToAddArea(){
    return Container(
      child: _addHowTo(),
    );
  }

  //写真エリア
  Widget photoArea(){
      return
          SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.deepOrange[100 * (2 % 9)],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10,right: 10),
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: Text('${_titleForm.quantity}${_displayUnit(_titleForm.unit)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
  //                      fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                _titleForm.time != 0
                  ? Container(
                    padding: EdgeInsets.only(left: 10,right: 10),
                    child: FittedBox(fit:BoxFit.fitWidth,
                      child: Text('${_titleForm.time}分', style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
    //                      fontWeight: FontWeight.bold
                      ),),
                    ),
                    )
                  : Container()
              ],
            ),
          ),
        );
  }

  //写真追加
  Widget photoAddArea(){
    return
      Container(
      child: _addPhoto(),
    );
  }

  Widget DescriptionTitleArea(){
      return
       _isEdit
        ? Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.deepOrange[100 * (2 % 9)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: Text('説明/メモ', style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
  //                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                    _recipi.thumbnail.isEmpty
                    ? Container()
                    : Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.text_fields,
                              color: _isDescriptionEdit
                                  ? Colors.grey
                                  : Colors.deepOrange[100 * (3 % 9)]),
                          Switch(
                            value: this._isDescriptionEdit,
                            activeColor: Colors.deepOrange[100 * (3 % 9)],
                            onChanged: (value) {
                              setState(() {
                                this._isDescriptionEdit = !this._isDescriptionEdit;

                              });
                              if(!this._isDescriptionEdit){
                                print('セットする');
                                this._setDescription(this._visionTextController.text);
                              }
                            },
                          ),
                          Icon(Icons.edit, color: _isDescriptionEdit
                              ? Colors.deepOrange[100 * (3 % 9)]
                              : Colors.grey)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
//            line(),
          ],
        )
        : Column(
           children: <Widget>[
             SizedBox(
               height: MediaQuery.of(context).size.height * 0.05,
               width: MediaQuery.of(context).size.width,
               child: Container(
                 color: Colors.deepOrange[100 * (2 % 9)],
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: <Widget>[
                     Container(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                       child: Text('説明/メモ', style: TextStyle(
                         color: Colors.white,
                         fontSize: 15,
                       ),),
                     ),
                     ),
                   ],
                 ),
               ),
             ),
           ],
        );
//    });
  }

  //文字変換テキストエリア
  Widget ocrTextArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
      return
        _isEdit
          ? _recipi.thumbnail.isEmpty
            ? Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.only(top: 13,bottom: 13),
                  child: Text('スキャンする画像が登録されると、文字変換されます。',
                    style: TextStyle(fontSize: 15,color: Colors.grey)
                  ),
                ),
            )
            : Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              width: MediaQuery.of(context).size.width,
              child:
              this._isDescriptionEdit
                  ? TextField(
                      style: TextStyle(fontSize: 15),
                      controller: _visionTextController,
                      autofocus: false,
          //                minLines: 5,
                      maxLines: 20,
                      decoration: const InputDecoration(
          //                  hintText: '写真を選択すると文字に変換された内容が表示されます',
                        border: InputBorder.none,
                      ),
                    )
                  : Container(
    //                  width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(top: 13),
                      child: Text('${_visionTextController.text}',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
            )
          : Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.only(top: 13),
              child: Text('${_visionTextController.text}',
                style: TextStyle(fontSize: 15),
              ),
            ),
          );
//    });
  }

  //削除ボタン
  Widget deleteButtonArea() {
    return
      _selectedID != -1 && !_isDescriptionEdit && _isEdit
        ? Container(
            margin: const EdgeInsets.all(50),
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              height: MediaQuery.of(context).size.height * 0.05,
              child: FittedBox(fit:BoxFit.fitWidth,
                child: RaisedButton.icon(
                  icon: Icon(Icons.delete,color: Colors.white,),
                  label: Text('レシピを削除する'),
                  textColor: Colors.white,
                  color: Colors.red[100 * (3 % 9)],
      //            shape: RoundedRectangleBorder(
      //              borderRadius: BorderRadius.circular(10.0),
      //            ),
                  onPressed:(){
                    _deleteModal();
      //              _changeEditType(0); //編集TOP
                  } ,
                ),
              ),
            ),
          )
          : Container();
  }
}