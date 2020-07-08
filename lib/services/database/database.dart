import 'dart:io';
import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

//②モデルを生成
class My{
  int id;
//  String title;
//  String body;
  String topImage;
//  List<File> imageFiles;

//  My(this.id, this.title, this.body,this.topImage,this.imageFiles);
  My(this.id,this.topImage);

  //データベースに送る形式
  Map<String, dynamic> toMap(){
    return{
//      "title"   : title,
//      "body"    : body,
      "topImage": topImage,
//      "imageFiles": imageFiles,
    };
  }

  //widgetに展開する形式
  My.fromMap(Map<String,dynamic> json){
//    title = json['title'];
//    body = json['body'];
    topImage = json['topImage'];
//    imageFiles = json['imageFiles'];
    id = json['id'];
  }
}

//①データベースの生成
class MyDatabase {
  static Database _db;                      //DBのインスタンスを定義
  static final String TABLE = 'myrecipis';  //テーブル名を定義
  static const String DB_NAME ='recipi.db'; //DB名を定義
  static const String ID = 'id';            //カラム
  static const String TOPIMAGE ='topImage'; //カラム


//①DBを取得する関数を生成
  Future initDB() async {

//    Directory documentDirectory = await getApplicationDocumentsDirectory();
//    final path = join(documentDirectory.path, "sample.db");
//    deleteDatabase(path); //DB削除

    //DBがopenされてない場合のみ、処理を行う
    if (_db != null){
      return;
    }
    //pathの取得
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentDirectory.path, "sample.db");
    //DBを開く
    _db = await openDatabase(
        path,
        version: 6,
        //一番最初のみ
        onCreate: (Database db, int version){
          print("on Create!!!!!!!!!!!!!");
          //table生成
          db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $TOPIMAGE TEXT); ");
//              "CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $TOPIMAGE TEXT NOT NULL,completed INTEGER DEFAULT 0 ); ");
        },
        //DBの構成に変更があった場合
        onUpgrade: (Database db, int oldVersion, int newVersion) {
          print("on Upgrade!!!!!!!!!!");
          if((oldVersion > 2) && (newVersion <= 6)){
            db.execute("ALTER TABLE $TABLE ADD COLUMN completed INTEGER DEFAULT 0;");
          }
        }
    );
    print("DB INITIALIZE!!!!!!!");
  }


  //CRUD関数を生成する

  //SELECT
  Future<List<My>> getAllMys() async {
//    List<Map<String, dynamic>> maps = await _db.query(TABLE);
    List<Map<String, dynamic>> maps = await _db.query(TABLE,columns: [ID]);
    List<My> result = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
        result.add(My.fromMap(maps[i]));
      }
    }
    print("#######select: ${result.length}");
    return result;
  }

  //INSERT
  Future<void> insert(My my) async {
    print('########insert:${my.id},${my.topImage}');
    var result = await _db.insert(TABLE, my.toMap());
    print('####insert結果:${result}');
  }

  //UPDATE
  Future<void> updateMy(My my) async {
    print('###############update:${my.id},${my.topImage}');
    //json形式にして送る
    await _db.update(TABLE, my.toMap(), where: "id = ?", whereArgs: [my.id]);
  }

  //DELETE
  Future<void> delete(My my) async {
    print("############delete:${my.id}");
    await _db.delete(TABLE,where: "id = ?",whereArgs: [my.id]);

  }

  //CLOSE
  Future<void> close() async{
    await _db.close();
  }

  //DB DELETE
 
}