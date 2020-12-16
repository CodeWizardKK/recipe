import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/diary/diary_list.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi/recipi_list.dart';
import 'package:recipe_app/page/home/home_list.dart';
import 'package:recipe_app/page/album/album_list.dart';
import 'package:recipe_app/page/folder/factory_folder.dart';

class FactoryRecipiApp extends StatelessWidget{

  final _rootPages = <Widget>[HomeList(),RecipiList(),FactoryFolder(),DiaryList(),AlbumList()];

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      builder: (context,Display,_){
        return _rootPages[Display.currentIndex];
      },
    );
  }
}