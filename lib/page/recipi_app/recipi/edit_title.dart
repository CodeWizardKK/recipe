import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_awesome_buttons/flutter_awesome_buttons.dart';
import 'package:recipe_app/model/edit/Titleform.dart';

class EditTitle extends StatefulWidget {

  TitleForm titleForm = TitleForm();
  int type;

  EditTitle({Key key, @required this.titleForm, @required this.type}) : super(key: key);

  @override
  _EditTitleState createState() => _EditTitleState();
}

class _EditTitleState extends State<EditTitle>{

  final _title = TextEditingController();        //タイトル
  final _description = TextEditingController();  //説明/メモ
  final _quantity = TextEditingController();     //分量
  final _time = TextEditingController();         //調理時間
  int _unit;                                     //単位（1：人分、2：個分、3：枚分、4：杯分、5：皿分）
  int _type;                                     //レシピ種別 1:写真レシピ 2:MYレシピ 3:テキストレシピ

  @override
  void initState() {
    super.initState();
    //編集内容を取得
    TitleForm item = widget.titleForm;
    //レシピ種別を取得
    this._type = widget.type;
    //編集内容を展開
    this._title.text = item.title;
    this._description.text = item.description;
    this._quantity.text = item.quantity.toString();
    this._unit = item.unit;
    this._time.text = item.time.toString();
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    TitleForm titleForm = TitleForm(title: _title.text,description: _description.text,quantity: intParse(_quantity.text),unit: _unit,time: intParse(_time.text));
    Navigator.pop(context,titleForm);
  }

  //string => int 変換
  int intParse(String text){
    if(text.isEmpty){
      return 0;
    }
    return int.parse(text);

  }

  //単位 表示用
  String _displayUnit({int unit}){
    print(unit);
    if(unit == 1){
      return '人分';
    }
    if(unit == 2){
      return '個分';
    }
    if(unit == 3){
      return '枚分';
    }
    if(unit == 4){
      return '杯分';
    }
    if(unit == 5){
      return '皿分';
    }
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
            leading: closeBtn(),
            elevation: 0.0,
            title: Center(
              child: Text( 'レシピ編集',
                style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                ),
              ),
            ),
            actions: <Widget>[
              completeBtn(),
            ],
          ),
          body: scrollArea()
        );
  }

  //レシピ編集
  Widget scrollArea(){
    return Container(
//      key: GlobalKey(),
      child: SingleChildScrollView(
//        key: GlobalKey(),
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
            children:
            _type == 3
            ? <Widget>[
              titleArea(),            //タイトル
              titleInputArea(),       //タイトル入力欄
              quantityArea(),         //分量
              quantityInputArea(),    //分量単位入力欄
              timeArea(),             //調理時間
              timeInputArea(),        //調理時間入力欄
//              line(),
            ]
           : <Widget>[
              titleArea(),            //タイトル
              titleInputArea(),       //タイトル入力欄
              descriptionArea(),      //説明メモ
              descriptionInputArea(), //説明メモ入力欄
              quantityArea(),         //分量
              quantityInputArea(),    //分量単位入力欄
              timeArea(),             //調理時間
              timeInputArea(),        //調理時間入力欄
//              line(),
            ],
          ),
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
            children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('タイトル',style: TextStyle(
                color: Colors.white,
                  fontSize: 15,
              ),),
            ),
          ],
          ),
        ),
      );
  }

  //タイトル入力欄
  Widget titleInputArea(){
    return
      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.98,
          child: TextField(
            controller: _title,
            autofocus: false,
            decoration: const InputDecoration(
              hintText: 'レシピ名を入力',
                border: InputBorder.none,
            ),
          ),
        ),
      );
  }

  //説明めも
  Widget descriptionArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('説明/メモ',style: TextStyle(
                color: Colors.white,
                  fontSize: 15,
              ),),
            ),
          ],
          ),
        ),
      );
  }

  //説明めも入力欄
  Widget descriptionInputArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.15,
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.98,
          child: TextField(
            controller: _description,
            autofocus: false,
            minLines: 5,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'メモを入力',
                border: InputBorder.none,
            ),
          ),
        ),
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
                padding: EdgeInsets.all(10),
                child: Text('分量',style: TextStyle(
                  color: Colors.white,
                    fontSize: 15,
                ),),
              ),
            ],
          ),
        ),
      );
  }

  //分量単位入力欄
  Widget quantityInputArea(){
    return
      SizedBox(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.98,
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.white,
                child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextField(
                      controller: _quantity,
                      autofocus: false,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [BlacklistingTextInputFormatter(new RegExp('[\\-|\\ ]'))],
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.035,
                    width: MediaQuery.of(context).size.width * 0.2,
                    child: Padding(padding: EdgeInsets.only(top: 10),
                      child: Text('${_displayUnit(unit: _unit)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                height:  MediaQuery.of(context).size.height * 0.08,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context,index) {
                      return Row(
                        children: <Widget>[
                          RoundedButton(
                            title: '${_displayUnit(unit: index + 1)}',
//                            splashColor: Colors.redAccent,
                            buttonColor: _unit == index + 1 ? Colors.orangeAccent :Colors.amber[100 * (1 % 9)],
                            splashColor: Colors.orangeAccent,
                            onPressed: () {
                              setState(() {
                                  _unit = index + 1;
                              });
                            },
                          ),
                          SizedBox(width: 2.0,)
                        ],
                      );
                    }
                ),
              ),
            ],
          ),
        ),
      );
  }

  //調理時間
  Widget timeArea(){
    return
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.05,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.deepOrange[100 * (2 % 9)],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: Text('調理時間',style: TextStyle(
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

  //調理時間入力欄
  Widget timeInputArea(){
    return
      SizedBox(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width * 0.98,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child:
                TextField(
                  controller: _time,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: InputBorder.none
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.2,
                child: Text('分',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
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

  //保存ボタン
  Widget completeBtn(){
    return Container(
      width: MediaQuery.of(context).size.width * 0.25,
      child: Padding(
        padding: EdgeInsets.all(10),
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
    );
  }

  //ｘボタン
  Widget closeBtn(){
    return IconButton(
      icon: const Icon(Icons.close,color: Colors.white,size: 30,),
      onPressed: (){
        Navigator.pop(context);
      },
    );
  }
}
