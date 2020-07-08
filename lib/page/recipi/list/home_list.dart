import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'DBHelper.dart';
import 'Myrecipi.dart';

class HomeList extends StatefulWidget{

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList>{

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

  void _changeBottomNavigation(int index,BuildContext context){
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
      body: Center(
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
      ),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }


  Widget menuBtn(){
    return IconButton(
      icon: const Icon(Icons.list,color: Colors.white,size:30,),
      onPressed: (){
//        _onList();
      },
    );
  }

  Widget checkBtn(){
    return IconButton(
      icon: const Icon(Icons.check_circle_outline,color: Colors.cyan,size:30,),
      onPressed: null
    );
  }

  Widget addBtn(){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.cyan,size:30,),
      onPressed: null
    );
  }

  Widget bottomNavigationBar(BuildContext context){
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
              _changeBottomNavigation(index,context);
            },
          );
        }
    );
  }
}