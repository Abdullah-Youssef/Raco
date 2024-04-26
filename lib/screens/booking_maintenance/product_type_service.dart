import 'dart:convert';
import 'package:http/http.dart' as http;

import 'const.dart';
import 'product_type_model.dart';

class ProductTypeService {
  static Future<List<ProductType>> fetchProductTypes() async {
    final response = await http.get(Uri.parse('$allProductTypes'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => ProductType.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch Product Types');
    }
  }

  static Future<ProductType> fetchProductTypeDetails(int productTypeId) async {
    final response = await http.get(Uri.parse('$allCities/$productTypeId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return ProductType.fromJson(responseData);
    } else {
      throw Exception('Failed to fetch Product Type details');
    }
  }
}
