import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';

class RecipiDetail extends StatefulWidget{

  Myrecipi Nrecipi = Myrecipi();
  List<Ingredient> Ningredients = [];      //レシピIDに紐づく材料リスト
  List<HowTo> NhowTos = [];                //レシピIDに紐づく作り方リスト
  List<Photo> Nphotos = [];                //レシピIDに紐づく写真

  RecipiDetail({Key key, @required this.Nrecipi,@required this.Ningredients,@required this.NhowTos,@required this.Nphotos,}) : super(key: key);

  @override
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{

  DBHelper dbHelper;
  Common common;
  bool _isEdit = false;
  Myrecipi _recipiOld = Myrecipi();
  List<Ingredient> _ingredientsOld = [];      //レシピIDに紐づく材料リスト
  List<HowTo> _howTosOld = [];                //レシピIDに紐づく作り方リスト
  List<Photo> _photosOld = [];                //レシピIDに紐づく写真
  static GlobalKey previewContainer = GlobalKey();

  final _stateController = TextEditingController();
  final _visionTextController = TextEditingController();
  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
  bool _isError = false;
  bool _isDescriptionEdit = false;
  bool _isLoading = false;

  @override
  void initState() {
   super.initState();
    _init();
  }

  @override
  void dispose() {
    this._stateController.dispose();
    this._visionTextController.dispose();
    super.dispose();
  }

  _init() async {
    dbHelper = DBHelper();
    common = Common();
  }

  //レシピの編集ボタン押下時処理
  void _onEdit(){
    setState(() {
      this._isEdit = !this._isEdit;
      var recipi = widget.Nrecipi;
      this._recipiOld = Myrecipi
        (
           id: recipi.id
          ,type: recipi.type
          ,thumbnail: recipi.thumbnail
          ,title: recipi.title
          ,description: recipi.description
          ,quantity: recipi.quantity
          ,unit: recipi.unit
          ,time: recipi.time
          ,folder_id: recipi.folder_id
        );
      widget.NhowTos.forEach((howto) => this._howTosOld.add(howto));
      widget.Ningredients.forEach((ingredient) => this._ingredientsOld.add(ingredient));
      widget.Nphotos.forEach((photo) => this._photosOld.add(photo));
      print('recipi:${this._recipiOld.id}');
      print('hotos:${this._howTosOld.length}');
      print('ingredient:${this._ingredientsOld.length}');
      print('photo:${this._photosOld.length}');
    });
  }

  //材料編集エリア
  Column _addIngredient(){
    List<Widget> column = new List<Widget>();
    setState(() {
    });
    //材料リストを展開する
    for(var i=0; i < this.widget.Ningredients.length; i++){
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          width: MediaQuery.of(context).size.width,
          child: Container(
            color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${widget.Ningredients[i].name}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                        ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${this.widget.Ningredients[i].quantity}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
                        ),),
                    ),
                  ],
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
    return Column(
      children: column,
    );
  }

  //作り方編集エリア
  Column _addHowTo(){
    List<Widget> column = new List<Widget>();
    setState(() {
    });
    //作り方リストを展開する
    for(var i=0; i < this.widget.NhowTos.length; i++){
      column.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 200,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      child: Container(
                        width: 250,
                        child: Text('${widget.NhowTos[i].memo}',
                          maxLines: 10,
                          style: TextStyle(
                            fontSize: 15,
                          ),),
                      ),
                    ),
                    widget.NhowTos[i].photo.isNotEmpty
                        ? Card(
                      child: Container(
                        height: 100,
                        width: 100,
                          child: Image.file(File(widget.NhowTos[i].photo),fit: BoxFit.cover,),
                      ),
                    )
                        : Container(),
                  ],
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
    return Column(
      children: column,
    );
  }

  //写真編集エリア
  Column _addPhoto(){
    List<Widget> column = new List<Widget>();
    setState(() {
    });
    //追加したイメージを展開する
    for(var i=0; i < widget.Nphotos.length; i++){
      column.add(
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: InkWell(
                child: Image.file(File(widget.Nphotos[i].path),fit: BoxFit.cover,),
                onTap: (){
//                  print('###tap!!!!');
//                  print('no:${widget.Nphotos[i].no},path:${widget.Nphotos[i].path}');
//                  _showImgSelectModal(thumbnail: false,edit: true,photo: widget.Nphotos[i],index: i);
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
    return Column(
      children: column,
    );
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

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal({bool thumbnail,bool edit,Photo photo,int index}) async {
    //サムネイル且つ、スキャンカメラの場合
    if(thumbnail && widget.Nrecipi.type == 3){
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

  //写真削除処理
  void _onPhotoDelete(int index) async {
    print('####delete');
    setState(() {
      //写真リストの取得
      //該当の写真を削除
      widget.Nphotos.removeAt(index);
      for(var i = 0; i < widget.Nphotos.length; i++){
        //noを採番し直す
        widget.Nphotos[i].no =  i + 1;
      }
    });
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
      if(widget.Nrecipi.type == 3 ){
        //写真のトリミング処理の呼び出し
        var isNull = await this._cropImage(imageFile: imageFile);
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
          widget.Nrecipi.thumbnail = imageFile.path;
        });
      }
      //写真エリアの場合
    }else{
      //写真追加の場合
      Photo photo = Photo(path: imageFile.path);
      if(!edit){
        setState(() {
          var no = widget.Nphotos.length + 1;
          Photo item  = Photo(no:no,path: photo.path);
          widget.Nphotos.add(item);
        });
        //写真変更の場合
      }else{
        setState(() {
          widget.Nphotos[index].path = photo.path;
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
      widget.Nrecipi.thumbnail = image.path;
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

  //文字変換処理
  Future<void> _vision() async {
    print('文字変換処理');
    this._setIsLoading();

    VisionText visionText;
    String thumbnail = widget.Nrecipi.thumbnail;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: previewContainer,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepOrange[100 * (1 % 9)],
          leading: backBtn(),
          elevation: 0.0,
          title: Center(
            child: Text('レシピ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
//                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
              ),
            ),
          ),
          actions: <Widget>[
            shareBtn(),
            editBtn(),
          ],
        ),
        body: scrollArea(),
      ),
    );
  }

  //シェアボタン
  Widget shareBtn() {
    return IconButton(
      icon: const Icon(Icons.share, color: Colors.white, size: 30,),
      onPressed: () {
        common.takeWidgetScreenShot(previewContainer);
      },
    );
  }

  //編集ボタン
  Widget editBtn(){
    return IconButton(
      icon: const Icon(Icons.edit,color: Colors.white,size: 30,),
      onPressed: (){
        _onEdit();
      },
    );
  }

  //戻るボタン
  Widget backBtn(){
    return IconButton(
        icon: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 30,),
        onPressed: (){
          Navigator.pop(context);
//          _onList();
        },
    );
  }

  //レシピ詳細
  Widget scrollArea(){
    return Container(
      key: GlobalKey(),
      child: SingleChildScrollView(
        key: GlobalKey(),
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
            widget.Nrecipi.type == 1 ||  widget.Nrecipi.type == 3
              ? widget.Nrecipi.type == 1
                ? <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(), //タイトル
//                  line(),
                  photoArea(), //写真
//                  line(),
                  photoAddArea(), //写真入力欄
//                  line(),
                ]
                : <Widget>[
                  thumbnailArea(), //トップ画像
                  titleArea(), //タイトル
//                  line(),
                  DescriptionTitleArea(),
                  ocrTextArea(),   //文字変換
//                  line(),
                  photoArea(), //写真
//                  line(),
                  photoAddArea(), //写真入力欄
//                  line(),
                ]
              : <Widget>[
                thumbnailArea(), //トップ画像
                titleArea(), //タイトル
//                line(),
                ingredientArea(), //材料
//                line(),
                ingredientAddArea(), //材料入力欄
//                line(),
                howToArea(), //作り方
//                line(),
                howToAddArea(), //作り方入力欄
                line(),
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
    return
      _isEdit
      //編集画面の場合
      ? widget.Nrecipi.thumbnail.isEmpty
        //サムネイル未登録の場合
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
                          Center(child: Text(widget.Nrecipi.type == 3 ? 'スキャンする写真を登録' : '写真を登録', style: TextStyle(fontSize: 20,color: Colors.grey),)),
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
        //サムネイル登録済みの場合
        : SizedBox(
          height: MediaQuery.of(context).size.height * 0.40,
          width: MediaQuery.of(context).size.width,
          child: Container(
            child: InkWell(
                child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: <Widget>[
                      Center(child: Image.file(File(widget.Nrecipi.thumbnail)),),
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
      : widget.Nrecipi.thumbnail.isEmpty
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
                child: Image.file(File(widget.Nrecipi.thumbnail),fit: BoxFit.cover,),
                onTap: (){
                  //                      _showImgSelectModal(thumbnail: true);
                }
            ),
          ),
        );
  }

  //レシピタイトル
  Widget titleArea(){
    return
      SizedBox(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${widget.Nrecipi.title}',
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),),
              ),
              widget.Nrecipi.type == 3
              ? Container()
              : Container(
                padding: EdgeInsets.all(10),
                child: Text('${widget.Nrecipi.description}',
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
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.deepOrange[100 * (2 % 9)],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('材料', style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                  fontWeight: FontWeight.bold
              ),),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Text('${widget.Nrecipi.quantity}${_displayUnit(widget.Nrecipi.unit)}', style: TextStyle(
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

  //材料追加
  Widget ingredientAddArea(){
    return Container(
      child: _addIngredient(),
    );
  }

  //作り方
  Widget howToArea(){
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.deepOrange[100 * (2 % 9)],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('作り方',style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                  fontWeight: FontWeight.bold
              ),),
            ),
            widget.Nrecipi.time != 0
              ? Container(
                  padding: EdgeInsets.all(10),
                  child: Text('${widget.Nrecipi.time}分', style: TextStyle(
                    color: Colors.white,
                      fontSize: 15,
//                      fontWeight: FontWeight.bold
                  ),),
                )
              : Container()
          ],
        ),
      ),
    );
  }

  //材料追加
  Widget howToAddArea(){
    return Container(
      child: _addHowTo(),
    );
  }

  Widget DescriptionTitleArea(){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
          return
//            Display.thumbnail.isEmpty
//                ? Container()
//                :
            Column(
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
                          padding: EdgeInsets.all(10),
                          child: Text('説明', style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                          ),),
                        ),
                      ],
                    ),
                  ),
                ),
//                line(),
              ],
            );
//        });
  }

  //文字変換テキストエリア
  Widget ocrTextArea(){
          return
            Container(
              padding: EdgeInsets.only(left: 15, right: 15),
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.only(top: 13),
                child: Text('${widget.Nrecipi.description}',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            );
  }

  //写真エリア
  Widget photoArea(){
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('${widget.Nrecipi.quantity}${_displayUnit(widget.Nrecipi.unit)}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
//                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              widget.Nrecipi.time != 0
                ? Container(
                    padding: EdgeInsets.all(10),
                    child: Text('${widget.Nrecipi.time}分', style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
//                        fontWeight: FontWeight.bold
                    ),),
                  )
                : Container()
            ],
          ),
        ),
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
}