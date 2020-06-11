import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';

class RecipiList extends StatefulWidget{
  _RecipiListState createState() => _RecipiListState();
}

class _RecipiListState extends State<RecipiList>{

  //url
  final String url = "https://reqres.in/api/users?page=2";

  //リスト表示するdata
  List data;

  @override
  void initState() {
    super.initState();
    //一覧情報取得処理の呼び出し
    this.getJsonData();
  }

  //一覧情報取得処理
  Future<String> getJsonData() async{
    var response = await http.get(
      //Encode the url
        Uri.encodeFull(url),
        headers: {"Accept":"applecation/json"}
    );

    print('response:${response.body}');

    setState(() {
      //表示様に変換する
      var convertDataToJson = jsonDecode(response.body);
      data = convertDataToJson['data'];
    });

    return "Success!!";
  }

  onEdit(int id){
    print('selectId[${id}]');
    Provider.of<Display>(context, listen: false).setId(id);
    Provider.of<Display>(context, listen: false).setState(1);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('レシピリスト',
          style: TextStyle(
              color: Colors.grey,
              fontSize: 25

          ),
        ),
        backgroundColor: Colors.white,
      ),
      body:
      ListView.builder(
          itemCount: data == null ? 0 :data.length,
            itemBuilder: (BuildContext context,int index){
            return InkWell(
              onTap: (){
                onEdit(data[index]['id']);
              },
              child:
              Card(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80.0,
                        height: 80.0,
                        child:Image.network(data[index]['avatar']),
                      ),
                      Container(
                        padding: EdgeInsets.all(20),
                        child:Text(data[index]['first_name'],style: TextStyle(fontSize: 17,fontWeight:FontWeight.bold),),
                      )
                    ],
                  ),
                ),
              ),
            );
            }
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          onEdit(-1);

        },
        tooltip: 'Increment',
        child: Icon(Icons.create),
        backgroundColor: Colors.orange,
      ),
    );
  }
}