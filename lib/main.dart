import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';//日本語対応
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

import 'package:recipe_app/page/factory_recipi_app.dart';
import 'package:recipe_app/store/display_state.dart';
import 'package:recipe_app/services/http/versionCheckService.dart';
import 'package:recipe_app/services/http/errorService.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  //アクセスするオブジェクトの登録
  locator.registerLazySingleton<versionCheckService>(() => versionCheckService());
  locator.registerLazySingleton<errorService>(() => errorService());
}

void main() async {

  setupLocator(); //バージョンチェック

  //向き指定 ===>
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,//縦固定
  ]);
  //向き指定 <===
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Debug無効
      debugShowCheckedModeBanner: false,
//        key: GlobalKey(),
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
        child: FactoryRecipiApp(),
      ),
    );
  }
}
