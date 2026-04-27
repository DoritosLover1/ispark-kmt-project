import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ispark_project/database/databaseinstance.dart';
import 'package:ispark_project/global/universaltheme.dart';
import 'package:ispark_project/pages/welcomepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart' as provider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  print("API KEY => ${dotenv.env['MAPTILER_MAPS_API_KEY']}");
  
  final String keyAPI = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';
  await DBInstance.getInstance();

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (context) => ThemeProvider()),
          provider.ChangeNotifierProvider(create: (context) => BottomTabState()),
        ],
        child: MyApp(keyAPI: keyAPI),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String keyAPI;

  const MyApp({super.key, required this.keyAPI});

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ISpark',
          theme: themeProvider.themeData,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => WelcomePage(keyAPI: keyAPI),
          },
        );
      },
    );
  }
}