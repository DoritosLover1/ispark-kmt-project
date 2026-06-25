import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ispark_project/database/databaseinstance.dart';
import 'package:ispark_project/global/universaltheme.dart';
import 'package:ispark_project/pages/welcomepage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'CheckExpiredReservations') {
        final db = await DBInstance.getInstance();
        final reservations = await db.reservationDao.getAllReservations();

        final now = DateTime.now();
        for (var res in reservations) {
          try {
            final resDate = DateTime.parse(res.date);
            final diff = now.difference(resDate);

            if (diff.inMinutes >= 30) {
              await db.reservationDao.deleteReservation(res.id);
            }
          } catch (e) {}
        }
      }
    } catch (e) {
      return Future.value(false);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  final String keyAPI = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';
  final String supabaseAPI = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  final String supabaseURL = dotenv.env['SUPABASE_URL'] ?? '';
  await Supabase.initialize(url: supabaseURL, anonKey: supabaseAPI);

  await DBInstance.getInstance();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  Workmanager().registerPeriodicTask(
    'ispark-check-expired-reservations',
    'CheckExpiredReservations',
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );

  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (context) => ThemeProvider()),
          provider.ChangeNotifierProvider(
            create: (context) => BottomTabState(),
          ),
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
          routes: {'/': (context) => WelcomePage(keyAPI: keyAPI)},
        );
      },
    );
  }
}
