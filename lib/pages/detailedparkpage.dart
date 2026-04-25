import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:ispark_project/extras/parkingmarkers.dart';
import 'package:ispark_project/database/databaseinstance.dart';
import 'package:ispark_project/database/entity/favorite.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart'; 

class DetailedParkPage extends StatefulWidget {
  final Map<String, dynamic> park;
  final String keyAPI = dotenv.env['MAPTILER_MAPS_API_KEY'] ?? '';

  DetailedParkPage({super.key, required this.park});

  @override
  State<DetailedParkPage> createState() => _DetailedParkPageState();
}

class _DetailedParkPageState extends State<DetailedParkPage> {
  static const primaryColor = Color(0xFF0056D2);

  bool _isFavorite = false;
  bool _isFavoriteBusy = false;

  late TextEditingController _plateController;
  late TextEditingController _phoneController;
  String? _plateError;
  String? _phoneError;
  bool _isCreatingReservation = false;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController();
    _phoneController = TextEditingController();
    _checkIfFavorite();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final db = await DBInstance.getInstance();
      final parkID = widget.park["parkID"];

      final favorite = await db.favoritesDao.findFavorite(parkID);
      
      if (mounted) {
        setState(() {
          _isFavorite = favorite != null;
        });
      }
    } catch (e) {
      print('Favori kontrol hatası: $e');
    }
  }

  void _toggleFavorite() async {
    if (_isFavoriteBusy) return;

    setState(() {
      _isFavoriteBusy = true;
    });

    final newState = !_isFavorite;
    final parkID = widget.park["parkID"];
    final parkName = widget.park["parkName"] ?? "Otopark";

    try {
      final db = await DBInstance.getInstance();

      if (newState) {
        final favorite = Favorite(
          id: DateTime.now().millisecondsSinceEpoch,
          parkID: parkID,
          parkName: parkName,
          district: widget.park["district"] ?? "",
          parkType: widget.park["parkType"] ?? "",
          workHours: widget.park["workHours"] ?? "",
          capacity: int.tryParse(widget.park["capacity"].toString()) ?? 0,
          freeTime: int.tryParse(widget.park["freeTime"].toString()) ?? 0,
          lat: widget.park['lat'],
          lng: widget.park['lng']
        );

        await db.favoritesDao.insertFavorite(favorite);

        if (mounted) {
            ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(
                    '${parkName} favorilere eklendi.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),),
                  backgroundColor: primaryColor,
                  behavior:
                    SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(12),
                  ),
                ),
              );
        }
      } else {
        await db.favoritesDao.deleteFavoriteByParkID(parkID);

        if (mounted) {
            ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(
                    '${parkName} favorilerden çıkarıldı.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),),
                  backgroundColor: primaryColor,
                  behavior:
                    SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                      BorderRadius.circular(12),
                  ),
                ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isFavorite = newState;
        });
      }
    } catch (e) {
      print('Favori toggle hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFavoriteBusy = false;
        });
      }
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

    _openGoogleMaps(context, lat, lng);
  }
 
  Future<void> _openGoogleMaps(BuildContext context, double lat, double lng) async {
    final String googleMapsAppUrl = 'google.navigation:q=$lat,$lng&z=16';

    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
 
    try {
      if (await canLaunchUrl(Uri.parse(googleMapsAppUrl))) {
        await launchUrl(Uri.parse(googleMapsAppUrl));
      } else if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(Uri.parse(googleMapsUrl));
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Google Maps açılamadı")),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e")),
        );
      }
    }
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

  void _validatePlate() {
    final plate = _plateController.text.trim().toUpperCase();

    if (plate.isEmpty) {
      setState(() {
        _plateError = 'Plaka boş olamaz';
      });
      return;
    }
    if (!RegExp(r'^[A-Z]{2}\d{4}[A-Z]{2}$|^[A-Z]\d{4}[A-Z]{3}$').hasMatch(plate)) {
      setState(() {
        _plateError = 'Geçerli bir plaka girin (ör: 34ABC1234)';
      });
      return;
    }

    setState(() {
      _plateError = null;
    });
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _phoneError = 'Telefon numarası boş olamaz';
      });
      return;
    }

    if (!RegExp(r'^05\d{9}$').hasMatch(phone)) {
      setState(() {
        _phoneError = 'Geçerli bir telefon numarası girin (05XXXXXXXXX)';
      });
      return;
    }

    setState(() {
      _phoneError = null;
    });
  }

  void _createReservation() async {
    _validatePlate();
    _validatePhone();

    if (_plateError != null || _phoneError != null) {
      return;
    }

    setState(() {
      _isCreatingReservation = true;
    });

    try {
      final plate = _plateController.text.trim().toUpperCase();
      final phone = _phoneController.text.trim();
      final parkID = widget.park["parkID"] ?? 0;
      final parkName = widget.park["parkName"] ?? "Otopark";

      // TODO: API çağrısı veya DB işlemi yapılacak
      print('Randevu Oluşturuluyor:');
      print('- Park: $parkName (ID: $parkID)');
      print('- Plaka: $plate');
      print('- Telefon: $phone');

      // Başarı mesajı
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Randevu başarıyla oluşturuldu! Plaka: $plate'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Formu temizle
        _plateController.clear();
        _phoneController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isCreatingReservation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final park = widget.park;
    final parkLoc = LatLng(park["lat"], park["lng"]);

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
              child: Column(
                spacing: 10,
                children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: FlutterMap(
                      options: MapOptions(
                        interactionOptions: InteractionOptions(
                          flags: InteractiveFlag.none
                        ),
                        initialCenter: parkLoc,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              "https://api.maptiler.com/maps/hybrid/256/{z}/{x}/{y}.jpg?key=${widget.keyAPI}",
                          userAgentPackageName: "com.example.app",
                        ),
                        MarkerLayer(
                          markers: [
                            ParkingMarkers.getSingleParkingMarker(park, context)
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openMapViewer(context),
                      icon: const Icon(Icons.map, color: Colors.white),
                      label: Text(
                        "Yol Tarifi Al",
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
                ],
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(primaryColor),
              child: Column(
                children: [
                  TextField(
                    controller: _plateController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Araç Plakası',
                      hintText: '34ABC1234',
                      prefixIcon: const Icon(Icons.directions_car),
                      errorText: _plateError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      if (_plateError != null) {
                        setState(() => _plateError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Telefon Numarası',
                      hintText: '5xxxxxxxxxx',
                      prefixIcon: const Icon(Icons.phone),
                      errorText: _phoneError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCreatingReservation
                          ? null
                          : _createReservation,
                      icon: _isCreatingReservation
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.calendar_today),
                      label: Text(
                        _isCreatingReservation
                            ? 'Oluşturuluyor...'
                            : 'Randevu Oluştur',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        disabledBackgroundColor:
                            primaryColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}