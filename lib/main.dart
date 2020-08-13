import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/page/recipi_app/factory_recipi_app.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/store/detail_state.dart';
import 'package:recipe_app/store/diary/edit_state.dart';
import 'package:flutter_localizations/flutter_localizations.dart';//日本語対応
import 'package:flutter/services.dart';

void main() {
  //向き指定 ===>
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  //向き指定 <===
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        key: GlobalKey(),
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
          ChangeNotifierProvider<Detail>(create: (_) => Detail()),
          ChangeNotifierProvider<Edit>(create: (_) => Edit()),
        ],
        child: FactoryRecipiApp(),
      )
    );
  }
}