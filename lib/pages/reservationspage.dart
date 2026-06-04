import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ispark_project/database/entity/reservation.dart';
import 'package:ispark_project/providers/reservation_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationsPage extends ConsumerStatefulWidget {
  const ReservationsPage({super.key});

  @override
  ConsumerState<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends ConsumerState<ReservationsPage> {
  static const primaryColor = Color(0xFF0056D2);
  bool _isCanceling = false;

  BoxDecoration _blueDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: primaryColor, width: 2),
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

  Future<void> _cancelReservation(Reservation reservation, String otp) async {
    setState(() => _isCanceling = true);
    try {
      final supabase = Supabase.instance.client;

      final resRes = await supabase.functions.invoke(
        'ispark-rezervasyon-iptal-handler',
        body: {
          'plaka': reservation.plate,
          'otopark_id': reservation.parkID.toString(),
          'telefon_numarasi': reservation.phone,
          'otp': otp,
        },
      );

      final resRaw = resRes.data;
      final Map<String, dynamic> resData = resRaw is String
          ? jsonDecode(resRaw)
          : Map<String, dynamic>.from(resRaw);

      if (resData['success'] != true) {
        throw Exception(
          resData['error'] ??
              'Rezervasyon ya hiç oluşmamış ya da çoktan silinmiş.',
        );
      }

      await ref
          .read(reservationParksProvider.notifier)
          .removeReservation(reservation.parkID, reservation.plate);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rezervasyon başarıyla iptal edildi.',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
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
            content: Text(
              'İptal edilirken hata oluştu: $e',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
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
        setState(() => _isCanceling = false);
      }
    }
  }

  Future<void> _showCancelDialog(Reservation reservation) async {
    final otpController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Text(
          'Rezervasyonu İptal Et',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${reservation.parkName} otoparkındaki rezervasyonunuzu iptal etmek için lütfen size verilen 6 haneli OTP kodunu giriniz.',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'OTP Kodu',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.password, color: primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              'Geri',
              style: Theme.of(context)
                  .textTheme
                  .displayMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (otpController.text.trim().length == 6) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              'İptal Et',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      _cancelReservation(reservation, otpController.text.trim());
    }
  }

  Future<void> _openGoogleMaps(
    BuildContext context,
    double lat,
    double lng,
  ) async {
    final String googleMapsAppUrl = 'google.navigation:q=$lat,$lng&z=16';
    final String googleMapsUrl =
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng';

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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final reservationsList = ref.watch(reservationParksProvider);

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        surfaceTintColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.onPrimary,
        elevation: 0,
        title: Text(
          'Rezervasyonlarım',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(reservationParksProvider.notifier).loadReservations(),
              color: primaryColor,
              child: reservationsList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: MediaQuery.of(context).size.height * 0.12,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Henüz rezervasyonunuz yok',
                            style: theme.textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Otopark detayından randevu oluşturabilirsiniz.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: List.generate(reservationsList.length, (
                              index,
                            ) {
                              final reservation = reservationsList[index];
                              
                              final dateObj = DateTime.tryParse(reservation.date) ?? DateTime.now();
                              final dateStr = "${dateObj.day.toString().padLeft(2, '0')}/${dateObj.month.toString().padLeft(2, '0')}/${dateObj.year} ${dateObj.hour.toString().padLeft(2, '0')}:${dateObj.minute.toString().padLeft(2, '0')}";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                padding: const EdgeInsets.all(16),
                                decoration: _blueDecoration(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.local_parking_rounded,
                                          color: primaryColor,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            reservation.parkName,
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
                                        Icon(
                                          Icons.directions_car,
                                          size: 16,
                                          color: colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Plaka: ${reservation.plate}',
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Tarih: $dateStr',
                                          style: TextStyle(
                                            color: colorScheme.secondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _openGoogleMaps(context, reservation.lat, reservation.lng),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: primaryColor,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'Yol Tarifi Al',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () => _showCancelDialog(reservation),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              'İptal Et',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),
                        if (_isCanceling)
                          Container(
                            color: Colors.black.withOpacity(0.3),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
