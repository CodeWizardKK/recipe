import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Photo.dart';

import 'package:recipe_app/updater.dart';

class RecipiList extends StatefulWidget{
  RecipiList({Key key}) : super(key: key);

  @override
  _RecipiListState createState() => _RecipiListState();
}

class _RecipiListState extends State<RecipiList>{

  DBHelper dbHelper;
  Common common;
  List<Ingredient> _ingredients;
  List _displayList;                          //チェックボック付きレシピリストor検索リスト
  List<Myrecipi> _recipis;                    //DBから取得したレコードを格納
  List<MyrecipiGroupFolder> _recipisGroupBy;  //フォルダID毎のレシピ件数を格納
  List<CheckRecipi> _displayRecipis;          //チェックボック付きレシピリスト
  List<Myrecipi> _searchs;                    //DBから取得したレコードを格納
  List<CheckRecipi> _displaySearchs;          //チェックボック付き検索リスト
  List<Check> _folders;                       //チェックボック付きフォルダリスト
  List<MstTag> _Mtags;                        //DBから取得したレコードを格納
  List<MultiSelectItem<MstTag>> _displayTags; //DBから取得したレコードをMultiSelectItem型で格納
  List<MstTag> _selectedtags;                 //タグ検索で選択したタグを格納
  List<Tag> _tags;                            //DBから取得したレコードを格納
  bool _isSeach = false;                      //true:検索結果表示
  bool _isTagSeach = false;                   //true:タグ検索結果表示
  bool _isCheck = false;                      //true:チェックボックス表示
  bool _isSelectedDelete = false;                //true:編集画面にて削除するボタン押下された場合

  List<CheckRecipi> _displayRecipisLazy = List<CheckRecipi>(); //遅延読み込み用リスト
  bool _isLoadingRecipi = false;                               //true:遅延読み込み中
  int _recipiCurrentLength = 0;                                //遅延読み込み件数を格納

  List<CheckRecipi> _displaySearchsLazy = List<CheckRecipi>(); //遅延読み込み用リスト
  bool _isLoadingSearch = false;                               //true:遅延読み込み中
  int _searchCurrentLength = 0;                                //遅延読み込み件数を格納
  final int increment = 10; //読み込み件数

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init(){
    //初期化
    dbHelper = DBHelper();
    common = Common();
    _ingredients = [];
    _displayList = [];
    _recipis = [];
    _recipisGroupBy = [];
    _displayRecipis = [];
    _searchs = [];
    _displaySearchs = [];
    _folders = [];
    _Mtags = [];
    _displayTags = [];
    _selectedtags = [];
    _tags = [];
    _displayRecipisLazy.clear();
    _displaySearchsLazy.clear();

    //レコードリフレッシュ
    this.refreshImages();
    //タグリスト取得
    this._getTags(type: 0);
    //レシピリスト用遅延読み込み
    this._loadMoreRecipi();
  }

  //レシピリスト用遅延読み込み
  Future _loadMoreRecipi() async {
    print('+++++_loadMoreRecipi+++++++');
    if(mounted){
      setState(() {
        _isLoadingRecipi = true;
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    for (var i = _recipiCurrentLength; i < _recipiCurrentLength + increment; i++) {
      if( i < this._displayRecipis.length){
        if(mounted){
          setState(() {
            _displayRecipisLazy.add(_displayRecipis[i]);
          });
        }
      } else {
        break;
      }
    }
    if(mounted){
      setState(() {
        _isLoadingRecipi = false;
        _recipiCurrentLength = _displayRecipisLazy.length;
      });
    }
  }

  void reset(){
    this._isSeach = false;
    this._isTagSeach = false;
    this._isCheck = false;
    this._isSelectedDelete = false;
    this._isLoadingRecipi = false;
    this._recipiCurrentLength = 0;
    this._isLoadingSearch = false;
    this._searchCurrentLength = 0;
  }

  //検索リスト用遅延読み込み
  Future _loadMoreSearch() async {
    print('+++++_loadMoreSearch+++++++');
    setState(() {
      _isLoadingSearch = true;
    });

    await Future.delayed(const Duration(seconds: 1));
    for (var i = _searchCurrentLength; i < _searchCurrentLength + increment; i++) {
      if( i < this._displaySearchs.length){
//      if(this._displaySearchs.length -1 >= i){
        setState(() {
          _displaySearchsLazy.add(_displaySearchs[i]);
        });
      } else {
        break;
      }

    }
    setState(() {
      _isLoadingSearch = false;
      _searchCurrentLength = _displaySearchsLazy.length;
    });
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
      //チェックBox付きレシピリストの生成
      this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: true);
    });
  }

