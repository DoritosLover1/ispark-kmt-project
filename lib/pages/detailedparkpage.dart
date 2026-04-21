import 'package:flutter/material.dart';
import 'package:ispark_project/pages/mapswebviewpage.dart';

class DetailedParkPage extends StatefulWidget {
  final Map<String, dynamic> park;

  const DetailedParkPage({super.key, required this.park});

  @override
  State<DetailedParkPage> createState() => _DetailedParkPageState();
}

class _DetailedParkPageState extends State<DetailedParkPage> {
  static const primaryColor = Color(0xFF0056D2);

  bool _isFavorite = false;
  bool _isFavoriteBusy = false;

  void _toggleFavorite() async {
    if (_isFavoriteBusy) return;

    setState(() {
      _isFavoriteBusy = true;
    });

    final newState = !_isFavorite;

    setState(() {
      _isFavorite = newState;
    });

    try {
      // TODO: DB / Firebase / Local storage entegrasyonu yapılacak
      // örnek:
      // await FavoritesService.togglePark(widget.park["parkID"]);

    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite;
      });
    } finally {
      setState(() {
        _isFavoriteBusy = false;
      });
    }
  }

  BoxDecoration _cardDecoration(Color primaryColor) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: primaryColor.withOpacity(0.2),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryColor.withOpacity(0.25),
          blurRadius: 25,
          spreadRadius: 2,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  void _openMapViewer(BuildContext context) {
    final double lat =
        double.tryParse(widget.park["lat"].toString()) ?? 0;
    final double lng =
        double.tryParse(widget.park["lng"].toString()) ?? 0;

    if (lat == 0 || lng == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konum bilgisi hatalı")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapsWebViewPage(
          lat: lat,
          lng: lng,
          name: widget.park["parkName"] ?? "Otopark",
        ),
      ),
    );
  }

  Widget _statusBadge(int isOpen, TextTheme textTheme) {
    final bool open = isOpen == 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: open
            ? Colors.green.withOpacity(0.15)
            : Colors.red.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: open ? Colors.green : Colors.red,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            open ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: open ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 5),
          Text(
            open ? "Açık" : "Kapalı",
            style: textTheme.labelMedium?.copyWith(
              color: open ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String title, String value, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
        Text(
          value,
          style: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final park = widget.park;

    final int capacity =
        int.tryParse(park["capacity"].toString()) ?? 0;

    final int empty =
        int.tryParse(park["emptyCapacity"].toString()) ?? 0;

    final int freeTime =
        int.tryParse(park["freeTime"].toString()) ?? 0;

    final int isOpen =
        int.tryParse(park["isOpen"].toString()) ?? 0;

    final int occupancy =
        capacity == 0 ? 0 : ((capacity - empty) / capacity * 100).toInt();

    return Scaffold(
      backgroundColor: colorScheme.surface,

      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
        title: Text(
          "Otopark Detayı",
          style: textTheme.titleLarge?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,

        actions: [
          AnimatedScale(
            scale: _isFavorite ? 1.2 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              onPressed: _isFavoriteBusy ? null : _toggleFavorite,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(_isFavorite),
                  color: _isFavorite ? Colors.red : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(primaryColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    park["parkName"] ?? "-",
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    park["district"] ?? "-",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${park["parkType"] ?? "-"} • ${park["workHours"] ?? "-"}",
                    style: textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _statusBadge(isOpen, textTheme),
                      Text(
                        "Ücretsiz: $freeTime dk",
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(primaryColor),
              child: Column(
                children: [
                  _row("Kapasite", "$capacity", textTheme),
                  const SizedBox(height: 10),
                  _row("Boş", "$empty", textTheme),
                  const SizedBox(height: 10),
                  _row("Doluluk", "%$occupancy", textTheme),

                  const SizedBox(height: 16),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: occupancy / 100,
                      minHeight: 10,
                      backgroundColor: primaryColor.withOpacity(0.2),
                      valueColor:
                          const AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(primaryColor),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _openMapViewer(context),
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: Text(
                    "Haritada Göster",
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}