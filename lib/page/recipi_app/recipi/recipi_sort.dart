import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/Check.dart';


class RecipiSort extends StatefulWidget{

  Myrecipi Nrecipi = Myrecipi();  //選択したレシピ
  String ingredientTX = '';       //選択したレシピの材料(テキスト)
  List<Tag> tags;                 //選択したレシピのタグ
  int sortType = 0;               //表示タイプ 0:全表示 1,3:フォルダのみ 2,4:タグのみ
  String title = '';              //表示するタイトル
  List ids = [];                  //チェックボックスにてチェックしたレシピ(ID)を格納

  RecipiSort({Key key, @required this.Nrecipi, @required this.ingredientTX,@required this.sortType,@required this.tags,@required this.title,@required this.ids,}) : super(key: key);

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
    this._title = widget.title;
    //表示タイプを取得
    this._sortType = widget.sortType;
    //フォルダアイコン押下時
    if(this._sortType == 0){
      //フォルダマスタを取得し、チェックボック付きリスト生成
      await this._getMstfolders(type: 1,isRefresh: true,sortType: this._sortType);
      //タグマスタを取得し、チェックボック付きリスト生成
      await this._getMstTags(type: 2,isRefresh: true,sortType: this._sortType);
      //編集前のチェックボック付きタグリストの生成(比較用)
      this._Mtags.forEach((Mtag) {
        setState(() {
          this._oldTags.add(Check(id:Mtag.id,name: Mtag.name,isCheck: checkTag(id: Mtag.id)));
        });
      });
    //フォルダ管理
    } else if(_sortType == 1 || _sortType == 3){
      if(_sortType == 1){
        print('選択したレシピID[${widget.ids}]');
      }
      await this._getMstfolders(type: 1,isRefresh: true,sortType: this._sortType);
    //タグ管理
    } else if(_sortType == 2 || _sortType == 4) {
      if(_sortType == 2){
        print('選択したレシピID[${widget.ids}]');
      }
      await this._getMstTags(type: 2,isRefresh: true,sortType: this._sortType);
    }
  }

  //選択のフォルダをチェック済み状態にする(フォルダアイコン押下時のみセット)
  bool checkFolder({int id}){
    if(id == widget.Nrecipi.folder_id){
      return true;
    }
    return false;
  }

  //選択のタグをチェック済み状態にする(フォルダアイコン押下時のみセット)
  bool checkTag({int id}){
    var result = widget.tags.firstWhere((tag) => tag.mst_tag_id == id, orElse: () => null);
    if(result == null){
      return false;
    }
    return true;
  }

  //一覧リストへ遷移
  void _onList({bool isFolderUpdate}){
    if(isFolderUpdate){
      Navigator.pop(context,'FolderUpdate');
    } else {
      Navigator.pop(context);
    }
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
        this.addDisplayCheck(check: check,type: type);
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
        this.addDisplayCheck(check: check,type: type);

        //変更前
        Check default_check = Check(id: result.id,name: result.name,isCheck: false);
        this.addefaultDisplayCheck(check: default_check,type: type);
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

  void addDisplayCheck({Check check,int type}){
    setState(() {
      //フォルダリスト
      if(type == 1){
        //フォルダは複数選択不可なので、全てfalseに変更する
        this._folders.forEach((folder) => folder.isCheck = false);
        this._folders.add(check);
        //タグリスト
      }else{
        this._tags.add(check);
      }
    });
  }

  void addefaultDisplayCheck({Check check,int type}){
    //フォルダリスト
    if(type == 1){
      //タグリスト
    }else{
      this._oldTags.add(check);
    }
  }

  //保存する押下時処理
  void _onSubmit() async {
    bool isFolderUpdate = false;
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
      for(var i = 0; i < widget.ids.length; i++){
        await dbHelper.updateFolderId(recipi_id: widget.ids[i],folder_id: folder_id);
      }
      isFolderUpdate = true;
    //タグ付けボタン
    }else if(this._sortType == 2){
      //フォルダIDを更新する
      for(var i = 0; i < widget.ids.length; i++){
        //タグ削除処理
        await dbHelper.deleteTagRecipiId(widget.ids[i]);
        //タグ追加処理
        for(var k = 0; k < this._tags.length; k++){
          if(this._tags[k].isCheck){
            Tag tag = Tag(id: -1,recipi_id: widget.ids[i],mst_tag_id: this._tags[k].id);
            await dbHelper.insertTag(tag);
          }
        }
      }
    //フォルダアイコン押下時
    }else{
      //該当のレシピを取得
      Myrecipi recipi = widget.Nrecipi;

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
        isFolderUpdate = true;
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
    this._onList(isFolderUpdate: isFolderUpdate);
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
      print('ID:${_folders[index].id},NAME:${_folders[index].name},isCheck:${_folders[index].isCheck}');

    //フォルダリスト(複数選択)
    }else if(type == 3){
      setState(() {
        this._folders[index].isCheck = !this._folders[index].isCheck;
      });
      //フォルダリストをsetする
      print('ID:${_folders[index].id},NAME:${_folders[index].name},isCheck:${_folders[index].isCheck}');


    //タグリスト
    }else{
      setState(() {
        this._tags[index].isCheck = !this._tags[index].isCheck;
      });
    }
  }

  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });
    if(this._sortType == 3){
      setState(() {
        this._folders.forEach((folder) => folder.isCheck = false);
      });
    }
    if(this._sortType == 4){
      this._tags.forEach((tag) => tag.isCheck = false);
    }
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

  //フォルダマスタの取得し、チェックボックス付きフォルダリストを生成する
  Future<void> _getMstfolders({int type,bool isRefresh,int sortType}) async {
    //最新フォルダマスタを取得
    await dbHelper.getMstFolders().then((item){
      setState(() {
        this._Mfolders.clear();
        this._Mfolders.addAll(item);
      });
    });
    setState(() {
      if(isRefresh){
        setState(() {
          this._folders.clear();
        });
        if(sortType == 0) {
//        //チェックBox付きフォルダリストの生成
          this._Mfolders.forEach((Mfolder) {
            setState(() {
              this._folders.add(Check(id: Mfolder.id, name: Mfolder.name, isCheck: checkFolder(id: Mfolder.id)));
            });
          });
        } else {
          if(sortType == 1) {
            this._folders.add(Check(id: 0, name: 'フォルダから出す', isCheck: false));
          }
//        //チェックBox付きフォルダリストの生成
          this._Mfolders.forEach((Mfolder) {
            setState(() {
              this._folders.add(Check(id:Mfolder.id,name: Mfolder.name,isCheck: false));
            });
          });
        }
      }
    });
  }

  //タグマスタの取得
  Future<void> _getMstTags({int type,bool isRefresh,int sortType}) async {
    //最新タグマスタを取得
    await dbHelper.getMstTags().then((item){
      setState(() {
        this._Mtags.clear();
        this._Mtags.addAll(item);
      });
    });
    setState(() {
      if(isRefresh){
        setState(() {
          this._tags.clear();
        });
        if(sortType == 0) {
//        //チェックBox付きフォルダリストの生成
          this._Mtags.forEach((Mtag) {
            setState(() {
              this._tags.add(Check(id:Mtag.id,name: Mtag.name,isCheck: checkTag(id: Mtag.id)));
            });
          });
        } else {
//        //チェックBox付きフォルダリストの生成
          this._Mtags.forEach((Mtag) {
            setState(() {
              this._tags.add(Check(id:Mtag.id,name: Mtag.name,isCheck: false));
            });
          });
        }
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
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _isCheck
                      ? Container(
//                          width: MediaQuery.of(context).size.width * 0.1,
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
//                        child: FittedBox(fit:BoxFit.fitWidth,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.width * 0.1,
                            width: MediaQuery.of(context).size.width * 0.1,
                            child: Container(
                              color: Colors.amber[100 * (1 % 9)],
                              child: Icon(Icons.folder_open,color: Colors.white,size: 30,),
                            ),
                          ),
//                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
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
                    child: Icon(Icons.add_circle_outline,color: Colors.deepOrange[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: FittedBox(fit:BoxFit.fitWidth,
                      child: Text('新しいフォルダ',style: TextStyle(
                          color: Colors.deepOrange[100 * (1 % 9)],
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
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
    _sortType == 1 || _sortType == 3
    ?
    // 空
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white10,
        ),
      ),
    )
    : null;
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
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Row(
//                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      _isCheck
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Checkbox(
                            value: _tags[i].isCheck,
                            onChanged: (bool value){
                              _onSelected(index: i,type: 2);
                            },
                          )
                      )
                      : Container(),
                      Container(
                        padding: EdgeInsets.all(5),
//                        child: FittedBox(fit:BoxFit.fitWidth,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.1,
                          child: Container(
                            color: Colors.amber[100 * (1 % 9)],
                            child: Icon(Icons.local_offer,color: Colors.white,size: 30,),
                          ),
                        ),
//                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
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
                    child: Icon(Icons.add_circle_outline,color: Colors.deepOrange[100 * (1 % 9)],)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: FittedBox(fit:BoxFit.fitWidth,
                      child: Text('新しいタグ',style: TextStyle(
                          color: Colors.deepOrange[100 * (1 % 9)],
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
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
    // 空
    column.add(
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white10,
        ),
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
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: IconButton(
                        icon: Icon(Icons.close,color: Colors.deepOrange[100 * (1 % 9)],size: 30,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text( type == 1 ? '新しいフォルダ' : '新しいタグ',
                  style: TextStyle(
                      color: Colors.deepOrange[100 * (1 % 9)]
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
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: FlatButton(
                      color: Colors.deepOrange[100 * (1 % 9)],
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
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: IconButton(
                      icon: Icon(Icons.close,color: Colors.deepOrange[100 * (1 % 9)],size: 30,),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Text( type == 1 ? 'フォルダ名の変更' : 'タグ名の変更',
                  style: TextStyle(
                      color: Colors.deepOrange[100 * (1 % 9)]
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
                width: MediaQuery.of(context).size.width * 0.25,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: FittedBox(fit:BoxFit.fitWidth,
                    child: FlatButton(
                      color: Colors.deepOrange[100 * (1 % 9)],
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
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        leading: closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text(_isCheck ?'${_selectedCount()}個選択' :'${_title}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
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
            width: MediaQuery.of(context).size.width * 0.3,
            child: Padding(
              padding: EdgeInsets.only(top: 5,bottom: 30,left: 10,right: 10),
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
                  onPressed:
                    _selectedCount() == 0
                      ? null
                      : (){_onDelete();},
                ),
              ),
            ),
          )
          : Container();
  }

  //チェックボタン
  Widget checkBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        icon: const Icon(Icons.check_circle_outline,color: Colors.white),
        onPressed: (){
          _onCheck();
        },
      ),
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
            child: Text(_isCheck ? '完了' : '保存',
              style: TextStyle(
                color: Colors.deepOrange[100 * (1 % 9)],
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
      ),
    );
  }

  //閉じるボタン
  Widget closeBtn(){
    return
      FittedBox(fit:BoxFit.fitWidth,
        child: IconButton(
          icon: Icon( Icons.close,color: Colors.white),
          onPressed: (){
            _onList(isFolderUpdate: false);
          },
        ),
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
              headerArea(type: 1), //フォルダに移動
              folderListArea(), //フォルダリストエリア
              headerArea(type: 2), //タグをつける
              tagListArea(), //タグリストエリア
            ]
      ),
    );
  }

  //MYレシピリスト
  Widget recipiArea(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
//      height: MediaQuery.of(context).size.height * 0.16,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
//        padding: EdgeInsets.all(5),
          child: FittedBox(fit:BoxFit.fitWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                //サムネイルエリア
                thumbnailArea(),
                //タイトル、材料、タグエリア
                Container(
  //                color: Colors.grey,
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
      ),
    );
  }

  //サムネイル
  Widget thumbnailArea(){
        return
          widget.Nrecipi.thumbnail.isNotEmpty
              ? SizedBox(
            height: MediaQuery.of(context).size.width * 0.25,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              child: Image.file(File(common.replaceImage(widget.Nrecipi.thumbnail)),fit: BoxFit.cover,),
            ),
          )
              : SizedBox(
            height: MediaQuery.of(context).size.width * 0.25,
            width: MediaQuery.of(context).size.width * 0.25,
            child: Container(
              color: Colors.grey,
              child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
            ),
          );
  }

  //タイトル
  Widget tilteArea(){
    return
      Container(
//        height: MediaQuery.of(context).size.height * 0.05,
        padding: EdgeInsets.all(5),
        child: Text('${widget.Nrecipi.title}',
          maxLines: 2,
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold
          ),),
      );
  }

  //材料
  Widget ingredientsArea(){
    return
      Container(
//        height: MediaQuery.of(context).size.height * 0.04,
        padding: EdgeInsets.all(5),
        child: Text('${widget.ingredientTX}',
          maxLines: 2,
          style: TextStyle(
              fontSize: 12,
              color: Colors.grey
          ),),
      );
  }

  //タグ
  Widget tagsArea(){
  return
    widget.tags.length == 0
      ? Container()
      : Container(
//      color:Colors.grey,
      height: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 0.08 : MediaQuery.of(context).size.height * 0.06,
      padding: EdgeInsets.only(left: 5,right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //タグicon
          Container(
            padding: EdgeInsets.only(top: 10),
            width: MediaQuery.of(context).size.width * 0.03,
            child: Icon(Icons.local_offer,size: 20,color: Colors.yellow[100 * (1 % 9)]),
          ),
          Container(
//            color: Colors.brown,
            width: MediaQuery.of(context).size.width * 0.64,
            child: MultiSelectChipDisplay(
              chipColor: Colors.yellow,
              onTap: null,
              items: widget.tags
                  .map((e) => MultiSelectItem<Tag>(e, e.name))
                  .toList(),
            ),
          ),
        ],
      ),
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
                  child: Text(type == 1 ? 'フォルダに移動' :'タグを付ける', style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold
                  ),),
                ),
              ),
            ],
          ),
        ),
      );
//    }
//    );
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