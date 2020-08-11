import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MyrecipiGroupFolder.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/Check.dart';
import 'package:recipe_app/model/CheckRecipi.dart';

class RecipiList extends StatefulWidget{

  @override
  _RecipiListState createState() => _RecipiListState();
}

class _RecipiListState extends State<RecipiList>{

  DBHelper dbHelper;
  List<Ingredient> _ingredients;
  List _displayList;                          //チェックボック付きレシピリストor検索リスト
  List<Myrecipi> _recipis;                    //DBから取得したレコードを格納
  List<MyrecipiGroupFolder> _recipisGroupBy;  //フォルダID毎のレシピ件数を格納
  List<CheckRecipi> _displayRecipis;          //チェックボック付きレシピリスト
  List<Myrecipi> _searchs;                    //DBから取得したレコードを格納
  List<CheckRecipi> _displaySearchs;          //チェックボック付き検索リスト
  List<Check> _folders;                       //チェックボック付きフォルダリスト
  List<MstTag> _Mtags;                        //DBから取得したレコードを格納
  List<Tag> _tags;                            //DBから取得したレコードを格納
  bool _isSeach = false;                      //true:検索結果表示
  bool _isTagSeach = false;                   //true:タグ検索結果表示
  bool _isCheck = false;                      //true:チェックボックス表示
  List<Check> _displayTags;
  List<Check> _oldTags;

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init(){
    //初期化
    dbHelper = DBHelper();
    _ingredients = [];
    _displayList = [];
    _recipis = [];
    _recipisGroupBy = [];
    _displayRecipis = [];
    _searchs = [];
    _displaySearchs = [];
    _folders = [];
    _Mtags = [];
    _tags = [];
    _displayTags = [];
    _oldTags = [];

    //レコードリフレッシュ
    this.refreshImages();
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {
    List<MstFolder> folders = [];

    //フォルダ別レシピ件数の取得
    await dbHelper.getMyRecipisCount().then((item){
      setState(() {
        _recipisGroupBy.clear();
        _recipisGroupBy.addAll(item);
      });
    });

    //レシピの取得
    await dbHelper.getMyRecipis().then((item){
      setState(() {
        _recipis.clear();
        _recipis.addAll(item);
      });
    });
    //取得したレシピをstoreに保存
    Provider.of<Display>(context, listen: false).setRecipis(_recipis);

    //材料の取得
    await dbHelper.getAllIngredients().then((item){
      setState(() {
        _ingredients.clear();
        _ingredients.addAll(item);
      });
    });
//    //取得した材料をstoreに保存
//    Provider.of<Display>(context, listen: false).setIngredients(this._ingredients);

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
      this._folders = Provider.of<Display>(context, listen: false).createCheckList(type: 1);
      //チェックBox付きレシピリストの生成
      this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: true);
    });

    //タグマスタの取得
    await dbHelper.getMstTags().then((item){
      setState(() {
        _Mtags.clear();
        _Mtags.addAll(item);
      });
    });
    //取得したタグマスタをstoreに保存
    Provider.of<Display>(context, listen: false).setMstTag(_Mtags);

    //タグリストの取得
    await dbHelper.getTags().then((item){
      setState(() {
        _tags.clear();
        _tags.addAll(item);
      });
    });

    this._displayTags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
    this._oldTags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);

  }

  //ナビゲーションバー
  void _changeBottomNavigation(index){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
  }

  //編集処理
  void _onEdit({int selectedId,int type}){
    //編集画面へ遷移
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    //レシピ種別をset
    Provider.of<Display>(context, listen: false).setType(type);
    //材料をreset
    Provider.of<Display>(context, listen: false).resetIngredients();
    //2:編集状態をset
    Provider.of<Display>(context, listen: false).setState(2);
  }

  //タグで検索　OKボタン押下時処理
  void _onTagSearch() async{
    setState(() {
      this._isTagSeach = this._isTagSeachFlg();
    });

    //検索するタグが選択されている場合
    if(this._isTagSeach){
      //選択したタグIDを取得
      List tagIds = [];
      for(var i = 0; i < this._displayTags.length; i++){
        if(this._displayTags[i].isCheck){
          tagIds.add(this._displayTags[i].id);
        }
      }
      //検索するタグを連結した文字列を作成
      String mstTagIdsTX = tagIds.join(',');
      //タグ検索結果
      var recipiIds = await dbHelper.getTagsGropByRecipiId(mstTagIdsTX,tagIds.length);
      print('タグ検索結果：${recipiIds.length}');

      setState(() {
        this._searchs.clear();
      });

      //テキスト検索ありの場合
      if(this._isSeach){
        //検索結果を取得
//        var searchs = Provider.of<Display>(context, listen: false).getSearchs();
        var searchs = Provider.of<Display>(context, listen: false).getSearchsTX();

        for(var i = 0; i < recipiIds.length; i++) {
          for (var k = 0; k < searchs.length; k++) {
            if (recipiIds[i].recipi_id == searchs[k].id) {
              setState(() {
                this._searchs.add(searchs[k]);
              });
              break;
            }
          }
        }

      //タグ検索のみの場合
      }else{
        for(var i = 0; i < recipiIds.length; i++) {
          for (var k = 0; k < this._recipis.length; k++) {
            if (recipiIds[i].recipi_id == this._recipis[k].id) {
              setState(() {
                this._searchs.add(this._recipis[k]);
              });
              break;
            }
          }
        }
      }
      //検索結果をstoreに保存
      Provider.of<Display>(context, listen: false).setSearchs(this._searchs);
      //チェックBox付き検索結果の生成
      setState(() {
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchList();
      });

    //タグ選択なしの場合
    }else{
//      var SearchListTX = Provider.of<Display>(context, listen: false).getSearchsTX();
//      //検索結果をstoreに保存
//      Provider.of<Display>(context, listen: false).setSearchs(SearchListTX);
      setState(() {
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchListTX();
      });
    }

  }

  //検索処理
  void _onSearch(String searchText){
    print('テキスト検索');
    if(searchText.isEmpty){
      setState(() {
        this._isSeach = false;
      });
      print('①false');
      if(this._isTagSeach){
        _onTagSearch();
      }
      return;
    }

//    print('###検索内容:${searchText}');

    setState(() {
     this._isSeach = true;
     this._searchs.clear(); //検索結果用リストのリセット
    });

    //タグ検索ありの場合
    if(this._isTagSeach){
      //検索結果を取得
      var searchs = Provider.of<Display>(context, listen: false).getSearchs();

      for(var i=0; i< searchs.length; i++){
        String title = searchs[i].title;
        if(title.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            this._searchs.add(searchs[i]);
          });
        }
      }

    //
    }else{
      for(var i=0; i< this._recipis.length; i++){
        String title = this._recipis[i].title;
        if(title.toLowerCase().contains(searchText.toLowerCase())) {
          setState(() {
            this._searchs.add(this._recipis[i]);
          });
        }
      }
      //検索結果をstoreに保存
      Provider.of<Display>(context, listen: false).setSearchsTX(_searchs);
    }

    //検索結果をstoreに保存
    Provider.of<Display>(context, listen: false).setSearchs(_searchs);
    //チェックBox付き検索結果の生成
    this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchList();
  }

  //新規投稿
  Future<void> _onAdd() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
