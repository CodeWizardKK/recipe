import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/edit/camera_app.dart';
import 'package:recipe_app/page/list/recipi_list.dart';
import 'package:recipe_app/page/edit/recipi_edit.dart';
import 'package:recipe_app/page/root/list_edit_root.dart';
import 'package:recipe_app/store/display_state.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MultiProvider(
        providers:[
          ChangeNotifierProvider<Display>(create: (_) => Display()),
        ],
        child: ListEditRoot(),
      )
    );
  }
}