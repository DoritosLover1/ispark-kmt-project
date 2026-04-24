import 'dart:convert';

import 'package:ispark_project/localentity/parkinglot.dart';
import 'package:http/http.dart' as http;

class IsparkService {
  Future<List<ParkingLot>> fetchParkings() async {
    final response =
        await http.get(Uri.parse("https://api.ibb.gov.tr/ispark/Park"));

    final List data = json.decode(response.body);

    return data
        .map<ParkingLot>((e) => ParkingLot.fromJson(e))
        .toList();
  }
}