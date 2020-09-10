import 'dart:io';
import 'dart:async';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/edit/Titleform.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/edit/Howto.dart';


class RecipiEdit extends StatefulWidget{

  @override
  _RecipiEditState createState() => _RecipiEditState();
}

class _RecipiEditState extends State<RecipiEdit>{

  DBHelper dbHelper;
  Common common;
  int _selectedID;                //編集するID
//  String _thumbnail;            //サムネイル DB送信用
  int _type;                      //レシピ種別 1:写真レシピ 2:MYレシピ 3:テキストレシピ
  List<Ingredient> _ingredients;  //材料リスト
  List<HowTo> _howTos;            //作り方リスト
  List<Photo> _photos;            //詳細の内容の写真(写真を追加欄)
//  List<File> imageFiles = new List<File>(); //詳細の内容の写真(写真を追加欄)
  int _backScreen = 0;            //0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面

  final _stateController = TextEditingController();
  final _visionTextController = TextEditingController();
  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
  bool _isError = false;
  bool _isDescriptionEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    common = Common();
    setState(() {
      //戻る画面を取得
      this._backScreen = Provider.of<Display>(context, listen: false).getBackScreen();
      //idを取得
      this._selectedID = Provider.of<Display>(context, listen: false).getId();
      print('ID:${_selectedID}');
      //レシピ種別を取得
      this._type = Provider.of<Display>(context, listen: false).getType();
      print('レシピ種別:${this._type}');
    });

