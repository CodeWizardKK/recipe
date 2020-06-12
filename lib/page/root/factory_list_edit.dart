import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/list/recipi_list.dart';
import 'package:recipe_app/page/edit/factory_edit.dart';

class FactoryListEdit extends StatelessWidget{

  var rootPage = <Widget>[RecipiList(),FactoryEdit()];


  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      builder: (context,Display,_){
//        if(DisplayState.edit >= rootPage.length){
//          return ErrorPage();
//        }
        return rootPage[Display.state];
      },
    );
  }
}