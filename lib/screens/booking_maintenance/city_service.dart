import 'dart:convert';
import 'package:http/http.dart' as http;

import 'city_model.dart';
import 'const.dart';

class CityService {
  static Future<List<City>> fetchCities() async {
    final response = await http.get(Uri.parse('$allCities'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => City.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch cities');
    }
  }

  static Future<City> fetchCityDetails(int cityId) async {
    final response = await http.get(Uri.parse('$allCities/$cityId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return City.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch city details');
    }
  }
}
