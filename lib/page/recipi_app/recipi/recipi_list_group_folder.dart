import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/CheckRecipi.dart';
import 'package:recipe_app/model/Check.dart';

class RecipiListGroupFolder extends StatefulWidget{

  @override
  _RecipiListGroupFolderState createState() => _RecipiListGroupFolderState();
}

class _RecipiListGroupFolderState extends State<RecipiListGroupFolder>{

  DBHelper dbHelper;
  MstFolder _folder;                          //選択したフォルダ情報を格納
  List<Ingredient> _ingredients;              //材料リストを格納
  List _displayList;                          //チェックボック付きレシピリストor検索リスト
  List<Myrecipi> _recipis;                    //選択したフォルダに紐づくレシピリストを格納
  List<CheckRecipi> _displayRecipis;          //チェックボック付きレシピリスト
  List<Myrecipi> _searchs;                    //検索結果リストを格納
  List<CheckRecipi> _displaySearchs;          //チェックボック付き検索結果リスト
  List<Tag> _tags;                            //タグリストを格納
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
    this.dbHelper = DBHelper();
    this._ingredients = [];
    this._displayList = [];
    this._recipis = [];
    this._displayRecipis = [];
    this._searchs = [];
    this._displaySearchs = [];
    this._tags = [];
    this._displayTags = [];
    this._oldTags = [];
    //レコードリフレッシュ
    this.refreshImages();
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {
    //選択したフォルダの情報を取得
    setState(() {
      this._folder = Provider.of<Display>(context, listen: false).getFolder();
    });

    //最新のレシピリストを取得
    List<Myrecipi> allRecipis = await this.getRecipis();
    this._recipis.clear();
    for(var i = 0; i < allRecipis.length; i++){
      if(allRecipis[i].folder_id == this._folder.id){
        setState(() {
          this._recipis.add(allRecipis[i]);
        });
      }
    }
    //取得したレシピをstoreに保存
    Provider.of<Display>(context, listen: false).setRecipis(this._recipis);
    //材料の取得
    this._ingredients = await this.getIngredients();
    //タグの取得
    this._tags = await this.getTags();

    setState(() {
      //チェックBox付きレシピリストの生成
      this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: false);
    });

