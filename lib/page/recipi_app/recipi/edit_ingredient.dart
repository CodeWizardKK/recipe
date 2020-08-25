import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:recipe_app/model/Format.dart';

class EditIngredient extends StatefulWidget{

  @override
  _EditIngredientState createState() => _EditIngredientState();
}

class _EditIngredientState extends State<EditIngredient>{

  final _name = TextEditingController();      //材料名
  final _quantity = TextEditingController();  //分量
  int _index;                                 //選択された材料のindex番号
  List<Format> _seasonings = List();          //調味料リスト
  List<Format> _quantityunit = List();        //分量単位リスト

  @override
  void initState() {
    super.initState();
    //ローカルjson
    this.getLocalSeasoningJsonData();
    this.getLocalQuantityUnitJsonData();
    //新規or更新かジャッチする
    _index = Provider.of<Display>(context, listen: false).getEditIndex();
//    print('index:${_index}');
    //更新の場合
    if(_index != -1){
      //選択した材料の取得
      Ingredient item = Provider.of<Display>(context, listen: false).getIngredient(_index);
      print('[更新]no:${item.no},name:${item.name},quantity:${item.quantity}');
      this._name.text = item.name;
      this._quantity.text = item.quantity;
    }
  }

  //材料ローカルjsonファイル読み込み
  Future<String> _loadSeasoningAsset() async {
    return await rootBundle.loadString('json/seasoning.json');
  }

  //分量単位ローカルjsonファイル読み込み
  Future<String> _loadQuantityUnitAsset() async {
    return await rootBundle.loadString('json/quantityUnit.json');
  }

  //材料ローカルjson データセット
  Future<void> getLocalSeasoningJsonData() async {
    setState(() {
      this._seasonings.clear();
    });
    String jsonString = await _loadSeasoningAsset();
    //データを個別に扱えるようデコードする
    final jsonResponse = json.decode(jsonString);
    List seasonings = jsonResponse['seasonings'];
//      print('### getJSON: ${jsonResponse.toString()}');
    for(var i = 0; i < seasonings.length; i++){
      Format seasoning = Format(id: seasonings[i]['id'],name: seasonings[i]['name']);
      setState(() {
        this._seasonings.add(seasoning);
      });
    }
//    for(var i = 0; i < this._seasonings.length; i++){
//      print('id:${this._seasonings[i].id},name:${this._seasonings[i].name}');
//    }
  }

  //分量単位ローカルjson データセット
  Future<void> getLocalQuantityUnitJsonData() async {
    setState(() {
      this._quantityunit.clear();
    });
    String jsonString = await _loadQuantityUnitAsset();
    //データを個別に扱えるようデコードする
    final jsonResponse = json.decode(jsonString);
    List quantityunit = jsonResponse['quantityunits'];
//      print('### getJSON: ${jsonResponse.toString()}');
    for(var i = 0; i < quantityunit.length; i++){
      Format seasoning = Format(id: quantityunit[i]['id'],name: quantityunit[i]['name']);
      setState(() {
        this._quantityunit.add(seasoning);
      });
    }
//    for(var i = 0; i < this._quantityunit.length; i++){
//      print('id:${this._quantityunit[i].id},name:${this._quantityunit[i].name}');
//    }
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    Ingredient ingredient;
    //更新の場合
    if(_index != -1){
      ingredient = Ingredient(name: _name.text,quantity: _quantity.text);
      //選択した材料の更新処理
      Provider.of<Display>(context, listen: false).setIngredient(_index,ingredient);
      return;
    }
    //入力内容が未入力以外の場合
    if(!_isEmptyCheck()){
      ingredient = Ingredient(name: _name.text,quantity: _quantity.text);
      //材料リストへの追加
      Provider.of<Display>(context, listen: false).addIngredient(ingredient);
    }
  }

  bool _isEmptyCheck(){
    if(this._name.text.isNotEmpty){
      return false;
    }
    if(this._quantity.text.isNotEmpty){
      return false;
    }
    return true;
  }

