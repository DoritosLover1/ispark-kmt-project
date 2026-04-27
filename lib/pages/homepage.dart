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
  // Her tab için kendi Navigator'ı
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<BottomTabState>(context);

    return Scaffold(
      body: IndexedStack(
        index: themeProvider.selectedTab,
        children: [
          Navigator(
            key: _navigatorKeys[0],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => MapPage(keyAPI: widget.keyAPI),
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[1],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => FavoriteParksPage(),
              );
            },
          ),
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (settings) {
              return MaterialPageRoute(
                builder: (_) => SettingsPage(),
              );
            },
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: themeProvider.selectedTab,

        onTap: (index) {
          themeProvider.setTab(index);
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