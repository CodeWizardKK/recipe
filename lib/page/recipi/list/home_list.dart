import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_app/services/database/database.dart';

class HomeList extends StatefulWidget{

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList>{
//  File imageFile;
//  final _picker = ImagePicker();
  List<My> images;
  MyDatabase db = MyDatabase();

  @override
  void initState() {
    super.initState();
    images = [];
    init();
//    selected();
  }

  Future<void> init()async{
    await db.initDB();
    await selected();

  }

  Future<void> selected() async{
    await db.getAllMys().then((imgs){
      setState(() {
        images.addAll(imgs);
      });
    });
    print('#####images:${images}');
    print('#####imageslength:${images.length}');
  }

  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
  }

  gridView(){
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        children: images.map((my){
          return Text('${my.id}');
//          return imageFromBase64String(my.topImage);
//        }).toList(),
        }).toList(),
      ),
    );
  }

  Image imageFromBase64String(String base64String){
    return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.fill,
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
//      body: FutureBuilder(
//        future: widget.db.initDB(),
//        builder: (BuildContext context,snapshot){
//          if(snapshot.connectionState == ConnectionState.done){
//            return _showList(context);
//          }else{
//            return Center(
//              child: CircularProgressIndicator(),
//            );
//          }
//        },
//      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Flexible(
              child: gridView(),
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }

  //テーブルの一覧表示
  _showList(BuildContext context){
    return FutureBuilder(
      future: db.getAllMys(),
      initialData: List<My>(),
      builder: (BuildContext context, AsyncSnapshot<List<My>> snapshot){
        debugPrint('######snapshot.hasData;;;${snapshot.hasData}');
//        if(snapshot.hasData){
          return ListView(
            children: <Widget>[
              for (My my in snapshot.data)
                ListTile(
                  onTap: () {
                    print('###my:${my}');
//                    _clickTask(task);
                  },
                  title: Text('${my.id}'),
//                  leading: Icon(
//                      my.completed
//                          ? Icons.check_box
//                          : Icons.check_box_outline_blank
//                  ),
                )
            ],
          );
//        } else {
//          return Center(
//            child: Text('Add tasks!!!!!!!!!!'),
//          );
//        }
      },
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