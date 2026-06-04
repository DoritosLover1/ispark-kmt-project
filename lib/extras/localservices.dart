import 'dart:convert';
import 'dart:io';

import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IsparkService {
  Future<List<ParkingLot>> fetchParkings() async {
    final supabase = Supabase.instance.client;

    try {
      final res = await supabase.functions.invoke(
        'ispark-otopark-listesi-retrieve',
      );

      final resRaw = res.data;
      final Map<String, dynamic> resData = resRaw is String
          ? jsonDecode(resRaw)
          : Map<String, dynamic>.from(resRaw);

      if (resData['success'] != true) {
        throw Exception(
          'Otopark listesi getirilemedi. Lütfen internetinizi kontrol edin.',
        );
      }

      final List data = resData['data'];
      return data.map<ParkingLot>((e) => ParkingLot.fromJson(e)).toList();
    } on SocketException {
      throw Exception('Bağlantı hatası. Lütfen internetinizi kontrol edin.');
    } on Exception {
      throw Exception(
        'Otopark listesi getirilemedi. Lütfen internetinizi kontrol edin.',
      );
    }
  }
}