    TitleForm titleform = Provider.of<Display>(context, listen: false).getTitleForm();
    //新規投稿の場合
    if(_selectedID == -1){
      print('new!!!!');
      //初期表示の場合
      if(titleform == null){
        //TitleFormの作成
        TitleForm newTitleForm = TitleForm(title:'',description:'',unit:1,quantity: 1,time: 0);
        //TitleForm
        Provider.of<Display>(context, listen: false).setTitleForm(newTitleForm);
        //説明をセットする
        setState(() {
          //説明をセットする
          this._visionTextController.text = newTitleForm.description;
        });
        return;
      }
    }else{
      //更新の場合
      print('update!!!!');
    }
    if(this._type == 3){
      setState(() {
        //説明をセットする
        this._visionTextController.text = titleform.description;
      });
    }

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
    //レシピ
    if(this._backScreen == 1) {
      //フォルダ別一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(4);
      //ごはん日記または、アルバム
    }else if(this._backScreen == 2 || this._backScreen == 4){
      //2:ごはん日記へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
      Provider.of<Display>(context, listen: false).setState(1);
      //ホーム
    }else if(this._backScreen == 3){
      //ホーム画面へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(0);
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }
    _init();
  }

  //初期化処理
  void _init(){
    //リセット処理
    Provider.of<Display>(context, listen: false).reset(); //編集フォーム
    Provider.of<Detail>(context, listen: false).reset();  //詳細フォーム
  }

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

  //保存する押下時処理
  void _onSubmit() async {
    String thumbnail = Provider.of<Display>(context, listen: false).getThumbnail();
    //新規登録の場合
    if(_selectedID == -1){
      //サムネイル
      var titleIsEmpty = Provider.of<Display>(context, listen: false).IsEmptyTitleForm();
      //内容が未入力の場合
      if(thumbnail.isEmpty && titleIsEmpty) {
        //DBに登録せず、一覧リストへ戻る
        if (_type == 2) {
          if (this._ingredients.length == 0 && this._howTos.length == 0) {
//            print('2:空');
          _onList();
            return;
          }
        } else {
          if (this._photos.length == 0) {
//            print('1:空');
          _onList();
            return;
          }
        }
      }
      //内容のいずれかが入力されている場合
      //タイトル、説明、分量、単位、調理時間
      TitleForm titleForm = Provider.of<Display>(context, listen: false).getTitleForm();
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
      Myrecipi recipi = Provider.of<Detail>(context, listen: false).getRecipi();
      //タイトル、説明、分量、単位、調理時間
      TitleForm titleForm = Provider.of<Display>(context, listen: false).getTitleForm();
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
      //更新したレシピIDの最新情報の取得し、詳細フォームへ反映させる
      //recipiをselectし、set
      var newMyrecipi = await dbHelper.getMyRecipi(_selectedID);
      Provider.of<Detail>(context, listen: false).setRecipi(newMyrecipi);
      //MYレシピの場合
      if (this._type == 2) {
        //recipi_ingredientテーブルをselectし、set
        var ingredients = await dbHelper.getIngredients(_selectedID);
        Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
        //recipi_howtoテーブルをselectし、set
        var howTos = await dbHelper.getHowtos(_selectedID);
        Provider.of<Detail>(context, listen: false).setHowTos(howTos);
        //写真レシピの場合
      } else {
        //recipi_photoテーブルをselectし、set
        var photos = await dbHelper.getRecipiPhotos(_selectedID);
        Provider.of<Detail>(context, listen: false).setPhotos(photos);
      }
      //詳細画面へ遷移
      Provider.of<Display>(context, listen: false).setState(1);
      //初期化
      Provider.of<Display>(context, listen: false).reset(); //編集フォーム
    }
  }

  //写真削除処理
  void _onPhotoDelete(int index) async {
    print('####delete');
    //写真リストの取得
    List<Photo> photos = Provider.of<Display>(context, listen: false).getPhotos();
    //該当の写真を削除
    photos.removeAt(index);
    for(var i = 0; i < photos.length; i++){
      //noを採番し直す
      photos[i].no =  i + 1;
    }
    setState(() {
      //最新の写真リストを取得
      this._photos = Provider.of<Display>(context, listen: false).getPhotos();
    });
  }

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal({bool thumbnail,bool edit,Photo photo,int index}) async {
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
//    File imageFile = await ImagePicker.pickImage(source: source,imageQuality: 50);
    File imageFile = await ImagePicker.pickImage(source: source);

    // 画像が選択されなかった場合はスキップ
    if (imageFile == null) {
      return;
    }
    print('###setしたimagepath:${imageFile.path}');

    File thumbnailfile = imageFile;
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
        await this._cropImage(imageFile: imageFile);
        //文字変換処理の呼び出し
        await this._vision();
      }else{
        setState(() {
          //セット
          Provider.of<Display>(context, listen: false).setThumbnail(imageFile.path);
        });
      }
    //写真エリアの場合
    }else{
      //写真追加の場合
      Photo photo = Photo(path: imageFile.path);
        if(!edit){
          setState(() {
            Provider.of<Display>(context, listen: false).addPhoto(photo);
          });
          //写真変更の場合
        }else{
          setState(() {
            Provider.of<Display>(context, listen: false).setPhoto(index,photo);
          });
        }

    }
  }

  //写真のトリミング処理
  Future<void> _cropImage({File imageFile}) async {
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
    if (croppedFile != null) {
      setState(() {
        File image = croppedFile;
        //セット
        Provider.of<Display>(context, listen: false).setThumbnail(image.path);
      });
    }
  }

  //材料編集エリア
  Column _addIngredient(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._ingredients = Provider.of<Display>(context, listen: false).getIngredients();
    });
    //材料リストを展開する
    for(var i=0; i < this._ingredients.length; i++){
      column.add(
          SizedBox(
//            height: MediaQuery.of(context).size.height * 0.06,
//            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: EdgeInsets.only(top: 10,bottom: 10),
              color: Colors.white,
              child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('${_ingredients[i].name}',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text('${this._ingredients[i].quantity}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
//                        fontWeight: FontWeight.bold
                          ),),
                      ),
                    ],
                  ),
