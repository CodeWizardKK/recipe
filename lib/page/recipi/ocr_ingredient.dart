import 'dart:io';
import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:list_group/list_group_item.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/edit/ocr/blockLine.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';

import 'package:recipe_app/model/Myrecipi.dart';


class OcrIngredient extends StatefulWidget{
  OcrIngredient({Key key, @required this.ingredients, @required this.thumbnail}) : super(key: key);

  List<Ingredient> ingredients = [];
  String thumbnail = '';

  @override
  _OcrIngredientState createState() => _OcrIngredientState();
}

class _OcrIngredientState extends State<OcrIngredient>{

  DBHelper dbHelper;
  Common common;
  String _name = '';             //モーダルにて入力した値
  // final _name = TextEditingController();      //材料名
  final _quantity = TextEditingController();  //分量
  bool _isNew = true;                        //true:新規 false:更新

  List<Model> _ingredientsOCR = List<Model>();
  List<Model> _bkIngredientsOCR = List<Model>();
  List<Model> _quantitysOCR = List<Model>();

  final TextRecognizer _textRecognizer = FirebaseVision.instance.cloudTextRecognizer();
  // Myrecipi _recipi = Myrecipi(id:-1,type: 3,thumbnail: '',title: '',description: '',quantity: -1,unit: -1,time:-1,folder_id: -1);
  final _stateController = TextEditingController();
  final _visionTextController = TextEditingController();
  bool _isError = false;
  bool _isDescriptionEdit = false;
  bool _isLoading = false;
  bool _isEdit = false;

  final FocusNode _focus = FocusNode();
  bool _isFocus = false;

  @override
  void initState() {
    super.initState();
    this._init();
    this._focus.addListener(_onFocusChange);
    this._showImgSelectModal(thumbnail: true);
  }

  Future<void> _init() async {
    setState(() {
      this.dbHelper = DBHelper();
      this.common = Common();
      this._bkIngredientsOCR = [];
      if(widget.ingredients.length != 0){
        for(var i = 0; i < widget.ingredients.length; i++){
          Model ingredientOCR = Model(
            id: widget.ingredients[i].id,
            no: widget.ingredients[i].no,
            name: widget.ingredients[i].name,
          );
          Model quantityOCR = Model(
            id: widget.ingredients[i].id,
            no: widget.ingredients[i].no,
            name: widget.ingredients[i].quantity,
          );
          setState(() {
            this._ingredientsOCR.add(ingredientOCR);
            this._quantitysOCR.add(quantityOCR);
          });
        }
      } else {
        this._ingredientsOCR = [];
        this._quantitysOCR = [];
      }
      // print('ingredients:${widget.ingredients.length}');
    });
  }

  //フォーカスが当たっているか監視する
  Future<void> _onFocusChange() async {
    //キーボードにフォーカスが当たった瞬間
    if(_focus.hasFocus){
      setState(() {
        this._isFocus = _focus.hasFocus;
      });
      print("Focus: " + _focus.hasFocus.toString());
    } else{
      //キーボードにフォーカスが当たってない瞬間のみ100ms後にセットする => キーボードが閉じるのに時差がある為
      Future.delayed(Duration(milliseconds: 100),(){
        setState(() {
          this._isFocus = _focus.hasFocus;
        });
        print("Focus: " + _focus.hasFocus.toString());
      });
    }
  }

