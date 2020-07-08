import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi/list/factory_recipi.dart';
import 'package:recipe_app/page/recipi/list/diary_list.dart';
import 'package:recipe_app/page/recipi/list/home_list.dart';
import 'package:recipe_app/page/recipi/list/album_list.dart';

class FactoryList extends StatelessWidget{

  var _rootPages = <Widget>[HomeList(),FactoryRecipi(),DiaryList(),AlbumList()];


  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      key: GlobalKey(),
      builder: (context,Display,_){
//        if(Display.currentIndex >= _listPages.length){
//          return ErrorPage();
//        }
        return _rootPages[Display.currentIndex];
      },
    );
  }
}