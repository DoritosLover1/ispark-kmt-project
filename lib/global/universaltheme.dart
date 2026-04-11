import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomTabState extends ChangeNotifier {
  int _selectedTab = 0;

  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  int get selectedTab => _selectedTab;

  void setTab(int index) {
    _selectedTab = index;
    notifyListeners();
  }
}

class ThemeProvider extends ChangeNotifier {
  double _fontsize = 12.0;
  String _fontFamily = 'Inter';

  double get fontSize => _fontsize;
  String get fontFamily => _fontFamily;

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _fontsize = prefs.getDouble('fontSize') ?? 12.0;
    _fontFamily = prefs.getString('fontFamily') ?? 'Inter';
    notifyListeners();
  }

  Future<void> updateFontSize(double newSize) async {
    _fontsize = newSize;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', newSize);
    notifyListeners();
  }

  Future<void> updateFontFamily(String newFont) async {
    _fontFamily = newFont;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fontFamily', newFont);
    notifyListeners();
  }

  TextStyle _createTextStyle(double multiplier,
      {FontWeight? fontWeight}) {
    return TextStyle(
      fontSize: _fontsize * multiplier,
      fontWeight: fontWeight,
    );
  }

  ThemeData get themeData {
    TextTheme baseTextTheme;

    switch (_fontFamily) {
      case 'Roboto':
        baseTextTheme = GoogleFonts.robotoTextTheme();
        break;
      case 'Poppins':
        baseTextTheme = GoogleFonts.poppinsTextTheme();
        break;
      case 'Montserrat':
        baseTextTheme = GoogleFonts.montserratTextTheme();
        break;
      case 'Lato':
        baseTextTheme = GoogleFonts.latoTextTheme();
        break;
      case 'Open Sans':
        baseTextTheme = GoogleFonts.openSansTextTheme();
        break;
      case 'Raleway':
        baseTextTheme = GoogleFonts.ralewayTextTheme();
        break;
      case 'Ubuntu':
        baseTextTheme = GoogleFonts.ubuntuTextTheme();
        break;
      case 'Nunito':
        baseTextTheme = GoogleFonts.nunitoTextTheme();
        break;
      case 'Playfair Display':
        baseTextTheme = GoogleFonts.playfairDisplayTextTheme();
        break;
      case 'Inter':
      default:
        baseTextTheme = GoogleFonts.interTextTheme();
        break;
    }

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF0056D2),
        onPrimary: Colors.white,
        secondary: Color(0xFF546E7A),
        onSecondary: Colors.white,
        surface: Color(0xFFF8F9FA),
        onSurface: Colors.black,
        error: Color(0xFFA93802),
        onError: Colors.white,
      ),
      textTheme: baseTextTheme
          .copyWith(
            headlineLarge:
                _createTextStyle(2.67, fontWeight: FontWeight.w600),
            headlineMedium:
                _createTextStyle(2.33, fontWeight: FontWeight.w600),
            headlineSmall:
                _createTextStyle(1.67, fontWeight: FontWeight.w600),
            displayLarge: _createTextStyle(1.33),
            displayMedium: _createTextStyle(1.167),
            displaySmall: _createTextStyle(1.0),
          )
          .apply(fontFamily: _getFontFamily()),
    );
  }

  String _getFontFamily() {
    switch (_fontFamily) {
      case 'Roboto':
        return GoogleFonts.roboto().fontFamily!;
      case 'Poppins':
        return GoogleFonts.poppins().fontFamily!;
      case 'Montserrat':
        return GoogleFonts.montserrat().fontFamily!;
      case 'Lato':
        return GoogleFonts.lato().fontFamily!;
      case 'Open Sans':
        return GoogleFonts.openSans().fontFamily!;
      case 'Raleway':
        return GoogleFonts.raleway().fontFamily!;
      case 'Ubuntu':
        return GoogleFonts.ubuntu().fontFamily!;
      case 'Nunito':
        return GoogleFonts.nunito().fontFamily!;
      case 'Playfair Display':
        return GoogleFonts.playfairDisplay().fontFamily!;
      case 'Inter':
      default:
        return GoogleFonts.inter().fontFamily!;
    }
  }
}