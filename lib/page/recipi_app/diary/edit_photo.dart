import 'dart:io';
import 'dart:async';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';

class EditPhoto extends StatefulWidget{

  List<DPhoto> photos = List<DPhoto>();

  @override
  _EditPhotoState createState() => _EditPhotoState();

  EditPhoto({Key key, @required this.photos}) : super(key: key);

}

class _EditPhotoState extends State<EditPhoto>{

  Common common;
  List<DPhoto> _selectedPhotos = List<DPhoto>();
  String _error = 'No Error Dectected';

  GalleryMode _galleryMode = GalleryMode.image;
  GlobalKey globalKey;

  @override
  void initState() {
    super.initState();
    this.init();
    globalKey = GlobalKey();
  }

  //初期処理
  void init(){
    common = Common();
    setState(() {
      this._selectedPhotos = [];
      widget.photos.forEach((photo) => this._selectedPhotos.add(photo));
    });
  }

  //+ボタン押下時処理(Android)
  Future<void> selectImageAndroid() async {
    print('android');
    List<Asset> resultList = List<Asset>();
    List<Asset> images = List<Asset>();
    String error = 'No Error Dectected';

      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 10,
          enableCamera: false,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            actionBarColor: "#000000",
            actionBarTitleColor: "#ffffff",
            actionBarTitle: "選択",
            allViewTitle: "全ての写真",
            useDetailsView: false,
            selectCircleStrokeColor: "#ffffff",
            statusBarColor: '#000000',
          ),
        );
      } on Exception catch (e) {
        error = e.toString();
      }

      if (!mounted) return;

      for (int i = 0; i < resultList.length; i++) {
        var path = await FlutterAbsolutePath.getAbsolutePath(resultList[i].identifier);
        print('path:${path}');
        DPhoto photo = DPhoto(path: path);
        setState(() {
          this._selectedPhotos.add(photo);
        });
        File thumbnailfile = File(path);
        //サムネイル用にファイル名を変更
        String thumbnailPath = common.replaceImageDiary(thumbnailfile.path);

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
      }

    setState(() {
      this._error = error;
    });
  }

  //+ボタン押下時処理(iOS)
  Future<void> selectImageIOS() async {
    print('iOS');
    List<Media> _listImagePaths = List();
    String error = 'No Error Dectected';

    try{
      _galleryMode = GalleryMode.image;
      _listImagePaths = await ImagePickers.pickerPaths(
        galleryMode: _galleryMode,
        showGif: true,
        selectCount: 10,
        showCamera: false,
        cropConfig :CropConfig(enableCrop: true,height: 1,width: 1),
        compressSize: 500,
        uiConfig: UIConfig(
//          uiThemeColor: Color(0xffff0000),
        ),
      );
      _listImagePaths.forEach((media){
        print(media.path.toString());
      });
    } on Exception catch(e){
      error = e.toString();
    }

    if(!mounted) return;

      if(_listImagePaths != null) {
        for(var i = 0; i < _listImagePaths.length; i++){
          DPhoto photo = DPhoto(path: _listImagePaths[i].path);
          setState(() {
            this._selectedPhotos.add(photo);
          });

          Media thumbnailfile = _listImagePaths[i];
          //サムネイル用にファイル名を変更
          String thumbnailPath = common.replaceImageDiary(thumbnailfile.path);

          // flutter_image_compressで指定サイズ／品質に圧縮
          List<int> thumbnailresult = await FlutterImageCompress.compressWithFile(
            thumbnailfile.path,
            minWidth: 200,
            minHeight: 200,
            quality: 50,
          );

          // 圧縮したファイルを端末の拡張ディスクに保存
          File saveFile = File(thumbnailPath);
          await saveFile.writeAsBytesSync(thumbnailresult, flush: true, mode: FileMode.write);
          print('saveFile:${saveFile.path}');
        }
//        print('++++++++++++++++++++++++++++++++++++++++');
//        for(var i = 0; i < this._selectedPhotos.length; i++){
//          print('no:${this._selectedPhotos[i].no},path:${this._selectedPhotos[i].path}');
//        }
//        print('++++++++++++++++++++++++++++++++++++++++');
      }
      setState(() {
        this._error = error;
      });
  }

  //イメージのno取得処理
  void _setNo(){
    for(var i = 0; i < this._selectedPhotos.length; i++){
      this._selectedPhotos[i].no = i + 1;
    }
  }

  //保存ボタン押下時処理
  void _onSubmit() async {
    await this._setNo();
    Navigator.pop(context,this._selectedPhotos);
  }

  //×ボタン押下時処理
  void _onClose(){
    Navigator.pop(context,'close');
  }

  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepOrange[100 * (1 % 9)],
              leading: closeBtn(),
              elevation: 0.0,
              title: Center(
                child: Text( '写真を追加',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
//                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              actions: <Widget>[
                completeBtn(),
              ],
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: buildGridView(),
                )
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                Platform.isIOS
                ? selectImageIOS()
                : selectImageAndroid();
              },
              child: Icon(Icons.add,size: 30,),
              backgroundColor: Colors.red[100 * (3 % 9)],
            ),
          );
  }

  //画像リスト表示
  Widget buildGridView(){
    return GridView.count(
      crossAxisCount:3,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      shrinkWrap: true,
      children: List.generate(_selectedPhotos.length, (index){
        return Container(
          child:Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                child: Image.file(File(_selectedPhotos[index].path),fit: BoxFit.cover,),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.25,
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
                child: Container(
//                    color: Colors.redAccent,
                  child: IconButton(
                    icon: Icon(Icons.remove_circle,),
                    onPressed: (){
                      setState(() {
                        //イメージ削除
                        _selectedPhotos.removeAt(index);
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      }),
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

//保存ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
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
    );
  }

  //ｘボタン
  Widget closeBtn(){
    return IconButton(
      icon: const Icon(Icons.close,color: Colors.white,size: 30,),
      onPressed: (){
        _onClose();
      },
    );
  }
}