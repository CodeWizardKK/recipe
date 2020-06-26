import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/root/factory_list_edit.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';//日本語対応

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RECIPI APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //多言語対応 ここから==>
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate, //ダイアログ用messageの日本語対応で必須
      ],
      supportedLocales: [
        Locale('ja', 'JP'),
      ],
      //<== 多言語対応 ここまで
      home: MultiProvider(
        providers:[
          ChangeNotifierProvider<Display>(create: (_) => Display()),
        ],
        child: FactoryListEdit(),
      )
    );
  }
}