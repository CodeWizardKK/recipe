import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:list_group/list_group.dart';
import 'package:list_group/list_group_item.dart';
import 'package:recipe_app/page/recipi_app/navigation/about.dart';

import 'package:recipe_app/page/recipi_app/recipi/recipi_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_sort.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/Check.dart';
import 'package:recipe_app/model/CheckRecipi.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MyrecipiGroupFolder.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/Tag.dart';

import 'package:recipe_app/updater.dart';
import 'package:recipe_app/error.dart';

class FolderList extends StatefulWidget{
  FolderList({Key key}) : super(key: key);

  @override
  _FolderListState createState() => _FolderListState();
}

class _FolderListState extends State<FolderList>{

  DBHelper dbHelper;
  Common common;
  List _displayList;                          //チェックボック付きレシピリストor検索リスト
  List<MyrecipiGroupFolder> _recipisGroupBy;  //フォルダID毎のレシピ件数を格納
  List<Check> _folders;                       //チェックボック付きフォルダリスト
  bool _isCheck = false;                      //true:チェックボックス表示
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init(){
    //初期化
    dbHelper = DBHelper();
    common = Common();
    _displayList = [];
    _recipisGroupBy = [];
    _folders = [];

    //レコードリフレッシュ
    this.refreshImages();
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {
    List<MstFolder> folders = [];

    try{
      //フォルダ別レシピ件数の取得
      await dbHelper.getMyRecipisCount().then((item){
        setState(() {
          _recipisGroupBy.clear();
          _recipisGroupBy.addAll(item);
        });
      });

      //フォルダマスタの取得
      await dbHelper.getMstFolders().then((item){
        setState(() {
          folders.clear();
          folders.addAll(item);
        });
      });
      //取得したフォルダをstoreに保存
      Provider.of<Display>(context, listen: false).setMstFolder(folders);

      setState(() {
        //チェックBox付きフォルダリストの生成
        this._folders = Provider.of<Display>(context, listen: false).createFoldersCheck();
      });
    } catch (exception) {
      print(exception);
      this._isError = true;
    }
  }

  //ナビゲーションバー
  void _changeBottomNavigation(index){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit({int selectedId,int type}){
    //選択したレシピのindexをsetする
    Myrecipi recipi = Myrecipi
      (
        id: selectedId
        , type: type
        , thumbnail: ''
        , title: ''
        , description: ''
        , quantity: 1
        , unit: 1
        , time: 0
    );
    //編集画面へ遷移
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiEdit(Nrecipi: recipi, Ningredients: [], NhowTos: [], Nphotos: []),
          fullscreenDialog: true,
        )
    ).then((result) {
      //最新のリストを取得し展開する
      this.refreshImages();
    });
  }

