import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_list.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_list_group_folder.dart';

class FactoryRecipi extends StatelessWidget{

  var _rootPages = <Widget>[ RecipiList(),RecipiListGroupFolder()];

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