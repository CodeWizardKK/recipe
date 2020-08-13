import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/diary/edit_recipi.dart';
import 'package:recipe_app/page/recipi_app/diary/edit_photo.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_edit.dart';

class FactoryDiaryEdit extends StatelessWidget{

  var _rootPages = <Widget>[ DiaryEdit(), EditRecipi(), EditPhoto()];

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