  //削除ボタン押下時処理
  void _onDelete(){
    print('####delete');
    //材料リストの取得
    List<Ingredient> ingredients = Provider.of<Display>(context, listen: false).getIngredients();
    //該当の材料を削除
    ingredients.removeAt(_index);
    for(var i = 0; i < ingredients.length; i++){
      //noを採番し直す
      ingredients[i].no =  i + 1;
      print('no:${ingredients[i].no},name:${ingredients[i].name},quantity:${ingredients[i].quantity}');
    }
    //新しく生成した材料リストをセットする
//    Provider.of<Display>(context, listen: false).setIngredients(ingredients);
  }

  //編集画面の状態の切り替え
  void _changeEditType(editType){
    Provider.of<Display>(context, listen: false).setEditType(editType);
    //
    Provider.of<Display>(context, listen: false).setEditIndex(-1);
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
                child: Text( Display.id == -1 ? 'レシピを作成' :'レシピを編集',
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
    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
      key: GlobalKey(),
      child: SingleChildScrollView(
        key: GlobalKey(),
//        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
    return Container(
      key: GlobalKey(),
      //入力フィールドをformでグループ化し、key:_formKey(グローバルキー)と
      child: Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            nameArea(),            //材料名
            nameInputArea(),       //材料名入力欄
            quantityArea(),         //分量
            quantityInputArea(),    //分量入力欄
            line(),
            deleteButtonArea(),
          ],
        ),
      ),
    );
  }

  //材料
  Widget nameArea(){
    return
      SizedBox(
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('材料',style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                  fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      );
  }

  //材料入力欄
  Widget nameInputArea(){
    return Column(
      children: <Widget>[
        SizedBox(
  //        height: MediaQuery.of(context).size.height * 0.08,
  //        width: MediaQuery.of(context).size.width,
          child: Container(
            width: 400,
            child: TextField(
              controller: _name,
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: 'トマト',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _seasonings.length,
            itemBuilder: (context,index) {
              return Row(
                children: <Widget>[
                  RoundedButton(
                    title: '${_seasonings[index].name}',
                    buttonColor: Colors.orangeAccent,
                    onPressed: () {
                      setState(() {
                        _name.text = _seasonings[index].name;
                      });
                      print('${_seasonings[index].name}');
                    },
                  ),
                  SizedBox(width: 2.0,)
                ],
              );
            }
          ),
        )
      ],
    );
  }

  //分量
  Widget quantityArea(){
    return
      SizedBox(
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('分量',style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
//                    fontWeight: FontWeight.bold
                ),),
              ),
            ],
          ),
        ),
      );
  }

  //分量入力欄
  Widget quantityInputArea(){
    return Column(
      children: <Widget>[
        SizedBox(
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
          child: Container(
            width: 400,
            child: TextField(
              controller: _quantity,
              autofocus: false,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                hintText: '1個',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
          height: 80,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quantityunit.length,
              itemBuilder: (context,index) {
                return Row(
                  children: <Widget>[
                    RoundedButton(
                      title: '${_quantityunit[index].name}',
                      buttonColor: Colors.orangeAccent,
                      onPressed: () {
                        setState(() {
                          if(_quantityunit[index].id < 5){
                            _quantity.text = '${_quantity.text}${_quantityunit[index].name}';
                          } else {
                            _quantity.text = '${_quantityunit[index].name}${_quantity.text}';
                          }
                        });
                        print('${_quantityunit[index].name}');
                      },
                    ),
                    SizedBox(width: 2.0,)
                  ],
                );
              }
          ),
        ),
    ],
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

  //削除ボタン
  Widget deleteButtonArea() {
    return
     _index != -1
      ? Container(
       margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: 200,
          height: 50,
          child: RaisedButton.icon(
            icon: Icon(Icons.delete,color: Colors.white,),
            label: Text('材料を削除する'),
            textColor: Colors.white,
            color: Colors.redAccent,
            onPressed:(){
              _onDelete();
              _changeEditType(0); //タイトル
            },
          ),
        ),
      )
      : Container();
  }


//保存ボタン
  Widget completeBtn(){
    return Container(
      width: 90,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FlatButton(
          color: Colors.white,
//          shape: RoundedRectangleBorder(
//            borderRadius: BorderRadius.circular(10.0),
//          ),
          child: Text('保存',
            style: TextStyle(
              color: Colors.cyan,
              fontSize: 15,
            ),
          ),
          onPressed: (){
            //入力したdataをstoreへ保存
            _onSubmit();
            _changeEditType(0); //タイトル
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
        _changeEditType(0); //編集TOP
      },
    );
  }
}