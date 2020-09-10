import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/Check.dart';


class RecipiSort extends StatefulWidget{

  @override
  _RecipiSortState createState() => _RecipiSortState();
}

class _RecipiSortState extends State<RecipiSort>{

  DBHelper dbHelper;
  Common common;
  List<MstFolder> _Mfolders = List<MstFolder>();     //フォルダマスタ
  List<MstTag> _Mtags = List<MstTag>();           //タグマスタ

  List<Check> _folders  = List<Check>();          //チェックボック付きフォルダリスト
  List<Check> _tags = List<Check>();             //チェックボックス付きタグリスト
  List<Check> _oldTags = List<Check>();          //チェックボック付きフォルダリスト

  String _name = '';             //モーダルにて入力した値
  int _sortType = 0;             //表示タイプ 0:全表示 1:フォルダのみ 2:タグのみ
  int _backScreen = 0;           //0:レシピのレシピ一覧 1:レシピのフォルダ別レシピ一覧 2:ごはん日記の日記詳細レシピ一覧 3:ホーム画面
  bool _isCheck = false;         //true:チェックボックス表示
  String _title = '';            //表示するタイトル


  @override
  void initState() {
    super.initState();
    _getItem();
  }

  _getItem() async {
    dbHelper = DBHelper();
    common = Common();
    this._Mfolders = [];
    this._Mtags = [];
    this._oldTags = [];

    //タイトルを取得
    this._title = Provider.of<Display>(context, listen: false).getSortTitle();
    //表示タイプを取得
    this._sortType = Provider.of<Display>(context, listen: false).getSortType();
    //チェックBox付きフォルダリストの生成
    this._folders = Provider.of<Display>(context, listen: false).createCheckList(type: 1);
    if(this._folders.length == 0 ){
      await this._getMstfolders(type: 1,isRefresh: true);
    }
    //チェックBox付きタグリストの生成
    this._tags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
    if(this._tags.length == 0 ){
      await this._getMstTags(type: 1,isRefresh: true);
    }
    this._oldTags = Provider.of<Display>(context, listen: false).createDefaultCheckList(type: 2);
    //戻る画面を取得
    this._backScreen = Provider.of<Display>(context, listen: false).getBackScreen();
  }

  //一覧リストへ遷移
  void _onList(){

    //レシピの整理での表示タイプをset
    Provider.of<Display>(context, listen: false).setSortType(0);
    if(this._backScreen == 1) {
      //フォルダ別一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(4);
    }else if(this._backScreen == 2){
      //2:ごはん日記へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }else if(this._backScreen == 3) {
      //3:ホーム画面へ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(0);
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }else if(this._backScreen == 4){
      //3:アルバムへ遷移
      Provider.of<Display>(context, listen: false).setCurrentIndex(3);
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }else{
      //一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(0);
    }
    //初期化
    this._init();
  }



  //初期化処理
  void _init(){
    this._name = '';
    this._Mfolders = [];
    this._Mtags = [];
    this._folders = [];
    this._oldTags = [];
    this._tags = [];
    //リセット処理
    Provider.of<Display>(context, listen: false).sortReset();
  }

