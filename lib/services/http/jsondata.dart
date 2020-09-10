import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recipe_app/model/Format.dart';
import 'package:recipe_app/services/http/seasoning.dart';

class jsondata {

  seasoning _seasoning = seasoning();

  bool _isError = false;
  http.Response _response;
  List<Format> data = List<Format>();

  Future<List<Format>> get() async {

    try{
      _response = await _seasoning.get();
      print('status:${_response.statusCode}');
      print(_response.body);
    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

    if(!_isError){
      if(_response.statusCode == 200){
         await fromMap(response: _response);
      }
    }
    return data;
  }

  Future<void> fromMap({http.Response response}) async {
    var json;

    try{
      json = jsonDecode(response.body);

    }catch(e){
      //エラー処理
      print('Error: ${e}');
      _isError = !_isError;
    }

    if(!_isError){
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
      if(json['seasonings'].length > 0){
        for(var i = 0; i < json['seasonings'].length; i++){
          data.add(Format.fromMap(json['seasonings'][i]));
        }
      }
      data.forEach((element) {
        print('id:${element.id},name:${element.name}');
      });
    }
  }
}
