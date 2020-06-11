import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraApp extends StatefulWidget {

  @override
  _CameraAppState createState() => _CameraAppState();

}
class _CameraAppState extends State<CameraApp> {

  List<CameraDescription> cameras;
  CameraController controller;
  int imageCount = 0;
  var selecedImage;  //クリックした画像を格納する
  var images = [
    {'no':1,'path':''},
    {'no':2,'path':''},
    {'no':3,'path':''},
    {'no':4,'path':''},
    {'no':5,'path':''},
  ];
  int selectIndex; //クリックした画像のindex番号を格納する
  int maxImage = 5; //撮影可能枚数
//  List<String> imageList;
  bool cameraRear = true; //true:アウトカメラ
  bool flashOn = false; //true:アウトカメラ
  int index = 0; //0:アウトカメラ 1:インカメラ
  bool imageTap = false;


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

  @override
  void initState() {
    super.initState();
    init();
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
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
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
//    print('file-pass:[${filePaths}]');
    return filePath;
  }

  //撮影した画像アイコンクリック時処理
  clickImage(imageNo){
//    print('クリックした画像:${images[selectIndex]}');
    setState(() {
      //画像番号からindex番号を取得
      selectIndex = imageNo -1;
      selecedImage = images[selectIndex];
//      print('表示用${selecedImage}');
      imageTap = true;
    });
  }

  clickTest(image){
    var index = image['no'];
    print('クリックした画像:${images[index - 1]}');
  }

  //<-(戻る)アイコン押下時処理
  backToShot(){
    setState(() {
      imageTap = !imageTap;
    });
  }

  //削除アイコン押下時処理
  deleteImage(){
    print('+-------------------------------+');
    print('|              削除              |');
    print('+--------------------------------+');
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
    print('削除前：formImages${removeImages}');
    removeImages.removeAt(selectIndex);
    print('削除後：formImages${removeImages}');
    print('+--------------------------------+');
    print('+--------------------------------+');
    print('+--------------------------------+');
    for(var i=0; i < removeImages.length;i++){
      newImages[i]['path'] = removeImages[i]['path'];
    }
    print('削除後：newImages${newImages}');
    setState(() {
      images = newImages;
      print('images${images}');
      imageTap = !imageTap;
      //削除した際のカウントダウンの処理を追加
      imageCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    } else {
      return
        Scaffold(
          body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  imageTap
                      ? SizedBox(
                    child: Image.file(File(selecedImage['path'])),
                  )
                      : AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: CameraPreview(controller)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for(var image in images)
                          SizedBox(
                            child:
                            image['path'] == ''
                                ? Card(color: Colors.black)
                                : InkWell(child: Image.file(File(image['path'])),
                              onTap: (){
                                clickImage(image['no']);
                              },
                            ) ,
                            width: 64.0,
                            height: 64.0,
                          ),
                      ],
                    ),
                  ),
                  !imageTap
                      ? Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                            icon: Icon( flashOn ? Icons.flash_off : Icons.flash_on),
//                    color: Colors.blue,
                            iconSize: 40,
                            onPressed: imageCount >= maxImage ? null : () {
                              changeFlash();
                            }
                        ),
                        IconButton(
                          icon: Icon(Icons.camera),
//                    color: Colors.blue,
                          iconSize: 80,
                          onPressed: imageCount >= maxImage ? null : () async {
                            var filePath = await takePicture();
                            setState(() {
                              images[imageCount]["path"] = filePath;
                              print('---------------------------------------------');
                              print('Images:${images}');
                              imageCount++;
                            });
                          },
                        ),
                        IconButton(
                            icon: Icon( cameraRear ? Icons.camera_front : Icons.camera_rear),
//                    color: Colors.blue,
                            iconSize: 40,
                            onPressed: imageCount >= maxImage ? null : () {
                              changeCamera();
                            }
                        ),
                      ],
                    ),
                  )
                      : Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                            icon: Icon( Icons.arrow_back),
//                    color: Colors.blue,
                            iconSize: 40,
                            onPressed: () {
                              backToShot();
                            }
                        ),
                        IconButton(
                            icon: Icon( Icons.delete),
//                    color: Colors.blue,
                            iconSize: 40,
                            onPressed: () {
                              deleteImage();
                            }
                        ),
                      ],
                    ),
                  )
                ]
            ),
          ),
        );
    }
  }
}
