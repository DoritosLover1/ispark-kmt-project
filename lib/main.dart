import 'package:flutter/material.dart';
import 'package:ispark_project/global/universaltheme.dart';
import 'package:ispark_project/pages/welcomepage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ChangeNotifierProvider(create: (context) => BottomTabState()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const WelcomePage(),
          },
        );
      },
    );
  }
}
