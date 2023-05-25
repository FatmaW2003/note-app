import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:note_app/db/db_helper.dart';

import 'package:note_app/ui/pages/home_page.dart';
import 'package:note_app/ui/theme.dart';

import 'services/theme_services.dart';



void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
    theme: Themes.light,
      darkTheme:Themes.dark ,
      themeMode:ThemeServices().theme,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home:const HomePage(),
    );
  }
}