  void _getTags({int type}) async {
    if(type == 1) {
      //タグリストの取得
      await dbHelper.getAllTags().then((item) {
        setState(() {
          _tags.clear();
          _tags.addAll(item);
        });
      });
    }else{
      //タグマスタの取得
      await dbHelper.getMstTags().then((item){
        setState(() {
          _Mtags.clear();
          _Mtags.addAll(item);
        });
      });
      setState(() {
        _displayTags = _Mtags
            .map((mstTag) => MultiSelectItem<MstTag>(mstTag, mstTag.name))
            .toList();
      });
//      //取得したタグマスタをstoreに保存
//      Provider.of<Display>(context, listen: false).setMstTag(_Mtags);

      //タグリストの取得
      await dbHelper.getAllTags().then((item){
        setState(() {
          _tags.clear();
          _tags.addAll(item);
        });
      });
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

  //タグで検索　OKボタン押下時処理
  void _onTagSearch() async{
    setState(() {
      this._isTagSeach = this._isTagSeachFlg();
//      print(_isTagSeach);
    });

    //検索するタグが選択されている場合
    if(this._isTagSeach){
      //選択したタグIDを取得
      List tagIds = [];
      for(var i = 0; i < this._selectedtags.length; i++){
          tagIds.add(this._selectedtags[i].id);
      }
      //検索するタグを連結した文字列を作成
      String mstTagIdsTX = tagIds.join(',');
      //タグ検索結果
      var recipiIds = await dbHelper.getTagsGropByRecipiId(mstTagIdsTX,tagIds.length);
//      print('タグ検索結果：${recipiIds.length}');

      setState(() {
        this._searchs.clear();
      });

      //テキスト検索ありの場合
      if(this._isSeach){
        //検索結果を取得
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
        this._displaySearchsLazy.clear();
        this._searchCurrentLength = 0;
      });
//      print('タグ選択あり');
//      print('②');
      await this._loadMoreSearch();

      //タグ選択なしの場合
    }else{
      setState(() {
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchListTX();
        this._displaySearchsLazy.clear();
        this._searchCurrentLength = 0;
      });
//      print('タグ選択なし');
//      print('③');
      this._getTags(type: 0);
      await this._loadMoreSearch();
    }

  }

  //検索処理
  void _onSearch(String searchText){
    //検索欄が未入力の場合
    if(searchText.isEmpty){
      //seachフラグ解除
      setState(() {
        this._isSeach = false;
      });
      //検索欄が未入力の場合でタグ検索ありの場合
      if(this._isTagSeach){
        _onTagSearch();
      }
      return;
    }
    //検索欄が入力されている場合
    setState(() {
      this._isSeach = true;
      this._searchs.clear(); //検索結果用リストのリセット
    });

    //タグ検索あり(+テキスト検索あり)の場合
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
      setState(() {
        //検索結果をstoreに保存
        Provider.of<Display>(context, listen: false).setSearchsTX(_searchs);
        //チェックBox付き検索結果の生成
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchListTX();
      });

      //タグ検索なし(+テキスト検索あり)の場合
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
      //検索結果をstoreに保存
      Provider.of<Display>(context, listen: false).setSearchs(_searchs);
      setState(() {
        //チェックBox付き検索結果の生成
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchList();
      });
    }

    setState(() {
      this._displaySearchsLazy.clear();
      this._searchCurrentLength = 0;
    });
//    print('⑤,${this._displaySearchs.length}');
    this._loadMoreSearch();
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

  //レシピを選択時処理
  Future<void> _onDetail({int index}) async {
    CheckRecipi item = this._displayList[index];
    List<Ingredient> ingredients = [];
    List<HowTo> howTos = [];
    List<Photo> photos = [];

    //選択したレシピのindexをsetする
    Myrecipi recipi = Myrecipi
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
    if(this._displayList[index].type == 2){
      ingredients = await dbHelper.getIngredients(this._displayList[index].id);
      howTos = await dbHelper.getHowtos(this._displayList[index].id);
    }else{
      photos = await dbHelper.getRecipiPhotos(this._displayList[index].id);
    }
    this._showDetail(recipi: recipi, ingredients: ingredients,howTos: howTos,photos: photos);
  }

  //詳細画面へ遷移
  void _showDetail({ Myrecipi recipi, List<Ingredient> ingredients, List<HowTo> howTos, List<Photo> photos }){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiEdit(Nrecipi: recipi,Ningredients: ingredients,NhowTos: howTos,Nphotos: photos,),
          fullscreenDialog: true,
        )
    ).then((result) {
      if(result == 'delete'){
        setState(() {
          this._isSelectedDelete = true;
        });
        _onDelete(recipi: recipi);
      } else {
        //最新のリストを取得し展開する
        this.refreshImages();
      }
    });
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
//      print(result);
//    if(type == 3 || type == 4){
//      this.reset()
//      this.init();
//
//    } else {
      if(this._isCheck){
        this._isCheck = false;
      }
      //最新のリストを取得し展開する
      this.refreshImages();
      //タグ検索ありの場合
      if(_selectedtags.length != 0){
        this._getTags(type: 1);
        this._onTagSearch();
      } else {
        this._getTags(type: 0);
      }
      if(result == 'FolderUpdate'){
        setState(() {
          //レシピリスト用遅延読み込みリセット
          this._displayRecipisLazy.clear();
          this._recipiCurrentLength = 0;

        });
        //レシピリスト用遅延読み込み
        this._loadMoreRecipi();
      }
//    }
    });
  }


  //右上チェックボタン押下時処理
  void _onCheck(){
    setState(() {
      this._isCheck = !this._isCheck;
    });
    //検索結果表示の場合
    if(this._isSeach || _isTagSeach){
      //チェックBox付き検索結果リストの生成
      setState(() {
        this._displaySearchs.clear();
        this._displaySearchs = Provider.of<Display>(context, listen: false).createDisplaySearchList();
      });
    }else{
      setState(() {
        //チェックBox付きフォルダリストの生成
        this._folders = Provider.of<Display>(context, listen: false).createFoldersCheck();
        //チェックBox付きレシピリストの生成
        this._displayRecipis.clear();
        this._displayRecipis = Provider.of<Display>(context, listen: false).createDisplayRecipiList(isFolderIdZero: true);
      });
    }
  }

  //削除処理
  void _onDelete({Myrecipi recipi}) async {
    List ids = [];
    bool isRecipiDelete = false;
    //編集画面に削除ボタン押下された場合
    if(this._isSelectedDelete){
      isRecipiDelete = true;
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
    } else {
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
        isRecipiDelete = true;
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
      if(_isSelectedDelete){
        for(var k = 0; k < this._displayList.length; k++){
          if(recipi.id == this._displayList[k].id){
            this._displayList.removeAt(k);
            searchs.removeAt(k);
          }
        }
      }
      setState(() {
        //検索リスト用遅延読み込みリセット
        this._displaySearchsLazy.clear();
        this._searchCurrentLength = 0;

      });
      //検索リスト用遅延読み込み
      await this._loadMoreSearch();
    }

    await this.refreshImages(); //レコードリフレッシュ
    //レシピ削除した場合
    if(isRecipiDelete){
      setState(() {
        //レシピリスト用遅延読み込みリセット
        this._displayRecipisLazy.clear();
        this._recipiCurrentLength = 0;

      });
      //レシピリスト用遅延読み込み
      await this._loadMoreRecipi();
    }
    //削除完了したので、削除フラグをfalseに戻す
    if(this._isSelectedDelete){
      setState(() {
        this._isSelectedDelete = !this._isSelectedDelete;
      });
    }

  }

  //タグ検索モーダルにてタグが選択されている場合trueを返す
  bool _isTagSeachFlg(){
      if(_selectedtags == null || _selectedtags.isEmpty){
        return false;
      }
      return true;
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
    return Drawer(
      child: ListView(
        children: <Widget>[
//          DrawerHeader(
//            child: Column(
////              mainAxisSize: MainAxisSize.min,
//              mainAxisAlignment: MainAxisAlignment.end,
//              children: <Widget>[
//
//                Text('設定',
//                  style: TextStyle(fontSize: 20,color: Colors.white),)
//              ],
//            ),
//            decoration: BoxDecoration(
//              color: Colors.deepOrange[100 * (1 % 9)],
//            ),
//          ),
          Container(
            color: Colors.deepOrange[100 * (1 % 9)],
            child: ListTile(
              title: Center(
                child: Text('設定',
                  style: TextStyle(
                      color:Colors.white,
//                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
//              subtitle: Text(''),
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder_open,color: Colors.deepOrange[100 * (1 % 9)],),
            title: Text('フォルダの管理',
              style: TextStyle(
//                fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
//              Navigator.pop(context);
              _onFolderTap(type: 3);
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
          ListTile(
            leading: Icon(Icons.local_offer,color: Colors.deepOrange[100 * (1 % 9)],),
            title: Text('タグの管理',
              style: TextStyle(
//                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
//              Navigator.pop(context);
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
    );
  }

  //チェックボタン
  Widget checkBtn(){
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.check_circle_outline,size:30,),
      onPressed: (){
        _onCheck();
      },
    );
  }

  //追加ボタン
  Widget addBtn(){
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.add_circle_outline,size:30,),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //フォルダボタン
            Container(
              width: 130,
              child: Padding(
                padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                child: FlatButton(
                  color: Colors.deepOrange[100 * (1 % 9)],
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
            //タグ付けボタン
            Container(
              width: 130,
              child: Padding(
                padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
                child: FlatButton(
                  color: Colors.deepOrange[100 * (1 % 9)],
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
            //削除するボタン
            Container(
              width: 130,
              child: Padding(
                padding: EdgeInsets.only(top: 5,bottom: 5,left: 10,right: 10),
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
          ],
        ),
      ),
    );
  }

  Widget recipiList(){
    return Stack(
      children: [
        showList(),
        updater()
      ],
    );
  }

  //リストページ全体
  Widget showList(){
    return
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children:
        _isSeach || _isTagSeach
        ? <Widget>[
          searchArea(), //検索欄
//          line(),
          searchResultArea(), //検索結果
//          line(),
          Expanded(child:searchResultListArea()), //検索結果リスト
          buttonArea()
        ]
        : <Widget>[
          searchArea(), //検索欄
//          line(),
          folderArea(),
//          line(),
          folderListArea(),//フォルダ別
//          line(),
          myrecipiArea(), //MYレシピ
//          line(),
          Expanded(child:myrecipiListArea()), //MYレシピリスト
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
                      padding: EdgeInsets.all(10),
                      child: Text('フォルダ別レシピ', style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
//                          fontWeight: FontWeight.bold
                      ),),
                    ),
                  ],
                ),
              ),
            );
        }
    );
  }

  //フォルダ別リスト
  Widget folderListArea(){
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
      child:
      ListView.builder(
          shrinkWrap: true,
          itemCount: this._folders.length,
          itemBuilder: (context,index) {
            return createFolder(index);
          }
      ),
//      Column(
//      children:List.generate(this._folders.length, (int index){
//    return createFolder(index);
//    }
//    ),
    );
  }

  //フォルダリスト
  Widget createFolder(int index){
    //材料リストを展開する
      int count = 0;
    //レシピIDに紐づくタグを取得する
    var recipisGroupBy = this._recipisGroupBy.firstWhere(
            (_recipi) => _recipi.folder_id == this._folders[index].id,
        orElse: () => null
    );

    if(recipisGroupBy != null){
      count = recipisGroupBy.count;
      print('###グループ別：${recipisGroupBy.count}');
    }

//      for(var k=0; k < this._recipisGroupBy.length; k++){
//        if(this._folders[index].id == this._recipisGroupBy[k].folder_id)
//          count = this._recipisGroupBy[k].count;
//      }

    return
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
                            value: _folders[index].isCheck,
                            onChanged: (bool value){
                              _onItemCheck(index: index,type: 1);
                              print('folderID:${_folders[index].id},name:${_folders[index].name},isCheck:${_folders[index].isCheck}');
                            },
                          )
                      ),
                    Container(
                      padding: EdgeInsets.all(5),
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Container(
                          color: Colors.amber[100 * (1 % 9)],
                          child: Icon(Icons.folder_open,color: Colors.white,size: 30,),
                        ),
                      ),
                    ),
                    Container(
//                      color: Colors.redAccent,
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: EdgeInsets.all(5),
                      child: Text('${_folders[index].name}',
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
                onTap: (){
                  if(this._isCheck) {
                    _onItemCheck(index: index, type: 1);
                    print('folderID:${_folders[index].id},name:${_folders[index].name},isCheck:${_folders[index].isCheck}');
                  }else{
                    //フォルダ別レシピリストを表示する
                    _onListGroupBy(index: index);
                  }
                }
            ),
          ),
        );
//      );
//      column.add(
//        Divider(
//          color: Colors.grey,
//          height: 0.5,
//          thickness: 0.5,
//        ),
//      );
//    }
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
                color: Colors.deepOrange[100 * (2 % 9)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('MYレシピ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
//                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${_displayRecipis.length}品',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
//                          fontWeight: FontWeight.bold
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
                color: Colors.deepOrange[100 * (2 % 9)],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('検索結果', style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
//                          fontWeight: FontWeight.bold
                      ),),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: Text('${_displaySearchs.length}品', style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
//                          fontWeight: FontWeight.bold
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
    return
          LazyLoadScrollView(
            isLoading: _isLoadingRecipi,
            onEndOfPage: () => _loadMoreRecipi(),
            child:
            ListView.builder(
              shrinkWrap: true,
              itemCount: _displayRecipisLazy.length,
              itemBuilder: (context,position){
                if(_isLoadingRecipi && position == _displayRecipisLazy.length - 1){
                  if(this._displayRecipis.length == _displayRecipisLazy.length){
                    print('${_displayRecipisLazy[position].title}');
                    return createRecipi(position);
                  } else{
                    return Center(child: CircularProgressIndicator(),);
                  }
                } else {
                    return createRecipi(position);
                }
              }
            ),
          );
  }

  //検索結果リスト
  Widget searchResultListArea(){
    return
          LazyLoadScrollView(
            isLoading: _isLoadingSearch,
            onEndOfPage: () => _loadMoreSearch(),
            child:
            ListView.builder(
              shrinkWrap: true,
              itemCount: _displaySearchsLazy.length,
              itemBuilder: (context,position){
                if(_isLoadingSearch && position == _displaySearchsLazy.length - 1){
                  if(this._displaySearchs.length == _displaySearchsLazy.length){
                    return createRecipi(position);
                  } else{
                    return Center(child: CircularProgressIndicator(),);
                  }
                } else {
                  return createRecipi(position);
                }
              }
            ),
          );
  }

  //レシピリストの生成
  Widget createRecipi(int index){

    if(_isSeach || _isTagSeach){
      this._displayList = this._displaySearchs;
    }else{
      this._displayList = this._displayRecipis;
    }

    List ingredients = [];
    List<Tag> tags = [];
    String ingredientsTX = '';

    var displayTargetIndex = this._displayList[index].id;

    //レシピIDに紐づく材料を取得する
    var ingredientList = this._ingredients.where(
            (ing) =>  ing.recipi_id == displayTargetIndex
    );

//    print('###材料：${ingredientList.length}');

    //レシピIDに紐づく材料が存在した場合
    if(ingredientList.length > 0){
      //nameのみ取得し配列を生成
      ingredientList.forEach((ingredient) => ingredients.add(ingredient.name));
      //上記の配列の全要素を順に連結した文字列を作成
      ingredientsTX = ingredients.join(',');
    }

    //レシピIDに紐づくタグを取得する
    var tagList = this._tags.where(
            (_tag) => _tag.recipi_id == displayTargetIndex
    );


    if(tagList.length > 0){
      tagList.forEach((tag) => tags.add(tag));
    }

    //MYレシピを展開する
     return
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
                              value: this._displayList[index].isCheck,
                              onChanged: (bool value){
                                _onItemCheck(index: index,type: 2);
                                print('ID:${this._displayList[index].id},name:${this._displayList[index].title},isCheck:${this._displayList[index].isCheck}');
                              },
                            )
                        ),
                      //サムネイルエリア
                      this._displayList[index].thumbnail.isNotEmpty
                          ? Card(
                        child: Container(
                          height: 100,
                          width: 100,
                          child: Image.file(File(common.replaceImage(this._displayList[index].thumbnail)),fit: BoxFit.cover,),
                        ),
                      )
                          : Card(
                        child: Container(
                          height: 100,
                          width: 100,
                          color: Colors.amber[100 * (1 % 9)],
                          child: Icon(Icons.restaurant,color: Colors.white,size: 50,),
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
                              child: Text('${this._displayList[index].title}',
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
                                      child: Icon(Icons.local_offer,size: 15,color: Colors.amber[100 * (1 % 9)]),
                                    ),
                                    //タグ名　最大5件まで
                                    for(var k = 0; k<tags.length;k++)
                                      Container(
                                        padding: EdgeInsets.all(2),
                                        child: SizedBox(
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            color: Colors.amber[100 * (1 % 9)],

                                            child: Text('${tags[k].name}',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey
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
                              child: Icon(Icons.folder,color: Colors.orange[100 * (3 % 9)],size: 30,),
                              onTap: (){
                                _onFolderTap(index: index,ingredients: ingredientsTX,tags: tags,type: 0);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: (){
                    if(this._isCheck){
                      _onItemCheck(index: index,type: 2);
                    }else{
                      _onDetail(index: index);
                    }
                  }
              ),
            ),
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
              //テキスト検索エリア
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
              //タグ検索エリア
              Container(
                decoration: BoxDecoration(
//                  color: Colors.blueGrey,
                ),
                width: 60,
                child: Column(
                  children: <Widget>[
                    MultiSelectBottomSheetField(
                      initialChildSize: 0.40,
                      listType: MultiSelectListType.CHIP,
                      searchable: true,
                      buttonIcon: Icon(Icons.local_offer,color: _selectedtags == null || _selectedtags.isEmpty ? Colors.grey : Colors.deepOrange[100 * (1 % 9)] ,size: 35,),
                      buttonText: Text(""),
                      title: Text("タグで検索"),
//                      selectedColor: Colors.deepOrange[100 * (2 % 9)] ,
//                      backgroundColor: Colors.blueGrey,
//                      chipColor: Colors.white,
                      items: _displayTags,

                      onConfirm: (results) {
                        setState(() {
                          _selectedtags = results;
                        });
                        this._onTagSearch();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }

}