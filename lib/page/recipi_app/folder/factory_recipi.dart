import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/folder/folder_list.dart';
import 'package:recipe_app/page/recipi_app/folder/group_by_folder_list.dart';

class FactoryFolder extends StatelessWidget{

  var _rootPages = <Widget>[ FolderList(),GroupByFolderList()];

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
//      key: GlobalKey(),
      builder: (context, Display, _) {
//        if(DisplayState.edit >= rootPage.length){
//          return ErrorPage();
//        }
        return _rootPages[Display.state];
      },
    );
  }

}