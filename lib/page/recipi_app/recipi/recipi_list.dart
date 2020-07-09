import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/recipi/recipi_list.dart' as recipiListRepo;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../services/database/DBHelper.dart';
import '../../../model/Myrecipi.dart';

class RecipiList extends StatefulWidget{

  @override
  _RecipiListState createState() => _RecipiListState();
}

class _RecipiListState extends State<RecipiList>{

  DBHelper dbHelper;
  List<Myrecipi> images; //DBから取得したレコードを格納

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DBHelper();
    refreshImages(); //レコードリフレッシュ
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  refreshImages(){
    //レコード取得
    dbHelper.getMyRecipis().then((imgs){
      setState(() {
        images.clear();
        images.addAll(imgs);
        for(var i=0;i < images.length; i++){
          print('images[${i}]ID:${images[i].id},NAME:${images[i].topImage}');
        }
      });
    });
  }

  void _changeBottomNavigation(index){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
  }

//  gridView(){
//    return Padding(
//      padding: EdgeInsets.all(5.0),
//      child: GridView.count(
//        crossAxisCount: 2,
//        childAspectRatio: 1.0,
//        mainAxisSpacing: 4.0,
//        crossAxisSpacing: 4.0,
//        children:images.map((myrecipi){
//          return imageFromBase64String(myrecipi.topImage);
//        }).toList(),
//      ),
//    );
//  }
//
//  Image imageFromBase64String(String base64String){
//    return Image.memory(
//        base64Decode(base64String),
//        fit: BoxFit.fill,
//    );
//  }

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

//  //検索処理
//  void _search(String searchText){
//    _state['search'] = true;
//
//    _searchData.clear(); //該当データのリセット
//    _data = _originData; //該当データを初期データでリセット
//
////    print('###検索内容:${searchText}');
//
//    for(var i=0; i<_data.length;i++){
//      String title = _data[i]['title'];
//      if(title.toLowerCase().contains(searchText.toLowerCase())) {
//        setState(() {
//          _searchData.add(_data[i]);
//        });
//      }
//    }
////    print('####検索結果:${_searchData}');
//    setState(() {
//      _data = _searchData;
//    });
//
//  }

  Future<void> _onAdd() async {
    return showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
//          title: const Text('Choose Options'),
//          message: const Text('Your options are '),
            actions: <Widget>[
              CupertinoActionSheetAction(
                child: const Text('MYレシピを追加'),
                onPressed: () {
                  Navigator.pop(context);
                  _onEdit(-1);
                },
              ),
              CupertinoActionSheetAction(
                child: const Text('写真レシピを追加'),
                onPressed: () {
                  Navigator.pop(context);
                  _onEdit(-1);
                },
              )
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('キャンセル'),
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
            )
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: menuBtn(),
        elevation: 0.0,
        title: Center(
          child: const Text('レシピ',
            style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          checkBtn(),
          addBtn(),
        ],
      ),
      body:showList(),
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  //メニューボタン
  Widget menuBtn(){
    return IconButton(
      icon: const Icon(Icons.list,color: Colors.white,size:30,),
      onPressed: (){
//        _onList();
      },
    );
  }

  //チェックボタン
  Widget checkBtn(){
    return IconButton(
      icon: const Icon(Icons.check_circle_outline,color: Colors.white,size:30),
      onPressed: (){
//        _onList();
      },
    );
  }

  //追加ボタン
  Widget addBtn(){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onAdd();
//        _onEdit(-1);
      },
    );
  }

  //ナビゲーション
  Widget bottomNavigationBar(){
    return Consumer<Display>(
        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
//      backgroundColor: Colors.redAccent,
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.black87,
            unselectedItemColor: Colors.black26,
            iconSize: 30,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                title: const Text('ホーム'),
//          backgroundColor: Colors.redAccent,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.import_contacts),
                title: const Text('レシピ'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.date_range),
                title: const Text('ごはん日記'),
//          backgroundColor: Colors.blue,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.image),
                title: const Text('アルバム'),
//          backgroundColor: Colors.blue,
              ),
            ],
            onTap: (index){
              _changeBottomNavigation(index);
            },
          );
        }
    );
  }

  Widget showList(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
//              child: gridView(),
            child: ListView.builder(
                itemCount: images == null ? 0: images.length,
                itemBuilder: (BuildContext contect,int index){
                  return InkWell(
                    child: Card(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.10,
                        child: Row(
                          children: <Widget>[
                            images[index].topImage == null
                                ? Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 90.0,
                              child: const Icon(Icons.camera_alt,color: Colors.white,),
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            )
                                :Container(
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 90.0,
                              child: Image.memory(
                                base64Decode(images[index].topImage),
                                fit: BoxFit.fill,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: ListTile(
                                  title: Text('${images[index].id}'),
//                                    title: Text('あいうえおあいうえおあいうえおあいうえお'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onTap: (){
                      print('${images[index].topImage}');
                    },
                  );
                }
            ),
          )
        ],
      ),
    );
  }

  //ページ全体
