import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_howto.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_ocr.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_title.dart';
import 'package:recipe_app/page/recipi_app/recipi/edit_ingredient.dart';
import 'package:recipe_app/store/display_state.dart';

class FactoryRecipiEdit extends StatelessWidget{

  var _rootPages = <Widget>[ RecipiEdit(), EditTitle(),EditIngredient(),EditHowTo(),EditOcr()];

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      key: GlobalKey(),
      builder: (context, Display, _) {
//        if(DisplayState.edit >= rootPage.length){
//          return ErrorPage();
//        }
        return _rootPages[Display.editType];
      },
    );
  }

}