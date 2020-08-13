import 'dart:io';
import 'dart:async';

import 'package:recipe_app/model/TagGroupRecipiId.dart';
import 'package:recipe_app/model/Tag.dart';
import 'package:recipe_app/model/MstTag.dart';
import 'package:recipe_app/model/MstFolder.dart';
import 'package:recipe_app/model/Myrecipi.dart';
import 'package:recipe_app/model/MyrecipiGroupFolder.dart';
import 'package:recipe_app/model/edit/Howto.dart';
import 'package:recipe_app/model/edit/Ingredient.dart';
import 'package:recipe_app/model/edit/Photo.dart';
import 'package:recipe_app/model/diary/Diary.dart';
import 'package:recipe_app/model/diary/edit/Photo.dart' as DPhoto;
import 'package:recipe_app/model/diary/edit/Recipi.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class DBHelper{

  static Database _db;//DBのインスタンスを定義

  //////////
  //DB//////
  //////////
  static const String DB_NAME ='recipi.db';

  //////////
  //column//
  //////////
  static const String RECIPI_ID = 'recipi_id';
  //recipi
  static const String ID = 'id';
  static const String TYPE = 'type';
  static const String THUMBNAIL ='thumbnail';
  static const String TITLE ='title';
  static const String DESCRIPTION ='description';
  static const String QUANTITY ='quantity';
  static const String UNIT ='unit';
  static const String TIME ='time';
  static const String FOLDER_ID ='folder_id';
  //recipi_photo
  static const String NO ='no';
  static const String PATH ='path';
  //recipi_ingredient
  static const String NAME ='name';
  //recipi_howto
  static const String MEMO ='memo';
  static const String PHOTO ='photo';
  //tag
  static const String MST_TAG_ID ='mst_tag_id';
  //diary
  static const String BODY ='body';
  static const String DATE ='date';
  static const String CATEGORY ='category';
  //diary_phto
  static const String DIARY_ID = 'diary_id';


  //////////
  //TABLE///
  //////////
  //レシピ
  static final String RECIPI_TABLE = 'recipi';
  static final String TAG_TABLE = 'tag';
  static final String MST_TAG_TABLE = 'mst_tag';
  static final String MST_FOLDER_TABLE = 'mst_folder';
  static final String RECIPI_PHOTO_TABLE = 'recipi_photo';
  static final String RECIPI_INGREDIENT_TABLE = 'recipi_ingredient';
  static final String RECIPI_HOWTO_TABLE = 'recipi_howto';
  //ごはん日記
  static final String DIARY_TABLE = 'diary';
  static final String DIARY_PHOTO_TABLE = 'diary_photo';
  static final String DIARY_RECIPI_TABLE = 'diary_recipi';

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
    //レシピ
    await db.execute("CREATE TABLE $RECIPI_TABLE ($ID INTEGER PRIMARY KEY, $TYPE INTEGER, $THUMBNAIL TEXT, $TITLE TEXT, $DESCRIPTION TEXT, $QUANTITY INTEGER, $UNIT INTEGER, $TIME INTEGER, $FOLDER_ID INTEGER); ");
    await db.execute("CREATE TABLE $TAG_TABLE ($ID INTEGER PRIMARY KEY,$RECIPI_ID INTEGER,$MST_TAG_ID INTEGER); ");
    await db.execute("CREATE TABLE $MST_TAG_TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT); ");
    await db.execute("CREATE TABLE $MST_FOLDER_TABLE ($ID INTEGER PRIMARY KEY, $NAME TEXT); ");
    await db.execute("CREATE TABLE $RECIPI_PHOTO_TABLE ($ID INTEGER PRIMARY KEY,$RECIPI_ID INTEGER,$NO INTEGER, $PATH TEXT); ");
    await db.execute("CREATE TABLE $RECIPI_INGREDIENT_TABLE ($ID INTEGER PRIMARY KEY,$RECIPI_ID INTEGER,$NO INTEGER, $NAME TEXT, $QUANTITY TEXT); ");
    await db.execute("CREATE TABLE $RECIPI_HOWTO_TABLE ($ID INTEGER PRIMARY KEY,$RECIPI_ID INTEGER,$NO INTEGER, $MEMO TEXT, $PHOTO TEXT); ");
    //ごはん日記
    await db.execute("CREATE TABLE $DIARY_TABLE ($ID INTEGER PRIMARY KEY, $BODY TEXT, $DATE TEXT, $CATEGORY INTEGER, $THUMBNAIL INTEGER); ");
    await db.execute("CREATE TABLE $DIARY_PHOTO_TABLE ($ID INTEGER PRIMARY KEY,$DIARY_ID INTEGER,$NO INTEGER, $PATH TEXT); ");
    await db.execute("CREATE TABLE $DIARY_RECIPI_TABLE ($ID INTEGER PRIMARY KEY,$DIARY_ID INTEGER,$RECIPI_ID INTEGER); ");
    print('#########CREATE!!!!!!');
  }

  //SELECT
  Future<List<Myrecipi>> getMyRecipis() async {
    var dbClient = await db;
//    List<Map> maps = await dbClient.query(TABLE,columns: [ID,TYPE,THUMBNAIL,TITLE,DESCRIPTON,QUANTITY,UNIT,TIME,PHOTOS,INGREDIENTS,HOWTO]);
    List<Map> maps = await dbClient.query(RECIPI_TABLE,columns: [ID,TYPE,THUMBNAIL,TITLE,DESCRIPTION,QUANTITY,UNIT,TIME,FOLDER_ID]);
    List<Myrecipi> myrecipis = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
        myrecipis.add(Myrecipi.fromMap(maps[i]));
      }
    }
    print("[myrecipi]Select: ${myrecipis.length}");
    return myrecipis;
  }

  //SELECT
  Future<List<MyrecipiGroupFolder>> getMyRecipisCount() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_TABLE.$FOLDER_ID,$MST_FOLDER_TABLE.$NAME,COUNT($RECIPI_TABLE.$FOLDER_ID) FROM $RECIPI_TABLE left outer join $MST_FOLDER_TABLE on $RECIPI_TABLE.$FOLDER_ID  = $MST_FOLDER_TABLE.$ID GROUP BY $RECIPI_TABLE.$FOLDER_ID');