  //モーダルの保存するボタン押下時処理
  void _onModalSubmit({int type,int selectedId}) async {
    print('type:${type}');
    //空の場合登録せず閉じる
    if(this._name.isEmpty){
      return;
    }

    //フォルダ追加の場合
    if(type == 1){
      //登録の場合
      if(selectedId == -1){
        //入力内容をセットする
        MstFolder folder = MstFolder(id: selectedId,name: this._name);
        //フォルダマスタへの登録処理
        MstFolder result = await dbHelper.insertMstFolder(folder);
//        print('登録したfolderMstID${result.id}');
        //フォルダマスタに登録したを内容を表示形式にし追加する
        //フォルダアイコンをタップした場合のみ、登録したフォルダを選択状態(true)で追加する
        Check check = Check(id: result.id,name: result.name,isCheck: this._sortType == 0 ? true : false);
        Provider.of<Display>(context, listen: false).addDisplayCheck(check: check,type: type);
        //最新のレコードを取得
        await this._getMstfolders(type: type,isRefresh: false);
      }else{
      //更新の場合
        //フォルダマスタへの更新処理
        await dbHelper.updateMstFolder(folder_id: selectedId,name: this._name);
        //最新のレコードを取得
        await this._getMstfolders(type: type,isRefresh: true);
      }
    }else{
    //タグ追加の場合
      //登録の場合
      if(selectedId == -1){
        //入力内容をセットする
        MstTag tag = MstTag(id:selectedId,name: this._name);
        //タグマスタ登録処理
        MstTag result = await dbHelper.insertMstTag(tag);

        //タグマスタに登録したを内容を表示形式にし追加する
        //フォルダアイコンをタップした場合のみ、登録したタグを選択状態にする
        print('登録したtagmstID${result.id}');
        Check check = Check(id: result.id,name: result.name,isCheck: this._sortType == 0 ? true : false);
        Provider.of<Display>(context, listen: false).addDisplayCheck(check: check,type: type);

        //変更前
        Check default_check = Check(id: result.id,name: result.name,isCheck: false);
        Provider.of<Display>(context, listen: false).addefaultDisplayCheck(check: default_check,type: type);
        //最新のレコードを取得
        await this._getMstTags(type: type, isRefresh: false);
      }else{
        //更新の場合
        //フォルダマスタへの更新処理
        await dbHelper.updateMstTag(tag_id: selectedId,name: this._name);
        //最新のレコードを取得
        await this._getMstTags(type: type,isRefresh: true);
      }
    }
  }

  //保存する押下時処理
  void _onSubmit() async {
    //フォルダボタン
    if(this._sortType == 1){
      int folder_id = 0;
      //変更後のフォルダIDを取得
      for(var i = 0; i < this._folders.length; i++){
        if(this._folders[i].isCheck ){
          folder_id = this._folders[i].id;
          break;
        }
      }
      //フォルダIDを更新する
      List ids = Provider.of<Display>(context, listen: false).getIds();
      for(var i = 0; i < ids.length; i++){
        await dbHelper.updateFolderId(recipi_id: ids[i],folder_id: folder_id);
      }
    //タグ付けボタン
    }else if(this._sortType == 2){
      //フォルダIDを更新する
      List ids = Provider.of<Display>(context, listen: false).getIds();
      for(var i = 0; i < ids.length; i++){
        //タグ削除処理
        await dbHelper.deleteTagRecipiId(ids[i]);
        //タグ追加処理
        for(var k = 0; k < this._tags.length; k++){
          if(this._tags[k].isCheck){
            Tag tag = Tag(id: -1,recipi_id: ids[i],mst_tag_id: this._tags[k].id);
            await dbHelper.insertTag(tag);
          }
        }
      }
    //フォルダアイコン押下時
    }else{
      //該当のレシピを取得
      Myrecipi recipi = Provider.of<Detail>(context, listen: false).getRecipi();

      //変更前のフォルダIDを取得
      int old_folder_id = recipi.folder_id;
      //変更後のフォルダIDを取得
      recipi.folder_id = 0;
      for(var i = 0; i < this._folders.length; i++){
        if(this._folders[i].isCheck ){
          recipi.folder_id = this._folders[i].id;
          break;
        }
      }
      //変更前後のフォルダIDを比較し、変更がある場合のみ更新
      if(old_folder_id != recipi.folder_id){
        //フォルダIDの更新
        await dbHelper.updateMyRecipi(recipi);
      }
      //タグの更新
      bool equals = this._equals(oldItem:this._oldTags, newItem:this._tags);
      print('equals:${equals}');
      if(!equals){
        print('--------タグテーブル更新---------');
        //タグ削除処理
        await dbHelper.deleteTagRecipiId(recipi.id);

        for(var i = 0; i < this._tags.length; i++){
          if(this._tags[i].isCheck){
            Tag tag = Tag(id: -1,recipi_id: recipi.id,mst_tag_id: this._tags[i].id);
            await dbHelper.insertTag(tag);
          }
        }
      }else{
        print('--------タグテーブル更新しない---------');
      }
    }
     //一覧リストへ遷移
    this._onList();
  }

