import 'dart:io';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:recipe_app/services/database/DBHelper.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart';
import 'package:recipe_app/model/diary/edit/Recipi.dart';
import 'package:recipe_app/model/diary/DisplayDiary.dart';
import 'package:recipe_app/model/diary/DisplayDiaryGroupDate.dart';
import 'package:intl/intl.dart';

class DiaryList extends StatefulWidget {

  @override
  _DiaryListState createState() => _DiaryListState();
}

class _DiaryListState extends State<DiaryList>{

  DBHelper dbHelper;
  List<DisplayDiaryGroupDate> _displayDiaryGroupDates = List<DisplayDiaryGroupDate>();

  @override
  void initState() {
    super.initState();
    this.init();
  }

  //初期処理
  void init(){
    dbHelper = DBHelper();
    //戻る画面をセット　2:ごはん日記の日記詳細レシピ一覧
    Provider.of<Display>(context, listen: false).setBackScreen(2);
    //レコードリフレッシュ
    refreshImages();
  }

  //表示しているレコードのリセットし、最新のレコードを取得し、表示
  Future<void> refreshImages() async {

    List<Diary> diarys = List<Diary>();
    List<DPhoto> photos = List<DPhoto>();
    List<DRecipi> recipis = List<DRecipi>();
    List<DisplayDiary> displayDiarys = List<DisplayDiary>();

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
    }
    for(var i = 0; i < this._displayDiaryGroupDates.length; i++){
      print('######################################################');
      print('id:${this._displayDiaryGroupDates[i].id},month:${this._displayDiaryGroupDates[i].month}');
      for(var j = 0; j < this._displayDiaryGroupDates[i].displayDiarys.length; j++){
        print('+++++++++++++++++++++++++++++++++++++++++++++');
        print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].id}');
        print('body:${this._displayDiaryGroupDates[i].displayDiarys[j].body}');
        print('date:${this._displayDiaryGroupDates[i].displayDiarys[j].date}');
        print('category:${this._displayDiaryGroupDates[i].displayDiarys[j].category}');
        print('thumbnail:${this._displayDiaryGroupDates[i].displayDiarys[j].thumbnail}');
        print('------ phtos ------------------');
        for(var k = 0; k < this._displayDiaryGroupDates[i].displayDiarys[j].photos.length; k++){
          print('-- [$k] --');
          print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].id}');
          print('diary_id:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].diary_id}');
          print('no:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].no}');
          print('path:${this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].path}');
          print('---------');
        }
        print('------------------------');
        print('------- recipis -----------------');
        for(var k = 0; k < this._displayDiaryGroupDates[i].displayDiarys[j].recipis.length; k++){
          print('-- [$k] --');
          print('id:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].id}');
          print('diary_id:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].diary_id}');
          print('no:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].recipi_id}');
          print('image:${this._displayDiaryGroupDates[i].displayDiarys[j].recipis[k].image}');
          print('---------');
        }
        print('------------------------');
        print('+++++++++++++++++++++++++++++++++++++++++++++');
      }
    }
//    //ご飯日記の全件取得
//    await dbHelper.getAllDiarys().then((item){
//      setState(() {
//        this._diarys.clear();
//        this._diarys.addAll(item);
//      });
//    });
//
//    for(var i = 0; i < this._diarys.length; i++){
//      print('==============[diary:${i}]====================');
//      print('id:${this._diarys[i].id}'
//            'body:${this._diarys[i].body},'
//            'date:${this._diarys[i].date}'
//            'category:${this._diarys[i].category}'
//            'thumbnail:${this._diarys[i].thumbnail}'
//      );
//    }
//    print('================================================');