//    List<Map> maps = await dbClient.rawQuery('SELECT $FOLDER_ID,COUNT($FOLDER_ID) FROM $RECIPI_TABLE GROUP BY $FOLDER_ID');
    List<MyrecipiGroupFolder> myrecipis = [];
    if(maps.length > 0){
//      print('####################################');
//      print('####################################');
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
//        print(maps[i]);
        myrecipis.add(MyrecipiGroupFolder.fromMap(maps[i]));
      }
    }
    print("[myrecipi]Select: ${myrecipis.length}");
    print('####################################');
    print('####################################');
    for(var i = 0; i < myrecipis.length; i++){
      print('folder_id:${myrecipis[i].folder_id},name:${myrecipis[i].name},count:${myrecipis[i].count}');
    }
    print('####################################');
    print('####################################');
    return myrecipis;
  }

  Future<List<MstFolder>> getMstFolders() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(MST_FOLDER_TABLE,columns: [ID,NAME]);
    List<MstFolder> folders = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
        folders.add(MstFolder.fromMap(maps[i]));
      }
    }
    print("[folder]select: ${folders.length}");
    return folders;
  }

  Future<List<MstTag>> getMstTags() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(MST_TAG_TABLE,columns: [ID,NAME]);
    List<MstTag> tags = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        //json形式 => Map型に展開する
        tags.add(MstTag.fromMap(maps[i]));
        print('TabMST[${i}]${maps[i]}');
      }
    }
    print("[tagMST]select: ${tags.length}");
    return tags;
  }

  Future<List<Tag>> getTags() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery('SELECT $TAG_TABLE.$ID,$TAG_TABLE.$RECIPI_ID,$TAG_TABLE.$MST_TAG_ID,$MST_TAG_TABLE.$NAME FROM $TAG_TABLE left outer join $MST_TAG_TABLE on $TAG_TABLE.$MST_TAG_ID  = $MST_TAG_TABLE.$ID');
