import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class FavoriteParksPage extends StatefulWidget {
  const FavoriteParksPage({super.key});

  @override
  State<FavoriteParksPage> createState() => _FavoriteParksPageState();
}

class _FavoriteParksPageState extends State<FavoriteParksPage> {
  static const primaryColor = Color(0xFF0056D2);

  // 🔥 MOCK DATA
  List<Map<String, dynamic>> _favoriteParksList = [
    {
      "id": "park_1",
      "name": "İSPARK Kadıköy",
      "capacity": 120,
      "empty": 35,
      "district": "Kadıköy"
    },
    {
      "id": "park_2",
      "name": "İSPARK Beşiktaş",
      "capacity": 200,
      "empty": 50,
      "district": "Beşiktaş"
    },
    {
      "id": "park_3",
      "name": "İSPARK Şişli",
      "capacity": 150,
      "empty": 20,
      "district": "Şişli"
    },
  ];

  bool _isLoading = false;

  BoxDecoration _blueDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: primaryColor,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.15),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Future<void> _removePark(Map<String, dynamic> park) async {
    if (_isLoading) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;
      setState(() {
        _favoriteParksList.removeWhere((p) => p["id"] == park["id"]);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Favori otopark silindi ✅'),
          backgroundColor: primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Otopark silinirken hata oluştu: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> park) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'Emin misin?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        content: Text(
          'Bu otoparkı favorilerinden kaldırmak istediğine emin misin?',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.grey[700],
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'İptal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Sil',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _removePark(park);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          'Favori Otoparklar',
          style: theme.textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(color: primaryColor),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 500));
              },
              color: primaryColor,
              child: _favoriteParksList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.car_detailed,
                            size: MediaQuery.of(context).size.height * 0.12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz favori otopark yok',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: List.generate(
                          _favoriteParksList.length,
                          (index) {
                            final park = _favoriteParksList[index];
                            final occupancyPercentage = ((park["capacity"] -
                                        park["empty"]) /
                                    park["capacity"] *
                                    100)
                                .toStringAsFixed(0);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 20),
                              padding: const EdgeInsets.all(16),
                              decoration: _blueDecoration(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Başlık ve İkon
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.car_rental_rounded,
                                        color: primaryColor,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          park["name"],
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          size: 16,
                                          color: colorScheme.secondary),
                                      const SizedBox(width: 8),
                                      Text(
                                        'İlçe: ${park["district"]}',
                                        style: TextStyle(
                                          color: colorScheme.secondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Toplam Kapasite',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${park["capacity"]}',
                                              style: theme.textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: primaryColor.withOpacity(0.2),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Boş Yer',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${park["empty"]}',
                                              style: theme.textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 1,
                                          height: 40,
                                          color: primaryColor.withOpacity(0.2),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Doluluk Oranı',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: colorScheme.secondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$occupancyPercentage%',
                                              style: theme.textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: primaryColor,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // İlerleme Çubuğu
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Doluluk Durumu',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.secondary,
                                            ),
                                          ),
                                          Text(
                                            '$occupancyPercentage%',
                                            style: theme.textTheme
                                                .displaySmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: primaryColor,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: int.parse(occupancyPercentage) /
                                              100,
                                          minHeight: 8,
                                          backgroundColor:
                                              primaryColor.withOpacity(0.2),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Aksiyon Butonları
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    '${park["name"]} seçildi'),
                                                backgroundColor: primaryColor,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Detaylar',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.remove,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () =>
                                              _confirmDelete(park),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}