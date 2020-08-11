import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';

class HomeList extends StatefulWidget{

  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList>{

  @override
  void initState() {
    super.initState();
  }

  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
  }

  //編集処理
  void _onEdit({int selectedId,int type}){
    //編集画面へ遷移
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    //レシピ種別をset
    Provider.of<Display>(context, listen: false).setType(type);
    //材料をreset
    Provider.of<Display>(context, listen: false).resetIngredients();
    //
    Provider.of<Display>(context, listen: false).setIsHome(true);
    //2:編集状態をset
    Provider.of<Display>(context, listen: false).setState(2);
    //レシピをset
    Provider.of<Display>(context, listen: false).setCurrentIndex(1);

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
      body: Container(
        width: MediaQuery.of(context).size.width,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.all(15),
                width: 100,
                height: 100,
                child: InkWell(
                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.photo_album,size: 40,),
                      Text('写真レシピ',
                        style: TextStyle(
                            fontSize: 12
                        ),),
                      Text('を追加',
                        style: TextStyle(
                            fontSize: 12
                        ),),
                    ],
                  ),
                  onTap:(){
                    print('写真レシピを追加');
                    _onEdit(selectedId:-1,type: 1);
                  }
                ),
              ),
            ),
            SizedBox(
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.all(15),
                width: 100,
                height: 100,
                child: InkWell(
                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.description,size: 40,),
                      Text('MYレシピ',
                        style: TextStyle(
                            fontSize: 12
                        ),),
                      Text('を追加',
                        style: TextStyle(
                            fontSize: 12
                        ),),
                    ],
                  ),
                  onTap:(){
                    print('MYレシピを追加');
                    _onEdit(selectedId:-1,type: 2);
                  }
                ),
              ),
            ),
            SizedBox(
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.all(15),
                width: 100,
                height: 100,
                child: InkWell(
                    child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.import_contacts,size: 40,),
                        Text('ごはん日記',
                          style: TextStyle(
                              fontSize: 12
                          ),),
                        Text('を追加',
                          style: TextStyle(
                              fontSize: 12
                          ),),
                      ],
                    ),
                    onTap:(){
                      print('ごはん日記を追加');
                    }
                ),
              ),
            ),
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