//    List<Map> maps = await dbClient.rawQuery('SELECT $TAG_TABLE.$ID,$TAG_TABLE.$RECIPI_ID,$TAG_TABLE.$MST_TAG_ID,$MST_TAG_TABLE.$NAME FROM $TAG_TABLE left outer join $MST_TAG_TABLE on $TAG_TABLE.$MST_TAG_ID  = $MST_TAG_TABLE.$ID where $RECIPI_TABLE.$ID = ? ',[id]);
//    List<Map> maps = await dbClient.query(TAG_TABLE,columns: [ID,RECIPI_ID,MST_TAG_ID]);
    List<Tag> tags = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('Tabs[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        tags.add(Tag.fromMap(maps[i]));
      }
    }
    print("[tag]select: ${tags.length}");
    return tags;
  }

  Future<List<TagGroupRecipiId>> getTagsGropByRecipiId(String mst_tag_ids,int count) async {
    print('①id:${mst_tag_ids}');
    String id = '1,2,3';
    var dbClient = await db;
//    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_ID,COUNT($RECIPI_ID) FROM $TAG_TABLE　GROUP BY $RECIPI_ID');
//    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_ID,COUNT($RECIPI_ID) FROM $TAG_TABLE GROUP BY $RECIPI_ID');
    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_ID FROM $TAG_TABLE where $MST_TAG_ID in ($mst_tag_ids) GROUP BY $RECIPI_ID having count($RECIPI_ID) = $count');
//    List<Map> maps = await dbClient.rawQuery('SELECT $TAG_TABLE.$ID,$TAG_TABLE.$RECIPI_ID,$TAG_TABLE.$MST_TAG_ID,$MST_TAG_TABLE.$NAME FROM $TAG_TABLE left outer join $MST_TAG_TABLE on $TAG_TABLE.$MST_TAG_ID  = $MST_TAG_TABLE.$ID where $RECIPI_TABLE.$ID = ? ',[id]);
//    List<Map> maps = await dbClient.query(TAG_TABLE,columns: [ID,RECIPI_ID,MST_TAG_ID]);
    List<TagGroupRecipiId> tags = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('##################################');
        print('##################################');
        print('グループ別Tabs[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        tags.add(TagGroupRecipiId.fromMap(maps[i]));
      }
    }
    print("[tag]select: ${tags.length}");
    return tags;
  }

  Future<List<Ingredient>> getAllIngredients() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery('SELECT * FROM $RECIPI_INGREDIENT_TABLE');
    List<Ingredient> ingredients = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('ingredient[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        ingredients.add(Ingredient.fromMap(maps[i]));
      }
    }
    print("[ingredient]select: ${ingredients.length}");
    return ingredients;
  }

  //レシピIDに紐づくデータを取得
  Future<Myrecipi> getMyRecipi(int id) async {
    print('########id:${id}');
    var dbClient = await db;
//    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_INGREDIENT_TABLE.$ID,$RECIPI_INGREDIENT_TABLE.$RECIPI_ID,$RECIPI_INGREDIENT_TABLE.$NO,$RECIPI_INGREDIENT_TABLE.$NAME,$RECIPI_INGREDIENT_TABLE.$QUANTITY FROM $RECIPI_TABLE left outer join $RECIPI_INGREDIENT_TABLE on $RECIPI_TABLE.$ID  = $RECIPI_INGREDIENT_TABLE.$RECIPI_ID where $RECIPI_TABLE.$ID = ? ',[id]);
    List<Map> maps = await dbClient.rawQuery('SELECT $ID,$TYPE,$THUMBNAIL,$TITLE,$DESCRIPTION,$QUANTITY,$UNIT,$TIME,$FOLDER_ID FROM $RECIPI_TABLE where $ID = ? ',[id]);
        print('myrecipi[${0}]${maps[0]}');
        //json形式 => Map型に展開する
    return Myrecipi.fromMap(maps[0]);
  }

  //レシピIDに紐づく材料データを取得
  Future<List<Ingredient>> getIngredients(int id) async {
    print('########id:${id}');
    var dbClient = await db;
//    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_INGREDIENT_TABLE.$ID,$RECIPI_INGREDIENT_TABLE.$RECIPI_ID,$RECIPI_INGREDIENT_TABLE.$NO,$RECIPI_INGREDIENT_TABLE.$NAME,$RECIPI_INGREDIENT_TABLE.$QUANTITY FROM $RECIPI_TABLE left outer join $RECIPI_INGREDIENT_TABLE on $RECIPI_TABLE.$ID  = $RECIPI_INGREDIENT_TABLE.$RECIPI_ID where $RECIPI_TABLE.$ID = ? ',[id]);
    List<Map> maps = await dbClient.rawQuery('SELECT $ID,$RECIPI_ID,$NO,$NAME,$QUANTITY FROM $RECIPI_INGREDIENT_TABLE where $RECIPI_ID = ? ',[id]);
    List<Ingredient> ingredients = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('ingredient[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        ingredients.add(Ingredient.fromMap(maps[i]));
      }
    }
    print("#######select: ${ingredients.length}");
    return ingredients;
  }

  //レシピIDに紐づく作り方データを取得
  Future<List<HowTo>> getHowtos(int id) async {
    print('id:${id}');
    var dbClient = await db;
//    List<Map> maps = await dbClient.rawQuery('SELECT $RECIPI_HOWTO_TABLE.$ID,$RECIPI_HOWTO_TABLE.$RECIPI_ID,$RECIPI_HOWTO_TABLE.$NO,$RECIPI_HOWTO_TABLE.$MEMO,$RECIPI_HOWTO_TABLE.$PHOTO FROM $RECIPI_TABLE left outer join $RECIPI_HOWTO_TABLE on $RECIPI_TABLE.$ID  = $RECIPI_HOWTO_TABLE.$RECIPI_ID where $RECIPI_TABLE.$ID = ? ',[id]);
    List<Map> maps = await dbClient.rawQuery('SELECT $ID,$RECIPI_ID,$NO,$MEMO,$PHOTO FROM $RECIPI_HOWTO_TABLE where $RECIPI_ID = ? ',[id]);
    List<HowTo> howTos = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('howto[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        howTos.add(HowTo.fromMap(maps[i]));
      }
    }
    print("#######select: ${howTos.length}");
    return howTos;
  }

  //レシピIDに紐づくデータを取得
  Future<List<Photo>> getPhotos(int id) async {
    print('id:${id}');
    var dbClient = await db;
    List<Map> maps = await dbClient.rawQuery('SELECT $ID,$RECIPI_ID,$NO,$PATH FROM $RECIPI_PHOTO_TABLE where $RECIPI_ID = ? ',[id]);
    List<Photo> phtos = [];
    if(maps.length > 0){
      for(var i = 0; i < maps.length; i++){
        print('phto[${i}]${maps[i]}');
        //json形式 => Map型に展開する
        phtos.add(Photo.fromMap(maps[i]));
      }
    }
    print("#######select: ${phtos.length}");
    return phtos;
  }

  //INSERT
  Future<MstFolder> insertMstFolder(MstFolder folder) async {
    print('########insert:${folder.id},${folder.name}}');
    var dbClient = await db;
    folder.id = await dbClient.insert(MST_FOLDER_TABLE, folder.toMap());
    print('####insert結果:${folder.id}');
    return folder;
  }

  //INSERT
  Future<MstTag> insertMstTag(MstTag tag) async {
    print('########insert:${tag.id},${tag.name}}');
    var dbClient = await db;
    tag.id = await dbClient.insert(MST_TAG_TABLE, tag.toMap());
    print('####insert結果:${tag.id}');
    return tag;
  }

  //INSERT
  Future<Tag> insertTag(Tag tag) async {
    print('########insert:${tag.id},${tag.recipi_id}}');
    var dbClient = await db;
    tag.id = await dbClient.insert(TAG_TABLE, tag.toMap());
    print('####insert結果:${tag.id}');
    return tag;
  }

  //INSERT
  Future<Myrecipi> insertMyRecipi(Myrecipi myrecipi) async {
//    print('########insert:${myrecipi.id},${myrecipi.type},${myrecipi.thumbnail},${myrecipi.title},${myrecipi.description},${myrecipi.quantity},${myrecipi.unit},${myrecipi.time},${myrecipi.photos},${myrecipi.ingredients},${myrecipi.howto}');
    print('########insert:${myrecipi.id},${myrecipi.type},${myrecipi.thumbnail},${myrecipi.title},${myrecipi.description},${myrecipi.quantity},${myrecipi.unit},${myrecipi.time},${myrecipi.folder_id}');
    var dbClient = await db;
//    var result = await dbClient.insert(TABLE, my.toMap());
    myrecipi.id = await dbClient.insert(RECIPI_TABLE, myrecipi.toMap());
    print('####insert結果:${myrecipi.id}');
    return myrecipi;
  }

  //recipi_photo
  Future<void> insertPhoto(List<Photo> photos) async {
    for(var i = 0; i < photos.length; i++){
      print('########insertするレコード[photo]:${photos[i].recipi_id},${photos[i].id},${photos[i].no},${photos[i].path}');
      var dbClient = await db;
      var id = await dbClient.insert(RECIPI_PHOTO_TABLE, photos[i].toMap());
//      print('########insert結果:${photos[i].recipi_id},${photos[i].id},${photos[i].no},${photos[i].path}');
    }
  }
  //recipi_photo
  Future<void> insertRecipiIngredient(List<Ingredient> ingredients) async {
    for(var i = 0; i < ingredients.length; i++){
      print('########insertするレコード[ingredient]:${ingredients[i].recipi_id},${ingredients[i].id},${ingredients[i].no},${ingredients[i].name}');
      var dbClient = await db;
      var id = await dbClient.insert(RECIPI_INGREDIENT_TABLE, ingredients[i].toMap());
//      print('########insert結果:${ingredients[i].recipi_id},${ingredients[i].id},${ingredients[i].no},${ingredients[i].name}');
    }
  }
  //recipi_photo
  Future<void> insertRecipiHowto(List<HowTo> howTos) async {
    for(var i = 0; i < howTos.length; i++){
      print('########insertするレコード[howTo]:${howTos[i].recipi_id},${howTos[i].id},${howTos[i].no},${howTos[i].memo},${howTos[i].photo}');
      var dbClient = await db;
      var id = await dbClient.insert(RECIPI_HOWTO_TABLE, howTos[i].toMap());
//      print('########insert結果:${howTos[i].recipi_id},${howTos[i].id},${howTos[i].no},${howTos[i].photo}');
    }
  }

  //diary
  Future<Diary> insertDiary(Diary diary) async {
    print('########insert:${diary.id},${diary.body},${diary.date},${diary.category},${diary.thumbnail},');
    var dbClient = await db;
    diary.id = await dbClient.insert(RECIPI_TABLE, diary.toMap());
    print('####insert結果:${diary.id}');
    return diary;
  }

