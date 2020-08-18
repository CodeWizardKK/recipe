import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
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
  List<DPhoto> _photoAll = List<DPhoto>();
  bool _isCheck = false;
  List<bool> _selected = List<bool>();

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    dbHelper = DBHelper();
    //戻る画面をセット　2:ごはん日記の日記詳細レシピ一覧
    Provider.of<Display>(context, listen: false).setBackScreen(4);
    //レコードリフレッシュ
    refreshImages();
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
    print('アルバム件数：${this._photoAll.length}');

  }

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
    print('selectId[${selectedId}]');
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

    //ごはん日記をset
    Provider.of<Display>(context, listen: false).setCurrentIndex(2);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: _isCheck ? Container() : menuBtn(),
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

  //画像リスト
  Widget buildGridView(){
    return GridView.count(
      crossAxisCount:4,
      crossAxisSpacing: 2.0,
      mainAxisSpacing: 2.0,
      shrinkWrap: true,
      children: List.generate(_photoAll.length, (index){
        return Container(
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              InkWell(
                onTap: (){
                  _isCheck
                  ? setState((){
                      _selected[index] = !_selected[index];
                      print('selected:${this._selected}');
                    })
                  : _onDetail(photo: _photoAll[index]);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  child: Image.file(File(_photoAll[index].path),fit: BoxFit.cover,),
                ),
              ),
              _isCheck
              ? _selected[index]
                ? InkWell(
                    onTap: (){
                      setState(() {
                        _selected[index] = !_selected[index];
                        print('selected:${this._selected}');
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 100,
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
                        print('selected:${this._selected}');
                      });
                    },
                  ),
                )
                : Container()
              : Container(),
            ],
          ),
        );
      }),
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
            color: Colors.cyan,
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
              color: Colors.cyan,
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

  Widget menuBtn(){
    return IconButton(
      icon: const Icon(Icons.list,color: Colors.white,size:30,),
      onPressed: (){
      },
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
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black26,
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