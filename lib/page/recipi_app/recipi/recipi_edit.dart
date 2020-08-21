import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
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
  int _selectedID;                //編集するID
//  String _thumbnail;            //サムネイル DB送信用
  int _type;                      //レシピ種別 1:写真レシピ 2:MYレシピ 3:テキストレシピ
  List<Ingredient> _ingredients;  //材料リスト
  List<HowTo> _howTos;            //作り方リスト
  List<Photo> _photos;            //詳細の内容の写真(写真を追加欄)
//  List<File> imageFiles = new List<File>(); //詳細の内容の写真(写真を追加欄)
  int _backScreen = 0;            //0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面

    final _visionTextController = TextEditingController();


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    //戻る画面を取得
    this._backScreen = Provider.of<Display>(context, listen: false).getBackScreen();
    //idを取得
    _selectedID = Provider.of<Display>(context, listen: false).getId();
    print('ID:${_selectedID}');
    //レシピ種別を取得
    this._type = Provider.of<Display>(context, listen: false).getType();
    print('レシピ種別:${this._type}');
    //新規投稿の場合
    if(_selectedID == -1){
      print('new!!!!');
      TitleForm titleform = Provider.of<Display>(context, listen: false).getTitleForm();
      //初めて開かれた場合
      if(titleform == null){
        //TitleFormの作成
        TitleForm newTitleForm = TitleForm(title:'',description:'',unit:1,quantity: 1,time: 0);
        //TitleForm
        Provider.of<Display>(context, listen: false).setTitleForm(newTitleForm);
        return;
      }
    }else{
      //更新の場合
      print('update!!!!');
    }
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

  //前画面へ戻る
//  void _onBack() async {
//      //更新したレシピIDの最新情報の取得し、詳細フォームへ反映させる
//      //recipiをselectし、set
//      var newMyrecipi = await dbHelper.getMyRecipi(_selectedID);
//      Provider.of<Detail>(context, listen: false).setRecipi(newMyrecipi);
//      //MYレシピの場合
//      if (this._type == 2) {
//        //recipi_ingredientテーブルをselectし、set
//        var ingredients = await dbHelper.getIngredients(_selectedID);
//        Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
//        //recipi_howtoテーブルをselectし、set
//        var howTos = await dbHelper.getHowtos(_selectedID);
//        Provider.of<Detail>(context, listen: false).setHowTos(howTos);
//      //写真レシピの場合
//      } else {
//        //recipi_photoテーブルをselectし、set
//        var photos = await dbHelper.getPhotos(_selectedID);
//        Provider.of<Detail>(context, listen: false).setPhotos(photos);
//      }
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(-1);
//      //初期化
//      Provider.of<Display>(context, listen: false).reset(); //編集フォーム
//  }

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
    PickedFile imageFile = await ImagePicker().getImage(source: source);
    //変換
//    var imageByte = await imageFile.readAsBytes();
//    String imgString = await base64Encode(imageByte);

    // 撮影せずに閉じた場合はnullになる
    if (imageFile == null) {
      return;
    }

    print('###setしたimagepath:${imageFile.path}');

//    一時的にローカル保存
//    var savedFile = await FileController.saveLocalImage(imageFile); //追加
//    this.imageFiles.add(savedFile);

    setState(() {
      //サムネイル画像の場合
      if(thumbnail){
        //セット
        Provider.of<Display>(context, listen: false).setThumbnail(imageFile.path);
      //写真エリアの場合
      }else{
        //写真追加の場合
        Photo photo = Photo(path: imageFile.path);
        if(!edit){
          Provider.of<Display>(context, listen: false).addPhoto(photo);
        //写真変更の場合
        }else{
          Provider.of<Display>(context, listen: false).setPhoto(index,photo);
        }
      }
    });
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
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            child: Container(
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
        height: MediaQuery.of(context).size.height * 0.06,
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
        height: MediaQuery.of(context).size.height * 0.06,
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
                    child: Text('作り方を追加',style: TextStyle(
                        color: Colors.cyan,
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
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.width,
            child: Container(
              child: InkWell(
//                  child: Image.memory(imageFiles[i].readAsBytesSync()),
                  child: Image.file(File(_photos[i].path),fit: BoxFit.cover,),
                  onTap: (){
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

  //テキスト変換
  void vision() async {
    String thumbnail = Provider.of<Display>(context, listen: false).getThumbnail();

    if (thumbnail.isNotEmpty) {

//      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(File(this._image.path));
//      VisionText visionText = await textRecognizer.processImage(visionImage);
//
//      String text = visionText.text;
//      //コンソール出力
//      print('visionText.blocks:${visionText.blocks.length}');
//      print('visionText.text:${text}');
//
//      var buf = new StringBuffer();
//      for (TextBlock block in visionText.blocks) {
//        final Rect boundingBox = block.boundingBox;
//        final List<Offset> cornerPoints = block.cornerPoints;
//        final String text = block.text;
////        print('block.text${text}');
//        final List<RecognizedLanguage> languages = block.recognizedLanguages;
////        print(languages);
////        buf.write("=====================\n");
//        for (TextLine line in block.lines) {
//          // Same getters as TextBlock
//          buf.write("${line.text}\n");
//          for (TextElement element in line.elements) {
//            // Same getters as TextBlock
//          }
//        }
//      }
//      setState(() {
//        //入力フォームへ反映させる
//        this._visionTextController.text = buf.toString();
//      });
    }
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
      body: scrollArea(),
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
                //_type == 3
                : <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(), //タイトル
                  line(),
                  ocrArea(),
//                  photoArea(), //写真
//                  line(),
//                  photoAddArea(), //写真入力欄
                  line(),
                  deleteButtonArea(),//削除ボタン
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
              color: Colors.grey,
              child: InkWell(
                  child: Icon(Icons.camera_alt,color: Colors.white,size: 100,),
                  onTap: (){
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
//                  child: Image.memory(topImageFile.readAsBytesSync()),
                  child: Image.file(File(Display.thumbnail),fit: BoxFit.cover,),
                  onTap: (){
                    _showImgSelectModal(thumbnail: true);
                  }
              ),
            ),
    );
        }
    );
  }

  //レシピタイトル
  Widget titleArea(){
    return Consumer<Display>(
      builder: (context,Display,_) {
        return SizedBox(
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
                        child: Text(Display.titleForm.title.isEmpty ? 'タイトルを入力' :'${Display.titleForm.title}',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),),
                      ),
                      Container(
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
                  onTap: () {
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
//    return Consumer<Display>(
//        builder: (context,Display,_) {
      return
        Container(
        child: _addPhoto(),
      );
//    });
  }

  Widget ocrArea(){
    return
      SizedBox(
        height: 130,
//        width: _getWidth(MediaQuery.of(context).size.width),
        child: Container(
          width: 400,
          child: TextField(
            controller: _visionTextController,
            autofocus: false,
            minLines: 5,
            maxLines: 5,
            decoration: const InputDecoration(
//              hintText: 'メモを入力',
              border: InputBorder.none,
            ),
          ),
        ),
      );
  }

  //削除ボタン
  Widget deleteButtonArea() {
    return
      _selectedID != -1
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


}