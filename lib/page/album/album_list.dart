import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/diary/diary_detail.dart';
import 'package:recipe_app/page/diary/diary_edit.dart';
import 'package:recipe_app/page/navigation/about.dart';
import 'package:recipe_app/page/recipi/recipi_sort.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:intl/intl.dart';
import 'package:frefresh/frefresh.dart';

import 'package:recipe_app/updater.dart';

class AlbumList extends StatefulWidget {

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList>{

  DBHelper dbHelper;
  Common common;
  List<DPhoto> _photoAll = List<DPhoto>();    //アルバム
  bool _isEditable = false;                   //true:右上Checkアイコン押下時に有効。複数アイテム選択編集モード管理フラグ
  List<bool> _selectedItems = List<bool>();   //各アルバムアイテムを選択を状態をチェックボックスでオンオフ
  List<DPhoto> _lazy = List<DPhoto>();        //遅延読み込み用リスト
  int _currentLength = 0;                     //遅延読み込み件数を格納
  final int increment = 21;                   //読み込み件数
  bool _isGetDiaryPhotos = false;             //true:写真用DBからの読み取り取得完了
  FRefreshController controller = FRefreshController(); //lazyload
  String text = "Drop-down to loading";                 //lazyload用text

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init() async {
    setState(() {
    //初期化
      this.dbHelper = DBHelper();
      this.common = Common();
      this._lazy.clear();
      this.controller = FRefreshController();
      FRefresh.debug = true;
    });
    //レコードリフレッシュ
    await this.refreshImages();
    //レシピリスト用遅延読み込み
    await this._loadMore();
  }

  //レシピリスト用遅延読み込み
  Future _loadMore() async {
//    print('+++++_loadMore+++++++');
    for (var i = _currentLength; i < _currentLength + increment; i++) {
      if( i < this._photoAll.length){
          setState(() {
            _lazy.add(_photoAll[i]);
          });
      }else{
        break;
      }
    }
    setState(() {
      _currentLength = _lazy.length;
    });
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {
    //写真の取得
    await dbHelper.getAllDiaryPhotos().then((item){
      setState(() {
        this._photoAll.clear();
        this._photoAll.addAll(item);
      });
    });
    setState(() {
      this._isGetDiaryPhotos = true;
    });
//    print('************************');
//    print('アルバム件数：${this._photoAll.length}');
    this._photoAll.forEach((element) => print('${element.diary_id},${element.id},${element.no},${element.path}'));
//    print('************************');
  }

  //チェックボックスにて選択した値を返す
  int _selectedItemsCount(){
    int count = 0;
    for(var i = 0; i < this._selectedItems.length; i++){
      if(this._selectedItems[i]){
        count++;
      }
    }
    return count;
  }


  //ナビゲーションバー
  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit(int selectedId){
//    print('selectId[${selectedId}]');
      //Date　=> String
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      DisplayDiary diary = DisplayDiary(
          id: selectedId
          ,body: ''
          ,date: dateString
          ,category: 1
          ,thumbnail: 1
          ,photos: []
          ,recipis: []
      );
    this._showEdit(diary: diary);
  }

  void _showEdit({DisplayDiary diary}){
    //編集画面へ遷移
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => DiaryEdit(selectedDiary: diary),
          fullscreenDialog: true,
        )
    ).then((result) async {
      //新規投稿の場合
      if(result != 'newClose') {
        //最新のリストを取得し展開する
        await this.refreshImages();
        setState(() {
          //レシピリスト用遅延読み込みリセット
          this._lazy.clear();
          this._currentLength = 0;
        });
        //レシピリスト用遅延読み込み
        await this._loadMore();
        await controller.refresh();
      }
    });
  }

  //日記を選択時処理
  void _onDetail({DPhoto photo}) async {

    Diary item = Diary();
    List<DPhoto> photos = List<DPhoto>();
    List<DRecipi> recipis = List<DRecipi>();

    //日記IDをもとにごはん日記を取得
    item = await dbHelper.getDiary(photo.diary_id);

    //ご飯日記IDに紐づくレシピの取得
    await dbHelper.getDiaryRecipis(photo.diary_id).then((item) {
      setState(() {
        recipis.clear();
        recipis.addAll(item);
      });
    });

    //ご飯日記IDに紐づく写真の取得
    await dbHelper.getDiaryPhotos(photo.diary_id).then((item) {
      setState(() {
        photos.clear();
        photos.addAll(item);
      });
    });

    DisplayDiary diary = DisplayDiary
      (
        id: item.id,
        body: item.body,
        date: item.date,
        category: item.category,
        thumbnail: item.thumbnail,
        photos: photos,
        recipis: recipis,
      );

    this._showDetail(diary: diary,selectedPhoto: photo);
  }