  // レシピの整理にて保存ボタン押下時、チェックリストの変更有無をチェック
  // true:変更あり
  bool _equals({List<Check> oldItem,List<Check> newItem}){

    for(var i = 0; i < newItem.length; i++){
      if(oldItem[i].id != newItem[i].id){
        return false;
      }
      if(oldItem[i].name != newItem[i].name){
        return false;
      }
      if(oldItem[i].isCheck != newItem[i].isCheck){
        return false;
      }
    }
    return true;
  }

  //テキスト欄入力
  void _onChange(String name){
    print('###入力内容:${name}');

    setState(() {
      this._name = name;
    });
  }

  //フォルダ、タグ選択処理
  void _onSelected({int index,int type}){
    //フォルダリスト(1件のみ選択)
    if(type == 1){
      if(!this._folders[index].isCheck){
        for(var i=0; i < this._folders.length; i++){
          this._folders[i].isCheck = false;
        }
      }
      setState(() {
        this._folders[index].isCheck = !this._folders[index].isCheck;
      });
      //フォルダリストをsetする
      Provider.of<Display>(context, listen: false).setCheck(index: index,isCheck:this._folders[index].isCheck,type: type);
      print('ID:${_folders[index].id},NAME:${_folders[index].name},isCheck:${_folders[index].isCheck}');

    //フォルダリスト(複数選択)
    }else if(type == 3){
      setState(() {
        this._folders[index].isCheck = !this._folders[index].isCheck;
      });
      //フォルダリストをsetする
      Provider.of<Display>(context, listen: false).setCheck(index: index,isCheck:this._folders[index].isCheck,type: type);
      print('ID:${_folders[index].id},NAME:${_folders[index].name},isCheck:${_folders[index].isCheck}');


    //タグリスト
    }else{
      setState(() {
        this._tags[index].isCheck = !this._tags[index].isCheck;
      });
      //タグリストをsetする
      Provider.of<Display>(context, listen: false).setCheck(index: index,isCheck:this._tags[index].isCheck,type: type);
      print('ID:${_tags[index].id},NAME:${_tags[index].name},isCheck:${_tags[index].isCheck}');
      print('ID:${_oldTags[index].id},NAME:${_oldTags[index].name},isCheck:${_oldTags[index].isCheck}');
    }
  }

  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });
  }

  //チェックボックスにて選択した値を返す
  int _selectedCount(){
    int count = 0;
    //フォルダの管理(menu)
    if(this._sortType == 3) {
      for (var i = 0; i < this._folders.length; i++) {
        if (this._folders[i].isCheck) {
          count++;
        }
      }
    }
    // 4:タグの管理(menu)
    if(this._sortType == 4) {
      for (var i = 0; i < this._tags.length; i++) {
        if (this._tags[i].isCheck) {
          count++;
        }
      }
    }
    return count;
  }

  //削除処理
  void _onDelete() async {
    List ids = [];

    //フォルダの管理(menu)
    if(this._sortType == 3){
      //選択したフォルダマスタを削除
      for(var i = 0; i < this._folders.length; i++){
        if(this._folders[i].isCheck){
          ids.add(this._folders[i].id);
        }
      }
      if(ids.length > 0){
        print('削除するフォルダマスタID：${ids}');
        //フォルダマスタ削除処理
        for(var i = 0; i < ids.length; i++){
          //フォルダマスタ削除
          await dbHelper.deleteMstFolder(ids[i]);
          //フォルダマスタで削除したIDに紐づくレシピを取得する
          List<Myrecipi> recipis = await dbHelper.getMyRecipibyFolderID(ids[i]);
          //フォルダマスタで削除したIDに紐づくレシピデータのフォルダIDを0に更新する
          for(var i = 0; i < recipis.length; i++){
            await dbHelper.updateFolderId(recipi_id: recipis[i].id,folder_id: 0);
          }
        }
        //最新のレコードを取得
        await this._getMstfolders(type: 1,isRefresh: true);
      }
    }

    //タグの管理(menu)
    if(this._sortType == 4){
      //選択したフォルダマスタを削除
      for(var i = 0; i < this._tags.length; i++){
        if(this._tags[i].isCheck){
          ids.add(this._tags[i].id);
        }
      }
      if(ids.length > 0){
        print('削除するタグマスタID：${ids}');
        //タグマスタ削除処理
        for(var i = 0; i < ids.length; i++){
          //タグマスタ削除
          await dbHelper.deleteMstTag(ids[i]);
          //タグマスタで削除したIDに紐づくタグデータを削除する
          await dbHelper.deleteTagMstTagId(ids[i]);
        }
        //最新のレコードを取得
        await this._getMstTags(type: 2,isRefresh: true);
      }
    }
    setState(() {
      this._isCheck = !this._isCheck;
    });
  }

  //フォルダマスタの取得
  Future<void> _getMstfolders({int type,bool isRefresh}) async {
    //最新フォルダマスタを取得
    await dbHelper.getMstFolders().then((item){
      setState(() {
        this._Mfolders.clear();
        this._Mfolders.addAll(item);
      });
    });
    //取得したフォルダマスタをstoreに保存
    Provider.of<Display>(context, listen: false).setMstFolder(this._Mfolders);

    //フォルダリストを取得し、展開する
    setState(() {
      if(isRefresh){
        //チェックBox付きフォルダリストの生成
        this._folders = Provider.of<Display>(context, listen: false).createCheckList(type: 1);
      }else{
        //追加データをリストへaddし、チェックBox付きフォルダリストを取得
        this._folders = Provider.of<Display>(context, listen: false).getDisplayCheck(type: type);
      }
    });
  }

  //タグマスタの取得
  Future<void> _getMstTags({int type,bool isRefresh}) async {
    //最新タグマスタを取得
    await dbHelper.getMstTags().then((item){
      setState(() {
        this._Mtags.clear();
        this._Mtags.addAll(item);
      });
    });
    //取得したタグマスタをstoreへ保存
    Provider.of<Display>(context, listen: false).setMstTag(this._Mtags);

    //タグリストを取得し、展開する
    setState(() {
      if(isRefresh){
        //チェックBox付きフォルダリストの生成
        this._tags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
      }else {
        //追加データをリストへaddし、チェックBox付きフォルダリストを取得
        this._tags = Provider.of<Display>(context, listen: false).getDisplayCheck(type: type);
      }
    });
  }

  //フォルダリストエリア
  Column _createFolderList(){
    List<Widget> column = new List<Widget>();
    //フォルダリストを展開する
    for(var i=0; i < this._folders.length; i++){
      column.add(
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white,
              child: InkWell(
                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _isCheck
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Checkbox(
                            value: _folders[i].isCheck,
                            onChanged: (bool value){
                              _onSelected(index: i,type: 3);
                            },
                          )
                      )
                      : Container(),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Container(
                            color: Colors.grey,
                            child: Icon(Icons.folder_open,color: Colors.white,size: 30,),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        padding: EdgeInsets.all(5),
                        child: Text('${_folders[i].name}',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        padding: EdgeInsets.all(5),
                      ),
                      _sortType == 3
                      ? Container()
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                          child:
                          Checkbox(
                            value: _folders[i].isCheck,
                            onChanged: (bool value){
//                              onTabCheck(index: i,value: value);
                              _onSelected(index: i,type: 1);
                            },
                          )
                      ),
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _sortType >= 3
                      ? _isCheck
                          ? _onSelected(index: i,type: 3)
                          : _onUpdate(type: 1,selected: _folders[i])
                      : _onSelected(index: i,type: 1);
                    });
                  }
              ),
            ),
          ),
      );
      column.add(
        Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
        ),
      );
    }
    // + 新しいフォルダ ボタン
    _isCheck
    ? null
    : column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add_circle_outline,color: Colors.brown[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('新しいフォルダ',style: TextStyle(
                        color: Colors.brown[100 * (1 % 9)],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
                //モーダル表示
                _onAdd(type: 1);
              }
          ),
        ),
      ),
    );
    _isCheck
    ? null
    : column.add(
      Divider(
        color: Colors.grey,
        height: 0.5,
        thickness: 0.5,
      ),
    );
    return Column(
      children: column,
    );
  }

  //タグリストエリア
  Column _createTagList(){
    List<Widget> column = new List<Widget>();
    //タグリストを展開する
    for(var i=0; i < this._tags.length; i++){
      column.add(
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white,
              child: InkWell(
                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _isCheck
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child:
                          Checkbox(
                            value: _tags[i].isCheck,
                            onChanged: (bool value){
                              _onSelected(index: i,type: 2);
                            },
                          )
                      )
                      : Container(),
                      Container(
                        padding: EdgeInsets.all(5),
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Container(
                            color: Colors.grey,
                            child: Icon(Icons.local_offer,color: Colors.white,size: 30,),
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        padding: EdgeInsets.all(5),
                        child: Text('${_tags[i].name}',
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 15,
//                              fontWeight: FontWeight.bold
                          ),),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.1,
                        padding: EdgeInsets.all(5),
                      ),
                      _sortType == 4
                      ? Container()
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                          child:
                          Checkbox(
                            value: _tags[i].isCheck,
                            onChanged: (bool value){
//                              onTabCheck(index: i,value: value);
                              _onSelected(index: i,type: 2);
                            },
                          )
                      ),
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _sortType >= 3 && !_isCheck
                        ? _onUpdate(type: 2,selected: _tags[i])
                        : _onSelected(index: i,type: 2);
                    });
                  }
              ),
            ),
          ),
      );
      column.add(
        Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
        ),
      );
    }
    // + 新しいフォルダ ボタン
    _isCheck
    ? null
    : column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          child: InkWell(
              child: Row(
//                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
//                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.add_circle_outline,color: Colors.brown[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('新しいタグ',style: TextStyle(
                        color: Colors.brown[100 * (1 % 9)],
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
              onTap: (){
                //モーダル表示
                _onAdd(type: 2);
              }
          ),
        ),
      ),
    );
    _isCheck
        ? null
        : column.add(
      Divider(
        color: Colors.grey,
        height: 0.5,
        thickness: 0.5,
      ),
    );
    return Column(
      children: column,
    );
  }

