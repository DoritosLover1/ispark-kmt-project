
import 'package:flutter/material.dart';
import 'package:ispark_project/global/universaltheme.dart';
import 'package:ispark_project/pages/mappage.dart';
import 'package:ispark_project/pages/settingspage.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final String keyAPI;
  const HomePage({super.key, required this.keyAPI});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>  {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final _bottomTabState = Provider.of<BottomTabState>(context);
    return Scaffold(
      body: Navigator(
        key: _bottomTabState.navigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => MapPage(keyAPI: widget.keyAPI),
          )
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomTabState.selectedTab,
        onTap: (index) async {
          setState(() {
            _bottomTabState.setTab(index);
          });

          switch (index) {
            case 0:
              _bottomTabState.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MapPage(keyAPI: widget.keyAPI), 
                  ),
              );
              break;
            
            case 1:
              _bottomTabState.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => FavoriteParksPage() 
                  ),
              );
              break;
            
            case 2:
              _bottomTabState.navigatorKey.currentState!.pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SettingsPage() 
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: 'Harita'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Favoriler'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_accessibility_rounded), label: 'Ayarlar'),
        ],
      ),
    );
  }
}