//                  child: Image.memory(imageFiles[i].readAsBytesSync()),
                  onTap: (){
                    print('材料編集');
                    _changeEditType(editType: 2,index: i,); //材料
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
    // + 材料を追加 ボタン
    column.add(
      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.06,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: InkWell(
              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add_circle_outline,color: Colors.brown[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('材料を追加',style: TextStyle(
                        color: Colors.brown[100 * (1 % 9)],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
                print('材料追加');
                _changeEditType(editType: 2); //材料
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

  //作り方編集エリア
  Column _addHowTo(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._howTos = Provider.of<Display>(context, listen: false).getHowTos();
    });
    print('作り方リスト:${this._howTos.length}');
    //作り方リストを展開する
    for(var i=0; i < this._howTos.length; i++){
      column.add(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 200,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SizedBox(
                        child: Container(
                          width: 250,
//                          padding: EdgeInsets.all(10),
                          child: Text('${_howTos[i].memo}',
                            maxLines: 10,
                            style: TextStyle(
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                            ),),
                        ),
                      ),
                      _howTos[i].photo.isNotEmpty
                        ? SizedBox(
                            height: 100,
                            width: 100,
                            child: Container(
                              child: InkWell(
                                child: Image.file(File(_howTos[i].photo),fit: BoxFit.cover,),
    //                              onTap: (){}
                              ),
                            ),
                          )
                        : Container(),
                    ],
                  ),
                  onTap: (){
                    print('作り方編集');
                    _changeEditType(editType: 3,index: i,); //作り方
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
    // + 作り方を追加 ボタン
    column.add(
      SizedBox(
//        width: MediaQuery.of(context).size.width,
//        height: 50,
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: InkWell(
              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add_circle_outline,color: Colors.brown[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('作り方を追加',style: TextStyle(
                        color: Colors.brown[100 * (1 % 9)],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
                print('作り方を追加');
                _changeEditType(editType: 3); //作り方
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

  //写真編集エリア
  Column _addPhoto(){
    List<Widget> column = new List<Widget>();
    setState(() {
      this._photos = Provider.of<Display>(context, listen: false).getPhotos();
    });
    //追加したイメージを展開する
    for(var i=0; i < _photos.length; i++){
      column.add(
          SizedBox(
//            height: 200,
//            width: 400,
            child: Container(
              child: InkWell(
                  child: Image.file(File(_photos[i].path),fit: BoxFit.cover,),
                  onTap: _isDescriptionEdit ? null : (){
                    print('###tap!!!!');
                    print('no:${_photos[i].no},path:${_photos[i].path}');
                    _showImgSelectModal(thumbnail: false,edit: true,photo: _photos[i],index: i);
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
    if(!_isDescriptionEdit)
    column.add(
      SizedBox(
        child: Container(
          padding: EdgeInsets.all(10),
          color: Colors.white,
          child: InkWell(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      child: Icon(Icons.add_circle_outline,color: Colors.brown[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('写真を追加',style: TextStyle(
                        color: Colors.brown[100 * (1 % 9)],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
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
//    print('###column:${column}');
    return Column(
      children: column,
    );
  }

  //各エリアの追加ボタン押下
  void _changeEditType({editType,index}){
    Provider.of<Display>(context, listen: false).setEditType(editType);
    if(editType > 1){
      if(index != null){
        Provider.of<Display>(context, listen: false).setEditIndex(index);
      }
    }
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
                  _onDelete();
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
    this._setIsLoading();
//    this._isLoading = !this._isLoading;

    VisionText visionText;
    String thumbnail = Provider.of<Display>(context, listen: false).getThumbnail();

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

        var buf = new StringBuffer();
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
    });
    Provider.of<Display>(context, listen: false).setDescription(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[100 * (1 % 9)],
        leading: _isDescriptionEdit ? Container() : closeBtn(),
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
      body: Stack(
        children: <Widget>[
          scrollArea(),
          showCircularProgress(),
        ],
      )
    );
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: _isDescriptionEdit ? Colors.brown[100 * (1 % 9)] : Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
          child: Text('完了',
            style: TextStyle(
              color: _isDescriptionEdit ? Colors.brown[100 * (1 % 9)] : Colors.brown[100 * (1 % 9)],
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
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return IconButton(
      icon: Icon( _selectedID == -1 ? Icons.close : Icons.arrow_back_ios,color: Colors.white,size: 30,),
      onPressed: (){
        _onList();
      },
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
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children:
            _type == 1 || _type == 3
            ? _type == 1
                ? <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(), //タイトル
                  line(),
                  photoArea(), //写真
                  line(),
                  photoAddArea(), //写真入力欄
                  line(),
                  deleteButtonArea(),//削除ボタン
               ]
                : <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(),     //タイトル
                  DescriptionTitleArea(),
                  ocrTextArea(),   //文字変換
                  line(),
                  photoArea(), //写真
                  line(),
                  photoAddArea(), //写真入力欄
                  line(),
                  deleteButtonArea(), //削除ボタン
              ]
             : <Widget>[
              thumbnailArea(), //トップ画像
              titleArea(), //タイトル
              line(),
              ingredientArea(), //材料
              line(),
              ingredientAddArea(), //材料入力欄
              line(),
              howToArea(), //作り方
              line(),
              howToAddArea(), //作り方入力欄
              line(),
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
    return Consumer<Display>(
        builder: (context,Display,_) {
    return
      Display.thumbnail.isEmpty
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
//                    SizedBox(
//                      height: 30,
//                      width: MediaQuery.of(context).size.width,
//                      child: Container(
//                          color: Colors.black26,
//                        child: Center(
//                          child: Text('各項目をタップして編集できます',
//                            style: TextStyle(color: Colors.white,fontSize: 15),
//                          ),
//                        )
//                      ),
//                    )
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
                      Center(child: Image.file(File(Display.thumbnail)),),
//                    child: Image.file(File(Display.thumbnail),fit: BoxFit.cover,),
                      editMsgArea(),
                    ]
                  ),
                  onTap: _isDescriptionEdit ? null : (){
                    _showImgSelectModal(thumbnail: true);
                  }
              ),
            ),
    );
        }
    );
  }

  //トップ画像に表示する文言
  Widget editMsgArea(){
    return
      SizedBox(
        height: 30,
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
    return Consumer<Display>(
      builder: (context,Display,_) {
        return SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
//            height: _type == 3 ? MediaQuery.of(context).size.height * 0.05 : MediaQuery.of(context).size.height * 0.1,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white,
              child: InkWell(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10),
                        child: Text(Display.titleForm.title.isEmpty ? 'タイトルを入力' :'${Display.titleForm.title}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      _type == 3
                      ? Container()
                      : Container(
                        padding: EdgeInsets.all(10),
                        child: Text(Display.titleForm.description.isEmpty ?'レシピの説明やメモを入力' :'${Display.titleForm.description}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 15,
  //                        fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
                  onTap: _isDescriptionEdit ? null : () {
                    print('タイトル');
                    _changeEditType(editType: 1); //タイトル
                  }
              ),
            ),
          );
      }
    );
  }

  //材料
  Widget ingredientArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('材料', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${Display.titleForm.quantity}${_displayUnit(Display.titleForm.unit)}', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      );
    }
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
    return Consumer<Display>(
        builder: (context,Display,_) {
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
            Display.titleForm.time != 0
            ? Container(
              padding: EdgeInsets.all(10),
              child: Text('${Display.titleForm.time}分', style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold
              ),),
            )
            : Container()
          ],
          ),
        ),
      );
        }
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
    return Consumer<Display>(
        builder: (context,Display,_) {
      return
//      Display.type != 1
//        ?
          SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('${Display.titleForm.quantity}${_displayUnit(Display.titleForm.unit)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Display.titleForm.time != 0
                    ? Container(
                  padding: EdgeInsets.all(10),
                  child: Text('${Display.titleForm.time}分', style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                )
                    : Container()
              ],
            ),
          ),
        );
//          :Container();
    },
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
    return Consumer<Display>(
        builder: (context,Display,_) {
      return
//        Display.thumbnail.isEmpty
//        ? Container()
//        :
        Column(
          children: <Widget>[
            line(),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.white30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('説明/メモ', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    Display.thumbnail.isEmpty
                    ? Container()
                    :
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.text_fields,
                              color: _isDescriptionEdit ? Colors.grey : Colors
                                  .orangeAccent),
                          Switch(
                            value: this._isDescriptionEdit,
                            activeColor: Colors.orangeAccent,
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
                              ? Colors.orangeAccent
                              : Colors.grey)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            line(),
          ],
        );
    });
  }

  //文字変換テキストエリア
  Widget ocrTextArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
      return
        Display.thumbnail.isEmpty
        ?         Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            width: MediaQuery.of(context).size.width,
            child: Container(
//                  width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(top: 13,bottom: 13),
          child: Text('スキャンする画像が登録されると、文字変換されます。',
            style: TextStyle(fontSize: 15,color: Colors.grey)
          ),
        ),
        )
        :
        Container(
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
        );
    });
  }

  //削除ボタン
  Widget deleteButtonArea() {
    return
      _selectedID != -1 && !_isDescriptionEdit
          ? Container(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 200,
          height: 50,
          child: RaisedButton.icon(
            icon: Icon(Icons.delete,color: Colors.white,),
            label: Text('レシピを削除する'),
            textColor: Colors.white,
            color: Colors.redAccent,
//            shape: RoundedRectangleBorder(
//              borderRadius: BorderRadius.circular(10.0),
//            ),
            onPressed:(){
              _deleteModal();
//              _changeEditType(0); //編集TOP
            } ,
          ),
        ),
      )
          : Container();
  }

  //null参照時に落ちない用、flutterで用意されてるを実装
  //CircularProgressIndicator() => 円形にグルグル回るタイプのやつ
  Widget showCircularProgress() {
    return
      _isLoading
      //通信中の場合
      ? Center(child: CircularProgressIndicator())
      : Container();
  }


}