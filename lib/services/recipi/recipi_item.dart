import 'dart:convert';
import 'package:http/http.dart' as http;


Future<Map<String,dynamic>> get(option) async{

  final String url = "https://reqres.in/api/users?page=2"; //不要
//  final String url = "https://reqres.in/api";

  var response = await http.get(
      Uri.encodeFull(url),//不要
//    Uri.encodeFull('${url}/users?page=${option['id']}'),//Encode the url
        headers: {"Accept":"applecation/json"}
    );

  print('該当レコード①:${response.body}');

  //不要　ここから=====>
  var convertDataToJson = jsonDecode(response.body);//不要
  var data = convertDataToJson['data'];//不要
  var selectedRecord = {};
  for(var i=0;i<data.length;i++){
    if(data[i]['id'] == option['id']){
      selectedRecord = data[i];
    }
  }
  print('該当レコード②:${selectedRecord}');
  //<===== ここまで 不要


  //表示用に変換してreturn
//  return jsonDecode(response.body);
  return selectedRecord; //不要
}
