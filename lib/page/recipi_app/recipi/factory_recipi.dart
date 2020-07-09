import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_edit.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_detail.dart';
import 'package:recipe_app/page/recipi_app/recipi/recipi_list.dart';

class FactoryRecipi extends StatelessWidget{

  var _rootPages = <Widget>[ RecipiList(), RecipiDetail(), RecipiEdit()];

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