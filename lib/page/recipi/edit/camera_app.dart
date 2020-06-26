import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:path_provider/path_provider.dart';

class CameraApp extends StatefulWidget {

  @override
  _CameraAppState createState() => _CameraAppState();

}
class _CameraAppState extends State<CameraApp> {

  List<CameraDescription> _cameras;
  CameraController _controller;
  int _imageCount = 0;//セットされている画像をカウント
  var _images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];
  //クリックした画像、index,tap状況を格納する ===> Ex.{index: 0, item: {no: 1, path: ''}, tap: true}
  var _selected = new Map<String,dynamic>();
  //フラッシュ、カメラの切り替え
  var _cameraOption = new Map<String,dynamic>();

//  var test = new List<Map<String,dynamic>>();

  @override
  void initState() {
    super.initState();
    _init();
    _initCamera();
    _setImage();
//    test.add(_images[1]);
  }

  //初期処理
  void _init(){
    _cameraOption['flash'] = false;     //true:フラッシュオン
    _cameraOption['cameraRear'] = true; //true:アウトカメラ
    _cameraOption['cameraIndex'] = 0; //0:アウトカメラ 1:インカメラ
  }

  //カメラ用初期処理
  void _initCamera(){
    _getCameras().then((_) {
      _controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  //編集画面より画像アイコンがtapされた場合に該当が画像が表示された状態にする処理
  void _setImage(){
    var result = Provider.of<Display>(context, listen: false).getImages();
    var selectImage = Provider.of<Display>(context, listen: false).getSelectImage();
    setState(() {
      for(var i=0; i<result.length;i++){
        if(result[i]['path'] != ''){
          _images[i]['path'] = result[i]['path'];
          _imageCount++;
        }
      }
      _selected['index'] = selectImage['index'];
      _selected['item'] = selectImage['item'];
      _selected['tap'] = selectImage['tap'];
    });
  }

  Future<void> _getCameras() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[_cameraOption['cameraIndex']], ResolutionPreset.medium);
  }

  //カメラ切り替えアイコン押下時処理
  void _changeCamera(){
    setState(() {
      //インカメラ、アウトカメラのアイコン切り替え
      _cameraOption['cameraRear'] = !_cameraOption['cameraRear'];
      //indexをsetする
      if(_cameraOption['cameraRear']){
        //アウトカメラ
        _cameraOption['cameraIndex'] = 0;
      }else{
        //インカメラ
        _cameraOption['cameraIndex'] = 1;
      }
    });
    //setしたindexを元にカメラ切り替え
    _initCamera();
  }

  //フラッシュアイコン押下時
  void _changeFlash(){
    setState(() {
      _cameraOption['flash'] = !_cameraOption['flash'];
    });
  }

  //現在時刻の取得
  String _timestamp(){
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  //カメラアイコン押下時処理 => カメラで撮影した画像を保存する関数(非同期)
  Future<String> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/recipi_app';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${_timestamp()}.jpg';

    if (_controller.value.isTakingPicture) {
      return null;
    }

    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  //撮影した画像アイコンクリック時処理
  void _clickImage(int index,Map<String,dynamic> item){
    setState(() {
      //画像番号からindex番号を取得
      _selected['index'] = index;
      _selected['item'] = item;
      _selected['tap'] = true;
    });
  }

  //<-(戻る)アイコン押下時処理
  void _backToShot(){
    setState(() {
      _selected['tap'] = !_selected['tap'];
    });
  }

  //削除アイコン押下時処理
  void _deleteImage(){
    //removeAt用
    var removeImages = [];
    var newImages = [
      {'no':1,'path':''},
      {'no':2,'path':''},
      {'no':3,'path':''},
      {'no':4,'path':''},
      {'no':5,'path':''},
    ];
    for(var i=0; i < _images.length;i++){
      removeImages.add(_images[i]);
    }
//    print('削除前：formImages${removeImages}');
    removeImages.removeAt(_selected['index']);
//    print('削除後：formImages${removeImages}');
    for(var i=0; i < removeImages.length;i++){
      newImages[i]['path'] = removeImages[i]['path'];
    }
//    print('削除後：newImages${newImages}');
    setState(() {
      _images = newImages;
      _selected['tap'] = !_selected['tap'];
      //削除した際のカウントダウンの処理を追加
      _imageCount--;
    });
  }

  void _onEdit(){
    //撮影した画像をstoreへ格納する
    Provider.of<Display>(context, listen: false).setImages(_images);
    //編集画面に戻る
    Provider.of<Display>(context, listen: false).setCamera();
  }

  //カメラエリアを生成
  SizedBox _createCameraAria(){
    var imagePath;
    //画像がtapされた場合
    if(_selected['tap']){
      imagePath = _selected['item']['path'];
      //事前読み込み画像ありの場合
      if(imagePath.startsWith('http')){
        return
          SizedBox(
            child: Container(
              decoration: BoxDecoration(
                image:DecorationImage(
                  fit:BoxFit.cover,
                  image:NetworkImage('${imagePath}'),
                ),
              ),
            ),
            height: 400,
          );
        //事前読み込みなしアップロード画像ありの場合
      }else {
        return
          SizedBox(
            child: Image.file(File(imagePath)),
            height: 400,
          );
      }
    //カメラアイコンがtapされた場合
    }else{
      return
        SizedBox(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: CameraPreview(_controller),
          ),
          height: 400,
        );
    }
  }

  //画像エリアを生成し、listにして返す
  Row _createImageAria(){
    List<Widget> row = new List<Widget>();
    var imagePath;
    for(var i = 0; i < _images.length; i++){
      imagePath = _images[i]['path'];
      //新規投稿の場合
      if(imagePath.isEmpty){
        row.add(
          SizedBox(
            child:InkWell(
              child: Card(
                color: Colors.black,
              ),
            ),
            width: 64.0,
            height: 64.0,
          ),
        );
      //事前読み込み画像ありの場合
      }else if (imagePath.startsWith('http')){
        row.add(
          SizedBox(
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
                _clickImage(i,_images[i]);
              },
            ),
            width: 64.0,
            height: 64.0,
          ),
        );
      //事前読み込みなしアップロード画像ありの場合
      }else{
        row.add(
          SizedBox(
            child:InkWell(
              child: Card(
                child: Image.file(File(imagePath)),
              ),
              onTap: (){
                _clickImage(i,_images[i]);
              },
            ),
            width: 64.0,
            height: 64.0,
          ),
        );
      }
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:row
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller.value.isInitialized) {
      return Container();
    } else {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Container(),
            title: title(),
            actions: <Widget>[
              completeBtn(),
            ],
          ),
          body: showCamera(),
        );
    }
  }

  //タイトル
  Widget title(){
    return
      Center(
        child: Text('カメラ',
          style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),
        ),
      );
  }

  //完了ボタン
  Widget completeBtn(){
    return
        FlatButton(
          child: Text('完了',
            style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold
            ),
          ),
          onPressed: (){
            _onEdit();
          },
        );
  }

  //ページ全体
  Widget showCamera(){
    return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _createCameraAria(),  //カメラエリア
                  imageArea(),          //撮影した画像を表示するエリア
                  iconChangeArea(),     //ボタンエリア
                ]
            ),
          );
  }

  //撮影した画像を表示するエリア
  Widget imageArea(){
    return
      Container(
        padding: EdgeInsets.all(10),
        child: _createImageAria(),
      );
  }

  //ボタンエリア
  Widget iconChangeArea(){
    return
      !_selected['tap']
          //カメラアイコンがtapされた場合
          ? shotIconArea()
          //画像がtapされた場合
          : previewIconArea();
  }

  //フラッシュ、撮影ボタン、カメラ切り替えボタン表示
  Widget shotIconArea(){
    return Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  flashChangeBtn(),
                  shotBtn(),
                  cameraChangeBtn(),
                ],
              ),
            );
  }

  //戻る、削除ボタン表示
  Widget previewIconArea(){
    return
      Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            backBtn(),
            deleteBtn(),
          ],
        ),
      );
  }

  //戻るボタン
  Widget backBtn(){
    return IconButton(
        icon: Icon( Icons.arrow_back),
        iconSize: 40,
        onPressed: () {
          _backToShot();
        }
    );
  }

  //削除ボタン
  Widget deleteBtn(){
    return IconButton(
        icon: Icon( Icons.delete),
        iconSize: 40,
        onPressed: () {
          _deleteImage();
        }
    );
  }

  //フラッシュ切り替えボタン
  Widget flashChangeBtn(){
    return IconButton(
        icon: Icon( _cameraOption['flash'] ? Icons.flash_off : Icons.flash_on),
        iconSize: 40,
        onPressed: _imageCount >= _images.length ? null : () {
          _changeFlash();
        }
    );
  }

  //撮影ボタン
  Widget shotBtn(){
    return IconButton(
        icon: Icon(Icons.camera),
        iconSize: 80,
        onPressed: _imageCount >= _images.length ? null : () async {
          var filePath = await _takePicture();
          setState(() {
            _images[_imageCount]["path"] = filePath;
            _imageCount++;
          });
        },
      );
  }

  //カメラ切り替えボタン
  Widget cameraChangeBtn(){
    return IconButton(
      icon: Icon( _cameraOption['cameraRear'] ? Icons.camera_front : Icons.camera_rear),
      iconSize: 40,
      onPressed: _imageCount >= _images.length ? null : () {
        _changeCamera();
      }
    );
  }

}

