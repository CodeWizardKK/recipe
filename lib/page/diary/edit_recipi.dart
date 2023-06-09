import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:frefresh/frefresh.dart';

import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';


class EditRecipi extends StatefulWidget{

  List<DRecipi> recipis = List<DRecipi>();

  @override
  _EditRecipiState createState() => _EditRecipiState();

  EditRecipi({Key key, @required this.recipis}) : super(key: key);

}

class _EditRecipiState extends State<EditRecipi>{

  DBHelper dbHelper;
  Common common;
  List<Myrecipi> _recipis = List<Myrecipi>();           //DBから取得した値を格納
  List<Ingredient> _ingredients = List<Ingredient>();   //DBから取得した値を格納
  List<Tag> _tags = List<Tag>();                        //DBから取得した値を格納
  List<DRecipi> _selectedItems = List<DRecipi>();       //レシピ一覧から選択したレシピを格納
  List<Myrecipi> _lazy = List<Myrecipi>();              //遅延読み込み用リスト
  int _currentLength = 0;                               //遅延読み込み件数を格納
  final int increment = 10;                             //読み込み件数
  FRefreshController controller = FRefreshController(); //lazyload
  String text = "Drop-down to loading";                 //lazyload用text

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init() async {
    setState(() {
      //初期化
      this.dbHelper = DBHelper();
      this.common = Common();
      this._selectedItems = [];
      this._lazy.clear();
      this.controller = FRefreshController();
      FRefresh.debug = true;
    });
    //レシピリスト取得
    await this.getRecipiList();
    //レシピリスト用遅延読み込み
    await this._loadMore();
  }

  //レシピリスト用遅延読み込み
  Future _loadMore() async {
//    print('+++++_loadMore+++++++');
    for (var i = _currentLength; i < _currentLength + increment; i++) {
      if( i < this._recipis.length){
        setState(() {
          _lazy.add(_recipis[i]);
        });
      }else{
        break;
      }

    }
    setState(() {
      _currentLength = _lazy.length;
    });
  }

  Future<void> getRecipiList() async {
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
    setState(() {
      widget.recipis.forEach((recipi) => this._selectedItems.add(recipi));
    });
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    Navigator.pop(context,this._selectedItems);
  }

  //×ボタン押下時処理
  void _onClose(){
    Navigator.pop(context,'close');
  }


