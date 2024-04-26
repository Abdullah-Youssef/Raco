import 'dart:convert';
import 'package:http/http.dart' as http;

import 'const.dart';
import 'model_code_model.dart';

class ModelCodeService {
  static Future<List<ModelCode>> fetchModelCodes() async {
    final response = await http.get(Uri.parse('$allModelCodes'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => ModelCode.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch Model Codes');
    }
  }

  static Future<ModelCode> fetchModelCodeDetails(int modelCodeId) async {
    final response = await http.get(Uri.parse('$allCities/$modelCodeId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return ModelCode.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch Model Code details');
    }
  }
}
