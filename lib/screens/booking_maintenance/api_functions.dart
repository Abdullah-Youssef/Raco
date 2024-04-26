import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:raco_ksa/screens/booking_maintenance/api_response.dart';
import 'package:raco_ksa/screens/booking_maintenance/booking_maintenance_model.dart';

import '../../main.dart';
import 'const.dart';

Future<ApiResponse> fetchBookingMaintenance() async {
  ApiResponse apiResponse = ApiResponse();

  try {
    String token = appStore.token;
    final response =
        await http.get(Uri.parse(bookingMaintenanceIndex), headers: {
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
        List<BookingMaintenanceModel> bookings = jsonData
            .map((book) => BookingMaintenanceModel.fromJson(book))
            .toList();
        print("==========================");
        print(jsonData);
        print(jsonData);
        print("==========================");

        apiResponse.data = bookings;
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

int bookingId = 0;
Future createBookingMaintenance(Map<String, dynamic> data) async {
  String token = appStore.token;
  var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  var request = http.Request('POST', Uri.parse('$bookingMaintenanceStore'));
  request.body = json.encode(data);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);
    bookingId = jsonResponse['data']['id']; // افترض هنا أن مفتاح الـ ID هو "id"
    print("Booking ID: $bookingId");
  } else {
    print(response.reasonPhrase);
  }
  // ApiResponse apiResponse = ApiResponse();

  // try {
  //   String token = appStore.token;

  //   final response = await http.post(
  //     Uri.parse(bookingMaintenanceStore),
  //     body: data,
  //     headers: {"accept": "application/json", "authorization": "Bearer $token"},
  //   );

  //   switch (response.statusCode) {
  //     case 200:
  //       apiResponse.data = jsonDecode(response.body);
  //       break;
  //     case 422:
  //       final errors = jsonDecode(response.body)['errors'];
  //       apiResponse.message = errors[errors.keys.elementAt(0)][0];
  //       break;
  //     case 401:
  //       apiResponse.message = authenticationErrorMessage;
  //       break;
  //     default:
  //       print(response.body);
  //       apiResponse.message = errorMessage;
  //       break;
  //   }
  // } catch (e) {
  //   apiResponse.message = serverErrorMessage;
  // }
  // return apiResponse;
}

Future<Map<String, dynamic>> fetchBookingMaintenanceById(String id) async {
  final response =
      await http.get(Uri.parse('$baseUrl/booking-maintenance/$id'));

  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load booking maintenance');
  }
}

Future updateBookingMaintenance(int id, Map<String, dynamic> data) async {
  String token = appStore.token;
  var headers = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  var request = http.Request('PUT', Uri.parse('$bookingMaintenanceUpdate/$id'));
  request.body = json.encode(data);
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    // print(await response.stream.bytesToString());
    String responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);
    bookingId = jsonResponse['data']['id'];
  } else {
    print(response.reasonPhrase);
  }

  // ApiResponse apiResponse = ApiResponse();
  // try {
  //   String token = appStore.token;
  //   final response = await http.put(Uri.parse('$bookingMaintenanceUpdate/$id'),
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $token'
  //       },
  //       body: {
  //         'body': data
  //       });

  //   switch (response.statusCode) {
  //     case 200:
  //       apiResponse.data = jsonDecode(response.body)['message'];
  //       break;
  //     case 403:
  //       apiResponse.message = jsonDecode(response.body)['message'];
  //       break;
  //     case 401:
  //       apiResponse.message = authenticationErrorMessage;
  //       break;
  //     default:
  //       print(response.body);
  //       apiResponse.message = errorMessage;
  //       break;
  //   }
  // } catch (e) {
  //   apiResponse.message = serverErrorMessage;
  // }
  // return apiResponse;
}

Future<ApiResponse> deleteBookingMaintenance(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = appStore.token;
    final response = await http
        .delete(Uri.parse('$bookingMaintenanceDestroy/$id'), headers: {
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
