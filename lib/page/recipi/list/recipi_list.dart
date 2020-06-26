import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/recipi/recipi_list.dart' as recipiListRepo;

class RecipiList extends StatefulWidget{
  _RecipiListState createState() => _RecipiListState();
}

class _RecipiListState extends State<RecipiList>{

  var _data;                 //リスト表示用データ
  var _isLoading = true;    //通信中:true(円形のグルグルのやつ)
  var _errorMessage = ''; //await関連のエラーメッセージ

  @override
  void initState() {
    super.initState();
    _getList();
  }

  //一覧情報取得処理
  void _getList() async{
    var result;
    try{
      //レシピリスト取得処理の呼び出し
//      result = await recipiListRepo.get(); //本番用
      result = await recipiListRepo.getLocal(); //mock用
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
    setState(() {
      _data = result['data'];
      _isLoading = false;
    });
  }

  void _onDetail(int selectedId){
//    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    //詳細画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);
  }

  void _onEdit(int selectedId){
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
//    //新規投稿以外の場合
//    if(id != -1){
//      //詳細画面へ遷移
//      Provider.of<Display>(context, listen: false).setState(2);
//    }else{
      //編集画面へ遷移
      Provider.of<Display>(context, listen: false).setState(2);
//    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0.0,
        title: Center(
          child: Text('レシピ',
            style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
      body: showList(),
      floatingActionButton: floatBtn(),
    );
  }

  //新規投稿ボタン
  Widget floatBtn(){
    return FloatingActionButton(
      onPressed: (){
        _onEdit(-1);
      },
      tooltip: 'Increment',
      child: Icon(Icons.create,),
      backgroundColor: Colors.orange,
    );
  }

  //ページ全体
  Widget showList(){
    return Stack(
      children: <Widget>[
        listArea(),             //リスト全体
        showCircularProgress(), //アクティビティインジケータ
      ],
    );
  }

  //レシピリスト
  Widget listArea(){
    return
      ListView.builder(
          itemCount: _data == null ? 0 :_data.length,
          itemBuilder: (BuildContext context,int index){
            return InkWell(
              child: Card(
                child: Container(
//                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      _data[index]['media_path'] == null
                        ? Container(
                        width: 90.0,
                        height: 90.0,
                        child: Icon(Icons.camera_alt,color: Colors.white,),
                        decoration: BoxDecoration(
                        color: Colors.grey,
                        ),
                      )
                        : Container(
                            width: 90.0,
                            height: 90.0,
                            decoration: BoxDecoration(
//                            shape: BoxShape.circle, //表示する画像の形
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: NetworkImage('${_data[index]['media_path']}'),
                              ),
                            ),
                          ),
                        Container(
                          child: SizedBox(
                            width: 230.0,
                            child: ListTile(
                              title: Text(_data[index]['title']),
//                              subtitle: Text(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              onTap: (){
                _onDetail(_data[index]['id']);
              },
            );
          }
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