//+新しいフォルダ、+新しいタグ 押下時処理
  Future<void> _onAdd({int type}){
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
                  child: IconButton(
                      icon: Icon(Icons.close,color: Colors.brown[100 * (1 % 9)],size: 30,),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text( type == 1 ? '新しいフォルダ' : '新しいタグ',
                  style: TextStyle(
                      color: Colors.brown[100 * (1 % 9)]
                  ),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: TextField(
                    onChanged: _onChange,
                  style: const TextStyle(fontSize: 15.0, color: Colors.black,),
                  minLines: 1,
                  maxLines: 1,
                  decoration: InputDecoration(
                    hintText: type == 1 ? '例）お肉のおかず' :'例）おもてなし',
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white, width: 20.0),
                        borderRadius: BorderRadius.circular(0.0)
                    ),
                  ),
              ),
            ),
            actions: <Widget>[
              Container(
                width: 90,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    color: Colors.brown[100 * (1 % 9)],
                    child: Text('保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                      _onModalSubmit(type: type,selectedId: -1);
                    },
                  ),
                ),
              ),
          ],
          );
        });
  }

//フォルダ、タグ押下時処理
  Future<void> _onUpdate({int type,Check selected}){
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
                  child: IconButton(
                    icon: Icon(Icons.close,color: Colors.brown[100 * (1 % 9)],size: 30,),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text( type == 1 ? 'フォルダ名の変更' : 'タグ名の変更',
                  style: TextStyle(
                      color: Colors.brown[100 * (1 % 9)]
                  ),
                ),
              ],
            ),
            content: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              child: TextField(
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
                width: 90,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FlatButton(
                    color: Colors.brown[100 * (1 % 9)],
                    child: Text('保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                      _onModalSubmit(type: type,selectedId: selected.id);
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[100 * (1 % 9)],
        leading: closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text(_isCheck ?'${_selectedCount()}個選択' :'${_title}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: _sortType >= 3 && !_isCheck
          ? <Widget>[
            checkBtn(),
          ]
          : <Widget>[
            completeBtn(),
          ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: scrollArea(),),
          deleteBtn(),
        ],
      ),
    );
  }

  //削除するボタン
  Widget deleteBtn(){
    return
      _isCheck
          ? Container(
        width: 130,
        child: Padding(
          padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
          child: FlatButton(
            color: Colors.redAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Icon(Icons.delete_outline,color: Colors.white,),
                const Text('削除する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
              ],
            ),
            onPressed:
              _selectedCount() == 0
                ? null
                : (){_onDelete();},
          ),
        ),
      )
          : Container();
  }

  //チェックボタン
  Widget checkBtn(){
    return IconButton(
      icon: const Icon(Icons.check_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onCheck();
      },
    );
  }

  //完了ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: Text(_isCheck ? '完了' : '保存',
            style: TextStyle(
              color: Colors.brown[100 * (1 % 9)],
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _isCheck
            ? setState(() {
                this._isCheck = !this._isCheck;
              })
            : _onSubmit();
          },
        ),
      ),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return IconButton(
      icon: Icon( Icons.close,color: Colors.white,size: 30,),
      onPressed: (){
        _onList();
      },
    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
//    return Consumer<Detail>(
//        builder: (context,Detail,_) {
      return Container(
        alignment: Alignment.center,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children:
              _sortType == 1 || _sortType == 3
              ? <Widget>[
                //フォルダ整理
                folderListArea(), //フォルダリストエリア
              ]
              : _sortType == 2 || _sortType == 4
                ? <Widget>[
                //タグ整理
                  tagListArea(), //タグリストエリア
                ]
                : <Widget>[
                  //全て
                  recipiArea(), //選択レシピ表示エリア
                  line(),
                  headerArea(type: 1), //フォルダに移動
                  line(),
                  folderListArea(), //フォルダリストエリア
                  headerArea(type: 2), //タグをつける
                  line(),
                  tagListArea(), //タグリストエリア
                ]
        ),
      );
