import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/recipi/recipi_item.dart' as recipiItemRepo;

class RecipiDetail extends StatefulWidget{
  _RecipiDetailState createState() => _RecipiDetailState();
}

class _RecipiDetailState extends State<RecipiDetail>{

  bool _isLoading = true;    //通信中:true(円形のグルグルのやつ)
  String _errorMessage = ''; //await関連のエラーメッセージ
  var _selectedItem = {}; //リストから選択されたレコード

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getItem();

  }

  Future<void> getItem() async{
    var option = {};
    var result;

    option['id'] = Provider.of<Display>(context, listen: false).getId();
    try{
      //該当レコード取得処理の呼び出し
      result = await recipiItemRepo.get(option);
    }catch(e){
      //エラー処理
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        //ここでエラー画面へ遷移する処理を追加(state=9にセットする)
//        Provider.of<Display>(context, listen: false).setState(9);
      });
    }
//    Provider.of<Display>(context, listen: false).setSelectItem(result);
    setState(() {
      _selectedItem = result;
      _isLoading = false;
    });

  }


  //レシピリストへ戻るボタン押下時処理
  void onList(){
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //削除処理
  void onDelete(){
   //該当レコード削除処理(IDをpushする)

   //レシピリストへ戻る
   this.onList();
  }

  //レシピの編集ボタン押下時処理
  void onEdit(){
//    print('selectId[${id}]');
//    //idをset
//    Provider.of<Display>(context, listen: false).setId(id);
//    //新規投稿以外の場合
//    if(id != -1){
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(2);
//    }else{
      //編集画面へ遷移
      Provider.of<Display>(context, listen: false).setState(1);
//    }
  }

  Future<void> _showDeleteDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('確認'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('削除してもよろしいですか？'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          title:FlatButton(
            child: Row(
              children: <Widget>[
                Icon(Icons.arrow_back_ios,color: Colors.grey,),
                Text('レシピリスト',
                  style: TextStyle(
                    color: Colors.grey
                  ),
                ),
              ],
            ),
            onPressed: (){
              onList();
            },
          ),
      ),
      //フッター
      persistentFooterButtons: <Widget>[
        //削除アイコン
        Padding(
          padding: EdgeInsets.only(right: 150),
          child: IconButton(icon:Icon(Icons.delete,size: 30,),
            onPressed: (){
              _showDeleteDialog();
            },),
        ),
        //レシピを編集ボタン
        Padding(
          padding: EdgeInsets.only(right: 10),
          child:
          FlatButton(
            color: Colors.redAccent,
            child: Text('レシピの編集',
              style: TextStyle(color: Colors.white),),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            onPressed: (){
              onEdit();
            },
          )
        ),],
      body:Stack(
        children: <Widget>[
          ScrollArea(),
          showCircularProgress(),
        ],
      ),
    );
  }

//  Widget showDetail(){
//    return Column(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
//      children: <Widget>[
//        ScrollArea(),
//        footerArea(),
//      ],
//    );
//  }

  //詳細ページ全般
  Widget ScrollArea(){
    return Container(
      child:SingleChildScrollView(
        child:Padding(
          padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            imageArea(),
            titleArea(),
            line(),
            ContentArea(),
          ],
        ),
        ),
      ),
    );
  }

//  Widget footerArea(){
//    return Padding(
//      padding: const EdgeInsets.only(top: 50.0),
//      child: SafeArea(
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//          children: <Widget>[
//            Icon(Icons.camera_alt)
//          ],
//        ),
//      ),
//    );
//  }

  Widget imageArea(){
    return
      _selectedItem['avatar'] == null
        ? Container()
        : Container(
        width: 350.0,
        height: 400.0,
        decoration: BoxDecoration(
//          shape: BoxShape.circle,
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage('${_selectedItem['avatar']}'),
          ),
        ),
      );
  }

  Widget titleArea(){
    return Container(
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(5),
      child: Text('鹿ラグーとバターとゴマのパスタパスタ',
        style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue
        ),
      ),
    );
  }

  Widget ContentArea(){
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(5),
          child: Text('レシピmemo',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.all(5),
          padding: EdgeInsets.all(5),
          child:Text('テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。テキストが入ります。')
        ),
      ],
    );
  }

  Widget line(){
    return Divider(
        color: Colors.grey
    );
  }

  //null参照時に落ちない用、flutterで用意されてるを実装
  //CircularProgressIndicator() => 円形にグルグル回るタイプのやつ
  Widget showCircularProgress() {
    return
      _isLoading
      //通信中の場合
          ? Center(child: CircularProgressIndicator())
      //それ以外の場合
          : Container(height: 0.0,width: 0.0,);
  }
}