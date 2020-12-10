import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi_app/folder/folder_list.dart';
import 'package:recipe_app/page/recipi_app/folder/group_by_folder_list.dart';

class FactoryFolder extends StatelessWidget{

  final _rootPages = <Widget>[ FolderList(),GroupByFolderList()];

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      builder: (context, Display, _) {
        return _rootPages[Display.state];
      },
    );
  }

}