  //新規投稿
  Future<void> _onAdd() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('スキャンレシピを追加'),
                onPressed: () {
                  Navigator.pop(context);
                  _onEdit(selectedId:-1,type: 3);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('MYレシピを追加'),
                onPressed: () {
                  Navigator.pop(context);
                  _onEdit(selectedId:-1,type: 2);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('写真レシピを追加'),
                onPressed: () {
                  Navigator.pop(context);
                  _onEdit(selectedId:-1,type: 1);
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

  //フォルダ別レシピリストの表示
  void _onListGroupBy({int index}){
    print('folderID:${this._folders[index].id},name:${this._folders[index].name},isCheck:${this._folders[index].isCheck}');
    //フォルダ情報をset
    Provider.of<Display>(context, listen: false).setFolder(this._folders[index]);
    //4:フォルダ別レシピ一覧へ遷移
    Provider.of<Display>(context, listen: false).setState(1);
  }

  //フォルダ、タグ付け、削除するボタンの活性、非活性
  bool _onDisabled({int type}){
    //フォルダ、タグ付け
    if(type != 3){
      for(var i = 0; i<this._folders.length; i++){
        if(this._folders[i].isCheck){
          return true;
        }
      }
      for(var i = 0; i<this._displayList.length; i++){
        if(this._displayList[i].isCheck){
          return false;
        }
      }
      return true;
    }

    //削除する
    for(var i = 0; i<this._folders.length; i++){
      if(this._folders[i].isCheck){
        return false;
      }
    }
    for(var i = 0; i<this._displayList.length; i++){
      if(this._displayList[i].isCheck){
        return false;
      }
    }
    return true;
  }

  //フォルダ、レシピ毎のチェックボックス
  void _onItemCheck({int index,int type}){
    //フォルダリスト
    if(type == 1){
      setState(() {
        this._folders[index].isCheck = !this._folders[index].isCheck;
      });

      //レシピリスト
    }else{
      setState(() {
        this._displayList[index].isCheck = !this._displayList[index].isCheck;
      });
    }

  }

  //レシピリストのフォルダアイコンtap時処理
  Future<void> _onFolderTap({int index,String ingredients,List<Tag> tags,int type}) async {
    // 0:フォルダアイコン押下時
    // 1:フォルダボタン(checkbox) 2:タグ付けボタン(checkbox)
    // 3:フォルダの管理(menu)     4:タグの管理(menu)

    Myrecipi recipi;      //選択したレシピ
    String title = '';    //タイトル
    List ids = [];        //チェックしたレシピ(ID)を格納する

    // 0:フォルダアイコン押下時
    if(type == 0) {
      CheckRecipi item = this._displayList[index];
      //選択したレシピのindexをsetする
      recipi = Myrecipi
        (
          id: item.id
          , type: item.type
          , thumbnail: item.thumbnail
          , title: item.title
          , description: item.description
          , quantity: item.quantity
          , unit: item.unit
          , time: item.time
          ,folder_id: item.folder_id
      );
      //タイトルセット
      title = 'レシピの整理';

      //1:フォルダボタン(checkbox),2:タグ付けボタン(checkbox)
    }else if(type == 1 || type == 2){
      //チェックしたレシピ(ID)を格納する
      for (var i = 0; i < this._displayList.length; i++) {
        if (this._displayList[i].isCheck) {
          ids.add(this._displayList[i].id);
        }
      }
      //タイトルセット
      if(type == 1){
        title = 'フォルダを選択';
      }else{
        title = 'タグを選択';
      }

      // 3:フォルダの管理(menu),4:タグの管理(menu)
    }else{
      //タイトルセット
      if(type == 3){
        title = 'フォルダの管理';
      }else{
        title = 'タグの管理';
      }
    }
    this._showSort(recipi: recipi, ingredients: ingredients, tags: tags,title: title, type: type, ids: ids);
  }

  //レシピの整理画面へ遷移
  void _showSort({ Myrecipi recipi, String ingredients, List<Tag> tags, String title, int type, List ids}){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiSort(Nrecipi: recipi,ingredientTX: ingredients,tags: tags,sortType: type,title: title,ids: ids, ),
          fullscreenDialog: true,
        )
    ).then((result) {
      if(this._isCheck){
        this._isCheck = false;
      }
      //最新のリストを取得し展開する
      this.refreshImages();
    });
  }


  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });
    setState(() {
      //チェックBox付きフォルダリストの生成
      this._folders = Provider.of<Display>(context, listen: false).createFoldersCheck();
    });
  }

  //削除処理
  void _onDelete({Myrecipi recipi}) async {
    List ids = [];

    try{

        //レシピを削除
        await dbHelper.deleteMyRecipi(recipi.id);
        //レシピIDに紐づくタグを削除する
        await dbHelper.deleteTagRecipiId(recipi.id);
        //レシピIDに紐づく材料リストを削除
        await dbHelper.deleteRecipiIngredient(recipi.id);
        //レシピIDに紐づく作り方リストを削除
        await dbHelper.deleteRecipiHowto(recipi.id);
        //レシピIDに紐づく写真リストを削除
        await dbHelper.deleteRecipiPhoto(recipi.id);
        //レシピIDに紐づくごはん日記のレシピリストを削除する
        await dbHelper.deleteDiaryRecipibyRecipiID(recipi.id);
        //選択したフォルダマスタを削除
        for(var i = 0; i < this._folders.length; i++){
          if(this._folders[i].isCheck){
            ids.add(this._folders[i].id);
          }
        if(ids.length > 0){
          print('削除するフォルダマスタID：${ids}');
          //フォルダマスタ削除処理
          for(var i = 0; i < ids.length; i++){
            //フォルダマスタ削除
            await dbHelper.deleteMstFolder(ids[i]);
            //フォルダマスタで削除したIDに紐づくレシピを取得する
            List<Myrecipi> recipis = await dbHelper.getMyRecipibyFolderID(ids[i]);
            //フォルダマスタで削除したIDに紐づくレシピを削除する
            await dbHelper.deleteMyRecipiFolderId(ids[i]);
            for(var j = 0; j < recipis.length; j++){
              //レシピIDに紐づくタグを削除する
              await dbHelper.deleteTagRecipiId(recipis[j].id);
              //レシピIDに紐づく材料リストを削除
              await dbHelper.deleteRecipiIngredient(recipis[j].id);
              //レシピIDに紐づく作り方リストを削除
              await dbHelper.deleteRecipiHowto(recipis[j].id);
              //レシピIDに紐づく写真リストを削除
              await dbHelper.deleteRecipiPhoto(recipis[j].id);
              //削除したレシピIDに紐づくごはん日記のレシピリストを削除する
              await dbHelper.deleteDiaryRecipibyRecipiID(recipis[j].id);
            }
          }
        }

        //選択したレシピを削除
        ids.clear();
        for(var i = 0; i < this._displayList.length; i++){
          if(this._displayList[i].isCheck){
            ids.add(this._displayList[i].id);
          }
        }
        if(ids.length > 0){
          print('削除するレシピID：${ids}');
          for(var i = 0; i < ids.length; i++){
            //レシピを削除
            await dbHelper.deleteMyRecipi(ids[i]);
            //レシピIDに紐づくタグを削除する
            await dbHelper.deleteTagRecipiId(ids[i]);
            //レシピIDに紐づく材料リストを削除
            await dbHelper.deleteRecipiIngredient(ids[i]);
            //レシピIDに紐づく作り方リストを削除
            await dbHelper.deleteRecipiHowto(ids[i]);
            //レシピIDに紐づく写真リストを削除
            await dbHelper.deleteRecipiPhoto(ids[i]);
            //レシピIDに紐づくごはん日記のレシピリストを削除する
            await dbHelper.deleteDiaryRecipibyRecipiID(ids[i]);
          }
        }
        setState(() {
          this._isCheck = !this._isCheck;
        });
      }

      await this.refreshImages(); //レコードリフレッシュ

    } catch (exception) {
      print(exception);
      this._isError = true;
    }
  }

  //チェックボックスにて選択した値を返す
  int _selectedCount(){
    int count = 0;
    for(var i = 0; i < this._displayList.length; i++){
      if(this._displayList[i].isCheck){
        count++;
      }
    }
    for(var i = 0; i < this._folders.length; i++){
      if(_folders[i].isCheck){
        count++;
      }
    }
    return count;
  }

  //グループ毎レシピの作成
  List<ListGroupItem> _createGroup(){
    List<ListGroupItem> column = [];

    for(var i = 0; i < this._folders.length; i++){
      //材料リストを展開する
      int count = 0;
      //レシピIDに紐づくタグを取得する
      var recipisGroupBy = this._recipisGroupBy.firstWhere(
              (_recipi) => _recipi.folder_id == this._folders[i].id,
          orElse: () => null
      );

      if(recipisGroupBy != null){
        count = recipisGroupBy.count;
      }

      column.add(
        ListGroupItem(
            leading: _isCheck
                ? Checkbox(
              value: _folders[i].isCheck,
              onChanged: (bool value){
                _onItemCheck(index: i,type: 1);
                print('folderID:${_folders[i].id},name:${_folders[i].name},isCheck:${_folders[i].isCheck}');
              },
            )
                : null,
            title: Text('${this._folders[i].name}'),
            subtitle: Text(
              '${count}件',
              style: TextStyle(fontSize: 15),
            ),
            trailing: Icon(Icons.chevron_right),
//            lastItem: true,
            onTap: (){
              if(this._isCheck) {
                _onItemCheck(index: i, type: 1);
                print('folderID:${_folders[i].id},name:${_folders[i].name},isCheck:${_folders[i].isCheck}');
              }else{
                //フォルダ別レシピリストを表示する
                _onListGroupBy(index: i);
              }
            }
        ),
      );
    }
    return column;
  }

  //レシピの整理画面へ遷移
  void _showAbout(){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => About(),
          fullscreenDialog: true,
        )
    ).then((result) {
      print('閉じる');
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
      drawer: _isCheck ? null : drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
//        leading: _isCheck ? Container() : menuBtn(),
        elevation: 0.0,
        title: Center(
          child: Text(_isCheck ? '${_selectedCount()}個選択':'レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
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
          addBtn(),
        ],
      ),
      body: recipiList(),
        bottomNavigationBar: bottomNavigationBar(),
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
                      Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
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
                      Icons.local_offer, color: Colors.deepOrange[100 * (1 % 9)],),
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
                this._isCheck = !this._isCheck;
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
        },
      ),
    );
  }

  //追加ボタン
  Widget addBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        color: Colors.white,
        icon: const Icon(Icons.add_circle_outline),
        onPressed: (){
          _onAdd();
        },
      ),
    );
  }

  //ナビゲーション
  Widget bottomNavigationBar(){
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
              _changeBottomNavigation(index);
            },
          );
        }
    );
  }

  //フォルダ、タグ付け、削除するボタン
  Widget buttonArea(){
    return
    !_isCheck
      ? Container()
      : SizedBox(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            //削除するボタン
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
                        const Icon(Icons.delete_outline,color: Colors.white,),
                        const Text('削除する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                      ],
                    ),
                    onPressed: _onDisabled(type: 3) ? null :(){
                      _onDelete();
                      print('削除する');
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recipiList(){
    return Stack(
      children: [
//        test(),
        showList(),
        updater(),
        error(isError: this._isError,),
      ],
    );
  }

  //リストページ全体
  Widget showList(){
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          folderArea(),
          Expanded(child: folderListArea()),//フォルダ別
          buttonArea()
        ],
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

  //フォルダ別リストエリア
  Widget folderArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
          return
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
              width: MediaQuery.of(context).size.width,
              child: Container(
                color: Colors.deepOrange[100 * (2 % 9)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10,right: 10),
                      child: FittedBox(fit:BoxFit.fitWidth,
                        child: Text('フォルダ別レシピ', style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
  //                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ),
                  ],
                ),
              ),
            );
        }
    );
  }

  Widget folderListArea(){
    return
      _folders.length == 0
          ? Container()
          : SingleChildScrollView(
        child: Container(
          child: ListGroup(
            borderColor: Colors.white,
//            borderRadius: 5.0,
//            borderWidth: 0.0,
            items: _createGroup(),
          ),
        ),
      );
  }
}