import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:intl/intl.dart';

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
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit({int selectedId,int type}){
    //編集画面へ遷移
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    //ごはん日記
    if(type == 4){
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      Provider.of<Edit>(context, listen: false).setDate(dateString);
      //リセット処理
      Provider.of<Edit>(context, listen: false).reset(); //編集フォーム
      //ごはん日記をset
      Provider.of<Display>(context, listen: false).setCurrentIndex(2);
     //レシピ
    }else{
      //レシピ種別をset
      Provider.of<Display>(context, listen: false).setType(type);
      //材料をreset
      Provider.of<Display>(context, listen: false).resetIngredients();
      //レシピをset
      Provider.of<Display>(context, listen: false).setCurrentIndex(1);
    }
    //戻る画面をセット
    Provider.of<Display>(context, listen: false).setBackScreen(3);
    //2:編集状態をset
    Provider.of<Display>(context, listen: false).setState(2);

  }

  //レシピリストのフォルダアイコンtap時処理
  void _onFolderTap({int type}){
    String title = '';
    // 3:フォルダの管理(menu)
    if(type == 3){
      //タイトルセット
      title = 'フォルダの管理';
    }else{
    // 4:タグの管理(menu)
      //タイトルセット
      title = 'タグの管理';
    }
    //フォルダ、タグ管理画面でのタイトルをset
    Provider.of<Display>(context, listen: false).setSortTitle(title);
    //フォルダ、タグ管理画面での表示タイプをset
    Provider.of<Display>(context, listen: false).setSortType(type);
    //戻る画面をセット
    Provider.of<Display>(context, listen: false).setBackScreen(3);
    //レシピをset
    Provider.of<Display>(context, listen: false).setCurrentIndex(1);
    //3:フォルダ、タグ管理画面をset
    Provider.of<Display>(context, listen: false).setState(3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.cyan,
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
        padding: EdgeInsets.only(top: 20),
        width: MediaQuery.of(context).size.width,
        child:Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              child: Container(
                color: Colors.white70,
                padding: EdgeInsets.all(15),
                width: MediaQuery.of(context).size.width * 0.25,
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
                width: MediaQuery.of(context).size.width * 0.25,
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
                width: MediaQuery.of(context).size.width * 0.25,
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
                width: MediaQuery.of(context).size.width * 0.25,
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
                      _onEdit(selectedId:-1,type: 4);
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

  //ドロワーナビゲーション
  Widget drawerNavigation(){
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            color: Colors.cyan,
            child: ListTile(
              title: Center(
                child: Text('設定',
                  style: TextStyle(
                      color:Colors.white,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
//              subtitle: Text(''),
            ),
          ),
          ListTile(
            leading: Icon(Icons.folder_open,color: Colors.cyan,),
            title: Text('フォルダの管理',
              style: TextStyle(
//                fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              _onFolderTap(type: 3);
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
          ListTile(
            leading: Icon(Icons.local_offer,color: Colors.cyan,),
            title: Text('タグの管理',
              style: TextStyle(
//                  fontWeight: FontWeight.bold
              ),
            ),
            onTap: () {
              _onFolderTap(type: 4);
            },
          ),
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
        ],
      ),
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