//    }
//    );
  }

  //MYレシピリスト
  Widget recipiArea(){
    return Consumer<Detail>(
      builder: (context,Detail,_) {
      return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //サムネイルエリア
                  thumbnailArea(),
                  //タイトル、材料、タグエリア
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        tilteArea(),//タイトル
                        ingredientsArea(),//材料
                        tagsArea(),//タグ
                      ],
                    ),
                  ),
                ],
              ),
          ),
        );
    });
  }

  //サムネイル
  Widget thumbnailArea(){
    return Consumer<Detail>(
      builder: (context,Detail,_) {
        return
          Detail.recipi.thumbnail.isNotEmpty
              ? SizedBox(
            height: 100,
            width: 100,
            child: Container(
              child: Image.file(File(common.replaceImage(Detail.recipi.thumbnail)),fit: BoxFit.cover,),
            ),
          )
              : SizedBox(
            height: 100,
            width: 100,
            child: Container(
              color: Colors.grey,
              child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
            ),
          );
      }
    );
  }

  //タイトル
  Widget tilteArea(){
    return Consumer<Detail>(
        builder: (context,Detail,_) {
          return
            Container(
              height: 50,
              padding: EdgeInsets.all(5),
              child: Text('${Detail.recipi.title}',
                maxLines: 2,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
            );
        }
    );
  }

  //材料
  Widget ingredientsArea(){
    return Consumer<Display>(
        builder: (context,Detail,_) {
          return
            Container(
              height: 40,
              padding: EdgeInsets.all(5),
              child: Text('${Detail.ingredientsTX}',
                maxLines: 2,
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                ),),
            );
        }
    );
  }

  //タグ
  Widget tagsArea(){
    return Consumer<Display>(
        builder: (context,Display,_) {
          return
            Display.tags.length < 0
                ? Container(
                height: 30,
                padding: EdgeInsets.only(left: 5,right: 5)
            )
                : Container(
              height: 30,
              padding: EdgeInsets.only(left: 5,right: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  //タグicon
                  Container(
                    child: Icon(Icons.local_offer,size: 15,color: Colors.brown,),
                  ),
                  //タグ名　最大5件まで
                  for (var k = 0; k<Display.tags.length; k++)
                    Container(
                      padding: EdgeInsets.all(2),
                      child: SizedBox(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          color: Colors.brown,

                          child: Text('${Display.tags[k].name}',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.white
                            ),),
                        ),
                      ),
                    ),
                ],
              ),
            );
        }
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

  //フォルダ
  Widget headerArea({int type}){
    return Consumer<Display>(
        builder: (context,Display,_) {
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text(type == 1 ? 'フォルダに移動' :'タグを付ける', style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      );
    }
    );
  }

  //フォルダリストエリア
  Widget folderListArea(){
    return Container(
      child: _createFolderList(),
    );
  }

  //タグリストエリア
  Widget tagListArea(){
    return Container(
      child: _createTagList(),
    );
  }

}