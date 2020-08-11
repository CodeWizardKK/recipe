import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
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
  List<MstFolder> _Mfolders;     //フォルダマスタ
  List<MstTag> _Mtags;           //タグマスタ

  List<Check> _folders;          //チェックボック付きフォルダリスト
  List<Check> _tags;             //チェックボックス付きタグリスト
  List<Check> _oldTags;          //チェックボック付きフォルダリスト

  String _name = '';             //モーダルにて入力した値
  int _sortType = 0;             //表示タイプ 0:全表示 1:フォルダのみ 2:タグのみ
  bool _isFolderBy = false;       //true:フォルダ別レシピ一覧へ遷移


  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    this._Mfolders = [];
    this._Mtags = [];
    this._oldTags = [];

    //表示タイプを取得
    this._sortType = Provider.of<Display>(context, listen: false).getSortType();
//    print('表示タイプ：${_sortType}');

    //チェックBox付きフォルダリストの生成
    this._folders = Provider.of<Display>(context, listen: false).createCheckList(type: 1);

    //チェックBox付きタグリストの生成
    this._tags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
    this._oldTags = Provider.of<Display>(context, listen: false).createDefaultCheckList(type: 2);
//    for(var i = 0; i < this._tags.length; i++){
//      this._oldTags.add(this._tags[i]);
//      print('${_oldTags[i].id},${_oldTags[i].name},${_oldTags[i].isCheck}');
//    }

  //戻る画面を取得
    this._isFolderBy = Provider.of<Display>(context, listen: false).getIsFolderBy();

  }

  //一覧リストへ遷移
  void _onList(){

    //レシピの整理での表示タイプをset
    Provider.of<Display>(context, listen: false).setSortType(0);

    if(this._isFolderBy){
      //フォルダ別一覧リストへ遷移
      Provider.of<Display>(context, listen: false).setState(4);
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
  void _onModalSubmit({int type}) async {
    print('type:${type}');
    if(this._name.isEmpty){
      return;
    }
    //フォルダに追加の場合
    if(type == 1){
      //入力内容をセットする
      MstFolder folder = MstFolder(id:-1,name: this._name);
      //フォルダマスタへの登録処理
      MstFolder result = await dbHelper.insertMstFolder(folder);
      print('登録したfolderMstID${result.id}');

      //フォルダマスタに登録したを内容を表示形式にし追加する
      //フォルダアイコンをタップした場合のみ、登録したフォルダを選択状態にする
      Check check = Check(id: result.id,name: result.name,isCheck: this._sortType == 0 ? true : false);
      Provider.of<Display>(context, listen: false).addDisplayCheck(check: check,type: type);

      //フォルダマスタ取得処理
      await dbHelper.getMstFolders().then((item){
        setState(() {
          this._Mfolders.clear();
          this._Mfolders.addAll(item);
        });
      });
      //取得したフォルダマスタをstoreに保存
      Provider.of<Display>(context, listen: false).setMstFolder(this._Mfolders);

      //フォルダリストを取得し、展開する
      this._folders = Provider.of<Display>(context, listen: false).getDisplayCheck(type: type);

    }else{
      //入力内容をセットする
      MstTag tag = MstTag(id:-1,name: this._name);
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

      //タグマスタ取得処理
      await dbHelper.getMstTags().then((item){
        setState(() {
          this._Mtags.clear();
          this._Mtags.addAll(item);
        });
      });
      //取得したタグマスタをstoreへ保存
      Provider.of<Display>(context, listen: false).setMstTag(this._Mtags);

      //タグリストを取得し、展開する
      this._tags = Provider.of<Display>(context, listen: false).getDisplayCheck(type: type);
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
        await dbHelper.updateFolderId(id: ids[i],folder_id: folder_id);
      }

    //タグ付けボタン
    }else if(this._sortType == 2){
      //フォルダIDを更新する
      List ids = Provider.of<Display>(context, listen: false).getIds();
      for(var i = 0; i < ids.length; i++){
        //タグ削除処理
        await dbHelper.deletetag(ids[i]);
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
        await dbHelper.deletetag(recipi.id);

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

  void _onCheck({int index,int type}){
    //フォルダリスト
    if(type == 1){
      if(!this._folders[index].isCheck){
        for(var i=0; i < this._folders.length; i++){
          this._folders[i].isCheck = false;
        }
      }
      setState(() {
        this._folders[index].isCheck = !this._folders[index].isCheck;
        if(this._folders[index].isCheck){

        }
      });
      //タグリストをsetする
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

  //フォルダリストエリア
  Column _createFolderList(){
    List<Widget> column = new List<Widget>();
    setState(() {
//        this._folders = Provider.of<Display>(context, listen: false).getFolder();
    });
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
//                      Container(
//                          width: MediaQuery.of(context).size.width * 0.05,
//                          padding: EdgeInsets.all(5),
//                          child: Icon(Icons.check_circle_outline,color: Colors.grey,size: 30,)
//                      ),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                          child:
                          Checkbox(
                            value: _folders[i].isCheck,
                            onChanged: (bool value){
//                              onTabCheck(index: i,value: value);
                              _onCheck(index: i,type: 1);
                            },
                          )
                      ),
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      _onCheck(index: i,type: 1);
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
    column.add(
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
                    child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('新しいフォルダ',style: TextStyle(
                        color: Colors.cyan,
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
    return Column(
      children: column,
    );
  }

  //タグリストエリア
  Column _createTagList(){
    List<Widget> column = new List<Widget>();
    setState(() {
//      this._tags = Provider.of<Display>(context, listen: false).createCheck();
//        this._Mtags = Provider.of<Display>(context, listen: false).getMstTag();
    });
    //フォルダリストを展開する
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
                      Container(
                          width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                          child:
                          Checkbox(
                            value: _tags[i].isCheck,
                            onChanged: (bool value){
//                              onTabCheck(index: i,value: value);
                              _onCheck(index: i,type: 2);
                            },
                          )
                      ),
                    ],
                  ),
                  onTap: (){
                    setState(() {
                      setState(() {
                        _onCheck(index: i,type: 2);
                      });
                      print('ID:${_tags[i].id},NAME:${_tags[i].name},isCheck:${_tags[i].isCheck}');
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
    column.add(
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
                    child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('新しいタグ',style: TextStyle(
                        color: Colors.cyan,
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
                      icon: Icon(Icons.close,color: Colors.cyan,size: 30,),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),
                Text( type == 1 ? '新しいフォルダ' : '新しいタグ',
                  style: TextStyle(
                      color: Colors.cyan
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
                    color: Colors.cyan,
                    child: Text('保存',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    onPressed: (){
                      Navigator.pop(context);
                      _onModalSubmit(type: type);
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
        backgroundColor: Colors.cyan,
        leading: closeBtn(),
        elevation: 0.0,
        title: Center(
          child: Text('レシピの整理',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          completeBtn(),
        ],
      ),
      body: scrollArea(),
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
          child: Text('保存',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 15,
            ),
          ),
          onPressed: (){
            _onSubmit();
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
              _sortType == 1
              ? <Widget>[
                //フォルダ整理
                folderListArea(), //フォルダリストエリア
                line(),
              ]
              : _sortType == 2
                ? <Widget>[
                //タグ整理
                  tagListArea(), //タグリストエリア
                  line(),
                ]
                : <Widget>[
                  //全て
                  recipiArea(), //選択レシピ表示エリア
                  line(),
                  headerArea(type: 1), //フォルダに移動
                  line(),
                  folderListArea(), //フォルダリストエリア
                  line(),
                  headerArea(type: 2), //タグをつける
                  line(),
                  tagListArea(), //タグリストエリア
                  line(),
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
              child: Image.file(File(Detail.recipi.thumbnail)),
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