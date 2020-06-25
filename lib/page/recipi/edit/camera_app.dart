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

  List<CameraDescription> cameras;
  CameraController controller;
  int imageCount = 0;
  var selectedImage;  //クリックした画像を格納する
  var images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];
  int selectNo; //クリックした画像のnoを格納する
  int selectIndex; //クリックした画像のindex番号を格納する
  int maxImage = 5; //撮影可能枚数
//  List<String> imageList;
  bool cameraRear = true; //true:アウトカメラ
  bool flashOn = false; //true:アウトカメラ
  int index = 0; //0:アウトカメラ 1:インカメラ
  bool imageTap = false;

  @override
  void initState() {
    super.initState();
    init();
    setImage();
  }

  //編集画面より画像アイコンがtapされた場合に該当が画像が表示された状態にする処理
  setImage(){
    var result = Provider.of<Display>(context, listen: false).getImages();
    var selectImage = Provider.of<Display>(context, listen: false).getSelectImage();
    setState(() {
      for(var i=0; i<result.length;i++){
        if(result[i]['path'] != ''){
          images[i]['path'] = result[i]['path'];
          imageCount++;
        }
      }
      selectIndex = selectImage['index'];
      selectedImage = selectImage['item'];
      imageTap = selectImage['tap'];
    });
  }

  Future<void> getCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[index], ResolutionPreset.medium);
  }

  //初期処理
  init(){
    getCameras().then((_) {
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  //カメラ切り替えアイコン押下時処理
  changeCamera(){
    setState(() {
      //インカメラ、アウトカメラのアイコン切り替え
      cameraRear = !cameraRear;
      //indexをsetする
      if(cameraRear){
        //アウトカメラ
        index = 0;
      }else{
        //インカメラ
        index = 1;
      }
    });
    //setしたindexを元にカメラ切り替え
    init();
  }

  //フラッシュアイコン押下時
  changeFlash(){
    setState(() {
      flashOn = !flashOn;
    });
  }

  String timestamp() => new DateTime.now().millisecondsSinceEpoch.toString();

  //カメラアイコン押下時処理 => カメラで撮影した画像を保存する関数(非同期)
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/recipi_app';
    await new Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      return null;
    }
    return filePath;
  }

  //撮影した画像アイコンクリック時処理
  clickImage(image){
    setState(() {
      //画像番号からindex番号を取得
      selectNo = image['no'];
      selectIndex = selectNo -1;
      selectedImage = images[selectIndex];
      imageTap = true;
    });
  }

  //<-(戻る)アイコン押下時処理
  backToShot(){
    setState(() {
      imageTap = !imageTap;
    });
  }

  //削除アイコン押下時処理
  deleteImage(){
    //removeAt用
    var removeImages = [];
    //
    var newImages = [
      {'no':1,'path':''},
      {'no':2,'path':''},
      {'no':3,'path':''},
      {'no':4,'path':''},
      {'no':5,'path':''},
    ];
    for(var i=0; i < images.length;i++){
      removeImages.add(images[i]);
    }
//    print('削除前：formImages${removeImages}');
    removeImages.removeAt(selectIndex);
//    print('削除後：formImages${removeImages}');
    for(var i=0; i < removeImages.length;i++){
      newImages[i]['path'] = removeImages[i]['path'];
    }
//    print('削除後：newImages${newImages}');
    setState(() {
      images = newImages;
      imageTap = !imageTap;
      //削除した際のカウントダウンの処理を追加
      imageCount--;
    });
  }

  onEdit(){
    //撮影した画像をstoreへ格納する
    Provider.of<Display>(context, listen: false).setImages(images);
    //編集画面に戻る
    Provider.of<Display>(context, listen: false).setCamera();
  }

  //カメラエリアを生成
  SizedBox _createCameraAria(){
    var imagePath;
    //画像がtapされた場合
    if(imageTap){
      imagePath = selectedImage['path'];
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
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller),
          ),
          height: 400,
        );
    }
  }

  //画像エリアを生成し、listにして返す
  Row _createImageAria(){
    List<Widget> row = new List<Widget>();
    var imagePath;
    for(var i = 0; i<images.length; i++){
      imagePath = images[i]['path'];
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
                clickImage(images[i]);
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
                clickImage(images[i]);
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
    if (controller == null || !controller.value.isInitialized) {
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
            onEdit();
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
      !imageTap
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
          backToShot();
        }
    );
  }

  //削除ボタン
  Widget deleteBtn(){
    return IconButton(
        icon: Icon( Icons.delete),
        iconSize: 40,
        onPressed: () {
          deleteImage();
        }
    );
  }

  //フラッシュ切り替えボタン
  Widget flashChangeBtn(){
    return IconButton(
        icon: Icon( flashOn ? Icons.flash_off : Icons.flash_on),
        iconSize: 40,
        onPressed: imageCount >= maxImage ? null : () {
          changeFlash();
        }
    );
  }

  //撮影ボタン
  Widget shotBtn(){
    return IconButton(
        icon: Icon(Icons.camera),
        iconSize: 80,
        onPressed: imageCount >= maxImage ? null : () async {
          var filePath = await takePicture();
          setState(() {
            images[imageCount]["path"] = filePath;
            imageCount++;
          });
        },
      );
  }

  //カメラ切り替えボタン
  Widget cameraChangeBtn(){
    return IconButton(
      icon: Icon( cameraRear ? Icons.camera_front : Icons.camera_rear),
      iconSize: 40,
      onPressed: imageCount >= maxImage ? null : () {
        changeCamera();
      }
    );
  }

}

