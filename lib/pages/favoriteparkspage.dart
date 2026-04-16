import 'package:flutter/material.dart';

// COMPLETLY MOCK. WE NEED TO RESDESIGN IT
class FavoriteParksPage extends StatefulWidget {
  const FavoriteParksPage({super.key});

  @override
  State<FavoriteParksPage> createState() => _FavoriteParksPageState();
}

class _FavoriteParksPageState extends State<FavoriteParksPage> {

  // 🔥 MOCK DATA
  List<Map<String, dynamic>> favoriteParks = [
    {
      "name": "İSPARK Kadıköy",
      "capacity": 120,
      "empty": 35,
      "district": "Kadıköy"
    },
    {
      "name": "İSPARK Beşiktaş",
      "capacity": 200,
      "empty": 50,
      "district": "Beşiktaş"
    },
    {
      "name": "İSPARK Şişli",
      "capacity": 150,
      "empty": 20,
      "district": "Şişli"
    },
  ];

  void removePark(int index) {
    setState(() {
      favoriteParks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favori Otoparklar"),
        centerTitle: true,
      ),
      body: favoriteParks.isEmpty
          ? const Center(
              child: Text(
                "Henüz favori otopark eklemedin 🚗",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: favoriteParks.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final park = favoriteParks[index];

                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      park["name"],
                      style: theme.textTheme.titleMedium,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text("İlçe: ${park["district"]}"),
                        Text("Toplam Kapasite: ${park["capacity"]}"),
                        Text("Boş Yer: ${park["empty"]}"),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => removePark(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}