//  Widget showList(){
//    return Stack(
//        key: GlobalKey(),
//      children: <Widget>[
//        scrollArea(),             //リスト全体
//        showCircularProgress(), //アクティビティインジケータ
//      ],
//    );
//  }

//  //検索・リスト
//  Widget scrollArea(){
//    return Container(
//        key: GlobalKey(),
//      child: SingleChildScrollView(
//        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
//        child: Column(
//          children: <Widget>[
//            searchArea(),//検索欄
//            listArea(),  //リスト
//          ],
//        ),
//      ),
//    );
//  }

//  //検索欄
//  Widget searchArea(){
//    return Row(
//      children: <Widget>[
//        Padding(
//          padding: const EdgeInsets.all(8.0),
//            child:
//            Container(
//              key: GlobalKey(),
//              width: MediaQuery.of(context).size.width * 0.80,
//              height: 35,
//              child: TextField(
//                onChanged: _search,
//                style: const TextStyle(fontSize: 15.0, color: Colors.grey,),
//                decoration: InputDecoration(
//          //                contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//                  prefixIcon: const Icon(Icons.search,size: 25,),
//                  hintText:"検索",
//                  contentPadding: const EdgeInsets.only(top: 10),
//                  border: OutlineInputBorder(
//                    borderSide: const BorderSide(color: Colors.grey, width: 32.0),
//                    borderRadius: BorderRadius.circular(15.0)
//                  ),
//            //                focusedBorder: OutlineInputBorder(
//            //                    borderSide: BorderSide(color: Colors.white, width: 32.0),
//            //                    borderRadius: BorderRadius.circular(15.0)
//            //                )
//                )
//              ),
//            ),
//        ),
////      Container(
////        width: 5,
////        height: 35,
////        child:
////        Padding(
////          padding: EdgeInsets.only(top: 5),
////          child:
////          IconButton(icon: Icon(Icons.close),iconSize: 30,)
////        ),
////      ),
//    ],
//    );
//  }

//  //レシピリスト
//  Widget listArea(){
//    return Container(
//      key: GlobalKey(),
//        child: SizedBox(
//          height: MediaQuery.of(context).size.height * 0.80,
//          child: ListView.builder(
//              itemCount: _data == null ? 0 :_data.length,
//              itemBuilder: (BuildContext context,int index){
//                return InkWell(
//                  key: GlobalKey(),
//                  child: Card(
//                    key: GlobalKey(),
//                    child: Container(
//                      key: GlobalKey(),
////                  padding: EdgeInsets.all(15.0),
//                      child: Row(
//                        children: <Widget>[
//                          _data[index]['media_path'] == null
//                            ? Container(
//                            key: GlobalKey(),
//                              width: 90.0,
//                              height: 90.0,
//                              child: const Icon(Icons.camera_alt,color: Colors.white,),
//                              decoration: const BoxDecoration(
//                                color: Colors.grey,
//                              ),
//                            )
//                            : Container(
//                            key: GlobalKey(),
//                              width: 90.0,
//                              height: 90.0,
//                              child:
////                              onImage(_data[index]['media_path']),
//                              CachedNetworkImage(
//                                key: GlobalKey(),
//                                imageUrl: '${_data[index]['media_path']}',
//                                progressIndicatorBuilder: (context, url, downloadProgress) =>
//                                    CircularProgressIndicator(value: downloadProgress.progress),
//                                errorWidget: (context, url, error) => Icon(Icons.error),
//                              ),
////                            decoration: BoxDecoration(
//////                            shape: BoxShape.circle, //表示する画像の形
////                              image: DecorationImage(
////                                fit: BoxFit.cover,
////                                image: NetworkImage(_data[index]['media_path']),
////                              ),
////                            ),
//                          ),
//                          Container(
//                          key: GlobalKey(),
//                            child: SizedBox(
//                              width: 230.0,
//                              child: ListTile(
//                                key: GlobalKey(),
//                                title: Text(_data[index]['title']),
////                              subtitle: Text(),
//                              ),
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                  onTap: (){
//                    _onDetail(_data[index]['id']);
//                  },
//                );
//              }
//          ),
//        ),
//      );
//  }

  //null参照時に落ちない用、flutterで用意されてるを実装
  //CircularProgressIndicator() => 円形にグルグル回るタイプのやつ
//  Widget showCircularProgress() {
//      return
//        _isLoading
//          //通信中の場合
//          ?  const Center(child: CircularProgressIndicator())
//          //それ以外の場合
//          : Container(
//              key: GlobalKey(),
//              height: 0.0,
//              width: 0.0,
//            );
//  }

}