//  //diary_photo
//  Future<void> insertDiaryPhoto(List<DPhoto> photos) async {
//    for(var i = 0; i < photos.length; i++){
//      print('########insertするレコード[photo]:${photos[i].diary_id},${photos[i].id},${photos[i].no},${photos[i].path}');
//      var dbClient = await db;
//      var id = await dbClient.insert(RECIPI_PHOTO_TABLE, photos[i].toMap());
//    }
//  }
//  //diary_recipi
//  Future<void> insertDiaryRecipi(List<Recipi> recipi) async {
//    for(var i = 0; i < recipi.length; i++){
//      print('########insertするレコード[photo]:${recipi[i].diary_id},${recipi[i].id},${recipi[i].recipi_id}');
//      var dbClient = await db;
//      var id = await dbClient.insert(RECIPI_PHOTO_TABLE, recipi[i].toMap());
//    }
//  }


  //UPDATE
  Future<void> updateMyRecipi(Myrecipi myrecipi) async {
    print('########update:id:${myrecipi.id},type:${myrecipi.type},thumbnail:${myrecipi.thumbnail},title:${myrecipi.title},quantity:${myrecipi.description},quantity:${myrecipi.quantity},unit:${myrecipi.unit},folder_id:${myrecipi.folder_id},');
    var dbClient = await db;
    //json形式にして送る
    var result = await dbClient.update(RECIPI_TABLE, myrecipi.toMap(), where: '$ID = ?', whereArgs: [myrecipi.id]);
    print('####update結果:${result}');
  }

  //UPDATE
  Future<void> updateFolderId({int id,int folder_id}) async {
    print('########update:ID${id},folder_id${folder_id}');
    var dbClient = await db;
    //json形式にして送る
    var result = await dbClient.rawUpdate('UPDATE $RECIPI_TABLE SET $FOLDER_ID = ? WHERE $ID = ?',[folder_id,id]);
    print('####update結果:${result}');
  }

