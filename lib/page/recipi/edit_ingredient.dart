import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:flutter/services.dart';
import 'package:recipe_app/model/Format.dart';
import 'package:recipe_app/services/database/DBHelper.dart';

class EditIngredient extends StatefulWidget{

  Ingredient ingredient = Ingredient();

  EditIngredient({Key key, @required this.ingredient}) : super(key: key);

  @override
  _EditIngredientState createState() => _EditIngredientState();
}

class _EditIngredientState extends State<EditIngredient>{

  DBHelper dbHelper;
  final _name = TextEditingController();      //材料名
  final _quantity = TextEditingController();  //分量
  bool _isNew = false;                        //true:新規 false:更新
  List<Format> _seasonings = List();          //調味料DBから取得したレコードを格納
  List<Format> _quantityunit = List();        //分量単位DBから取得したレコードを格納
  Ingredient _ingredient = Ingredient();      //材料

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      this.dbHelper = DBHelper();
    });
    //seasonings、quantityunitの取得
    var seasonings = await dbHelper.getSeasoning();
    var quantityunit = await dbHelper.getQuantityUnit();
    setState(() {
      this._seasonings = seasonings;
      this._quantityunit = quantityunit;
      this._ingredient = widget.ingredient;
    });
    //追加or更新チェック
    if(this._ingredient.id == null){
      setState(() {
        this._isNew = true;
      });
    } else {
      setState(() {
        this._isNew = false;
      });
    }
      //選択した材料の取得
//      print('選択した材料 no:${this._ingredient.no},name:${this._ingredient.name},quantity:${this._ingredient.quantity}');
      setState(() {
        this._name.text = this._ingredient.name;
        this._quantity.text = this._ingredient.quantity;
      });
  }


  //保存ボタン押下時処理
  void _onSubmit(){
    //更新の場合
    if(!_isNew){
      this._ingredient.name = _name.text;
      this._ingredient.quantity = _quantity.text;
//      print('id:${this._ingredient.id},no:${this._ingredient.no},name:${this._ingredient.name},quantity:${this._ingredient.quantity}');
      Navigator.pop(context,this._ingredient);
    //新規の場合
    } else {
      //入力内容が未入力以外の場合
      if(!_isEmptyCheck()){
        this._ingredient.id = -1;
        this._ingredient.name = _name.text;
        this._ingredient.quantity = _quantity.text;
//        print('id:${this._ingredient.id},no:${this._ingredient.no},name:${this._ingredient.name},quantity:${this._ingredient.quantity}');
        Navigator.pop(context,this._ingredient);
      //未入力の場合
      } else {
        Navigator.pop(context);
      }
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

  @override
  Widget build(BuildContext context) {
//    return Consumer<Display>(
//        builder: (context, Display, _) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepOrange[100 * (1 % 9)],
              leading: closeBtn(),
              elevation: 0.0,
              title: Center(
                child: Text( '材料',
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
            body: scrollArea(),
          );
//        }
//    );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
//      key: GlobalKey(),
      child: SingleChildScrollView(
//        key: GlobalKey(),
//        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        child: showForm(),
      ),
    );
  }

  //ページ全体
  Widget showForm(){
    return Container(
//      key: GlobalKey(),
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
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10,right: 10),
                child: FittedBox(fit:BoxFit.fitWidth,
                  child: Text('材料',style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
  //                  fontWeight: FontWeight.bold
                  ),),
                ),
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
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.98,
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
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
          height:  MediaQuery.of(context).size.height * 0.08,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _seasonings.length,
            itemBuilder: (context,index) {
              return Row(
                children: <Widget>[
                  FittedBox(fit:BoxFit.fitWidth,
                    child:RoundedButton(
                      title: '${_seasonings[index].name}',
                      buttonColor: Colors.amber[100 * (1 % 9)],
                      splashColor: Colors.orangeAccent,
                      onPressed: () {
                        setState(() {
                          _name.text = _seasonings[index].name;
                        });
  //                      print('${_seasonings[index].name}');
                      },
                    ),
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
                  child: Text('分量',style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
  //                    fontWeight: FontWeight.bold
                  ),),
                ),
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
          child: Container(
            color: Colors.white,
            width: MediaQuery.of(context).size.width * 0.98,
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
          padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
          height:  MediaQuery.of(context).size.height * 0.08,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _quantityunit.length,
              itemBuilder: (context,index) {
                return Row(
                  children: <Widget>[
                    FittedBox(fit:BoxFit.fitWidth,
                      child:RoundedButton(
                        title: '${_quantityunit[index].name}',
                        buttonColor: Colors.amber[100 * (1 % 9)],
                        splashColor: Colors.orangeAccent,
                        onPressed: () {
                          setState(() {
                            _quantity.text += '${_quantityunit[index].name}';
                          });
//                          print('${_quantityunit[index].name}');
                        },
                      ),
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

  //削除ボタン
  Widget deleteButtonArea() {
    return
     !_isNew
      ? Container(
       margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.45,
          height: MediaQuery.of(context).size.height * 0.05,
          child: FittedBox(fit:BoxFit.fitWidth,
            child: RaisedButton.icon(
              icon: Icon(Icons.delete,color: Colors.white),
              label: Text('材料を削除する'),
              textColor: Colors.white,
              color: Colors.red[100 * (3 % 9)],
              onPressed:(){
                Navigator.pop(context,'delete');
              },
            ),
          ),
        ),
      )
      : Container();
  }


//保存ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: FittedBox(fit:BoxFit.fitWidth,
          child: FlatButton(
            color: Colors.white,
  //          shape: RoundedRectangleBorder(
  //            borderRadius: BorderRadius.circular(10.0),
  //          ),
            child: Text('保存',
              style: TextStyle(
                color: Colors.deepOrange[100 * (1 % 9)],
                fontSize: 15,
              ),
            ),
            onPressed: (){
              //入力したdataをstoreへ保存
              _onSubmit();
            },
          ),
        ),
      ),
    );
  }

  //ｘボタン
  Widget closeBtn(){
    return FittedBox(fit:BoxFit.fitWidth,
      child: IconButton(
        icon: const Icon(Icons.close,color: Colors.white),
        onPressed: (){
          Navigator.pop(context);
        },
      ),
    );
  }
}