import 'dart:convert';
import 'package:http/http.dart' as http;

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
