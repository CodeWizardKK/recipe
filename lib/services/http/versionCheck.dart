import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:recipe_app/model/Format.dart';

import 'package:recipe_app/model/Version.dart';
import 'package:recipe_app/model/VersionCheck.dart';
import 'package:recipe_app/services/http/version.dart';
import 'package:recipe_app/services/http/seasoning.dart';
import 'package:recipe_app/services/http/quantityunit.dart';
import 'package:recipe_app/services/database/DBHelper.dart';

class versionCheck {

  DBHelper dbHelper = DBHelper();
  version _version = version();
  seasoning _seasoning = seasoning();
  quantityunit _quantityunit = quantityunit();


  Future<VersionCheck> check() async {

    //firebaseのversion.jsonの取得
    Version h = await this.getHttpVersion();
    print('[firebase] s:${h.s},q:${h.q}');
    //localのversion.jsonの取得
    Version l = await this.getLocalVersion();
    print('[local] s:${l.s},q:${l.q}');

    VersionCheck check = VersionCheck(s: false,q: false,h: h,l: l);
    //seasoningバージョンチェック
    if( l.s < h.s ){
      //localのversionの's'の値を更新
      await dbHelper.updateVersion(colum: 's',version: h.s);
      //localのseasoningを削除
      await dbHelper.deleteSeasoning();
      //firebase上から取得した値を登録
      List<Format> seasonings = await this.getHttpSeasoning();
      await dbHelper.insertSeasoning(seasonings);
      check.s = true;
    }
    //quantityUnitバージョンチェック
    if( l.q < h.q ){
      //localのversion.jsonの'q'の値を更新
      await dbHelper.updateVersion(colum: 'q',version: h.q);
      //localのseasoningを削除
      await dbHelper.deleteQuantityUnit();
      //firebase上から取得した値を登録
      List<Format> quantityunits = await this.getHttpQuantityunit();
      await dbHelper.insertQuantityunit(quantityunits);
      check.q = true;
    }

    print('バージョンチェック実行時間:${DateTime.now()}');
    check.time = DateTime.now().millisecondsSinceEpoch;
    return check;
  }

  //firebasaから取得 バージョン情報
  Future<Version> getHttpVersion() async {
    http.Response _response;
    bool _isError = false;

    try{
      _response = await _version.get();
//      print('status:${_response.statusCode}');
//      print(_response.body);
    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

    if(!_isError){
      if(_response.statusCode == 200){
        var json;

        try{
          json = await jsonDecode(_response.body);

        }catch(e){
          //エラー処理
          print('Error: ${e}');
          _isError = !_isError;
        }

        if(!_isError){
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
//          Version.fromMap(json);
          return Version.fromMap(json);
        }
      }
    }
  }

  //firebasaから取得 Seasoning
  Future<List<Format>> getHttpSeasoning() async {
    http.Response _response;
    bool _isError = false;

    try{
      _response = await _seasoning.get();
//      print('status:${_response.statusCode}');
//      print(_response.body);
    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

    if(!_isError){
      if(_response.statusCode == 200){
        var json;

        try{
          json = await jsonDecode(_response.body);

        }catch(e){
          //エラー処理
          print('Error: ${e}');
          _isError = !_isError;
        }

        if(!_isError){
          List<Format> seasonings = List<Format>();
          //データを個別に扱えるようデコードする
//          final jsonResponse = json.decode(json);
          List s = json['seasonings'];
          for(var i = 0; i < json['seasonings'].length; i++){
            Format seasoning = Format(id: s[i]['id'],name: s[i]['name']);
              seasonings.add(seasoning);
          }
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
//          Version.fromMap(json);
          return seasonings;
        }
      }
    }
  }

  //firebasaから取得 Quantityunit
  Future<List<Format>> getHttpQuantityunit() async {
    http.Response _response;
    bool _isError = false;

    try{
      _response = await _quantityunit.get();
//      print('status:${_response.statusCode}');
//      print(_response.body);
    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

    if(!_isError){
      if(_response.statusCode == 200){
        var json;

        try{
          json = await jsonDecode(_response.body);

        }catch(e){
          //エラー処理
          print('Error: ${e}');
          _isError = !_isError;
        }

        if(!_isError){
          List<Format> quantityunits = List<Format>();
          //データを個別に扱えるようデコードする
//          final jsonResponse = json.decode(json);
          List q = json['quantityunits'];
          for(var i = 0; i < json['quantityunits'].length; i++){
            Format seasoning = Format(id: q[i]['id'],name: q[i]['name']);
            quantityunits.add(seasoning);
          }
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
//          Version.fromMap(json);
          return quantityunits;
        }
      }
    }
  }

  //ローカルから取得
  Future<Version> getLocalVersion() async {
    Version version ;
//    String jsonString = '';
    bool _isError = false;

    try{
      version = await dbHelper.getVersion();
    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

//    if(!_isError) {
//      var json;
//      try{
//        json = await jsonDecode(jsonString);
//
//      }catch(e){
//        //エラー処理
//        print('Error: ${e}');
//        _isError = !_isError;
//      }

      if(!_isError){
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
//          Version.fromMap(json);
//        return Version.fromMap(json);
        return version;
      }

    }

}