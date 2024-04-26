import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:raco_ksa/main.dart';
import '../../component/empty_error_state_widget.dart';
import '../../component/loader_widget.dart';
import '../../utils/constant.dart';
import '../dashboard/dashboard_screen.dart';
import 'api_functions.dart';
import 'api_response.dart';
import 'booking_maintenance_model.dart';
import 'maintenance_form.dart';
import 'package:http/http.dart' as http;

class BookingMaintenance extends StatefulWidget {
  const BookingMaintenance({super.key});

  @override
  State<BookingMaintenance> createState() => _BookingMaintenanceState();
}

class _BookingMaintenanceState extends State<BookingMaintenance> {
  var bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print("=======================================");
    print(appStore.token);
    print("=======================================");
    fetchBookingMaintenanceData();
  }

  String error = "";

  Future<void> fetchBookingMaintenanceData() async {
    try {
      ApiResponse response = await fetchBookingMaintenance();

      if (response.message != null) {
        log(response.message);
        if (!await isNetworkAvailable()) {
          setState(() {
            error = errorInternetNotAvailable;
          });
        } else {
          error = response.message ?? "خطأ";
        }
        return;
      }

      setState(() {
        bookings = response.data! as List<BookingMaintenanceModel>;
        isLoading = false;
      });
    } catch (e) {
      log(e);
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      error = "";
    });
    await fetchBookingMaintenanceData();
  }

  TimeOfDayFormat timeFormat = TimeOfDayFormat.h_colon_mm_space_a;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (error != errorInternetNotAvailable || error == "")
          ? FloatingActionButton(
              elevation: 10.0,
              backgroundColor: context.primaryColor,
              child: Icon(
                Icons.add,
                color: white,
              ),
              onPressed: () {
                MaintenanceForm(
                  typeForm: "store",
                ).launch(context);
              })
          : null,
      appBar: appBarWidget(
        language.booking,
        textColor: white,
        showBack: false,
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
          child: (isLoading)
              ? (error == "")
                  ? Center(
                      child: LoaderWidget(),
                    )
                  : NoDataWidget(
                      title: error,
                      imageWidget: ErrorStateWidget(),
                      retryText: language.reload,
                      onRetry: () {
                        appStore.setLoading(true);

                        _refreshData();
                        setState(() {});
                      },
                    )
              : (bookings.isEmpty
                  ? Center(
                      child: Text('لا يوجد طلبات صيانة.'),
                    )
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookingMaintenanceDetailsPage(
                                        id: bookings[index].id),
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
                                      'رقم الحجز: ${bookings[index].id}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.iconColor),
                                    ),
                                    Text(
                                      '${bookings[index].status}',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: context.iconColor),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'التاريخ: ${DateFormat("yyyy-MM-dd").format(DateTime.parse(bookings[index].date))}',
                                      style:
                                          TextStyle(color: context.iconColor),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      'الوقت: ${DateFormat.jm().format(DateTime.parse(bookings[index].date))}',
                                      style:
                                          TextStyle(color: context.iconColor),
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
    fetchOrderDetails(widget.id);
  }

  // late BookingMaintenanceModel orderData;

  BookingMaintenanceModel? orderData;
  bool isLoading = true;

  Future<void> fetchOrderDetails(int id) async {
    try {
      String token = appStore.token;

      final response = await http.get(
          Uri.parse('https://catalog.raco-ksa.com/api/booking-maintenance/$id'),
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
          orderData = BookingMaintenanceModel.fromJson(orderJson);
          isLoading = false;
        });
      } else {
        print(
            'Failed to fetch order details. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching order details: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        'تفاصيل الحجز',
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
                              'رقم الحجز:',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: context.iconColor),
                            ),
                          )),
                          DataColumn(
                              label: Text(
                            '${orderData?.id}',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.iconColor),
                          )),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text(
                              'التاريخ:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(
                              Text(
                                '${DateFormat("yyyy-MM-dd").format(DateTime.parse(orderData?.date ?? ""))}',
                                style: TextStyle(
                                    fontSize: 16, color: context.iconColor),
                              ),
                            ),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'الوقت:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(
                              Text(
                                '${DateFormat.jm().format(DateTime.parse(orderData?.date ?? ""))}',
                                style: TextStyle(
                                    fontSize: 16, color: context.iconColor),
                              ),
                            ),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'حالة الطلب:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.status}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'المدينة:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.city}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'الحي',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.alhayi}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'نوع المنتج:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.productType}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'اسم العميل:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.customerName}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'رقم الهاتف:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.mobileNumber}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'عدد الأجهزة:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.devicesNumber}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'رمز الموديل:',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.modelCode}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'الرقم التسلسلي',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.serialNumber}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'الوصف',
                              style: TextStyle(color: context.iconColor),
                            )),
                            DataCell(Text(
                              '${orderData?.description}',
                              style: TextStyle(color: context.iconColor),
                            )),
                          ]),
                        ],
                      ),
                    ),

                    // قم بإضافة المزيد من البيانات حسب الحاجة
                    SizedBox(height: 8),
                    orderData?.status != "قيد المراجعة"
                        ? SizedBox()
                        : Center(
                            child: Row(
                              children: [
                                AppButton(
                                  color: context.primaryColor,
                                  text: 'تعديل الحجز',
                                  textColor: Colors.white,
                                  onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MaintenanceForm(
                                                  typeForm: "edit",
                                                  data: orderData,
                                                )));
                                  },
                                ).expand(),
                                SizedBox(width: 10.0),
                                AppButton(
                                  color: Colors.red,
                                  text: 'إلغاء الحجز',
                                  textColor: Colors.white,
                                  onTap: () async {
                                    ApiResponse response =
                                        await deleteBookingMaintenance(
                                            orderData?.id ?? 0);
                                    push(
                                        DashboardScreen(
                                            redirectToBooking: true),
                                        isNewTask: true,
                                        pageRouteAnimation:
                                            PageRouteAnimation.Fade);
                                  },
                                ).expand(),
                              ],
                            ),
                          )
                  ],
                ),
              ),
      ),
    );
  }
}
