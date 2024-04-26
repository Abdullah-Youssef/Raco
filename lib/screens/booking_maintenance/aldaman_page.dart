import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:raco_ksa/main.dart';
import '../../component/loader_widget.dart';
import '../../utils/constant.dart';
import 'aldaman_form.dart';
import 'aldaman_model.dart';
import 'aldaman_service.dart';
import 'api_response.dart';
import 'package:http/http.dart' as http;

class Aldaman extends StatefulWidget {
  const Aldaman({super.key});

  @override
  State<Aldaman> createState() => _AldamanState();
}

class _AldamanState extends State<Aldaman> {
  var aldamans = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("=======================================");
    print(appStore.token);
    print("=======================================");
    fetchAldamansData();
  }

  Future<void> fetchAldamansData() async {
    try {
      ApiResponse response = await fetchAldaman();

      if (response.message != null) {
        print('حدث خطأ: ${response.message}');
        return;
      }

      setState(() {
        aldamans = response.data! as List<AldamanModel>;
        isLoading = false;
      });
    } catch (e) {
      print('حدث خطأ: $e');
    }
  }

  Future<void> _refreshData() async {
    await fetchAldamansData();
  }

  TimeOfDayFormat timeFormat = TimeOfDayFormat.h_colon_mm_space_a;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          elevation: 10.0,
          backgroundColor: context.primaryColor,
          child: Icon(
            Icons.add,
            color: white,
          ),
          onPressed: () {
            AldamanForm().launch(context);
          }),
      appBar: appBarWidget(
        "الضمان",
        textColor: white,
        showBack: true,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         Navigator.of(context).push(MaterialPageRoute(
        //             builder: (context) => MaintenanceForm(
        //                   typeForm: "store",
        //                 )));
        //       },
        //       icon: Icon(Icons.add))
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SizedBox(
          width: context.width(),
          height: context.height(),
          child: isLoading
              ? Center(
                  child: LoaderWidget(),
                )
              : (aldamans.isEmpty
                  ? Center(
                      child: Text('لم يتم تسجيل أي ضمان حتى الآن'),
                    )
                  : ListView.builder(
                      itemCount: aldamans.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingMaintenanceDetailsPage(
                                        id: aldamans[index].id),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: context.dividerColor),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'رقم الضمان: ${aldamans[index].id}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                        'كود الموديل: ${aldamans[index].modelCode}'),
                                    SizedBox(
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )),
        ),
      ),
    );
  }
}

class BookingMaintenanceDetailsPage extends StatefulWidget {
  // final BookingMaintenanceModel booking;
  final int id;

  const BookingMaintenanceDetailsPage({required this.id});

  @override
  State<BookingMaintenanceDetailsPage> createState() =>
      _BookingMaintenanceDetailsPageState();
}

class _BookingMaintenanceDetailsPageState
    extends State<BookingMaintenanceDetailsPage> {
  @override
  void initState() {
    super.initState();
    fetchAldamanDetails(widget.id);
  }

  // late BookingMaintenanceModel orderData;

  AldamanModel? orderData;
  bool isLoading = true;

  Future<void> fetchAldamanDetails(int id) async {
    try {
      String token = appStore.token;

      final response = await http.get(
          Uri.parse('https://catalog.raco-ksa.com/api/aldaman/$id'),
          headers: {
            "authorization": "Bearer $token",
            "content-type": "application/json; charset=utf-8",
            "accept": "application/json",
            "cache-control": "no-cache",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Origin": "*"
          });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final orderJson = jsonData['data'][0];
        setState(() {
          orderData = AldamanModel.fromJson(orderJson);
          isLoading = false;
        });
      } else {
        print(
            'Failed to fetch Aldaman details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching Aldaman details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'تفاصيل الضمان',
        textColor: white,
        showBack: true,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: LoaderWidget(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(
                        // columnSpacing: MediaQuery.of(context).size.width * 0.35,
                        // dataRowHeight: 50,
                        // horizontalMargin: 5,
                        dataRowMaxHeight: double.infinity,
                        columnSpacing: 0,
                        horizontalMargin: 0,
                        // checkboxHorizontalMargin: 5,
                        // border: TableBorder.all(),
                        columns: [
                          DataColumn(
                              label: Container(
                            width: MediaQuery.of(context).size.width * 0.25,
                            child: Text(
                              'رقم الضمان:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            '${orderData?.id}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          )),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('اسم العميل:')),
                            DataCell(Text('${orderData?.customerName}')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('رقم الهاتف:')),
                            DataCell(Text('${orderData?.mobileNumber}')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('كود الموديل:')),
                            DataCell(Text('${orderData?.modelCode}')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('الرقم التسلسلي')),
                            DataCell(Text('${orderData?.serialNumber}')),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
