import 'package:flutter/material.dart';
import 'package:ispark_project/global/universaltheme.dart';
import 'package:ispark_project/pages/favoriteparkspage.dart';
import 'package:ispark_project/pages/mappage.dart';
import 'package:ispark_project/pages/settingspage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String keyAPI;
  const HomePage({super.key, required this.keyAPI});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<BottomTabState>(context);

    return Scaffold(
      body: Navigator(
        key: themeProvider.navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => MapPage(keyAPI: widget.keyAPI),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: themeProvider.selectedTab,

        onTap: (index) {
          setState(() {
            themeProvider.setTab(index);
          });

          switch (index) {
            case 0:
              themeProvider.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MapPage(keyAPI: widget.keyAPI),
                ),
              );
              break;

            case 1:
              themeProvider.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => FavoriteParksPage(),
                ),
              );
              break;
            
            case 2:
              themeProvider.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SettingsPage(),
                ),
              );
              break;
          }
        },

        type: BottomNavigationBarType.fixed,

        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.secondary,
        backgroundColor: colorScheme.onPrimary,

        elevation: 8,

        selectedLabelStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),

        unselectedLabelStyle: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
              color: colorScheme.secondary,
            ),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border_rounded),
            label: 'Favoriler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_accessibility_rounded),
            label: 'Ayarlar',
          ),
        ],
      ),
    );
  }
}