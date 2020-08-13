import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_list.dart';
import 'package:recipe_app/page/recipi_app/diary/diary_detail.dart';
import 'package:recipe_app/page/recipi_app/diary/factory_diary_edit.dart';

class FactoryDiary extends StatelessWidget{

  var _rootPages = <Widget>[ DiaryList(), DiaryDetail(), FactoryDiaryEdit()];

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      key: GlobalKey(),
      builder: (context, Display, _) {
//        if(DisplayState.edit >= rootPage.length){
//          return ErrorPage();
//        }
        return _rootPages[Display.state];
      },
    );
  }

}