import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle; //mock用

Future<Map<String,dynamic>> get() async{

  final String url = "https://reqres.in/api/users";

  var response = await http.get(
        Uri.encodeFull(url),//Encode the url
        headers: {"Accept":"applecation/json"}
    );

  print('レシピリスト:${response.body}');

  //表示用に変換してreturn
  return jsonDecode(response.body);
}


// ==============mock==================== //

//ローカルJSON　データセット
Future<Map<String,dynamic>> getLocal() async {
  var jsonString = await _loadAVaultAsset();
    final jsonResponse = jsonDecode(jsonString);

    print("### getLocalTestJSONData:" + jsonResponse.toString());
    return jsonResponse;
}

// ローカルJSONファイル読み込みテスト用「api_name.json」
Future<String> _loadAVaultAsset() async {
  return await rootBundle.loadString('json/recipi_list.json');
}
