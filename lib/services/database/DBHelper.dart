import 'dart:io';
import 'dart:async';

import 'package:recipe_app/model/Photo.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DBHelper{

  static Database _db;                      //DBのインスタンスを定義
  static const String ID = 'id';            //カラム
  static const String NAME = 'photoName';   //カラム
  static const String TOPIMAGE ='topImage'; //カラム


//  static const String TABLE = 'PhotosTable';  //テーブル名を定義
  static final String TABLE = 'myrecipis';  //テーブル名を定義
  static const String DB_NAME ='recipi.db'; //DB名を定義

  Future<Database> get db async{

//    Directory documentDirectory = await getApplicationDocumentsDirectory();
//    final path = join(documentDirectory.path,DB_NAME);
//    await deleteDatabase(path); //DB削除

    if(null != _db){
      return _db;
    }
    _db = await initDB();
    return _db;
  }

  Future<Database> initDB() async{

    print('#######init!!!!!!');
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path,DB_NAME);
    var db = await openDatabase(path,version: 1,onCreate:_onCreate);
    return db;
  }

  _onCreate(Database db,int version) async {
//    await db.execute("CREATE TABLE $TABLE ($ID INTEGER, $NAME TEXT); ");
//    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT); ");
    await db.execute("CREATE TABLE $TABLE ($ID INTEGER PRIMARY KEY, $TOPIMAGE TEXT); ");
    print('#########CREATE!!!!!!');
  }

  //Photo
  //SELECT
  Future<List<Photo>> getPhotos() async{
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,columns: [ID,NAME]);
    List<Photo> photos = [];
    if (maps.length > 0 ){
      for (int i = 0; i < maps.length; i++){
        photos.add((Photo.fromMap(maps[i])));
        print('getPhotos:${photos[i].id}');
      }
    }
    print('getPhotos:${photos.length}');
    return photos;
  }
  //INSERT
  Future<Photo> insetrtPhoto(Photo photo) async{
    var dbClient = await db;
    photo.id = await dbClient.insert(TABLE, photo.toMap());
    print('###insert!!!!${photo.photoName}');
    return photo;
  }

  //myrecipi
  //SELECT
  Future<List<Myrecipi>> getMyRecipis() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE,columns: [ID,TOPIMAGE]);
    List<Myrecipi> myrecipis = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
        myrecipis.add(Myrecipi.fromMap(maps[i]));
      }
    }
    print("#######select: ${myrecipis.length}");
    return myrecipis;
  }

  //INSERT
  Future<Myrecipi> insertMyRecipi(Myrecipi my) async {
    print('########insert:${my.id},${my.topImage}');
    var dbClient = await db;
//    var result = await dbClient.insert(TABLE, my.toMap());
    my.id = await dbClient.insert(TABLE, my.toMap());
    print('####insert結果:${my.id}');
    return my;
  }

  //UPDATE
  Future<void> updateMy(Myrecipi my) async {
    print('########update:${my.id},${my.topImage}');
    var dbClient = await db;
    //json形式にして送る
    var result = await dbClient.update(TABLE, my.toMap(), where: "id = ?", whereArgs: [my.id]);
    print('####update結果:${result}');
  }

  //DELETE
  Future<void> delete(Myrecipi my) async {
    print("########delete:${my.id}");
    var dbClient = await db;
    var result = await dbClient.delete(TABLE,where: "id = ?",whereArgs: [my.id]);
    print('####delete結果:${result}');
  }

  //DB CLOSE
  Future close() async{
    var dbClient = await db;
    await dbClient.close();
  }
}