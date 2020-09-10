import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';

import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';


class EditRecipi extends StatefulWidget{

  @override
  _EditRecipiState createState() => _EditRecipiState();
}

class _EditRecipiState extends State<EditRecipi>{

  DBHelper dbHelper = DBHelper();
  Common common = Common();

  List<Myrecipi> _recipis = List<Myrecipi>();
  List<Ingredient> _ingredients = List<Ingredient>();
  List<Tag> _tags = List<Tag>();
  List<DRecipi> _selectedRecipis = List<DRecipi>();
  List<DRecipi> _selectedRecipisOld = List<DRecipi>();

  List<Myrecipi> _recipisLazy = List<Myrecipi>(); //遅延読み込み用リスト
  bool _isLoadingRecipi = false;                               //true:遅延読み込み中
  int _recipiCurrentLength = 0;                                //遅延読み込み件数を格納

  final int increment = 10; //読み込み件数

  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init(){
    this.getRecipiList();
    setState(() {
      _recipisLazy.clear();
    });
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
      if( i < this._recipis.length){
        if(mounted){
          setState(() {
            _recipisLazy.add(_recipis[i]);
          });
        }
      }else{
        break;
      }

    }
    if(mounted){
      setState(() {
        _isLoadingRecipi = false;
        _recipiCurrentLength = _recipisLazy.length;
      });
    }
  }

  void getRecipiList() async {
    //レシピの取得
    await dbHelper.getMyRecipis().then((item){
      setState(() {
        _recipis.clear();
        _recipis.addAll(item);
      });
    });

    //材料の取得
    await dbHelper.getAllIngredients().then((item){
      setState(() {
        _ingredients.clear();
        _ingredients.addAll(item);
      });
    });

    //タグリストの取得
    await dbHelper.getAllTags().then((item){
      setState(() {
        _tags.clear();
        _tags.addAll(item);
      });
    });

    //選択レシピリストをセット
    this._selectedRecipis = Provider.of<Edit>(context, listen: false).getRecipis();
    for(var i = 0; i < this._selectedRecipis.length; i++){
      this._selectedRecipisOld.add(this._selectedRecipis[i]);
    }

//    //レシピの取得
//    this._recipis = Provider.of<Display>(context, listen: false).getRecipis();
//    //材料の取得
//    this._ingredients = Provider.of<Display>(context, listen: false).getIngredients();
//    //タグの取得
//    this._tags = Provider.of<Display>(context, listen: false).getTags();
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    //選択したレシピを保存
    Provider.of<Edit>(context, listen: false).setRecipis(this._selectedRecipis);
    this._changeEditType();
  }

  //×ボタン押下時処理
  void _onClose(){
    //編集前のレシピを保存
    Provider.of<Edit>(context, listen: false).setRecipis(this._selectedRecipisOld);
    this._changeEditType();
  }

  //編集画面の状態の切り替え
  void _changeEditType(){
    Provider.of<Display>(context, listen: false).setEditType(0);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
        builder: (context, Display, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.brown[100 * (1 % 9)],
              leading: closeBtn(),
              elevation: 0.0,
              title: Center(
                child: Text( 'レシピを追加',
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
            body: Column(
              children: <Widget>[
                selectedArea(),//選択したレシピ
                line(),
                titleArea(),//タイトル
                line(),
                Expanded(child:recipiArea()),//レシピリスト
              ],
            ),
          );
        }
    );
  }

  //選択レシピリスト
  Widget selectedArea(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 24.0),
      height: MediaQuery.of(context).size.height * 0.15,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: _selectedRecipis.length,
          itemBuilder: (context,index){
            return Container(
              width: MediaQuery.of(context).size.width * 0.2,
              child: Stack(
                children: <Widget>[
                  _selectedRecipis[index].image.isNotEmpty
                  ? Card(
//                    color: Colors.blue,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.file(File(common.replaceImage(_selectedRecipis[index].image)),fit: BoxFit.cover,),
                    ),
                  )
                  : Card(
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                        child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                    ),
                  ),
                  Positioned(
                    left: 45,
                    width: 40,
                    height: 40,
                    child: Container(
//                    color: Colors.redAccent,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle,),
                        onPressed: (){
                          setState(() {
                            //イメージ削除
                            _selectedRecipis.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ),
                ],
              )
            );
          }
      ),
    );
  }

  //タイトル
  Widget titleArea(){
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
                      child: Text('レシピから選択', style: TextStyle(
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
  Widget recipiArea(){
    return
      LazyLoadScrollView(
        isLoading: _isLoadingRecipi,
        onEndOfPage: () => _loadMoreRecipi(),
        child:
        ListView.builder(
            shrinkWrap: true,
            itemCount: _recipisLazy.length,
            itemBuilder: (context,position){
              if(_isLoadingRecipi && position == _recipisLazy.length - 1){
                if(this._recipis.length == _recipisLazy.length){
                  print('${_recipisLazy[position].title}');
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

      List ingredients = [];
      List<Tag> tags = [];
      String ingredientsTX = '';

    var displayTargetIndex = this._recipis[index].id;

    //レシピIDに紐づく材料を取得する
    var ingredientList = this._ingredients.where(
            (ing) =>  ing.recipi_id == displayTargetIndex
    );

    //レシピIDに紐づく材料が存在した場合
    if(ingredientList.length > 0){
      //nameのみ取得し配列を生成
      ingredientList.forEach((ingredient) => ingredients.add(ingredient.name));
      //上記の配列の全要素を順に連結した文字列を作成
      ingredientsTX = ingredients.join(',');
    }

//      //レシピIDに紐づく材料を取得する
//      for(var k = 0;k < this._ingredients.length;k++){
//        if(this._recipis[index].id == this._ingredients[k].recipi_id){
//          ingredients.add(this._ingredients[k].name);
//        }
//      }

    //レシピIDに紐づくタグを取得する
    var tagList = this._tags.where(
            (_tag) => _tag.recipi_id == displayTargetIndex
    );

    if(tagList.length > 0){
      tagList.forEach((tag) => tags.add(tag));
    }

//      //レシピIDに紐づくタグを取得する
//      for(var k = 0;k < this._tags.length;k++){
//        if(this._recipis[index].id == this._tags[k].recipi_id){
//          tags.add(this._tags[k]);
//        }
//      }

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
                    //サムネイルエリア
                    this._recipis[index].thumbnail.isNotEmpty
                        ? SizedBox(
                      height: 100,
                      width: 100,
                      child: Container(
                        child: Image.file(File(common.replaceImage(this._recipis[index].thumbnail)),fit: BoxFit.cover,),
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
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          //タイトル
                          Container(
                            height: 50,
                            padding: EdgeInsets.all(5),
                            child: Text('${this._recipis[index].title}',
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
                  ],
                ),
                onTap: (){
                  print('recipiID:${this._recipis[index].id},thumbnail:${this._recipis[index].thumbnail}');
                  bool isDelete = false;
                  //tapしたレシピが選択レシピリストに存在する場合
                  for(var k = 0; k < this._selectedRecipis.length; k++){
                    if(this._recipis[index].id == this._selectedRecipis[k].recipi_id){
                      //削除
                      setState(() {
                        this._selectedRecipis.removeAt(k);
                      });
                      isDelete = true;
                      break;
                    }
                  }
                  //tapしたレシピが選択レシピリストに存在しなかった場合
                  if(!isDelete){
                    setState(() {
                      DRecipi recipi = DRecipi(recipi_id: this._recipis[index].id,image: this._recipis[index].thumbnail);
                      this._selectedRecipis.add(recipi);
                    });
                  }
                }
            ),
          ),
        );
  }

  //線
  Widget line(){
    return
      Divider(
        color: Colors.grey,
        height: 0.5,
        thickness: 0.5,
      );
  }

//保存ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: Text('保存',
            style: TextStyle(
              color: Colors.brown[100 * (1 % 9)],
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

  //ｘボタン
  Widget closeBtn(){
    return IconButton(
      icon: const Icon(Icons.close,color: Colors.white,size: 35,),
      onPressed: (){
        _onClose();
      },
    );
  }
}