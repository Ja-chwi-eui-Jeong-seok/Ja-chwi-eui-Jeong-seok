import 'dart:convert';
import 'package:flutter/services.dart';

Future<List<Map<String, String>>> loadSidoJson() async {
  final jsonString = await rootBundle.loadString('assets/config/sido.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return List<Map<String, String>>.from(jsonList);
}
