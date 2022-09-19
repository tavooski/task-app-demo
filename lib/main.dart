import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:calendar_task_app_01/db/db_helper.dart';
import 'package:calendar_task_app_01/services/theme_services.dart';
import 'package:calendar_task_app_01/ui/home_page.dart';
import 'package:calendar_task_app_01/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:page_transition/page_transition.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeService().theme,
        home: AnimatedSplashScreen(
            duration: 3000,
            splash: const Text('h a i r l u x', style: TextStyle(fontFamily: 'Blanka', fontSize: 45.0),),
            nextScreen: const HomePage(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.bottomToTop,
            backgroundColor: orangeClr)); //const HomePage());  }
  }
}