  @override
  void dispose() {
    this._stateController.dispose();
    this._visionTextController.dispose();
    super.dispose();
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    List<int> ids = [];
    List<int> nos = [];
    var maxID = 0;
    var maxNO = 0;

    //材料リスト、分量リストのlengthを合わせる
    if(this._ingredientsOCR.length != this._quantitysOCR.length){
      print('材料リスト !=  分量リスト');
      //材料リストの方が大きい場合
      if(this._ingredientsOCR.length > this._quantitysOCR.length){
        print('材料リストが大きい');
        this._quantitysOCR.forEach((quantity) {
          ids.add(quantity.id);
          nos.add(quantity.no);
        });
        //分量リストの最大値を取得
        maxID = ids.reduce(max);
        maxNO = nos.reduce(max);
        print('[max]ID:${maxID},NO:${maxNO}');
        for(var i = maxNO; i < this._ingredientsOCR.length; i++){
          setState(() {
            print('**************** ADD ****************');
            maxID++;
            maxNO++;
            this._quantitysOCR.add(Model(id: maxID,no: maxNO,name: ''));
          });
        }
      } else {
        //分量リストの方が大きい場合
        print('分量リストが大きい');
        this._ingredientsOCR.forEach((quantity) {
          ids.add(quantity.id);
          nos.add(quantity.no);
        });
        //材料リストの最大値を取得
        maxID = ids.reduce(max);
        maxNO = nos.reduce(max);
        print('[max]ID:${maxID},NO:${maxNO}');
        for(var i = maxNO; i < this._quantitysOCR.length; i++){
          setState(() {
            print('**************** ADD ****************');
            maxID++;
            maxNO++;
            this._ingredientsOCR.add(Model(id: maxID,no: maxNO,name: ''));
          });
        }
      }
    }
    print('++++材料リスト(調整済み)+++++');
    this._ingredientsOCR.forEach((ingredient) => print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}'));
    print('++++分量リスト(調整済み)+++++');
    this._quantitysOCR.forEach((quantity) => print('id:${quantity.id},no:${quantity.no},name:${quantity.name}'));
    print('+++++++++++++++++++++++++++++++++++++');

    //材料、分量をIngredient型にセットする
    List<Ingredient> ingredients = [];
    for(var i = 0; i < this._ingredientsOCR.length; i++){
      for(var k = 0; k < this._quantitysOCR.length; k++){
        if(this._ingredientsOCR[i].no == this._quantitysOCR[k].no){
          ingredients.add(
              Ingredient(
                  id: this._ingredientsOCR[i].id
                  ,no: this._ingredientsOCR[i].no
                  ,name: this._ingredientsOCR[i].name
                  ,quantity: this._quantitysOCR[k].name));
          break;
        }
      }
    }
    ingredients.forEach((ingredient) =>print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name},quantity:${ingredient.quantity}'));
    RESULT result = RESULT(thumbnail: widget.thumbnail, ingredients: ingredients);
    Navigator.pop(context,result);
//     //更新の場合
//     if(!_isNew){
//       this._ingredient.name = _name.text;
//       this._ingredient.quantity = _quantity.text;
// //      print('id:${this._ingredient.id},no:${this._ingredient.no},name:${this._ingredient.name},quantity:${this._ingredient.quantity}');
//       Navigator.pop(context,this._ingredient);
//     //新規の場合
//     } else {
//       //入力内容が未入力以外の場合
//       if(!_isEmptyCheck()){
//         this._ingredient.id = -1;
//         this._ingredient.name = _name.text;
//         this._ingredient.quantity = _quantity.text;
// //        print('id:${this._ingredient.id},no:${this._ingredient.no},name:${this._ingredient.name},quantity:${this._ingredient.quantity}');
//         Navigator.pop(context,this._ingredient);
//       //未入力の場合
//       } else {
//         Navigator.pop(context);
//       }
//     }
  }

  //写真削除処理
  void _onPhotoDelete(int index) async {
  }