//  Future<void> updateIngredient(List<Ingredient> ingredients) async {
//    for(var i = 0; i < ingredients.length; i++){
//      print('########updateするレコード[ingredient]:${ingredients[i].recipi_id},${ingredients[i].id},${ingredients[i].no},${ingredients[i].name}');
//      var dbClient = await db;
//      var id = await dbClient.insert(RECIPI_INGREDIENT_TABLE, ingredients[i].toMap());
////      print('########insert結果:${ingredients[i].recipi_id},${ingredients[i].id},${ingredients[i].no},${ingredients[i].name}');
//    }
//  }

  //DELETE
  Future<void> deleteMyRecipi(int id) async {
    print("########①delete:${id}");
    var dbClient = await db;
    var result = await dbClient.delete(
        RECIPI_TABLE,where: '$ID = ?',whereArgs: [id]);
    print('####①delete結果:${result}');
  }

  //レシピIDに紐づくデータを削除
  Future<void> deleteRecipiIngredient(int id) async {
      print("########②deleteID:${id}");
      var dbClient = await db;
      var result = await dbClient.delete(
          RECIPI_INGREDIENT_TABLE, where: '$RECIPI_ID = ?', whereArgs: [id]);
      print('####②delete結果:${result}');
  }

  //レシピIDに紐づくデータを削除
  Future<void> deleteRecipiHowto(int id) async {
      print("########③deleteID:${id}");
      var dbClient = await db;
      var result = await dbClient.delete(
          RECIPI_HOWTO_TABLE, where: '$RECIPI_ID = ?', whereArgs: [id]);
      print('####③delete結果:${result}');
  }

  //レシピIDに紐づくデータを削除
  Future<void> deleteRecipiPhoto(int id) async {
      print("########④deleteID:${id}");
      var dbClient = await db;
      var result = await dbClient.delete(
          RECIPI_PHOTO_TABLE, where: '$RECIPI_ID = ?', whereArgs: [id]);
      print('####④delete結果:${result}');
  }

  //レシピIDに紐づくタグデータを削除
  Future<void> deletetag(int id) async {
      print("########⑤deleteID:${id}");
      var dbClient = await db;
      var result = await dbClient.delete(
          TAG_TABLE, where: '$RECIPI_ID = ?', whereArgs: [id]);
      print('####⑤delete結果:${result}');
  }

  //フォルダマスタデータを削除
  Future<void> deleteMstFolder(int id) async {
      print("########⑥deleteID:${id}");
      var dbClient = await db;
      var result = await dbClient.delete(
          MST_FOLDER_TABLE, where: '$ID = ?', whereArgs: [id]);
      print('####⑥delete結果:${result}');
  }

  //フォルダIDに紐づくレシピを削除
  Future<void> deleteMyRecipiFolderId(int folder_id) async {
    print("########①delete:${folder_id}");
    var dbClient = await db;
    var result = await dbClient.delete(
        RECIPI_TABLE,where: '$FOLDER_ID = ?',whereArgs: [folder_id]);
    print('####①delete結果:${result}');
  }

  //DB CLOSE
  Future close() async{
    var dbClient = await db;
    await dbClient.close();
  }


}