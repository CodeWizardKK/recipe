import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:recipe_app/services/database/DBHelper.dart';
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

  List<Myrecipi> _recipis = List<Myrecipi>();
  List<Ingredient> _ingredients = List<Ingredient>();
  List<Tag> _tags = List<Tag>();
  List<DRecipi> _selectedRecipis = List<DRecipi>();
  List<DRecipi> _selectedRecipisOld = List<DRecipi>();


  @override
  void initState() {
    super.initState();
    this.init();
  }

  void init(){
    this.getRecipiList();
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

  //レシピエリア
  Column _onList(){
    List<Widget> column = new List<Widget>();
    //MYレシピを展開する
    for(var i=0; i < this._recipis.length; i++){
      List ingredients = [];
      List<Tag> tags = [];
      String ingredientsTX = '';

      //レシピIDに紐づく材料を取得する
      for(var k = 0;k < this._ingredients.length;k++){
        if(this._recipis[i].id == this._ingredients[k].recipi_id){
          ingredients.add(this._ingredients[k].name);
        }
      }
      //配列の全要素を順に連結した文字列を作成
      ingredientsTX = ingredients.join(',');

      //レシピIDに紐づくタグを取得する
      for(var k = 0;k < this._tags.length;k++){
        if(this._recipis[i].id == this._tags[k].recipi_id){
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
                    //サムネイルエリア
                    this._recipis[i].thumbnail.isNotEmpty
                        ? SizedBox(
                      height: 100,
                      width: 100,
                      child: Container(
                        child: Image.file(File(this._recipis[i].thumbnail),fit: BoxFit.cover,),
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
                            child: Text('${this._recipis[i].title}',
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
                  print('recipiID:${this._recipis[i].id},thumbnail:${this._recipis[i].thumbnail}');
                  bool isDelete = false;
                  //tapしたレシピが選択レシピリストに存在する場合
                  for(var k = 0; k < this._selectedRecipis.length; k++){
                    if(this._recipis[i].id == this._selectedRecipis[k].recipi_id){
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
                      DRecipi recipi = DRecipi(recipi_id: this._recipis[i].id,image: this._recipis[i].thumbnail);
                      this._selectedRecipis.add(recipi);
                    });
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

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
        builder: (context, Display, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.cyan,
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
                recipiArea(),//レシピリスト
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
                      child: Image.file(File(_selectedRecipis[index].image),fit: BoxFit.cover,),
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

  //レシピリスト
  Widget recipiArea(){
    return Expanded(
      child: SingleChildScrollView(
        child:_onList(),
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