import 'dart:io';
import 'dart:async';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:recipe_app/services/Common.dart';


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

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    common = Common();
    setState(() {
      this._selectedPhotos = [];
      widget.photos.forEach((photo) => this._selectedPhotos.add(photo));
    });
  }

  //+ボタン押下時処理
  Future<void> loadFiles() async {
    List<File> files = List<File>();
    print('files:${files}');
    String error = 'No Error Dectected';

    try{
      files = await FilePicker.getMultiFile(
        type: FileType.custom,
        allowedExtensions: ['JPG','JPEG','jpg','jpeg','PNG','png'],
      );

//      var resultList = await MultiImagePicker.pickImages(
//          maxImages: 300,
////          enableCamera: true,
////        selectedAssets: this.images,
//        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
//        materialOptions: MaterialOptions(
//          actionBarColor: "#abcdef",
//          actionBarTitle: "カメラロールから選択",
////          allViewTitle: "All Photos",
//          useDetailsView: false,
//          selectCircleStrokeColor: "#000000"
//        ),
//      );
//      for(var i = 0; i < resultList.length; i++){
//        resultList[i].
//      }



    } on Exception catch(e){
      error = e.toString();
    }

    if(!mounted) return;

      if(files != null) {
        for(var i = 0; i < files.length; i++){
          DPhoto photo = DPhoto(path: files[i].path);
          setState(() {
            this._selectedPhotos.add(photo);
          });

          File thumbnailfile = files[i];
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
//          File saveFile = await files[i].copy(thumbnailPath);
          print('saveFile:${saveFile.path}');
//          saveFile.copy('/storage/emulated/0/Android/data/com.example.recipe_app/files/Pictures/test20200910_thumb.jpg');


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
                loadFiles();
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
                width: 300,
                height: 300,
                child: Image.file(File(_selectedPhotos[index].path),fit: BoxFit.cover,),
              ),
              Positioned(
                left: 100,
                width: 40,
                height: 40,
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
//                Positioned(
//                  left: 100,
//                  width: 40,
//                  height: 40,
//                  child: InkWell(
//                    child: Container(
////                      color: Colors.grey,
//                      child: Icon(Icons.remove,color: Colors.white,),
//                    ),
//                    onTap: (){
//                      print('削除2');
//                      setState(() {
//                        images.removeAt(index);
//                      });
//                    },
//                  ),
//                ),
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
      width: 90,
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