//          message: const Text('Your options are '),
            actions: <Widget>[
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
    //取得したタグをstoreに保存
    Provider.of<Display>(context, listen: false).setTags(_tags);
    //取得した材料をstoreに保存
    Provider.of<Display>(context, listen: false).setIngredients(this._ingredients);
    //フォルダ別レシピ一覧
    Provider.of<Display>(context, listen: false).setIsFolderBy(true);
    //4:フォルダ別レシピ一覧へ遷移
    Provider.of<Display>(context, listen: false).setState(4);
}

  //レシピを選択時処理
  void _onDetail({int index}) async {
    //選択したレシピのindexをsetする
    Provider.of<Detail>(context, listen: false).setRecipi(this._displayList[index]);

    if(this._displayList[index].type == 2){
    var ingredients = await dbHelper.getIngredients(this._displayList[index].id);
    print('①${ingredients.length}');
    Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
    var howTos = await dbHelper.getHowtos(this._displayList[index].id);
    print('②${howTos.length}');
    Provider.of<Detail>(context, listen: false).setHowTos(howTos);
    }else{
      var photos = await dbHelper.getPhotos(this._displayList[index].id);
      Provider.of<Detail>(context, listen: false).setPhotos(photos);
    }
    //2:詳細画面へ遷移
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

//      //フォルダリストをsetする
//      Provider.of<Display>(context, listen: false).setCheck(index: index,isCheck:this._folders[index].isCheck,type: type);
//      print('ID:${_folders[index].id},NAME:${_folders[index].name},isCheck:${_folders[index].isCheck}');

      //レシピリスト
    }else{
      setState(() {
        this._displayList[index].isCheck = !this._displayList[index].isCheck;
      });
//      //タグリストをsetする
//      Provider.of<Display>(context, listen: false).setCheck(index: index,isCheck:this._tags[index].isCheck,type: type);
//      print('ID:${_tags[index].id},NAME:${_tags[index].name},isCheck:${_tags[index].isCheck}');
//      print('ID:${_oldTags[index].id},NAME:${_oldTags[index].name},isCheck:${_oldTags[index].isCheck}');
    }

  }

  //フォルダ別リストエリア
  Column _onFolderList(){
    List<Widget> column = new List<Widget>();
//    List checks = [];
    //材料リストを展開する
    for(var i=0; i < this._folders.length; i++){
      int count = 0;
      for(var k=0; k < this._recipisGroupBy.length; k++){
        if(this._folders[i].id == this._recipisGroupBy[k].folder_id)
          count = this._recipisGroupBy[k].count;
      }
//      checks.add(false);
//    for(var i=0; i < 3; i++){
      column.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 70,
          child: Container(
            color: Colors.white,
            child: InkWell(
                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if(this._isCheck)
                    Container(
                        width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                      child:Checkbox(
                          value: _folders[i].isCheck,
                          onChanged: (bool value){
                            _onItemCheck(index: i,type: 1);
                            print('folderID:${_folders[i].id},name:${_folders[i].name},isCheck:${_folders[i].isCheck}');
                          },
                        )
                    ),
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
//                      color: Colors.redAccent,
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: EdgeInsets.all(5),
                      child: Text('${_folders[i].name}',
//                      child: Text('フォルダー名フォルダー名フォルダー名フォルダー名フォルダー名${i+1}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
//                              fontWeight: FontWeight.bold
                        ),),
                    ),
                    if(!this._isCheck)
                    Container(
//                      color: Colors.blue,
                      width: MediaQuery.of(context).size.width * 0.08,
                      padding: EdgeInsets.all(5),
                      child: Text('${count}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
//                              fontWeight: FontWeight.bold
                        ),),
                    ),
                    if(!this._isCheck)
                    Container(
//                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.05,
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.arrow_forward_ios,size: 12,)
                    ),
                  ],
                ),
