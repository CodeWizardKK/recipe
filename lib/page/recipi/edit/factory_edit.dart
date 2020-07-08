import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/page/recipi/edit/recipi_edit.dart';
import 'package:recipe_app/page/recipi/edit/camera_app.dart';

class FactoryEdit extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Consumer<Display>(
      key: GlobalKey(),
      builder: (context,Display,_){
        if(Display.isCamera){
          return CameraApp();
        }
        return RecipiEdit();
      },
    );
  }
}