  //文字変換処理
  Future<void> _vision() async {
//    print('文字変換処理');
    this._setIsLoading();

    VisionText visionText;
    String thumbnail = widget.thumbnail;

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
//        print('Error: ${e}');
//        print('visionText: ${visionText}');
        setState(() {
          this._visionTextController.text = '';
          this._isError = !this._isError;
        });
        this._setIsLoading();
        //エラーポップアップを表示する
      }
      //OCR(文字認識)処理にてエラーとならなかった場合
      if(!this._isError){
        var buf = StringBuffer();
        List<Model> ingredients = [];
        List<Model> quantitys = [];
        List<BlockLine> blockLines = [];
        int index_i = 0;
        int index_q = 0;
        int index_b = 0;
        double LMin = 0;
        double RMax = 0;
        int index = 0;
        String text = '';
        print('##########################');
        print(visionText.text);
        print(visionText.blocks.length);
        print('##########################');

        setState(() {
          this._bkIngredientsOCR = [];
          this._ingredientsOCR = [];
          this._quantitysOCR = [];
        });

        //1.同一の段に並んでいることを保証する。(Topソート)
        for (TextBlock block in visionText.blocks) {
          for (TextLine line in block.lines) {
            var blockLine = BlockLine(
                id: index_b++
                , boundingBoxLEFT: line.boundingBox.left
                , boundingBoxTOP: line.boundingBox.top
                , boundingBoxRIGHT: line.boundingBox.right
                , boundingBoxBOTTOM: line.boundingBox.bottom
                , text: line.text
            );
            blockLines.add(blockLine);
          }
        }
        blockLines.sort((a,b) => a.boundingBoxTOP.compareTo(b.boundingBoxTOP));
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        blockLines.forEach((line) => print('id:${line.id},boundingBoxTOP:${line.boundingBoxTOP},text:${line.text},'));
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%');
        //2.画像の左@LMinと右@RMaxの最小値と最大値を取得。(for Loop)
        blockLines.forEach((line) {
          if(index == 0){
            //最初の値を取得
            LMin = line.boundingBoxLEFT;
            RMax = line.boundingBoxRIGHT;
            // print('初回セット[LMin:$LMin,RMax:$RMax]');
          } else {
            //最小値比較
            if(line.boundingBoxLEFT < LMin ){
              //最小値を取得
              LMin = line.boundingBoxLEFT;
              // print('最小値更新[LMin:$LMin,RMax:$RMax]');
            }
            //最大値比較
            if(line.boundingBoxRIGHT > RMax ){
              //最大値を取得
              RMax = line.boundingBoxRIGHT;
              // print('最大値更新[LMin:$LMin,RMax:$RMax]');
            }
          }
          index++;
        });
        //3.実際に引き算を行いで左(食材)右(分量)かを判断して振り分ける。(for Loop)
        blockLines.forEach((line) {
            text = line.text;
            //text内のゴミを排除
            text = text.replaceAll('…', '');
            text = text.replaceAll('.', '');
            text = text.replaceAll('·', '');
            text = text.replaceAll(' ', '');
            // text = text.trim();
            if(text.isNotEmpty){
              //振り分け
              if((line.boundingBoxLEFT - LMin) <= (RMax - line.boundingBoxRIGHT) ){
                //左(食材)
                var ingredient = Model(id:index_i,no: index_i + 1,name: text);
                ingredients.add(ingredient);
                index_i++;
              } else {
                //右(分量)
                var quantity = Model(id:index_q,no: index_q + 1,name: text);
                quantitys.add(quantity);
                index_q++;
              }
              buf.write("$text\n");
            }
        });
        print('++++材料リスト+++++');
        ingredients.forEach((ingredient) {
          setState(() {
            // print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}');
            this._ingredientsOCR.add(ingredient);
          });
        });
        this._ingredientsOCR.forEach((ingredient) => print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}'));
        print('++++分量リスト+++++');
        quantitys.forEach((quantity) {
          setState(() {
            this._quantitysOCR.add(quantity);
          });
        });
        this._quantitysOCR.forEach((quantity) => print('id:${quantity.id},no:${quantity.no},name:${quantity.name}'));

        //削除取消し用のbackup
        for(var i = 0; i < this._ingredientsOCR.length; i++){
          Model ingredientOCR = Model(
            id: this._ingredientsOCR[i].id,
            no: this._ingredientsOCR[i].no,
            name: this._ingredientsOCR[i].name,
          );
          setState(() {
            this._bkIngredientsOCR.add(ingredientOCR);
          });
        }
        //入力フォームへ反映させる
        this._setDescription(buf.toString());
        print('**************************');
        print(buf.toString());
        print('**************************');
        this._setIsLoading();
      }
    }
  }

  void _setDescription(String text){
    setState(() {
      //入力フォームへ反映させる
      this._visionTextController.text = text;
      // this._titleForm.description = this._visionTextController.text;
    });
  }

  void _setIsLoading(){
    setState(() {
      this._isLoading = !this._isLoading;
    });
  }

  // bool _isEmptyCheck(){
  //   if(this._name.text.isNotEmpty){
  //     return false;
  //   }
  //   if(this._quantity.text.isNotEmpty){
  //     return false;
  //   }
  //   return true;
  // }

  //画像エリアtap時に表示するモーダル
  Future<void> _showImgSelectModal({bool thumbnail,bool edit,Photo photo,int index}) async {
    // //サムネイル且つ、スキャンカメラの場合
    // if(thumbnail && _type == 3){
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
    // }
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
//          message: const Text('Your options are '),
            actions: <Widget>[
              // !thumbnail //サムネイル画像以外の場合
              //     ? edit     //かつ、セットした写真をtapした場合
              //     ? CupertinoActionSheetAction(
              //   child: const Text('手順を削除'),
              //   onPressed: () {
              //     Navigator.pop(context);
              //     _onPhotoDelete(index);
              //   },
              // )
              //     : Container()
              //     : Container(),
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

  // カメラまたはライブラリから画像を取得
  Future<void> _getAndSaveImageFromDevice({ImageSource source,bool thumbnail,bool edit,Photo photo,int index}) async {

    // 撮影/選択したFileが返ってくる
    PickedFile imageFile = await ImagePicker().getImage(source: source);

    // 画像が選択されなかった場合はスキップ
    if (imageFile == null) {
      return;
    }
//    print('###setしたimagepath:${imageFile.path}');

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
//    print('saveFile:${saveFile.path}');

    //サムネイル画像の場合
    // if(thumbnail){
      //スキャンレシピの場合
      // if(_type == 3 ){
        //写真のトリミング処理の呼び出し
        var isNull = await this._cropImage(imageFile: File(imageFile.path));
        //トリミング処理にてXまたは<ボタン押下時
        if(isNull){
          //編集画面へ戻る
          return;
        }
        //文字変換処理の呼び出し
        await this._vision();
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
//    print('croppedFile:${croppedFile}');
    if (croppedFile != null) {
      File image = croppedFile;
      //セット
      setState(() {
        widget.thumbnail = image.path;
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
//        print('#########saveFile:${saveFile.path}');
      return false;
    } else {
      return true;
    }
  }

  //テキスト欄入力
  void _onChange(String name){
   // print('###入力内容:${name}');
    setState(() {
      this._name = name;
    });
  }


  Future<void> _showDialog({Model selected,String tabType}){
    setState(() {
      //初期化
      this._name = '';
    });
    //モーダル表示
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: IconButton(
                      icon: Icon(Icons.close,color: Colors.deepOrange[100 * (1 % 9)],size: 30,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text( selected.id == -1 ? '追加' : '変更',
                  style: TextStyle(
                      color: Colors.deepOrange[100 * (1 % 9)]
                  ),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: TextField(
                focusNode: this._focus, //フォーカスが当たっているか監視
                controller: TextEditingController(text: selected.name),
                onChanged: _onChange,
                style: const TextStyle(fontSize: 15.0, color: Colors.black,),
                minLines: 1,
                maxLines: 1,
                decoration: InputDecoration(
                  hintText: '${selected.name}',
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 20.0),
                      borderRadius: BorderRadius.circular(0.0)
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: FlatButton(
                      color: Colors.red,
                      child: Text('削除',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        //削除
                        this._keywordDelete(selected,tabType);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.25,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: FlatButton(
                      color: Colors.deepOrange[100 * (1 % 9)],
                      child: Text('保存',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: (){
                        Navigator.pop(context);
                        _onModalSubmit(selected: selected,tabType: tabType);
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        }).then((value) async {
          FocusScope.of(context).unfocus();
          // print('クローズ');
    });
  }

  //モーダルの保存するボタン押下時処理
  void _onModalSubmit({Model selected,String tabType}) async {
    List<int> ids = [];
    List<int> nos = [];
    //空の場合登録せず閉じる
    if(selected.id != -1 && this._name.isEmpty){
      return;
    }
    //材料の場合
    if(tabType == 'ingredients'){
      //追加の場合
      if(selected.id == -1){
        this._ingredientsOCR.forEach((ingredient) {
          ids.add(ingredient.id);//idのみ抽出
          nos.add(ingredient.no);//noのみ抽出
        });
        print('[追加]id:${selected.id},no:${selected.no},name:${this._name}');
        print('[最大値]id:${ids.reduce(max)},no:${nos.reduce(max)}');
        //id,noの最大値を取得し、追加レコードに採番
        this._ingredientsOCR.add(Model(id: ids.reduce(max) + 1, no: nos.reduce(max) + 1, name: this._name));
        this._ingredientsOCR.forEach((ingredient) => print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}'));
      //変更の場合
      } else {
        for(var i=0; i < this._ingredientsOCR.length; i++){
          if(this._ingredientsOCR[i].id == selected.id){
            setState(() {
              this._ingredientsOCR[i].name = this._name;
            });
            break;
          }
        }
      }
    //分量の場合
    } else {
      //追加の場合
      if(selected.id == -1){
        this._quantitysOCR.forEach((quantity) {
          ids.add(quantity.id);//idのみ抽出
          nos.add(quantity.no);//noのみ抽出
        });
        print('[追加]id:${selected.id},no:${selected.no},name:${this._name}');
        print('[最大値]id:${ids.reduce(max)},no:${nos.reduce(max)}');
        //id,noの最大値を取得し、追加レコードに採番
        this._quantitysOCR.add(Model(id: ids.reduce(max) + 1, no: nos.reduce(max) + 1, name: this._name));
        this._quantitysOCR.forEach((quantity) => print('id:${quantity.id},no:${quantity.no},name:${quantity.name}'));
        //変更の場合
      } else {
        for(var i=0; i < this._quantitysOCR.length; i++){
          if(this._quantitysOCR[i].id == selected.id){
            setState(() {
              this._quantitysOCR[i].name = this._name;
            });
            break;
          }
        }
      }
    }
  }

  //削除
  void _keywordDelete(Model selected,String tabType){
    if(tabType == 'ingredients'){
      for(var i = 0; i < this._ingredientsOCR.length; i++){
        if(this._ingredientsOCR[i].id == selected.id){
          setState(() {
            this._ingredientsOCR.removeAt(i);
          });
        }
      }
    } else {
      for(var i = 0; i < this._quantitysOCR.length; i++){
        if(this._quantitysOCR[i].id == selected.id){
          setState(() {
            this._quantitysOCR.removeAt(i);
          });
        }
      }
    }
    //no再取得
    this._getNO(tabType);

  }

  //No取得
  void _getNO(String tabType){
    if(tabType == 'ingredients'){
      setState(() {
        for(var i = 0; i < this._ingredientsOCR.length; i++){
          this._ingredientsOCR[i].no = i + 1;
        }
      });
    } else {
      setState(() {
        for(var i = 0; i < this._quantitysOCR.length; i++){
          this._quantitysOCR[i].no = i + 1;
        }
      });
    }
  }

  List<Model> _createMultiSelectItem(){
    List<Model> ingredients = [];
    for(var i = 0; i < this._ingredientsOCR.length; i++){
      if(this._ingredientsOCR[i].name.isNotEmpty){
        Model ingredient = Model(
          id: this._ingredientsOCR[i].id,
          no: this._ingredientsOCR[i].no,
          name: this._ingredientsOCR[i].name,
        );
        ingredients.add(ingredient);
      }
    }
    return ingredients;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        leading: _isLoading ? Container() : closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text( '材料スキャン',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//                    fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          _isLoading ? Container() : completeBtn(),
        ],
      ),
      body: ModalProgressHUD(
          opacity: 0.5,
          color: Colors.grey,
          progressIndicator: CupertinoActivityIndicator(
            animating: true,
            radius: 20,
          ),
          child: scrollArea(),
          inAsyncCall: _isLoading
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: (){
      //     print('add');
      //   },
      //   child: Icon(Icons.add,size: 30,),
      //   backgroundColor: Colors.red[100 * (3 % 9)],
      // ),
    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
      child: showForm(),
    );
  }

  //トップ画像
  Widget thumbnailArea(){
    return
      widget.thumbnail.isEmpty
          ? SizedBox(
        height: MediaQuery.of(context).size.height * 0.30,
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
                        Center(child: Text('材料の写真を登録', style: TextStyle(fontSize: 20,color: Colors.grey),)),
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
        height: MediaQuery.of(context).size.height * 0.30,
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: InkWell(
              child: Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: <Widget>[
                    Center(child: Image.file(File(widget.thumbnail)),),
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
              icon: Icon(Icons.delete,color: Colors.white),
              label: Text('材料を削除する'),
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

  Widget showForm(){
    return
      SafeArea(
        child: DefaultTabController(
          length: 3,
          child: Column(
            children: <Widget>[
              thumbnailArea(), //トップ画像
              widget.thumbnail.isEmpty
              ? Container()
              : ButtonsTabBar(
                backgroundColor: Colors.red[600],
                unselectedBackgroundColor: Colors.white,
                labelStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                borderColor: Colors.red[600],
                unselectedLabelStyle: TextStyle(color: Colors.red[600], fontWeight: FontWeight.bold),
                unselectedBorderColor: Colors.red[600],
                borderWidth: 1,
                radius: 100,
                tabs: [
                  Tab(
                    icon: Icon(Icons.search),
                    text: "キーワード",
                  ),
                  Tab(
                    icon: Icon(Icons.restaurant),
                    text: "材料",
                  ),
                  Tab(
                    icon: Icon(Icons.timer_sharp),
                    text: "分量",
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Center(
                      child:
                      _ingredientsOCR.length == 0
                        ? Container()
                        : Container(
                          // height: MediaQuery.of(context).size.height * 0.3,
                        child:Column(
                          children: [
                            this._isFocus
                                ? Container()
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('キーワード',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 20
                                      ),
                                    ),
                                    //削除取消しボタン
                                    Container(
                                      width: MediaQuery.of(context).size.width * 0.3,
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                                        child: FittedBox(fit:BoxFit.fitWidth,
                                          child: FlatButton(
                                            color: Colors.red[100 * (3 % 9)],
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                const Text('削除取消し', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                                              ],
                                            ),
                                            onPressed : (){
                                              print('削除取消し');
                                              this._bkIngredientsOCR.forEach((ingredient) {
                                                print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}');
                                              });
                                              setState(() {
                                                this._ingredientsOCR = [];
                                              });
                                              //削除取消し用のbackupをset
                                              for(var i = 0; i < this._bkIngredientsOCR.length; i++){
                                                Model ingredientOCR = Model(
                                                  id: this._bkIngredientsOCR[i].id,
                                                  no: this._bkIngredientsOCR[i].no,
                                                  name: this._bkIngredientsOCR[i].name,
                                                );
                                                setState(() {
                                                  this._ingredientsOCR.add(ingredientOCR);
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            //キーワード
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10.0),
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  child: _keyword(),
                                ),
                              ),
                            ),
                            // //完了ボタン
                            // this._isFocus
                            //  ? Container()
                            //  : Container(
                            //   width: MediaQuery.of(context).size.width * 0.3,
                            //   child: Padding(
                            //     padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                            //     child: FittedBox(fit:BoxFit.fitWidth,
                            //       child: FlatButton(
                            //         color: Colors.red[100 * (3 % 9)],
                            //         child: Row(
                            //           mainAxisAlignment: MainAxisAlignment.center,
                            //           children: <Widget>[
                            //             const Text('完了', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                            //           ],
                            //         ),
                            //         onPressed : (){
                            //           // _onDelete();
                            //         },
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        )
                        )
                    ),
                    Center(
                      child:
                        _ingredientsOCR.length == 0
                          ? Container()
                          : Column(
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(child: _reorderable('ingredients')),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.3,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                                    child: FittedBox(fit:BoxFit.fitWidth,
                                      child: RaisedButton.icon(
                                        icon: Icon(Icons.add,color: Colors.white),
                                        label: Text('追加'),
                                        textColor: Colors.white,
                                        color: Colors.red[100 * (3 % 9)],
                                        onPressed:(){
                                          _showDialog(selected: Model(id: -1, no: -1, name: ''),tabType: 'ingredients');
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Center(
                      child:
                       _quantitysOCR.length == 0
                           ? Container()
                           : Column(
                         // crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           Expanded(child: _reorderable('quantitys')),
                           Container(
                             width: MediaQuery.of(context).size.width * 0.3,
                             child: Padding(
                               padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                               child: FittedBox(fit:BoxFit.fitWidth,
                                 child: RaisedButton.icon(
                                   icon: Icon(Icons.add,color: Colors.white),
                                   label: Text('追加'),
                                   textColor: Colors.white,
                                   color: Colors.red[100 * (3 % 9)],
                                   onPressed:(){
                                     _showDialog(selected: Model(id: -1, no: -1, name: ''),tabType: 'quantitys');
                                   },
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

  //キーワード
  Widget _keyword(){
    return
      CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate([
              Column(
                children: <Widget>[
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('キーワード',
                  //       style: TextStyle(
                  //           fontWeight: FontWeight.bold,
                  //           color: Colors.grey,
                  //           fontSize: 20
                  //       ),
                  //     ),
                  //     //削除取消しボタン
                  //     Container(
                  //       width: MediaQuery.of(context).size.width * 0.3,
                  //       child: Padding(
                  //         padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  //         child: FittedBox(fit:BoxFit.fitWidth,
                  //           child: FlatButton(
                  //             color: Colors.red[100 * (3 % 9)],
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: <Widget>[
                  //                 const Text('削除取消し', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                  //               ],
                  //             ),
                  //             onPressed : (){
                  //               print('削除取消し');
                  //               this._bkIngredientsOCR.forEach((ingredient) {
                  //                 print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name}');
                  //               });
                  //               setState(() {
                  //                 this._ingredientsOCR = [];
                  //               });
                  //               //削除取消し用のbackupをset
                  //               for(var i = 0; i < this._bkIngredientsOCR.length; i++){
                  //                 Model ingredientOCR = Model(
                  //                   id: this._bkIngredientsOCR[i].id,
                  //                   no: this._bkIngredientsOCR[i].no,
                  //                   name: this._bkIngredientsOCR[i].name,
                  //                 );
                  //                 setState(() {
                  //                   this._ingredientsOCR.add(ingredientOCR);
                  //                 });
                  //               }
                  //             },
                  //           ),
                  //         ),
                  //       ),
                  //     ),
                  //   ],),
                  //キーワードエリア
                  // Container(
                  //   padding: const EdgeInsets.all(10.0),
                  //   // height: MediaQuery.of(context).size.height * 0.25,
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   decoration: BoxDecoration(
                  //     border: Border.all(color: Colors.red),
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child: Container(
                  //   child:
                    MultiSelectChipDisplay(
                      // scroll: true,
                      // scrollBar: HorizontalScrollBar(isAlwaysShown: true),
                      // shape: const StadiumBorder(
                      //   side: BorderSide(color: Colors.black),
                      // ),
                      alignment: Alignment.center,
                      textStyle: TextStyle(color: Colors.black),
                      chipColor: Colors.grey,
                      onTap: (ingredient){
                        print('id:${ingredient.id},no:${ingredient.no},name:${ingredient.name},');
                        _showDialog(selected: ingredient,tabType: 'ingredients');
                      },
                      items: _createMultiSelectItem()
                          .map((ingredient) => MultiSelectItem<Model>(ingredient, ingredient.name)).toList(),
                    ),
                  //   ),
                  // ),
                  // //完了ボタン
                  // Container(
                  //   width: MediaQuery.of(context).size.width * 0.3,
                  //   child: Padding(
                  //     padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                  //     child: FittedBox(fit:BoxFit.fitWidth,
                  //       child: FlatButton(
                  //         color: Colors.red[100 * (3 % 9)],
                  //         child: Row(
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: <Widget>[
                  //             const Text('完了', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                  //           ],
                  //         ),
                  //         onPressed : (){
                  //           // _onDelete();
                  //         },
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ]
              )
            ]),
          ),
        ],
      );
  }

  // Widget _keyword(){
  //   return
  //     ListView.builder(
  //       itemCount: this._ingredientsOCR.length,
  //       itemBuilder: (context, index) {
  //         return
  //           ListGroupItem(
  //             onTap: (){
  //             },
  //             title: Text('${_ingredientsOCR[index].name}'),
  //             trailing: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 IconButton(
  //                   icon: Icon(Icons.edit,color: Colors.grey),
  //                   onPressed: () {
  //                     print('edit');
  //                   },
  //                 ),
  //                 IconButton(
  //                   icon: Icon(Icons.close,color: Colors.red),
  //                   onPressed: () {
  //                     print('delete');
  //                   },
  //                 ),
  //               ],
  //             ),
  //           );
  //       },
  //     );
  // }

  ReorderableListView _reorderable(String tabType){

    List<Model> reorderList = [];
    List reorders = [];
    if(tabType == 'ingredients'){
      this._ingredientsOCR.forEach((ingredient) => reorders.add(ingredient));
    } else {
      this._quantitysOCR.forEach((quantity) => reorders.add(quantity));
    }
    for (int i = 0; i < reorders.length; i++) {
      Model model = Model(
        id: reorders[i].id,
        no: reorders[i].no,
        name: reorders[i].name,
      );
      reorderList.add(model);
    }

    return ReorderableListView(
      padding: EdgeInsets.all(10.0),
      scrollDirection: Axis.vertical,
      onReorder: (oldIndex, newIndex) {
        print('並び替え');
        if (oldIndex < newIndex) {
          // removing the item at oldIndex will shorten the list by 1.
          newIndex -= 1;
        }
        // final Model model = modelList.removeAt(oldIndex);
        final Model model = reorderList.removeAt(oldIndex);

        setState(() {
          // modelList.insert(newIndex, model);
          reorderList.insert(newIndex, model);
        });

        if(tabType == 'ingredients'){
          final Model Ingredient = this._ingredientsOCR.removeAt(oldIndex);
          setState(() {
            this._ingredientsOCR.insert(newIndex, Ingredient);
            // for(var i = 0; i < this._ingredientsOCR.length; i++){
            //     this._ingredientsOCR[i].no = i + 1;
            // }
          });
        } else {
          final Model quantity = this._quantitysOCR.removeAt(oldIndex);
          setState(() {
            this._quantitysOCR.insert(newIndex, quantity);
          });
          // for(var i = 0; i < this._quantitysOCR.length; i++){
          //   this._quantitysOCR[i].no = i + 1;
          // }
        }
        this._getNO(tabType);
      },
      // children: modelList.map(
      children: reorderList.map((Model model) {
          return _slidable(model,tabType);
        },
      ).toList(),
      // ),
      // )
    );
  }

  Widget _slidable(Model model,String tabType){
    return
      Slidable(
        key: Key(model.id.toString()),
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Container(
          color: Colors.white,
          child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                  elevation: 2.0,
                  child:
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        key: Key(model.id.toString()),
                        // tileColor: Colors.black12,
                        onTap: (){
                          print('ダイアログの呼び出し');
                          _showDialog(selected: model,tabType: tabType);
                        },
                        leading: Text(model.no.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                              color: Colors.black54
                          ),
                        ),
                        title: Text(model.name),
                          trailing:Icon(Icons.list,color: Colors.black12,)
                      ),
                    ],
                  ),
                ),
                ),
        // actions: <Widget>[
        //   IconSlideAction(
        //     caption: 'Archive',
        //     color: Colors.blue,
        //     icon: Icons.archive,
        //     onTap: () => _showSnackBar('Archive'),
        //   ),
        //   IconSlideAction(
        //     caption: 'Share',
        //     color: Colors.indigo,
        //     icon: Icons.share,
        //     onTap: () => _showSnackBar('Share'),
        //   ),
        // ],
        secondaryActions: <Widget>[
          // IconSlideAction(
          //   caption: 'More',
          //   color: Colors.black45,
          //   icon: Icons.more_horiz,
          //   onTap: () => _showSnackBar('More'),
          // ),
          IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => _keywordDelete(model,tabType),
          ),
        ],
      );
  }
}

class Model{
  int id;
  int no;         //材料の表示順
  String name;    //材料名

  Model({
    @required this.id,
    @required this.no,
    @required this.name
  });
}
class RESULT{
  String thumbnail;
  List<Ingredient> ingredients;

  RESULT({
    @required this.thumbnail,
    @required this.ingredients,
  });
}