import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi/list/recipi_list.dart';
import 'package:recipe_app/page/recipi/list/factory_list.dart';
import 'package:recipe_app/page/recipi/edit/factory_edit.dart';
import 'package:recipe_app/page/recipi/detail/recipi_detail.dart';

class FactoryListEdit extends StatelessWidget{

  var _rootPage = <Widget>[ FactoryList(),RecipiDetail(),FactoryEdit()];


  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      key: GlobalKey(),
      builder: (context,Display,_){
//        if(DisplayState.edit >= rootPage.length){
//          return ErrorPage();
//        }
        return _rootPage[Display.state];
      },
    );
  }
}