  //詳細画面へ遷移
  void _showDetail({ DisplayDiary diary ,DPhoto selectedPhoto}){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => DiaryDetail(selectedDiary: diary,selectedPhoto: selectedPhoto,),
          fullscreenDialog: true,
        )
    ).then((result) async {
      //削除または更新の場合
      if(result == 'delete' || result == 'update') {
        //最新のリストを取得し展開する
        await this.refreshImages();
        setState(() {
          //レシピリスト用遅延読み込みリセット
          this._lazy.clear();
          this._currentLength = 0;
        });
        //レシピリスト用遅延読み込み
        await this._loadMore();
        await controller.refresh();
      }
    });
  }

  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isEditable = !this._isEditable;
    });

    //チェックボックス作成
    if(this._isEditable){
      this._selectedItems = List<bool>.generate(this._photoAll.length, (index) => false);
//      print('selected:${this._selectedItems}');
    }
  }

  void _onImgShareSave() async {
    List<String> photos = [];
    for(var i = 0; i < this._selectedItems.length; i++){
      if(this._selectedItems[i]){
        photos.add(this._photoAll[i].path);
      }
    }
    //シェア機能の呼び出し
    await common.takeImageScreenShot(photos);
    setState(() {
      this._isEditable = !this._isEditable;
    });
  }

  //レシピリストのフォルダアイコンtap時処理
  void _onFolderTap({int type}){
    String title = '';
    // 3:フォルダの管理(menu)
    if(type == 3){
      //タイトルセット
      title = 'フォルダの管理';
    }else{
      // 4:タグの管理(menu)
      //タイトルセット
      title = 'タグの管理';
    }
    this._showSort(title: title, type: type);
  }

  //レシピの整理画面へ遷移
  void _showSort({ String title, int type}){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiSort(sortType: type,title: title ),
          fullscreenDialog: true,
        )
    ).then((result) {
    });
  }

  //レシピの整理画面へ遷移
  void _showAbout(){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => About(),
          fullscreenDialog: true,
        )
    ).then((result) {
//      print('閉じる');
    });
  }

  //URLのシェア
  void _onShareSave() async {
    //シェア機能の呼び出し
    await common.takeURLScreenShot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isEditable ? null : drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        elevation: 0.0,
        title: Center(
          child: Text(_isEditable ? '${_selectedItemsCount()}個選択':'レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: _isEditable
            ? <Widget>[
          completeBtn(),
        ]
            : <Widget>[
          checkBtn(),
          addBtn(context),
        ],
      ),
      body: albumList(),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }

  //ドロワーナビゲーション
  Widget drawerNavigation(){
    return Consumer<Display>(
        builder: (context,Display,_) {
          return Drawer(
            child: ListView(
              children: <Widget>[
                Container(
                  color: Colors.deepOrange[100 * (1 % 9)],
                  child: ListTile(
                    title: Center(
                      child: Text('設定',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
//              subtitle: Text(''),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.folder_open, color: Colors.deepOrange[100 * (1 % 9)],),
                    title: Text('フォルダの管理',
                      style: TextStyle(
//                fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      _onFolderTap(type: 3);
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
                    title: Text('タグの管理',
                      style: TextStyle(
//                  fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      _onFolderTap(type: 4);
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.email_outlined, color: Colors.deepOrange[100 * (1 % 9)],),
                    title: Text('アプリを友達に紹介',
                      style: TextStyle(
//                  fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      _onShareSave();
                    },
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.import_contacts, color: Colors.deepOrange[100 * (1 % 9)],),
                    title: Text('アプリについて',
                      style: TextStyle(
//                  fontWeight: FontWeight.bold
                      ),
                    ),
                    onTap: () {
                      _showAbout();
                    },
                  ),
                ),
                Container(
//            color: Colors.deepOrange[100 * (1 % 9)],
                  child: ListTile(
                    title: Center(
                      child: Text('version${Display.appCurrentVersion}',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
    );
  }

  Widget albumList(){
    return Stack(
      children: [
        this._isGetDiaryPhotos
          ? this._photoAll.length == 0
            ? showDefault()
            : Column(
                children: <Widget>[
                  Expanded(child: gridViewArea(),),
                  shareAndSaveBtn(),
                ],
              )
          : Container(),
        updater(),
      ],
    );
  }

  Widget showDefault(){
    return Center(
      child: Text('ごはん日記に写真を登録すると\nここから見れるようになります。',
        style: TextStyle(
            color: Colors.grey,
            fontSize: 20,
            fontWeight: FontWeight.bold
        ),
      ),
    );
  }

  Widget gridViewArea() {
    return FRefresh(
      controller: controller,
      footerBuilder: (setter) {
        controller.setOnStateChangedCallback((state) {
          setter(() {
            if (controller.loadState == LoadState.PREPARING_LOAD) {
              text = "Release to load";
            } else if (controller.loadState == LoadState.LOADING) {
              text = "Loading..";
            } else if (controller.loadState == LoadState.FINISHING) {
              text = "Loading completed";
            } else {
              text = "Drop-down to loading";
            }
          });
        });
        return Container(
//          color: Colors.black,
            height: 38,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CupertinoActivityIndicator(
                     animating: true,
                     radius: 10,
                  ),
//                  child: CircularProgressIndicator(
////                      backgroundColor: mainBackgroundColor,
//                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
////                      new AlwaysStoppedAnimation<Color>(mainTextSubColor),
//                    strokeWidth: 2.0,
//                  ),
                ),
                const SizedBox(width: 9.0),
                Text(text, style: TextStyle(color: Colors.white)),
              ],
            ));
      },
      footerHeight: 70.0,
      onLoad: () {
        Timer(Duration(milliseconds: 1000), () {
          _loadMore();
          controller.finishLoad();
//          print('controller.position = ${controller.position}, controller.scrollMetrics = ${controller.scrollMetrics}');
//          setState(() {
//          });
        });
      },
      child: Container(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GridView.builder(
                itemCount: _lazy.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2.0,
                  mainAxisSpacing: 2.0,
                ),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return LayoutBuilder(builder: (_, constraints) {
                    return createAlbum(index);
                  });
                }
            ),
          ],
        ),
      ),
    );
  }

  Widget createAlbum(int index){
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          InkWell(
            onTap: (){
              _isEditable
                  ? setState((){
                _selectedItems[index] = !_selectedItems[index];
//                      print('selected:${this._selectedItems}');
              })
                  : _onDetail(photo: _photoAll[index]);
            },
            child: Container(
              width: MediaQuery.of(context).size.width * 0.35,
              height: MediaQuery.of(context).size.width * 0.35,
              child: Image.file(File(common.replaceImageDiary(_photoAll[index].path)),fit: BoxFit.cover,),
            ),
          ),
          _isEditable
              ? _selectedItems[index]
              ? InkWell(
              onTap: (){
                setState(() {
                  _selectedItems[index] = !_selectedItems[index];
//                        print('selected:${this._selectedItems}');
                });
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.35,
                height: MediaQuery.of(context).size.width * 0.35,
                color: Colors.black26,
              )
          )
              : Container()
              : Container(),
          _isEditable
              ? _selectedItems[index]
              ? Container(
              child: FittedBox(fit:BoxFit.fitWidth,
                child: IconButton(
                icon: Icon(Icons.check_circle_outline,color: Colors.white),
                onPressed: (){
                  setState(() {
                    _selectedItems[index] = !_selectedItems[index];
  //                        print('selected:${this._selectedItems}');
                  });
                },
              ),
            ),
          )
              : Container()
              : Container(),
        ],
      ),
    );
  }

  //共有/保存するボタン
  Widget shareAndSaveBtn(){
    return
      _isEditable
          ? Container(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Padding(
              padding: EdgeInsets.only(top: 5,bottom: 5,left: 6,right: 6),
              child: FittedBox(fit:BoxFit.fitWidth,
                child: FlatButton(
                  onPressed:
                  _selectedItemsCount() == 0
                      ? null
                      : (){
                    _onImgShareSave();
                  },
                  color: Colors.deepOrange[100 * (1 % 9)],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('共有 / 保存する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                    ],
                  ),
                ),
              ),
            ),
          )
          : Container();
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FittedBox(fit:BoxFit.fitWidth,
          child: FlatButton(
            color: Colors.white,
            child: Text('完了',
              style: TextStyle(
                color: Colors.deepOrange[100 * (1 % 9)],
                fontSize: 15,
              ),
            ),
            onPressed: (){
              setState(() {
                this._isEditable = !this._isEditable;
              });
            },
          ),
        ),
      ),
    );
  }

  //チェックボタン
  Widget checkBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.check_circle_outline),
          onPressed: (){
            _onCheck();
          }
      ),
    );
  }

//追加ボタン
  Widget addBtn(BuildContext context){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        onPressed: (){
          _onEdit(-1);
        },
      ),
    );
  }

  //ナビゲーション
  Widget bottomNavigationBar(BuildContext context){
    return Consumer<Display>(
//        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.deepOrange[100 * (2 % 9)],
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                title: const Text('ホーム'),
//          backgroundColor: Colors.redAccent,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts),
                title: const Text('レシピ'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.folder_open),
                title: const Text('フォルダ別'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.date_range),
                title: const Text('ごはん日記'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: const Text('アルバム'),
//          backgroundColor: Colors.blue,
              ),
            ],
            onTap: (index){
              _changeBottomNavigation(index,context);
            },
          );
        }
    );
  }
}