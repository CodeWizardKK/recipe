import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/model/edit/Titleform.dart';

class EditTitle extends StatefulWidget {

  @override
  _EditTitleState createState() => _EditTitleState();
}

class _EditTitleState extends State<EditTitle>{

//  TitleForm titleForm;
  final _title = TextEditingController();        //タイトル
  final _description = TextEditingController();  //説明/メモ
  final _quantity = TextEditingController();     //分量
  int _unit;                                     //単位（1：人分、2：個分、3：枚分、4：杯分、5：皿分）
  final _time = TextEditingController();         //調理時間

  @override
  void initState() {
    super.initState();
    TitleForm item = Provider.of<Display>(context, listen: false).getTitleForm();
//    print('set!!!!!');
    this._title.text = item.title;
    this._description.text = item.description;
    this._quantity.text = item.quantity.toString();
    this._unit = item.unit;
    this._time.text = item.time.toString();
  }

  //編集画面の状態の切り替え
  void _changeEditType(editType){
    Provider.of<Display>(context, listen: false).setEditType(editType);
  }

  //保存ボタン押下時処理
  void _onSubmit(){
    TitleForm titleForm = TitleForm(title: _title.text,description: _description.text,quantity: intParse(_quantity.text),unit: _unit,time: intParse(_time.text));
    Provider.of<Display>(context, listen: false).setTitleForm(titleForm);
  }

  //string => int 変換
  int intParse(String text){
    if(text.isEmpty){
      return 0;
    }
    return int.parse(text);

  }

  //単位 表示用
  String _displayUnit(){
    if(_unit == 1){
      return '人分';
    }
    if(_unit == 2){
      return '個分';
    }
    if(_unit == 3){
      return '枚分';
    }
    if(_unit == 4){
      return '杯分';
    }
    if(_unit == 5){
      return '皿分';
    }
  }

  //単位の変更処理
  Future<void> _changeUnit() async{
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height / 3,
          child: CupertinoPicker(
            onSelectedItemChanged: (value) {
              setState(() {
                _unit = ++value;
              });
            },
            itemExtent: 40.0,
            children: <Widget>[
              Center(child: Text("人分")),
              Center(child: Text("個分")),
              Center(child: Text("枚分")),
              Center(child: Text("杯分")),
              Center(child: Text("皿分")),
            ],
          ),
        );
      });
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
              titleArea(),            //タイトル
              titleInputArea(),       //タイトル入力欄
              descriptionArea(),      //説明メモ
              descriptionInputArea(), //説明メモ入力欄
              quantityArea(),         //分量
              quantityInputArea(),    //分量単位入力欄
              timeArea(),             //調理時間
              timeInputArea(),        //調理時間入力欄
              line(),
            ],
          ),
        ),
    );
  }

  //タイトル
  Widget titleArea(){
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
              child: Text('タイトル',style: TextStyle(
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

  //タイトル入力欄
  Widget titleInputArea(){
    return
      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          width: 400,
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
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text('説明/メモ',style: TextStyle(
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

  //説明めも入力欄
  Widget descriptionInputArea(){
//    print('####width:${MediaQuery.of(context).size.width}');
    return
      SizedBox(
        height: 130,
//        width: _getWidth(MediaQuery.of(context).size.width),
        child: Container(
          width: 400,
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

  //分量単位入力欄
  Widget quantityInputArea(){
    return
      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _quantity,
                  autofocus: false,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 100,
                child: InkWell(
                  child: Padding(padding: EdgeInsets.only(top: 10),
                    child: Text('${_displayUnit()}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: (){
                    _changeUnit();
                  },
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
        height: 50,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.grey,
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
//        height: MediaQuery.of(context).size.height * 0.08,
//        width: MediaQuery.of(context).size.width,
        child: Container(
          width: 400,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 300,
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
                width: 100,
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
