import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_detail.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_sort.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/services/Common.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/model/diary/DisplayDiaryGroupDate.dart';
import 'package:intl/intl.dart';

import 'package:recipe_app/updater.dart';


class DiaryList extends StatefulWidget {

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList>{

  DBHelper dbHelper;
  Common common;
  List<DisplayDiaryGroupDate> _displayDiaryGroupDates = List<DisplayDiaryGroupDate>();

  List<DisplayDiaryGroupDate> _lazy = List<DisplayDiaryGroupDate>(); //遅延読み込み用リスト
  bool _isLoading = false;                               //true:遅延読み込み中
  int _currentLength = 0;                                //遅延読み込み件数を格納
  final int increment = 6; //読み込み件数

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    dbHelper = DBHelper();
    common = Common();
    //レコードリフレッシュ
    this.refreshImages();
    this._lazy.clear();
    //レシピリスト用遅延読み込み
    this._loadMore();
  }

  //レシピリスト用遅延読み込み
  Future _loadMore() async {
    print('+++++_loadMore+++++++');
    if(mounted){
      setState(() {
        _isLoading = true;
      });
    }

    await Future.delayed(const Duration(seconds: 1));
    for (var i = _currentLength; i < _currentLength + increment; i++) {
      if( i < this._displayDiaryGroupDates.length){
        if(mounted){
          setState(() {
            _lazy.add(_displayDiaryGroupDates[i]);
          });
        }
      }else{
        break;
      }

    }
    if(mounted){
      setState(() {
        _isLoading = false;
        _currentLength = _lazy.length;
      });
    }
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {

    List<Diary> diarys = [];
    List<DPhoto> photos = [];
    List<DRecipi> recipis = [];
    List<DisplayDiary> displayDiarys = [];
    this._displayDiaryGroupDates = [];

    //月別リストの取得
    var groups = await dbHelper.getDiaryMonth();

    for(var i = 0; i < groups.length; i++) {
      //月別ごとのごはん日記を取得
      await dbHelper.getDiaryGroupByMonth(groups[i].month).then((item) {
        setState(() {
          diarys.clear();
          diarys.addAll(item);
        });
        print(diarys.length);
      });
      for (var j = 0; j < diarys.length; j++) {
        //ご飯日記IDに紐づくレシピの取得
        await dbHelper.getDiaryRecipis(diarys[j].id).then((item) {
          setState(() {
            recipis.clear();
            recipis.addAll(item);
          });
        });

        //ご飯日記IDに紐づく写真の取得
        await dbHelper.getDiaryPhotos(diarys[j].id).then((item) {
          setState(() {
            photos.clear();
            photos.addAll(item);
          });
        });

        //取得したデータを元に表示用リスト生成
        DisplayDiary displayDiary = DisplayDiary(
          id: diarys[j].id,
          body: diarys[j].body,
          date: diarys[j].date,
          category: diarys[j].category,
          thumbnail: diarys[j].thumbnail,
          photos: this._getPhotos(photos),
          recipis: this._getRecipis(recipis),
        );

        displayDiarys.add(displayDiary);
      }

      DisplayDiaryGroupDate displayDiaryGroupDate = DisplayDiaryGroupDate(
        id:i + 1,
        month: groups[i].month,
        displayDiarys:_getDisplayDiarys(displayDiarys),
      );

      displayDiarys.clear();
      this._displayDiaryGroupDates.add(displayDiaryGroupDate);
      this._displayDiaryGroupDates.sort((a,b) => b.id.compareTo(a.id));
    }
//    for(var i = 0; i < this._displayDiaryGroupDates.length; i++){
//      print('######################################################');
//      print('id:${this._displayDiaryGroupDates[i].id},month:${this._displayDiaryGroupDates[i].month}');
//      for(var j = 0; j < this._displayDiaryGroupDates[i].displayDiarys.length; j++){
//        print('+++++++++++++++++++++++++++++++++++++++++++++');
//        print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].id}');
//        print('body:${this._displayDiaryGroupDates[i].displayDiarys[j].body}');
//        print('date:${this._displayDiaryGroupDates[i].displayDiarys[j].date}');
//        print('category:${this._displayDiaryGroupDates[i].displayDiarys[j].category}');
//        print('thumbnail:${this._displayDiaryGroupDates[i].displayDiarys[j].thumbnail}');
//        print('------ phtos ------------------');
//        for(var k = 0; k < this._displayDiaryGroupDates[i].displayDiarys[j].photos.length; k++){
//          print('-- [$k] --');
//          print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].id}');
//          print('diary_id:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].diary_id}');
//          print('no:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].no}');
//          print('path:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].path}');
//          print('---------');
//        }
//        print('------------------------');
//        print('------- recipis -----------------');
//        for(var k = 0; k < this._displayDiaryGroupDates[i].displayDiarys[j].recipis.length; k++){
//          print('-- [$k] --');
//          print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].id}');
//          print('diary_id:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].diary_id}');
//          print('no:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].recipi_id}');
//          print('image:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].image}');
//          print('---------');
//        }
//        print('------------------------');
//        print('+++++++++++++++++++++++++++++++++++++++++++++');
//      }
//    }
  }

  //写真リストを作成し返す
  List<DPhoto> _getPhotos(List<DPhoto> photos){
    List<DPhoto> item = List<DPhoto>();
    for(var i = 0; i < photos.length; i++){
      item.add(photos[i]);
    }
    return item;
  }

  //レシピリストを作成し返す
  List<DRecipi> _getRecipis(List<DRecipi> recipis){
    List<DRecipi> item = List<DRecipi>();
    for(var i = 0; i < recipis.length; i++){
      item.add(recipis[i]);
    }
    return item;
  }

  //月別ごはん日記を作成し返す
  List<DisplayDiary> _getDisplayDiarys(List<DisplayDiary> displayDiarys){
    List<DisplayDiary> item = List<DisplayDiary>();
    for(var i = 0; i < displayDiarys.length; i++){
      item.add(displayDiarys[i]);
    }
    return item;
  }

  //ナビゲーションバー
  void _changeBottomNavigation(int index,BuildContext context){
    Provider.of<Display>(context, listen: false).setCurrentIndex(index);
    //一覧リストへ遷移
    Provider.of<Display>(context, listen: false).setState(0);
  }

  //編集処理
  void _onEdit(int selectedId){
//    print('selectId[${selectedId}]');
      //Date　=> String
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      DisplayDiary diary = DisplayDiary(
          id: selectedId
          ,body: ''
          ,date: dateString
          ,category: 1
          ,thumbnail: 1
          ,photos: []
          ,recipis: []
      );
    this._showEdit(diary: diary);
  }

  void _showEdit({DisplayDiary diary}){
    //編集画面へ遷移
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => DiaryEdit(diary: diary),
          fullscreenDialog: true,
        )
    ).then((result) {
//      print('①${result}');
      //新規投稿の場合
      if(result != 'newClose'){
        //最新のリストを取得し展開する
        this.refreshImages();
        setState(() {
          //レシピリスト用遅延読み込みリセット
          this._lazy.clear();
          this._currentLength = 0;
        });
        //レシピリスト用遅延読み込み
        this._loadMore();
      }
    });
  }

  //曜日
  String _displayWeekday(weekday){
    if(weekday == 1){
      return '月';
    }
    if(weekday == 2){
      return '火';
    }
    if(weekday == 3){
      return '水';
    }
    if(weekday == 4){
      return '木';
    }
    if(weekday == 5){
      return '金';
    }
    if(weekday == 6){
      return '土';
    }
    if(weekday == 7){
      return '日';
    }
  }

  //分類
  String _displayCategory(category){
    if(category == 2){
      return '朝食';
    }
    if(category == 3){
      return '昼食';
    }
    if(category == 4){
      return '夕食';
    }
    if(category == 5){
      return '間食';
    }
  }

  //日記を選択時処理
  void _onDetail({DisplayDiary dd}) async {
    DisplayDiary diary = dd;
    this._showDetail(diary: diary);
  }

  //詳細画面へ遷移
  void _showDetail({ DisplayDiary diary }){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => DiaryDetail(diary: diary,selectedPhoto: DPhoto(id: -1),),
          fullscreenDialog: true,
        )
    ).then((result) {
//      print('②${result}');
      //削除または更新の場合
      if(result == 'delete' || result == 'update'){
        //最新のリストを取得し展開する
        this.refreshImages();
        setState(() {
          //レシピリスト用遅延読み込みリセット
          this._lazy.clear();
          this._currentLength = 0;
        });
        //レシピリスト用遅延読み込み
        this._loadMore();
      }
    });
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
    this._showSort(title: title, type: type);
  }

  //レシピの整理画面へ遷移
  void _showSort({ String title, int type}){
    Navigator.push(context,
        MaterialPageRoute(
          builder: (context) => RecipiSort(sortType: type,title: title ),
          fullscreenDialog: true,
        )
    ).then((result) {
    });
  }

  //サムネイルの取得
  String _getThumbnail(displayDiarys){
    for(var i = 0; i < displayDiarys.photos.length; i++) {
      if (displayDiarys.thumbnail == displayDiarys.photos[i].no) {
        return displayDiarys.photos[i].path;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawerNavigation(),
      appBar: AppBar(
        backgroundColor: Colors.deepOrange[100 * (1 % 9)],
        elevation: 0.0,
        title: Center(
          child: const Text('レシピ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
//              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        actions: <Widget>[
          checkBtn(),
          addBtn(context),
        ],
      ),
      body:diaryList(),
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
            color: Colors.deepOrange[100 * (1 % 9)],
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
            leading: Icon(Icons.folder_open,color: Colors.deepOrange[100 * (1 % 9)],),
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
            leading: Icon(Icons.local_offer,color: Colors.deepOrange[100 * (1 % 9)],),
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

  //線
  Widget line(){
    return Divider(
      color: Colors.grey,
      height: 0.5,
      thickness: 0.5,
    );
  }

  Widget diaryList(){
    return Stack(
      children: [
        listViewArea(),
        updater(),
      ],
    );
  }

  //ごはん日記リスト
  Widget listViewArea(){
    return
      LazyLoadScrollView(
        isLoading: _isLoading,
        onEndOfPage: () => _loadMore(),
        child:
          ListView.builder(
            shrinkWrap: true,
            itemCount: _lazy.length,
            itemBuilder: (context, position) {
              if(_isLoading && position == _lazy.length - 1){
                if(this._displayDiaryGroupDates.length == _lazy.length){
                  return createDiary(position);
                } else{
                  return Center(child: CircularProgressIndicator(),);
                }
              } else {
                return createDiary(position);
              }
    }),
      );
  }

  Widget createDiary(int index){
    String month = this._displayDiaryGroupDates[index].month.substring(0,4) +'年' + this._displayDiaryGroupDates[index].month.substring(5,7) + '月';
    //ごはん日記を展開する
    return StickyHeader(
        header:
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
                  child: Text('${month}', style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
//                      fontWeight: FontWeight.bold
                  ),),
                ),
              ],
            ),
          ),
        ),
        content: Column(
          children: List<int>.generate(_displayDiaryGroupDates[index].displayDiarys.length, (index) => index).map((diaryIndex) =>
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.11,
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
                  child: InkWell(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          //サムネイルエリア
                          this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].photos.length > 0
                              ? Card(
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.2,
                              width: MediaQuery.of(context).size.width * 0.2,
                              child: Image.file(File(common.replaceImageDiary(_getThumbnail(this._displayDiaryGroupDates[index].displayDiarys[diaryIndex]))),fit: BoxFit.cover,),
                            ),
                          )
                              : Card(
                            child: Container(
                              height: MediaQuery.of(context).size.width * 0.2,
                              width: MediaQuery.of(context).size.width * 0.2,
                              color: Colors.amber[100 * (1 % 9)],
                              child: Icon(Icons.restaurant,color: Colors.white,size: 50,),
                            ),
                          ),
                          //本文
                          Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              padding: EdgeInsets.all(5),
                              child: Text('${this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].body}',
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 15,
                                ),),
                            ),
                          ),
                          //日付エリア
                          Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            padding: EdgeInsets.only(top: 10,bottom: 10,left: 5,right: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.03,
                                      child: Container(
                                        child: Text('${DateTime.parse(this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].date).day}',
                                          style: TextStyle(
                                              color: Colors.brown[100 * (2 % 9)],
                                              fontSize: 23,
                                              fontWeight: FontWeight.bold
                                          ),),
                                      ),
                                    ),
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height * 0.025,
                                      child: Container(
                                        padding: EdgeInsets.only(top: 7,right: 5,left: 5),
                                        child: Text('${this._displayWeekday(DateTime.parse(this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].date).weekday)}',
                                          style: TextStyle(
                                              color: Colors.brown[100 * (2 % 9)],
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold
                                          ),),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.03,
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    child:
                                    this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].category == 1
                                        ? Container()
                                        : Text('${this._displayCategory(this._displayDiaryGroupDates[index].displayDiarys[diaryIndex].category)}',
                                      style: TextStyle(
                                          color: Colors.brown[100 * (2 % 9)],
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: (){
                        _onDetail(dd: this._displayDiaryGroupDates[index].displayDiarys[diaryIndex]);
                      }
                  ),
                ),
              ),
          ).toList(),
        )
    );
  }


  Widget checkBtn(){
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.check_circle_outline,size:30,),
      onPressed: null,
      disabledColor: Colors.deepOrange[100 * (1 % 9)],
    );
  }

  Widget addBtn(BuildContext context){
    return IconButton(
      color: Colors.white,
      icon: const Icon(Icons.add_circle_outline,size:30,),
      onPressed: (){
        _onEdit(-1);
      },
    );
  }

  Widget bottomNavigationBar(BuildContext context){
    return Consumer<Display>(
//        key: GlobalKey(),
        builder: (context,Display,_){
          return BottomNavigationBar(
            currentIndex: Display.currentIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.deepOrange[100 * (1 % 9)],
//      fixedColor: Colors.black12,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.deepOrange[100 * (2 % 9)],
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