//                  child: Image.memory(imageFiles[i].readAsBytesSync()),
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
    return Column(
      children: column,
    );
  }


  //MYレシピエリア
  Column _onList(){
//    List recipis = [];
    if(_isSeach || _isTagSeach){
      this._displayList = this._displaySearchs;
    }else{
      this._displayList = this._displayRecipis;
    }
    List<Widget> column = new List<Widget>();
    //MYレシピを展開する
    for(var i=0; i < this._displayList.length; i++){
      List ingredients = [];
      List<Tag> tags = [];
      String ingredientsTX = '';

      //レシピIDに紐づく材料を取得する
      for(var k = 0;k < this._ingredients.length;k++){
        if(this._displayList[i].id == this._ingredients[k].recipi_id){
          ingredients.add(this._ingredients[k].name);
        }
      }
      //配列の全要素を順に連結した文字列を作成
      ingredientsTX = ingredients.join(',');

      //レシピIDに紐づくタグを取得する
      for(var k = 0;k < this._tags.length;k++){
        if(this._displayList[i].id == this._tags[k].recipi_id){
          tags.add(this._tags[k]);
        }
      }
      column.add(
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 150,
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
            child: InkWell(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if(this._isCheck)
                      Container(
                          width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                          child:Checkbox(
                            value: this._displayList[i].isCheck,
                            onChanged: (bool value){
                              _onItemCheck(index: i,type: 2);
                              print('ID:${this._displayList[i].id},name:${this._displayList[i].title},isCheck:${this._displayList[i].isCheck}');
                            },
                          )
                      ),
                     //サムネイルエリア
                    this._displayList[i].thumbnail.isNotEmpty
                        ? SizedBox(
                          height: 100,
                          width: 100,
                          child: Container(
                            child: Image.file(File(this._displayList[i].thumbnail)),
                          ),
                        )
                        : SizedBox(
                          height: 100,
                          width: 100,
                          child: Container(
                            color: Colors.grey,
                                child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                          ),
                        ),
                    //タイトル、材料、タグエリア
                    Container(
//                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width * 0.56,
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //タイトル
                          Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Text('${this._displayList[i].title}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold
                              ),),
                          ),
                          //材料
                          Container(
                            height: 40,
                            padding: EdgeInsets.all(5),
//                            child: Text('${ingredients.join(',')}',
                            child: Text('${ingredientsTX}',
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey
                              ),),
                          ),
                          //タグ
                          if(tags.length > 0)
                            Container(
//                              width: MediaQuery.of(context).size.width * 0.5,
//                              color: Colors.grey,
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
                                for(var k = 0; k<tags.length;k++)
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    child: SizedBox(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        color: Colors.brown,

                                        child: Text('${tags[k].name}',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.white
                                          ),
                                        maxLines: 1,),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          //フォルダicon
                        ],
                      ),
                    ),
                    //フォルダエリア
                    if(!this._isCheck)
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.15,
                        height: 150,
                        child: Container(
//                          color: Colors.greenAccent,
                            padding: EdgeInsets.all(5),
                            child: InkWell(
                              child: Icon(Icons.folder,color: Colors.orangeAccent,size: 30,),
                              onTap: (){
                                _onFolderTap(index: i,ingredients: ingredientsTX,tags: tags,type: 0);
                              },
                            ),
                        ),
                      ),
                  ],
                ),
                onTap: (){
                  if(this._isCheck){
                    _onItemCheck(index: i,type: 2);
                  }else{
                    _onDetail(index: i);
                  }
                }
            ),
          ),
        ),
      );
      //線
      column.add(
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      );
    }
    return Column(
      children: column,
    );
  }

  //レシピリストのフォルダアイコンtap時処理
  void _onFolderTap({int index,String ingredients,List<Tag> tags,int type}){
    //フォルダアイコン押下時
    if(type == 0) {
      print('選択したレシピID:${this._displayList[index].id}');
      print('${ingredients}');
      //選択したレシピの内容をsetする
      Provider.of<Detail>(context, listen: false).setRecipi(this._displayList[index]);
      //レシピIDに紐づく材料リストをsetする
      Provider.of<Display>(context, listen: false).setIngredientTX(ingredients);
      //レシピIDに紐づくタグリストをsetする
      Provider.of<Display>(context, listen: false).setTags(tags);
      //レシピIDに紐づくフォルダIDをsetする
      Provider.of<Display>(context, listen: false).setFolderId(this._displayList[index].folder_id);
//    _onSort();

    //フォルダボタン、タグ付けボタン押下時
    }else{
      //チェックしたレシピ(ID)を格納する
      List ids = [];
      for (var i = 0; i < this._displayList.length; i++) {
        if (this._displayList[i].isCheck) {
          ids.add(this._displayList[i].id);
        }
      }
      Provider.of<Display>(context, listen: false).setIds(ids);
    }
    //レシピの整理での表示タイプをset
    Provider.of<Display>(context, listen: false).setSortType(type);
    //3:レシピの整理をset
    Provider.of<Display>(context, listen: false).setState(3);

  }

  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });
    //検索結果表示の場合
    if(this._isSeach || _isTagSeach){
      //チェックBox付き検索結果リストの生成
      this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchList();
    }else{
      //チェックBox付きフォルダリストの生成
      this._folders = Provider.of<Display>(context, listen: false).createCheckList(type: 1);
      //チェックBox付きレシピリストの生成
      this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: true);
    }
  }

  //削除処理
  void _onDelete() async {
    //選択したフォルダマスタを削除
    List ids = [];
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
        //フォルダマスタで削除したIDに紐づくレシピを削除する
        await dbHelper.deleteMyRecipiFolderId(ids[i]);
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
      //フォルダマスタ削除処理
      for(var i = 0; i < ids.length; i++){
        //レシピを削除
        await dbHelper.deleteMyRecipi(ids[i]);
        //レシピIDに紐づくタグを削除する
        await dbHelper.deletetag(ids[i]);
        //レシピIDに紐づく材料リストを削除
        await dbHelper.deleteRecipiIngredient(ids[i]);
        //レシピIDに紐づく作り方リストを削除
        await dbHelper.deleteRecipiHowto(ids[i]);
        //レシピIDに紐づく写真リストを削除
        await dbHelper.deleteRecipiPhoto(ids[i]);
      }
    }

    setState(() {
      this._isCheck = !this._isCheck;
    });

    //検索結果表示の場合
    if(this._isSeach || _isTagSeach){
      List<Myrecipi> searchs = Provider.of<Display>(context, listen: false).getSearchs();
      //検索結果のリフレッシュ
      for(var i = 0; i <ids.length; i++){
        for(var k = 0; k < this._displayList.length; k++){
          if(ids[i] == this._displayList[k].id){
            this._displayList.removeAt(k);
            searchs.removeAt(k);
          }
        }
      }
    }

    refreshImages(); //レコードリフレッシュ
  }

  //タグリストエリア
  Column _createTagList(){
    List<Widget> column = new List<Widget>();

    //チェックBox付きタグリストの生成
//    List<Check> tags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);

    //フォルダリストを展開する
    for(var i=0; i < this._displayTags.length; i++){

      column.add(
        SizedBox(
//          height: MediaQuery.of(context).size.height * 0.06,
//          width: MediaQuery.of(context).size.width * 0.7,
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
                      width: MediaQuery.of(context).size.width * 0.4,
                      padding: EdgeInsets.all(5),
                      child: Text('${this._displayTags[i].name}',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 15,
//                              fontWeight: FontWeight.bold
                        ),),
                    ),
                    Container(
//                      width: MediaQuery.of(context).size.width * 0.1,
                      padding: EdgeInsets.all(5),
                    ),
                    Container(
//                        width: MediaQuery.of(context).size.width * 0.1,
//                      padding: EdgeInsets.all(5),
                        child:
                        Checkbox(
                          value: this._displayTags[i].isCheck,
                          onChanged: (bool value){
//                              onTabCheck(index: i,value: value);
//                            _onTagCheck(index: i,type: 2);
                            setState(() {
                              this._displayTags[i].isCheck = !this._displayTags[i].isCheck;
                              print('ID:${this._displayTags[i].id},NAME:${this._displayTags[i].name},isCheck:${this._displayTags[i].isCheck}');
                            });
                          },
                        )
                    ),
                  ],
                ),
                onTap: (){
//                      _onTabCheck(index: i,type: 2);
                  setState(() {
                    this._displayTags[i].isCheck = !this._displayTags[i].isCheck;
                    print('ID:${this._displayTags[i].id},NAME:${this._displayTags[i].name},isCheck:${this._displayTags[i].isCheck}');
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
    return Column(
      children: column,
    );
  }

  //タグ検索モーダルにてタグが選択されている場合trueを返す
  bool _isTagSeachFlg(){
    for(var i = 0; i < this._displayTags.length; i++){
      if(this._displayTags[i].isCheck){
          return true;
      }
    }
    return false;
  }

  //タグ検索モーダル
  Future<void> _onTag(){
    return showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState) {
            return SimpleDialog(
                  backgroundColor: Colors.white,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: IconButton(
                          icon: Icon(Icons.close,color: Colors.cyan,size: 30,),
                          onPressed: (){
                              for(var i = 0; i < this._displayTags.length; i++){
                                if(this._displayTags[i].id == this._oldTags[i].id){
                                  setState(() {
                                    this._displayTags[i].isCheck = this._oldTags[i].isCheck;
                                  });
                                }
                              }
                              setState(() {
                                this._isTagSeach = this._isTagSeachFlg();
                              });
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Text('タグで検索',
                        style: TextStyle(
                            color: Colors.cyan
                        ),
                      ),
                      Container(
                        width: 90,
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: FlatButton(
                            color: Colors.cyan,
                            child: Text('OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            onPressed: (){
                              setState(() {
                                for(var i = 0; i < this._displayTags.length; i++){
                                  if(this._displayTags[i].id == this._oldTags[i].id){
                                    this._oldTags[i].isCheck = this._displayTags[i].isCheck;
                                  }
                                }
                              });
                              this._onTagSearch();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  children: <Widget>[
                    for(var i = 0; i < this._displayTags.length; i++)
                      SizedBox(
                        child: Container(
                          color: Colors.white,
                          child: Column(
                            children: <Widget>[
                              InkWell(
                                  child: Row(
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
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        padding: EdgeInsets.all(5),
                                        child: Text('${this._displayTags[i].name}',
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(5),
                                        child: Checkbox(
                                          value: this._displayTags[i].isCheck,
                                          onChanged: (bool value){
                                            setState(() {
                                              this.onTagChange(index: i);
                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      this.onTagChange(index: i);
                                    });
                                  }
                              ),
                              Divider(
                                color: Colors.grey,
                                height: 0.5,
                                thickness: 0.5,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
            );
        });
      });
  }

  //タグ検索のチェックボックス
  void onTagChange({int index}){
    setState(() {
      this._displayTags[index].isCheck = !this._displayTags[index].isCheck;
      print('[display]id:${this._displayTags[index].id},name:${this._displayTags[index].name},isCheck:${this._displayTags[index].isCheck}');
      print('[old]id:${this._oldTags[index].id},name:${this._oldTags[index].name},isCheck:${this._oldTags[index].isCheck}');
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
          child: Text(_isCheck ? '個選択':'レシピ',
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
              addBtn(),
            ],
      ),
      body:scrollArea(),
      bottomNavigationBar: bottomNavigationBar(),
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

  //メニューボタン
  Widget menuBtn(){
    return IconButton(
      icon: const Icon(Icons.list,color: Colors.white,size:30,),
      onPressed: (){
//        _onList();
      },
    );
  }

  //チェックボタン
  Widget checkBtn(){
    return IconButton(
      icon: const Icon(Icons.check_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onCheck();
//        _onList();
      },
    );
  }

  //追加ボタン
  Widget addBtn(){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onAdd();
      },
    );
  }

  //ナビゲーション
  Widget bottomNavigationBar(){
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
              _changeBottomNavigation(index);
            },
          );
        }
    );
  }

  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
              _isCheck
                  ? <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: showList(),
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width,
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            //                      height: 25,
                            width: 130,
                            //                        color: Colors.grey,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                              child: FlatButton(
                                color: Colors.cyan,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(Icons.folder_open,color: Colors.white,),
                                    const Text('フォルダ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                                  ],
                                ),
                                onPressed: _onDisabled(type: 1) ? null :(){
                                  _onFolderTap(type: 1);
                                  print('フォルダ');
                                },
                              ),
                            ),
                          ),
                          Container(
                            width: 130,
                            child: Padding(
                              padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                              child: FlatButton(
                                color: Colors.cyan,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    const Icon(Icons.local_offer,color: Colors.white,),
                                    const Text('タグ付け', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12,),),
                                  ],
                                ),
                                onPressed: _onDisabled(type: 2) ? null :(){
                                  _onFolderTap(type: 2);
                                  print('タグ付け');
                                },
                              ),
                            ),
                          ),
                          Container(
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
                                onPressed: _onDisabled(type: 3) ? null :(){
                                  _onDelete();
                                  print('削除する');
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                )
              ]
                  : <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: showList(),
                  ),
                ),
              ]
          )
      ),
    );
  }

  //リストページ全体
  Widget showList(){
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        _isSeach || _isTagSeach
            ? <Widget>[
              searchArea(), //検索欄
              line(),
              searchResultArea(), //検索結果
              line(),
              searchResultListArea(), //検索結果リスト
            ]
            : <Widget>[
              searchArea(), //検索欄
              line(),
              folderArea(),//フォルダ別
              myrecipiArea(), //MYレシピ
              line(),
              myrecipiListArea(), //MYレシピリスト
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
  Widget folderArea(){
    return Container(
      child: _onFolderList(),
    );
  }

  //MYレシピ
  Widget myrecipiArea(){
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
                      child: Text('MYレシピ', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${_displayList.length}品', style: TextStyle(
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

  //検索結果
  Widget searchResultArea(){
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
                      child: Text('検索結果', style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${_displayList.length}品', style: TextStyle(
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

  //MYレシピリスト
  Widget myrecipiListArea(){
    return Container(
      child: _onList(),
    );
  }

  //検索結果リスト
  Widget searchResultListArea(){
    return Container(
      child: _onList(),
    );
  }

  //検索欄
  Widget searchArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width,
        child: Container(
//          padding: EdgeInsets.all(5),
          color: Colors.white30,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                height: 40,
                child: Container(
                  child: TextField(
                      onChanged: _onSearch,
                      style: const TextStyle(fontSize: 15.0, color: Colors.grey,),
                      decoration: InputDecoration(
                        //                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        prefixIcon: const Icon(Icons.search,size: 25,),
                        hintText:"全てのレシピを検索",
                        contentPadding: const EdgeInsets.only(top: 10),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey, width: 32.0),
                            borderRadius: BorderRadius.circular(15.0)
                        ),
                      )
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.1,
                height: 40,
                child: Container(
//                  color: Colors.grey,
//                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    child: Icon(Icons.local_offer,color: Colors.grey,size: 35,),
                    onTap: (){
                      _onTag();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

//  Widget showList(){
//    return Center(
//      child: Column(
//        mainAxisAlignment: MainAxisAlignment.start,
//        children: <Widget>[
//          Flexible(
////              child: gridView(),
//            child: ListView.builder(
//                itemCount: _recipis == null ? 0: _recipis.length,
//                itemBuilder: (BuildContext context,int index){
//                  return InkWell(
//                    child: Card(
//                      color: Colors.white,
//                      child: Container(
//                        height: MediaQuery.of(context).size.height * 0.10,
//                        child: Row(
//                          children: <Widget>[
////                            images[index].topImage == null
////                              ? Container(
//                              Container(
////                                  padding: EdgeInsets.all(10),
//                                  width: 100,
//                                  height: 100,
//                                  child:
//                                  _recipis[index].thumbnail.isEmpty
//                                     ? const Icon(Icons.camera_alt,color: Colors.white,)
//                                     : Image.file(File(_recipis[index].thumbnail)),
//                                  decoration: BoxDecoration(
//                                    color: _recipis[index].thumbnail.isEmpty ? Colors.grey : Colors.white,
//                                  ),
//                                ),
//                            Column(
//                              children: <Widget>[
//                                Container(
//                                  child: SizedBox(
//                                    width: MediaQuery.of(context).size.width * 0.7,
//                                    height: 30,
//                                    child: ListTile(
//                                      title: Text('${_recipis[index].title}'),
////                                    title: Text(''),
//                                    ),
//                                  ),
//                                ),
//                                Container(
//                                  child: SizedBox(
//                                    width: MediaQuery.of(context).size.width * 0.7,
//                                    child: ListTile(
//                                      title: Text('${_recipis[index].description}'),
////                                    title: Text(''),
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            )
//                          ],
//                        ),
//                      ),
//                    ),
//                    onTap: (){
//                      _onDetail(index);
//                    },
//                  );
//                }
//            ),
//          )
//        ],
//      ),
//    );
//  }


}