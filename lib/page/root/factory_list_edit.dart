import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi/list/recipi_list.dart';
import 'package:recipe_app/page/recipi/edit/factory_edit.dart';
import 'package:recipe_app/page/recipi/detail/recipi_detail.dart';

class FactoryListEdit extends StatelessWidget{

  var rootPage = <Widget>[RecipiList(),RecipiDetail(),FactoryEdit()];


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