//    //レシピの取得
//    await dbHelper.getAllDiaryRecipis().then((item){
//      setState(() {
//        this._recipis.clear();
//        this._recipis.addAll(item);
//      });
//    });
//
//    for(var i = 0; i < this._recipis.length; i++){
//      print('==============[recipis:${i}]====================');
//      print('id:${this._recipis[i].id}'
//          'diary_id:${this._recipis[i].diary_id}'
//          'recipi_id:${this._recipis[i].recipi_id},'
//      );
//    }
//    print('================================================');
//
//    //写真の取得
//    await dbHelper.getAllDiaryPhotos().then((item){
//      setState(() {
//        this._photos.clear();
//        this._photos.addAll(item);
//      });
//    });
//
//    for(var i = 0; i < this._photos.length; i++){
//      print('==============[phtos:${i}]====================');
//      print('id:${this._photos[i].id}'
//          'diary_id:${this._photos[i].diary_id}'
//          'no:${this._photos[i].no},'
//          'path:${this._photos[i].path},'
//      );
//    }
//    print('================================================');
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
  void _onEdit(int selectedId,BuildContext context){
    print('selectId[${selectedId}]');
    //idをset
    Provider.of<Display>(context, listen: false).setId(selectedId);
    if(selectedId == -1){
      //Date　=> String
      DateFormat formatter = DateFormat('yyyy-MM-dd');
      String dateString = formatter.format(DateTime.now());
      Provider.of<Edit>(context, listen: false).setDate(dateString);
      //編集フォームリセット処理
      Provider.of<Edit>(context, listen: false).reset();
    }
    //編集画面へ遷移
    Provider.of<Display>(context, listen: false).setState(2);
  }

  //ごはん日記リスト
  Column _onList(){
    this._displayDiaryGroupDates.sort((a,b) => b.id.compareTo(a.id));
    List<Widget> column = new List<Widget>();
    //ごはん日記を展開する
    for(var i = 0; i < this._displayDiaryGroupDates.length; i++){
      String month = this._displayDiaryGroupDates[i].month.substring(0,4) +'年' + this._displayDiaryGroupDates[i].month.substring(5,7) + '月';
      //線
      column.add(
        Divider(
          color: Colors.grey,
          height: 0.5,
          thickness: 0.5,
        ),
      );
      column.add(
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
            width: MediaQuery.of(context).size.width,
            child: Container(
              color: Colors.white30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Text('${month}', style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                    ),),
                  ),
                ],
              ),
            ),
          ),
      );
      for(var j = 0; j < this._displayDiaryGroupDates[i].displayDiarys.length; j++){
        //日付取得
        DateTime date = DateTime.parse(this._displayDiaryGroupDates[i].displayDiarys[j].date);
        //サムネイル取得
        String thumbnail = '';
        if(this._displayDiaryGroupDates[i].displayDiarys[j].photos.length != 0){
          for(var k = 0; k < this._displayDiaryGroupDates[i].displayDiarys[j].photos.length; k++){
            if(this._displayDiaryGroupDates[i].displayDiarys[j].thumbnail == this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].no){
              thumbnail = this._displayDiaryGroupDates[i].displayDiarys[j].photos[k].path;
              break;
            }
          }
        }
        //線
        column.add(
          Divider(
            color: Colors.grey,
            height: 0.5,
            thickness: 0.5,
          ),
        );
        column.add(
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 120,
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: 10,bottom: 10,left: 10),
              child: InkWell(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      //サムネイルエリア
                      thumbnail.isNotEmpty
                      ? Card(
                      child: Container(
                        height: 100,
                        width: 100,
                        child: Image.file(File(thumbnail)),
                          ),
                      )
                      : Card(
                      child: Container(
                        height: 100,
                        width: 100,
                        color: Colors.grey,
                        child: Icon(Icons.camera_alt,color: Colors.white,size: 50,),
                      ),
                      ),
                      //本文
                      Container(
  //                      color: Colors.grey,
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Container(
                              height: 50,
                              padding: EdgeInsets.all(5),
                              child: Text('${this._displayDiaryGroupDates[i].displayDiarys[j].body}',
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 15,
  //                                  fontWeight: FontWeight.bold
                                ),),
                            ),
                      ),
                      //日付エリア
                      Container(
  //                      color: Colors.orangeAccent,
                        width: MediaQuery.of(context).size.width * 0.2,
                        padding: EdgeInsets.only(top: 10,bottom: 10,left: 5,right: 5),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
  //                              width: MediaQuery.of(context).size.width * 0.15,
                                  height: 25,
                                  child: Container(
  //                          color: Colors.greenAccent,
  //                                  padding: EdgeInsets.all(5),
                                    child: Text('${date.day}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),
                                ),
                                SizedBox(
  //                              width: MediaQuery.of(context).size.width * 0.15,
                                  height: 25,
                                  child: Container(
    //                            color: Colors.orangeAccent,
                                    padding: EdgeInsets.only(top: 7,right: 5,left: 5),
                                    child: Text('${this._displayWeekday(date.weekday)}',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold
                                      ),),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
  //                          width: MediaQuery.of(context).size.width * 0.15,
                              height: 30,
                              child: Container(
//                            color: Colors.blue,
                                padding: EdgeInsets.all(5),
                                child:
                                  this._displayDiaryGroupDates[i].displayDiarys[j].category == 1
                                  ? Container()
                                  : Text('${this._displayCategory(this._displayDiaryGroupDates[i].displayDiarys[j].category)}',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
  //                              Icon(Icons.wb_sunny,color: Colors.grey,size: 25,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  onTap: (){
                    _onDetail(diary: this._displayDiaryGroupDates[i].displayDiarys[j]);
                  }
              ),
            ),
          ),
        );
      }
    }
    //線
    column.add(
      Divider(
        color: Colors.grey,
        height: 0.5,
        thickness: 0.5,
      ),
    );
    return Column(
      children: column,
    );
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
  void _onDetail({DisplayDiary diary}) async {
    //選択した日記をセットする
    Provider.of<Edit>(context, listen: false).setDiary(diary);
    //2:詳細画面へ遷移
    Provider.of<Display>(context, listen: false).setState(1);

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
          addBtn(context),
        ],
      ),
      body:scrollArea(),
      bottomNavigationBar: bottomNavigationBar(context),
//      floatingActionButton: floatBtn(),
    );
  }

  //リスト全体
  Widget scrollArea(){
    return Container(
      child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: myrecipiListArea(),
                  ),
                ),
              ]
          )
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

  //ごはん日記リスト
  Widget myrecipiListArea(){
    return Container(
      child: _onList(),
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

  Widget addBtn(BuildContext context){
    return IconButton(
      icon: const Icon(Icons.add_circle_outline,color: Colors.white,size:30),
      onPressed: (){
        _onEdit(-1,context);
      },
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