import 'dart:convert';

import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class IsparkService {
  Future<List<ParkingLot>> fetchParkings() async {
    final supabase = Supabase.instance.client;

    final res = await supabase.functions.invoke('ispark-otopark-listesi-retrieve');

    final resRaw = res.data;
    final Map<String, dynamic> resData = resRaw is String
        ? jsonDecode(resRaw)
        : Map<String, dynamic>.from(resRaw);

    if (resData['success'] != true) {
      throw Exception('İnternetiniz kapalı olduğundan veriler çekilemedi' ?? 'Veri çekilemedi');
    }

    final List data = resData['data'];
    return data.map<ParkingLot>((e) => ParkingLot.fromJson(e)).toList();
  }
}