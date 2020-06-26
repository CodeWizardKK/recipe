import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String,dynamic>> get(option) async{

  final String url = "https://reqres.in/api/users";

  var response = await http.get(
    Uri.encodeFull('${url}/${option['id']}'),//Encode the url
        headers: {"Accept":"applecation/json"}
    );

  print('該当レコード:${response.body}');

  //表示用に変換してreturn
  return jsonDecode(response.body);
}