    this._displayTags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
    this._oldTags = Provider.of<Display>(context, listen: false).createCheckList(type: 2);
  }

  //ナビゲーションバー
  void _changeBottomNavigation(index){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
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
      setState(() {
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchListTX();
      });
    }

  }

  //検索処理
  void _onSearch(String searchText){
    if(searchText.isEmpty){
      setState(() {
        this._isSeach = false;
      });
      print('false');
      if(this._isTagSeach){
        _onTagSearch();
      }
      return;
    }

    setState(() {
      this._isSeach = true;
      _searchs.clear(); //検索結果用リストのリセット
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
    for(var i=0; i<_recipis.length;i++){
      String title = _recipis[i].title;
      if(title.toLowerCase().contains(searchText.toLowerCase())) {
        setState(() {
          _searchs.add(_recipis[i]);
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

  //レシピを選択時処理
  void _onDetail({int index}) async {
    //選択したレシピのindexをsetする
    Provider.of<Detail>(context, listen: false).setRecipi(_recipis[index]);

    if(_recipis[index].type == 2){
      var ingredients = await dbHelper.getIngredients(_recipis[index].id);
      print('①${ingredients.length}');
      Provider.of<Detail>(context, listen: false).setIngredients(ingredients);
      var howTos = await dbHelper.getHowtos(_recipis[index].id);
      print('②${howTos.length}');
      Provider.of<Detail>(context, listen: false).setHowTos(howTos);
    }else{
      var photos = await dbHelper.getRecipiPhotos(_recipis[index].id);
      Provider.of<Detail>(context, listen: false).setPhotos(photos);
    }
    //2:詳細画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);

  }

  //フォルダ、タグ付け、削除するボタンの活性、非活性
  bool _onDisabled(){
    for(var i = 0; i<this._displayList.length; i++){
      if(this._displayList[i].isCheck){
        return false;
      }
    }
    return true;
  }

  //レシピ毎のチェックボックス
  void _onItemCheck({int index}){
      setState(() {
        this._displayList[index].isCheck = !this._displayList[index].isCheck;
      });
  }

  //レシピリストへ戻るボタン押下時処理
  void _onBack(){
    //フォルダ別レシピ一覧
    Provider.of<Display>(context, listen: false).setBackScreen(0);
    //0 :一覧へ遷移
    Provider.of<Display>(context, listen: false).setState(0);
//    _init();
  }

  //MYレシピエリア
  Column _onList(){
    if(this._isSeach || _isTagSeach){
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
                          child:Checkbox(
                            value: this._displayList[i].isCheck,
                            onChanged: (bool value){
                              _onItemCheck(index: i);
                              print('ID:${this._displayList[i].id},name:${this._displayList[i].title},isCheck:${this._displayList[i].isCheck}');
                            },
                          )
                      ),
                    //サムネイルエリア
                    this._displayList[i].thumbnail.isNotEmpty
                        ? Card(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(File(this._displayList[i].thumbnail),fit: BoxFit.cover,),
                      ),
                    )
                        : Card(
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey,
                        child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                      ),
                    ),
                    //タイトル、材料、タグエリア
                    Container(
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
                    _onItemCheck(index: i);
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
      print('選択したレシピID:${_recipis[index].id}');
      print('${ingredients}');
      //選択したレシピの内容をsetする
      Provider.of<Detail>(context, listen: false).setRecipi(_recipis[index]);
      //レシピIDに紐づく材料リストをsetする
      Provider.of<Display>(context, listen: false).setIngredientTX(ingredients);
      //レシピIDに紐づくタグリストをsetする
      Provider.of<Display>(context, listen: false).setTags(tags);
      //レシピIDに紐づくフォルダIDをsetする
      Provider.of<Display>(context, listen: false).setFolderId(_recipis[index].folder_id);

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
      //チェックBox付きレシピリストの生成
      this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: false);
    }
  }

  //削除処理
  void _onDelete() async {
    List ids = [];
    //選択したレシピを削除
//    ids.clear();
    for(var i = 0; i < this._displayList.length; i++){
      if(this._displayList[i].isCheck){
        ids.add(this._displayList[i].id);
      }
    }
    if(ids.length > 0){
      print('削除するレシピID：${ids}');
      //削除処理
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
        //レシピIDに紐づくごはん日記のレシピリストを削除する
        await dbHelper.deleteDiaryRecipibyRecipiID(ids[i]);
      }
    }

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
    //レコードリフレッシュ
    refreshImages();

    setState(() {
      this._isCheck = !this._isCheck;
    });
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

  //DBからレシピリストを取得
  Future<List<Myrecipi>> getRecipis() async {
    //レシピの取得
    List<Myrecipi> allRecipis = [];
    await dbHelper.getMyRecipis().then((item){
      setState(() {
        allRecipis.clear();
        allRecipis.addAll(item);
      });
    });
    //取得したレシピをstoreに保存
    Provider.of<Display>(context, listen: false).setRecipis(allRecipis);

    return allRecipis;
  }

  //DBから材料リストを取得
  Future<List<Ingredient>> getIngredients() async {
    //材料の取得
    List<Ingredient> ingredients = [];
    await dbHelper.getAllIngredients().then((item){
      setState(() {
        ingredients.clear();
        ingredients.addAll(item);
      });
    });
    //取得した材料をstoreに保存
    Provider.of<Display>(context, listen: false).setIngredients(this._ingredients);

    return ingredients;
  }

  //DBからタグリストを取得
  Future<List<Tag>> getTags() async {
    //材料の取得
    List<Tag> tags = [];
    await dbHelper.getAllTags().then((item){
      setState(() {
        tags.clear();
        tags.addAll(item);
      });
    });
    //取得したタグをstoreに保存
    Provider.of<Display>(context, listen: false).setTags(_tags);

    return tags;
  }

  //チェックボックスにて選択した値を返す
  String _selectedCount(){
    int count = 0;
    for(var i = 0; i < this._displayList.length; i++){
      if(this._displayList[i].isCheck){
        count++;
      }
    }
    if(count == 0){
      return '';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: backBtn(),
        elevation: 0.0,
        title: Center(
          child: Text(_isCheck ? '${_selectedCount()}個選択':'${_folder.name}',
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

  //戻るボタン
  Widget backBtn(){
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios,color: Colors.white,size: 30,),
      onPressed: (){
        _onBack();
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

  //チェックボタン
  Widget checkBtn(){
    return IconButton(
      icon: const Icon(Icons.check_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onCheck();
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
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black26,
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                title: const Text('ホーム'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts),
                title: const Text('レシピ'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.date_range),
                title: const Text('ごはん日記'),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: const Text('アルバム'),
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
                            width: 130,
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
                                onPressed: _onDisabled() ? null :(){
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
                                onPressed: _onDisabled() ? null :(){
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
                                onPressed: _onDisabled() ? null :(){
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
                        prefixIcon: const Icon(Icons.search,size: 25,),
                        hintText:"${_folder.name}から検索",
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
                  child: InkWell(
                    child: Icon(Icons.local_offer,color: Colors.grey,size: 35,),
                    onTap: (){
                      print('tagTAP!!!!!!!');
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
}