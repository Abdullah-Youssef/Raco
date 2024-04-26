import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:raco_ksa/screens/booking_maintenance/api_response.dart';
import '../../main.dart';
import 'aldaman_model.dart';
import 'const.dart';

Future<ApiResponse> fetchAldaman() async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = appStore.token;
    final response = await http.get(Uri.parse('$baseUrl/aldaman'), headers: {
      "authorization": "Bearer $token",
      "content-type": "application/json; charset=utf-8",
      "accept": "application/json",
      "cache-control": "no-cache",
      "Access-Control-Allow-Headers": "*",
      "Access-Control-Allow-Origin": "*"
    });

    switch (response.statusCode) {
      case 200:
        List<dynamic> jsonData = jsonDecode(response.body)['data'];
        List<AldamanModel> aldamans =
            jsonData.map((aldaman) => AldamanModel.fromJson(aldaman)).toList();
        print("==========================");
        print(jsonData);
        print(jsonData);
        print("==========================");

        apiResponse.data = aldamans;
        break;
      case 401:
        apiResponse.message = authenticationErrorMessage;
        break;
      default:
        apiResponse.message = errorMessage;
        break;
    }
  } catch (e) {
    apiResponse.message = serverErrorMessage;
  }

  return apiResponse;
}

int aldamanId = 0;
Future createAldaman(Map<String, dynamic> data) async {
  String token = appStore.token;
  var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  var request = http.Request('POST', Uri.parse('$baseUrl/aldaman'));
  request.body = json.encode(data);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);
    aldamanId = jsonResponse['data']['id']; // افترض هنا أن مفتاح الـ ID هو "id"
    print("Aldaman ID: $aldamanId");
  } else {
    print(response.reasonPhrase);
  }
}

Future<Map<String, dynamic>> fetchAldamanById(String id) async {
  final response = await http.get(Uri.parse('$baseUrl/aldaman/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load aldaman');
  }
}

Future updateAldaman(int id, Map<String, dynamic> data) async {
  String token = appStore.token;
  var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  var request = http.Request('PUT', Uri.parse('$baseUrl/aldaman/$id'));
  request.body = json.encode(data);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);
    aldamanId = jsonResponse['data']['id'];
  } else {
    print(response.reasonPhrase);
  }
}

Future<ApiResponse> deleteAldaman(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = appStore.token;
    final response = await http.delete(Uri.parse('$baseUrl/aldaman/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.message = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.message = authenticationErrorMessage;
        break;
      default:
        print(response.body);
        apiResponse.message = errorMessage;
        break;
    }
  } catch (e) {
    apiResponse.message = serverErrorMessage;
  }
  return apiResponse;
}
