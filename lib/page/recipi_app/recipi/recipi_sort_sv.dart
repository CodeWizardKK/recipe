//import 'dart:io';
//import 'dart:async';
//
//import 'package:flutter/cupertino.dart';
//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:recipe_app/store/display_state.dart';
//import 'package:recipe_app/services/database/DBHelper.dart';
//import 'package:recipe_app/model/Myrecipi.dart';
//import 'package:recipe_app/model/MstFolder.dart';
//import 'package:recipe_app/model/MstTag.dart';
//
//
//class RecipiSort extends StatefulWidget{
//
//  @override
//  _RecipiSortState createState() => _RecipiSortState();
//}
//
//class _RecipiSortState extends State<RecipiSort>{
//
//  DBHelper dbHelper;
//  int _selectedID;              //編集するID
//  int _type;                    //種別
//  List<MstFolder> _folders;     //DBから取得したレコードを格納
//  List<MstTag> _Mtags;     //DBから取得したレコードを格納
//  String _name; //モーダルにて入力した値
//
//
//  @override
//  void initState() {
//    super.initState();
//    dbHelper = DBHelper();
//    this._folders = [];
//    this._Mtags = [];
////    this._folder.id = -1;
////    //idを取得
////    _selectedID = Provider.of<Display>(context, listen: false).getId();
////    print('ID:${_selectedID}');
////    //レシピ種別を取得
////    this._type = Provider.of<Display>(context, listen: false).getType();
////    print('レシピ種別:${this._type}');
////    //新規投稿の場合
////    if(_selectedID == -1){
////      print('new!!!!');
////      TitleForm titleform = Provider.of<Display>(context, listen: false).getTitleForm();
////      //初めて開かれた場合
////      if(titleform == null){
////        //TitleFormの作成
////        TitleForm newTitleForm = TitleForm(title:'',description:'',unit:1,quantity: 1,time: 0);
////        //TitleForm
////        Provider.of<Display>(context, listen: false).setTitleForm(newTitleForm);
////        return;
////      }
////    }else{
////      //更新の場合
////      print('update!!!!');
////    }
//  }
//
//  //一覧リストへ遷移
//  void _onList(){
////    var state = _getBackState();
//    Provider.of<Display>(context, listen: false).setState(-3);
////    _init();
//  }
//
//  //初期化処理
//  void _init(){
//    this._name = '';
//    //リセット処理
////    Provider.of<Display>(context, listen: false).reset(); //編集フォーム
//  }
//
//  //モーダルの保存するボタン押下時処理
//  void _onModalSubmit() async {
//    if(this._name.isEmpty){
//      return;
//    }
//    //入力内容をセットする
//    MstFolder folder = MstFolder(id:-1,name: this._name);
//    //登録処理
//    await dbHelper.insertMstFolder(folder);
//    await dbHelper.getMstFolders().then((item){
//      setState(() {
//        this._folders.clear();
//        this._folders.addAll(item);
//      });
//    });
//    //最新のフォルダをstoreに保存
//    Provider.of<Display>(context, listen: false).setFolder(this._folders);
//  }
//
//  //保存する押下時処理
//  void _onSubmit() async {
//    //レシピIDに紐づく、フォルダIDとtabを更新する
////      //フォルダーIDを取得
////      Myrecipi recipi = Provider.of<Detail>(context, listen: false).getRecipi();
////      //myrecipiテーブルへ更新
////      Myrecipi myrecipi = Myrecipi
////        (
////          id: this._selectedID
//////          ,type: this._type
//////          ,thumbnail: thumbnail
//////          ,title: titleForm.title
//////          ,description: titleForm.description
//////          ,quantity: titleForm.quantity
//////          ,unit: titleForm.unit
//////          ,time: titleForm.time
////          ,folder_id: recipi.folder_id
////      );
////      await dbHelper.updateMyRecipi(myrecipi);
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(-3);
////      //初期化
////      Provider.of<Display>(context, listen: false).reset(); //編集フォーム
//  }
//
//  //テキスト欄入力
//  void _onChange(String name){
//    print('###入力内容:${name}');
//
//    setState(() {
//      this._name = name;
//    });
//  }
//
//  //フォルダリストエリア
//  Column _createList({int type}){
//    List<Widget> column = new List<Widget>();
//    var list = [];
//    setState(() {
//      if(type == 1){
//        this._folders = Provider.of<Display>(context, listen: false).getFolder();
//        list = this._folders;
//      }else{
//        this._Mtags = Provider.of<Display>(context, listen: false).getMstTag();
//        list = this._Mtags;
//      }
//    });
//    //材料リストを展開する
//    for(var i=0; i < this._folders.length; i++){
//      column.add(
//          SizedBox(
//            height: MediaQuery.of(context).size.height * 0.06,
//            width: MediaQuery.of(context).size.width,
//            child: Container(
//              color: Colors.white,
//              child: InkWell(
//                  child: Row(
////                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                    children: <Widget>[
//                      Container(
//                        padding: EdgeInsets.all(5),
//                        child: SizedBox(
//                          height: 50,
//                          width: 50,
//                          child: Container(
//                            color: Colors.grey,
//                            child: Icon(Icons.folder_open,color: Colors.white,size: 30,),
//                          ),
//                        ),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.65,
//                        padding: EdgeInsets.all(5),
//                        child: Text('${_folders[i].name}',
//                          maxLines: 1,
//                          style: TextStyle(
//                              fontSize: 15,
////                              fontWeight: FontWeight.bold
//                          ),),
//                      ),
//                      Container(
//                        width: MediaQuery.of(context).size.width * 0.1,
//                        padding: EdgeInsets.all(5),
//                      ),
//                      Container(
//                          width: MediaQuery.of(context).size.width * 0.05,
//                          padding: EdgeInsets.all(5),
//                          child: Icon(Icons.check_circle_outline,color: Colors.grey,size: 30,)
//                      ),
//                    ],
//                  ),
//                  onTap: (){
//                    print('フォルダーIDを取得${_folders[i].id}');
//                  }
//              ),
//            ),
//          ),
//      );
//      column.add(
//        Divider(
//            color: Colors.grey,
//            height: 0.5,
//            thickness: 0.5,
//        ),
//      );
//    }
//    // + 新しいフォルダ ボタン
//    column.add(
//      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.06,
//        width: MediaQuery.of(context).size.width,
//        child: Container(
//          color: Colors.white,
//          child: InkWell(
//              child: Row(
////                crossAxisAlignment: CrossAxisAlignment.center,
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: <Widget>[
//                  Container(
////                    padding: EdgeInsets.all(10),
//                    child: Icon(Icons.add_circle_outline,color: Colors.cyan,)
//                  ),
//                  Container(
//                    padding: EdgeInsets.all(10),
//                    child: Text('新しいフォルダ',style: TextStyle(
//                        color: Colors.cyan,
//                        fontSize: 20,
//                        fontWeight: FontWeight.bold
//                    ),),
//                  ),
//                ],
//              ),
//              onTap: (){
//                _onAdd();
////                _changeEditType(editType: 2); //材料
//              }
//          ),
//        ),
//      ),
//    );
////    print('###column:${column}');
//    return Column(
//      children: column,
//    );
//  }
//
////新しいフォルダ、新しいタグ
//  Future<void> _onAdd(){
//    setState(() {
//      this._name = '';
//    });
//    print('①${this._name}');
//    return showDialog(
//        context: context,
//        builder: (context){
//          return AlertDialog(
//            backgroundColor: Colors.white,
//            title: Row(
//              mainAxisAlignment: MainAxisAlignment.start,
//              children: <Widget>[
//                Padding(
//                  padding: EdgeInsets.only(right: 20),
//                  child: IconButton(
//                      icon: Icon(Icons.close,color: Colors.cyan,size: 30,),
//                    onPressed: (){
//                      Navigator.pop(context);
//                    },
//                  ),
//                ),
//                Text('新しいフォルダ',
//                  style: TextStyle(
//                      color: Colors.cyan
//                  ),
//                ),
//              ],
//            ),
//            content: Container(
//              width: MediaQuery.of(context).size.width,
//              color: Colors.white,
//              child: TextField(
//                    onChanged: _onChange,
//                  style: const TextStyle(fontSize: 15.0, color: Colors.black,),
//                  minLines: 1,
//                  maxLines: 1,
//                  decoration: InputDecoration(
//                    hintText:"例）お肉のおかず",
//                    border: OutlineInputBorder(
//                      borderSide: const BorderSide(color: Colors.white, width: 20.0),
//                        borderRadius: BorderRadius.circular(0.0)
//                    ),
//                  ),
//              ),
//            ),
//            actions: <Widget>[
//              Container(
//                width: 90,
//                child: Padding(
//                  padding: EdgeInsets.all(10),
//                  child: FlatButton(
//                    color: Colors.cyan,
//                    child: Text('保存',
//                      style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 15,
//                      ),
//                    ),
//                    onPressed: (){
//                      Navigator.pop(context);
//                      _onModalSubmit();
//                    },
//                  ),
//                ),
//              ),
//          ],
//          );
//        });
//  }
//
//
//  //各エリアの追加ボタン押下
//  void _changeEditType({editType,index}){
//    Provider.of<Display>(context, listen: false).setEditType(editType);
//    if(editType > 1){
//      if(index != null){
//        Provider.of<Display>(context, listen: false).setEditIndex(index);
//      }
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(
//        backgroundColor: Colors.cyan,
//        leading: closeBtn(),
//        elevation: 0.0,
//        title: Center(
//          child: Text('レシピの整理',
//            style: TextStyle(
//              color: Colors.white,
//              fontSize: 25,
//              fontWeight: FontWeight.bold,
//              fontFamily: 'Roboto',
//            ),
//          ),
//        ),
//        actions: <Widget>[
//          completeBtn(),
//        ],
//      ),
//      body: scrollArea(),
//    );
//  }
//
//  //完了ボタン
//  Widget completeBtn(){
//    return Container(
//      width: 90,
//      child: Padding(
//        padding: EdgeInsets.all(10),
//        child: FlatButton(
//          color: Colors.white,
////          shape: RoundedRectangleBorder(
////            borderRadius: BorderRadius.circular(10.0),
////          ),
//          child: Text('保存',
//            style: TextStyle(
//              color: Colors.cyan,
//              fontSize: 15,
//            ),
//          ),
//          onPressed: (){
//            _onSubmit();
//          },
//        ),
//      ),
//    );
//  }
//
//  //閉じるボタン
//  Widget closeBtn(){
//    return IconButton(
//      icon: Icon( Icons.close,color: Colors.white,size: 30,),
//      onPressed: (){
//        _onList();
//      },
//    );
//  }
//
//  //レシピ編集
//  Widget scrollArea(){
//    return Container(
//      key: GlobalKey(),
//      child: SingleChildScrollView(
//        key: GlobalKey(),
////        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//        child: showForm(),
//      ),
//    );
//  }
//
//  //ページ全体
//  Widget showForm(){
//      return Container(
//        alignment: Alignment.center,
//        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.center,
//          children:<Widget>[
//            headerArea(type: 1), //フォルダに移動
//            line(),
//            listArea(type: 1), //フォルダリスト
//            line(),
//            headerArea(type: 2), //フォルダに移動
//            line(),
//         ]
//          ),
//      );
//  }
//
//  //線
//  Widget line(){
//    return Divider(
//      color: Colors.grey,
//      height: 0.5,
//      thickness: 0.5,
//    );
//  }
//
//  //フォルダ
//  Widget headerArea({int type}){
//    return Consumer<Display>(
//        builder: (context,Display,_) {
//    return
//      SizedBox(
//        height: MediaQuery.of(context).size.height * 0.05,
//        width: MediaQuery.of(context).size.width,
//        child: Container(
//          color: Colors.white30,
//          child: Row(
//            mainAxisAlignment: MainAxisAlignment.spaceBetween,
//            children: <Widget>[
//              Container(
//                padding: EdgeInsets.all(10),
//                child: Text(type == 1 ? 'フォルダに移動' :'タグをつける', style: TextStyle(
//                    fontSize: 15,
//                    fontWeight: FontWeight.bold
//                ),),
//              ),
//            ],
//          ),
//        ),
//      );
//    }
//    );
//  }
//
//  //フォルダ追加
//  Widget listArea({int type}){
//    return Container(
//      child: _createList(type: type),
//    );
//  }
//
//}