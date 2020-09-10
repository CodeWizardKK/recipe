import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:intl/intl.dart';

class AlbumList extends StatefulWidget {

  @override
  _AlbumListState createState() => _AlbumListState();
}

class _AlbumListState extends State<AlbumList>{

  DBHelper dbHelper;
  Common common;
  List<DPhoto> _photoAll = List<DPhoto>(); //アルバム
  bool _isCheck = false;                   //true:右上Checkアイコン押下時
  List<bool> _selected = List<bool>();     //右上Checkアイコン押下時に表示するチェックボックス

  List<DPhoto> _lazy = List<DPhoto>(); //遅延読み込み用リスト
  bool _isLoading = false;             //true:遅延読み込み中
  int _currentLength = 0;              //遅延読み込み件数を格納
  final int increment = 22;            //読み込み件数

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    dbHelper = DBHelper();
    common = Common();
    //戻る画面をセット　2:ごはん日記の日記詳細レシピ一覧
    Provider.of<Display>(context, listen: false).setBackScreen(4);
    //レコードリフレッシュ
    refreshImages();
    //レシピリスト用遅延読み込み
    _lazy.clear();
    this._loadMore();
  }

  //レシピリスト用遅延読み込み
  Future _loadMore() async {
    print('+++++_loadMore+++++++');
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    for (var i = _currentLength; i < _currentLength + increment; i++) {
      if( i < this._photoAll.length){
        if(mounted){
          setState(() {
            _lazy.add(_photoAll[i]);
          });
        }
      }else{
        break;
      }
    }
    if(mounted){
      setState(() {
        _isLoading = false;
        _currentLength = _lazy.length;
      });
    }
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
//    print('アルバム件数：${this._photoAll.length}');

  }

  //チェックボックスにて選択した値を返す
  String _selectedCount(){
    int count = 0;
    for(var i = 0; i < this._selected.length; i++){
      if(this._selected[i]){
        count++;
      }
    }
    if(count == 0){
      return '';
    }
    return count.toString();
  }


  //ナビゲーションバー
  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit(int selectedId,BuildContext context){
//    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    if(selectedId == -1){
      //Date　=> String
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      Provider.of<Edit>(context, listen: false).setDate(dateString);
      //編集フォームリセット処理
      Provider.of<Edit>(context, listen: false).reset();
      //ごはん日記をset
      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
    }
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(2);
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

    //選択した日記をセットする
    Provider.of<Edit>(context, listen: false).setDiary(diary);
    //ごはん日記をセットする
    Provider.of<Display>(context, listen: false).setCurrentIndex(2);
    //選択した写真をセットする
    Provider.of<Edit>(context, listen: false).setSelectedPhoto(photo);
    //2:詳細画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);

  }

  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });

    //チェックボックス作成
    if(this._isCheck){
      this._selected = List<bool>.generate(this._photoAll.length, (index) => false);
      print('selected:${this._selected}');
    }
  }

  void _onShareSave(){
    List<DPhoto> photos = List<DPhoto>();
    for(var i = 0; i < this._selected.length; i++){
      if(this._selected[i]){
        photos.add(this._photoAll[i]);
      }
    }
    print('選択した写真の件数：${photos.length}');
    setState(() {
      this._isCheck = !this._isCheck;
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
    //フォルダ、タグ管理画面でのタイトルをset
    Provider.of<Display>(context, listen: false).setSortTitle(title);
    //フォルダ、タグ管理画面での表示タイプをset
    Provider.of<Display>(context, listen: false).setSortType(type);
    //戻る画面をセット
    Provider.of<Display>(context, listen: false).setBackScreen(4);
    //レシピをset
    Provider.of<Display>(context, listen: false).setCurrentIndex(1);
    //3:フォルダ、タグ管理画面をset
    Provider.of<Display>(context, listen: false).setState(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _isCheck ? null : drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.brown[100 * (1 % 9)],
        elevation: 0.0,
        title: Center(
          child: Text(_isCheck ? '${_selectedCount()}個選択':'レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: _isCheck
            ? <Widget>[
          completeBtn(),
        ]
            : <Widget>[
          checkBtn(),
          addBtn(context),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildGridView(),),
          shareAndSaveBtn(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }

  //ドロワーナビゲーション
  Widget drawerNavigation(){
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            color: Colors.brown[100 * (1 % 9)],
            child: ListTile(
              title: Center(
                child: Text('設定',
                  style: TextStyle(
                      color:Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
//              subtitle: Text(''),
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder_open,color: Colors.brown[100 * (1 % 9)],),
            title: Text('フォルダの管理',
              style: TextStyle(
//                fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              _onFolderTap(type: 3);
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
          ListTile(
            leading: Icon(Icons.local_offer,color: Colors.brown[100 * (1 % 9)],),
            title: Text('タグの管理',
              style: TextStyle(
//                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              _onFolderTap(type: 4);
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
        ],
      ),
    );
  }

  //画像リスト
  Widget buildGridView(){
    return
      LazyLoadScrollView(
        isLoading: _isLoading,
        onEndOfPage: () => _loadMore(),
    child:
      GridView.builder(
        itemCount: _lazy.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 2.0,
        ),
        itemBuilder: (context, position) {
          if(_isLoading && position == _lazy.length - 1){
            if(this._photoAll.length == _lazy.length){
              return createAlbum(position);
            } else{
              return Center(child: CircularProgressIndicator(),);
            }
          } else {
            return createAlbum(position);
          }
      }),
    );
  }

  Widget createAlbum(int index){
    return Container(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          InkWell(
            onTap: (){
              _isCheck
                  ? setState((){
                _selected[index] = !_selected[index];
//                      print('selected:${this._selected}');
              })
                  : _onDetail(photo: _photoAll[index]);
            },
            child: Container(
              width: 150,
              height: 150,
              child: Image.file(File(common.replaceImageDiary(_photoAll[index].path)),fit: BoxFit.cover,),
            ),
          ),
          _isCheck
              ? _selected[index]
              ? InkWell(
              onTap: (){
                setState(() {
                  _selected[index] = !_selected[index];
//                        print('selected:${this._selected}');
                });
              },
              child: Container(
                width: 150,
                height: 150,
                color: Colors.black26,
              )
          )
              : Container()
              : Container(),
          _isCheck
              ? _selected[index]
              ? Container(
            child: IconButton(
              icon: Icon(Icons.check_circle_outline,color: Colors.white,size: 30,),
              onPressed: (){
                setState(() {
                  _selected[index] = !_selected[index];
//                        print('selected:${this._selected}');
                });
              },
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
      _isCheck
          ? Container(
        width: 130,
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5,left: 6,right: 6),
          child: FlatButton(
            onPressed:
            _selectedCount().isEmpty
                ? null
                : (){
              _onShareSave();
            },
            color: Colors.brown[100 * (1 % 9)],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
//                  const Icon(Icons.folder_open,color: Colors.white,),
                const Text('共有 / 保存する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
              ],
            ),
          ),
        ),
      )
          : Container();
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: Text('完了',
            style: TextStyle(
              color: Colors.brown[100 * (1 % 9)],
              fontSize: 15,
            ),
          ),
          onPressed: (){
            setState(() {
              this._isCheck = !this._isCheck;
            });
          },
        ),
      ),
    );
  }

  Widget checkBtn(){
    return IconButton(
        icon: const Icon(Icons.check_circle_outline,color: Colors.white,size:30,),
        onPressed: (){
          _onCheck();
        }
    );
  }

  Widget addBtn(BuildContext context){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onEdit(-1,context);
      },
    );
  }

  Widget bottomNavigationBar(BuildContext context){
    return Consumer<Display>(
        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
//      backgroundColor: Colors.redAccent,
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.brown[100 * (3 % 9)],
            unselectedItemColor: Colors.brown[100 * (1 % 9)],
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