  @override
  Widget build(BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepOrange[100 * (1 % 9)],
              leading: closeBtn(),
              elevation: 0.0,
              title: Center(
                child: Text( 'レシピを追加',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
//                    fontWeight: FontWeight.bold,
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
//                line(),
                titleArea(),//タイトル
//                line(),
                Expanded(child:recipiArea()),//レシピリスト
              ],
            ),
          );
  }

  //選択レシピリスト
  Widget selectedArea(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 24.0),
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
          itemCount: _selectedItems.length,
          itemBuilder: (context,index){
            return Container(
              width: 90,
              child: Stack(
                children: <Widget>[
                  _selectedItems[index].image.isNotEmpty
                  ? Card(
//                    color: Colors.blue,
                    child: Container(
                      width: 100,
                      height: 100,
                      child: Image.file(File(common.replaceImage(_selectedItems[index].image)),fit: BoxFit.cover,),
                    ),
                  )
                  : Card(
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.amber[100 * (1 % 9)],
                        child: Icon(Icons.restaurant,color: Colors.white,size: 50,),
                    ),
                  ),
                  Positioned(
                    left: 50,
                    width: 40,
                    height: 40,
                    child: Container(
//                    color: Colors.redAccent,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle),
                        onPressed: (){
                          setState(() {
                            //イメージ削除
                            _selectedItems.removeAt(index);
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
                        child: Text('レシピから選択', style: TextStyle(
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

  //MYレシピリスト
  Widget recipiArea(){
    return FRefresh(
      controller: controller,
      footerBuilder: (setter) {
        controller.setOnStateChangedCallback((state) {
          setter(() {
            if (controller.loadState == LoadState.PREPARING_LOAD) {
              text = "Release to load";
            } else if (controller.loadState == LoadState.LOADING) {
              text = "Loading..";
            } else if (controller.loadState == LoadState.FINISHING) {
              text = "Loading completed";
            } else {
              text = "Drop-down to loading";
            }
          });
        });
        return Container(
//          color: Colors.black,
            height: 38,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 15,
                  height: 15,
                  child: CupertinoActivityIndicator(
                    animating: true,
                    radius: 10,
                  ),
//                  child: CircularProgressIndicator(
////                      backgroundColor: mainBackgroundColor,
//                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
////                      new AlwaysStoppedAnimation<Color>(mainTextSubColor),
//                    strokeWidth: 2.0,
//                  ),
                ),
                const SizedBox(width: 9.0),
                Text(text, style: TextStyle(color: Colors.white)),
              ],
            ));
      },
      footerHeight: 70.0,
      onLoad: () {
        Timer(Duration(milliseconds: 1000), () {
          _loadMore();
          controller.finishLoad();
//          print('controller.position = ${controller.position}, controller.scrollMetrics = ${controller.scrollMetrics}');
//          setState(() {
//          });
        });
      },
      child: Container(
        width: 220,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListView.builder(
                itemCount: _lazy.length,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return LayoutBuilder(builder: (_, constraints) {
                    return createRecipi(index);
                  });
                }),
          ],
        ),
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
//          height: MediaQuery.of(context).size.height * 0.16,
          child: Container(
            color: Colors.white,
//            padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
            padding: EdgeInsets.all(5),
            child: InkWell(
              child: FittedBox(fit:BoxFit.fitWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    //サムネイルエリア
                    this._recipis[index].thumbnail.isNotEmpty
                        ? SizedBox(
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                        child: Image.file(File(common.replaceImage(this._recipis[index].thumbnail)),fit: BoxFit.cover,),
                      ),
                    )
                        : SizedBox(
                      height: MediaQuery.of(context).size.width * 0.25,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Container(
                        color: Colors.amber[100 * (1 % 9)],
                        child: Icon(Icons.restaurant,color: Colors.white,size: 50,),
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
//                            height: MediaQuery.of(context).size.height * 0.045,
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
//                            height: MediaQuery.of(context).size.height * 0.04,
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
                              height: MediaQuery.of(context).size.height < 600 ? MediaQuery.of(context).size.height * 0.08 : MediaQuery.of(context).size.height * 0.06,
                              padding: EdgeInsets.only(left: 5,right: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  //タグicon
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    width: MediaQuery.of(context).size.width * 0.03,
                                    child: Icon(Icons.local_offer,color: Colors.yellow[100 * (1 % 9)]),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.52,
                                    child: MultiSelectChipDisplay(
                                      chipColor: Colors.yellow,
                                      onTap: null,
                                      items: tags
                                          .map((e) => MultiSelectItem<Tag>(e, e.name))
                                          .toList(),
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
              ),
                onTap: (){
//                  print('recipiID:${this._recipis[index].id},thumbnail:${this._recipis[index].thumbnail}');
                  bool isDelete = false;
                  //tapしたレシピが選択レシピリストに存在する場合
                  for(var k = 0; k < this._selectedItems.length; k++){
                    if(this._recipis[index].id == this._selectedItems[k].recipi_id){
                      //削除
                      setState(() {
                        this._selectedItems.removeAt(k);
                      });
                      isDelete = true;
                      break;
                    }
                  }
                  //tapしたレシピが選択レシピリストに存在しなかった場合
                  if(!isDelete){
                    setState(() {
                      DRecipi recipi = DRecipi(recipi_id: this._recipis[index].id,image: this._recipis[index].thumbnail);
                      this._selectedItems.add(recipi);
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
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
          child: Text('保存',
            style: TextStyle(
              color: Colors.deepOrange[100 * (1 % 9)],
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
      icon: const Icon(Icons.close,color: Colors.white,size: 30,),
      onPressed: (){
        _onClose();
      },
    );
  }
}