import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recipe_app/model/Format.dart';


class seasoning {

  Future<List<Format>> get() async {
    const String url = "https://us-central1-mlkit-66aba.cloudfunctions.net/seasoning";
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"}
    );
    print('resCODE:${response.statusCode}');
    if (response.statusCode == 200){
      var json = jsonDecode(response.body);
      List<Format> items = List<Format>();
//      print('######body:${response.body}');
//      print('######bodylength:${response.body.length}');
      if(json['seasonings'].length > 0){
        for(var i = 0; i < json['seasonings'].length; i++){
          items.add(Format.fromMap(json['seasonings'][i]));
        }
      }
      items.forEach((element) {
        print('id:${element.id},name:${element.name}');
      });
      return items;
//    }else{
//      throw Exception('Failed to load album');
    }
  }
}