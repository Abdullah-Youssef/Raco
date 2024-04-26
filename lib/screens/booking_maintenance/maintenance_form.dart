import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pinput/pinput.dart';
import 'package:raco_ksa/screens/booking_maintenance/model_code_model.dart';
import 'package:raco_ksa/screens/booking_maintenance/product_type_model.dart';
import 'dart:ui' as ui;
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/common.dart';
import '../../utils/configs.dart';
import '../../utils/constant.dart';
import '../dashboard/dashboard_screen.dart';
import 'api_functions.dart';
import 'booking_maintenance.dart';
import 'city_model.dart';
import 'city_service.dart';
import 'model_code_service.dart';
import 'product_type_service.dart';

class MaintenanceForm extends StatefulWidget {
  final typeForm;
  final data;
  // final Function(String? otpCode) onTap;
  const MaintenanceForm({super.key, required this.typeForm, this.data});

  @override
  State<MaintenanceForm> createState() => _MaintenanceFormState();
}

class _MaintenanceFormState extends State<MaintenanceForm> {
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();
  // قيم الحقول الافتراضية
  TextEditingController cityController = TextEditingController();
  TextEditingController alhayiController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController productTypeController = TextEditingController();
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController devicesNumberController = TextEditingController();
  TextEditingController modelCodeController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateCodeController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController pinController = TextEditingController();

  DateTime _date = DateTime.now();
  String _status = '';
  bool _isLoading = false;
  bool _isNotTwoYears = false;
  @override
  void initState() {
    super.initState();
    fetchCities();
    fetchProductTypes();
    fetchModelCodes();
    // print(cities);
    init();
  }

  int devicesNumber = 1;
  bool isSelected = false;
  void increment() {
    setState(() {
      devicesNumber++;
      devicesNumberController.text = devicesNumber.toString();
    });
  }

  void decrement() {
    setState(() {
      if (devicesNumber > 1) {
        devicesNumber--;
        devicesNumberController.text = devicesNumber.toString();
      }
    });
  }

  init() {
    if (widget.typeForm == 'edit') {
      cityController.text = widget.data.city;
      alhayiController.text = widget.data.alhayi;
      addressController.text = widget.data.address;
      productTypeController.text = widget.data.productType;
      customerNameController.text = widget.data.customerName;
      mobileNumberController.text = widget.data.mobileNumber;
      devicesNumberController.text = widget.data.devicesNumber.toString();
      modelCodeController.text = widget.data.modelCode;
      serialNumberController.text = widget.data.serialNumber;
      descriptionController.text = widget.data.description;
      _date = DateTime.parse(widget.data.date);
      dateCodeController.text = DateFormat("yyyy-MM-dd").format(_date);
      timeController.text = DateFormat.jm().format(_date);
    }
    if (widget.typeForm == 'store') {
      devicesNumberController.text = devicesNumber.toString();
      // mobileNumberController.text = 'devicesNumber.toString()';
    }
  }

  @override
  void dispose() {
    // تحرير مراقبي الوحدة التحكم عند الانتهاء
    cityController.dispose();
    alhayiController.dispose();
    addressController.dispose();
    productTypeController.dispose();
    customerNameController.dispose();
    mobileNumberController.dispose();
    devicesNumberController.dispose();
    modelCodeController.dispose();
    serialNumberController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void submitForm() async {
    String city = cityController.text;
    String alhayi = alhayiController.text;
    String address = addressController.text;
    String productType = productTypeController.text;
    String customerName = customerNameController.text;
    String mobileNumber =
        "+${selectedCountry.phoneCode}${mobileNumberController.text}";
    int devicesNumber = int.parse(devicesNumberController.text);
    String modelCode = modelCodeController.text;
    String serialNumber = serialNumberController.text;
    String description = descriptionController.text;
    String? model_img =
        model_image == null ? null : getStringImage(model_image);
    String? invoice_img =
        invoice_image == null ? null : getStringImage(invoice_image);
    // قم بإنشاء خريطة بيانات النموذج
    Map<String, dynamic> bookingData = {
      'user_id': appStore.uid,
      'city': city,
      'alhayi': alhayi,
      'address': 'null',
      'product_type': productType,
      'customer_name': customerName,
      'mobile_number': mobileNumber,
      'devices_number': devicesNumber,
      'model_code': modelCode,
      'Is_two_years': !_isNotTwoYears,
      'serial_number': serialNumber,
      'description': description,
      'model_image': model_img,
      'invoice_image': invoice_img,
      'date': _date.toString(),
      'created_at': '',
      'updated_at': '',
      'customer': null,
      'status': 'قيد المراجعة',
    };
    // استدعاء دالة إنشاء طلب الصيانة
    createBookingMaintenance(bookingData)
        .then((value) => sendBookingSMS(bookingId));
  }

  void editForm() async {
    String city = cityController.text;
    String alhayi = alhayiController.text;
    String address = addressController.text;
    String productType = productTypeController.text;
    String customerName = customerNameController.text;
    String mobileNumber = mobileNumberController.text;
    int devicesNumber = int.parse(devicesNumberController.text);
    String modelCode = modelCodeController.text;
    String serialNumber = serialNumberController.text;
    String description = descriptionController.text;
    // قم بإنشاء خريطة بيانات النموذج
    Map<String, dynamic> bookingData = {
      // 'user_id': appStore.uid,
      'city': city,
      'alhayi': alhayi,
      'address': address,
      'product_type': productType,
      'customer_name': customerName,
      'mobile_number': mobileNumber,
      'devices_number': devicesNumber,
      'model_code': modelCode,
      'Is_two_years': false,
      'serial_number': serialNumber,
      'description': description,
      'model_image': null,
      'invoice_image': null,
      'date': _date.toString(),
      'updated_at': '',
      'customer': null,
      'status': widget.data.status,
    };
    // استدعاء دالة إنشاء طلب الصيانة
    updateBookingMaintenance(widget.data.id, bookingData).then((value) {
      cityController.clear();
      alhayiController.clear();
      addressController.clear();
      productTypeController.clear();
      customerNameController.clear();
      mobileNumberController.clear();
      devicesNumberController.clear();
      modelCodeController.clear();
      serialNumberController.clear();
      descriptionController.clear();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BookingMaintenanceDetailsPage(id: widget.data.id),
        ),
      );
    });
  }

  int _currentStep = 0;
  tapped(int step) {
    setState(() => _currentStep = step);
  }

  Country selectedCountry = defaultCountry();
  bool isCodeSent = false;

  late TwilioFlutter twilioFlutter;

  String sentOTP = "";

  sendOTPsms() async {
    twilioFlutter = await TwilioFlutter(
      accountSid:
          'ACa928547ee3f466268ea009c96e857e27', // replace it with your account SID
      authToken:
          '888c2064b89fc55aa7d4ed2e36205314', // replace it with your auth token
      twilioNumber:
          '+19382010874', // replace it with your purchased twilioNumber
      // messagingServiceSid: 'MG55636f808270d104130ad56046b4e051',
    );

    var rnd = new Random();

    var digits = rnd.nextInt(900000) + 100000;

    sentOTP = digits.toString();

    // lets print otp as well

    print(sentOTP);
    // print("+${selectedCountry.phoneCode}${mobileNumberController.text}");

    try {
      print('+${selectedCountry.phoneCode}${mobileNumberController.text}');
      await twilioFlutter.sendSMS(
          toNumber:
              '+${selectedCountry.phoneCode}${mobileNumberController.text}',
          messageBody: 'Code:$digits');
    } catch (e) {
      print(e);
      print(e);
      print(e);
    }
  }

  sendBookingSMS(int id) async {
    twilioFlutter = TwilioFlutter(
      accountSid:
          'ACa928547ee3f466268ea009c96e857e27', // replace it with your account SID
      authToken:
          '888c2064b89fc55aa7d4ed2e36205314', // replace it with your auth token
      twilioNumber:
          '+19382010874', // replace it with your purchased twilioNumber
      // messagingServiceSid: 'MG55636f808270d104130ad56046b4e051',
    );
    try {
      await twilioFlutter.sendSMS(
          toNumber:
              '+${selectedCountry.phoneCode}${mobileNumberController.text}',
          messageBody:
              'عزيزنا العميل تم حجز موعد صيانة برقم $id وسنقوم بالتواصل معكم في اقرب وقت ممكن.');
    } catch (e) {
      print(e);
      print(e);
      print(e);
    }
  }

  verifyOTP(var pin) {
    if (sentOTP == pin) {
      setState(() => _currentStep += 1);
      Fluttertoast.showToast(
          msg: "تم التحقق بنجاح", backgroundColor: Colors.green);
    } else {
      Fluttertoast.showToast(
          msg: "رمز التحقق غير صحيح", backgroundColor: Colors.red);
    }
  }

  continued() async {
    if (_currentStep == 0) {
      if (_formKey0.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        if (isSelected) {
          sendOTPsms();

          setState(() => _currentStep += 1);
        } else {
          toast(language.termsConditionsAccept);
        }
      }
    } else if (_currentStep == 2) {
      if (pinController.text.isNotEmpty && pinController.text.length == 6) {
        verifyOTP(pinController.text);
      }
    } else if (_currentStep == 3) {
      if (_formKey3.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 4) {
      if (_formKey4.currentState!.validate()) {
        if (widget.typeForm == 'store') {
          submitForm();
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    'تم الإرسال',
                    style: TextStyle(color: context.iconColor),
                  ),
                  content: Text(
                    'تم إرسال طلب الصيانة بنجاح',
                    style: TextStyle(color: context.iconColor),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        cityController.clear();
                        alhayiController.clear();
                        addressController.clear();
                        productTypeController.clear();
                        customerNameController.clear();
                        mobileNumberController.clear();
                        devicesNumberController.clear();
                        modelCodeController.clear();
                        serialNumberController.clear();
                        descriptionController.clear();
                        // setState(() {
                        //   _isLoading = !_isLoading;
                        // });
                        push(DashboardScreen(redirectToBooking: true),
                            isNewTask: true,
                            pageRouteAnimation: PageRouteAnimation.Fade);
                      },
                      child: Text('حسناً'),
                    ),
                  ],
                );
                // }
              });
        } else {
          editForm();
        }

        // إظهار نافذة التأكيد
        // ...
      }
    }
  }

  // continued() {
  //   if (_formKey1.currentState!.validate()) {
  //     _currentStep == 0 ? setState(() => _currentStep += 1) : null;
  //   } else if (_formKey2.currentState!.validate()) {
  //     _currentStep == 1 ? setState(() => _currentStep += 1) : null;
  //   } else if (_formKey4.currentState!.validate()) {
  //     if (widget.typeForm == 'store') {
  //       submitForm();
  //     } else {
  //       editForm();
  //     }

  //     // نافذة منبثقة للتأكيد
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text('تم الإرسال'),
  //           content: Text('تم إرسال النموذج بنجاح'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 cityController.clear();
  //                 alhayiController.clear();
  //                 addressController.clear();
  //                 productTypeController.clear();
  //                 customerNameController.clear();
  //                 mobileNumberController.clear();
  //                 devicesNumberController.clear();
  //                 modelCodeController.clear();
  //                 serialNumberController.clear();
  //                 descriptionController.clear();
  //                 // setState(() {
  //                 //   _isLoading = !_isLoading;
  //                 // });
  //                 Navigator.of(context).pop();
  //                 Navigator.of(context).pop();
  //               },
  //               child: Text('حسناً'),
  //             ),
  //           ],
  //         );
  //       },
  //     );
  //   }
  // }

  cancel() {
    _currentStep > 0
        ? setState(() => _currentStep -= 1)
        : Navigator.pop(context);
  }

  // Get base64 encoded image
  String? getStringImage(File? file) {
    if (file == null) return null;
    return base64Encode(file.readAsBytesSync());
  }

  File? model_image;
  File? invoice_image;
  final _picker = ImagePicker();

  Future getImage(ImageSource type, String img) async {
    final pickedFile = await _picker.pickImage(source: type);
    if (pickedFile != null && img == "model") {
      setState(() {
        model_image = File(pickedFile.path);
      });
    }

    if (pickedFile != null && img == "invoice") {
      setState(() {
        invoice_image = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker(BuildContext context, String img) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: cardColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('التقاط صورة باستخدام الكاميرا'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(ImageSource.camera, img);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('اختيار صورة من المعرض'),
                onTap: () {
                  Navigator.pop(context);
                  getImage(ImageSource.gallery, img);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // String? selectedCity = 'اخترالمدينة';
  void showCityBottomSheet(BuildContext context, List<City> cities) {
    List<String> cityNames = cities.map((city) => city.name).toList();
    List<String> filteredCities = List.from(cityNames);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: context.iconColor),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.primaryColor,
                      ),
                      hintStyle: TextStyle(color: context.iconColor),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredCities = cityNames
                            .where((city) => city
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredCities.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(
                          Icons.location_city_rounded,
                          color: context.primaryColor,
                          size: 30,
                        ),
                        title: Text(
                          filteredCities[index],
                          style: TextStyle(color: context.iconColor),
                        ),
                        onTap: () {
                          setState(() {
                            // احتفظ بالمدينة المحددة
                            City selectedCity = cities.firstWhere(
                                (city) => city.name == filteredCities[index]);

                            // احضر الأحياء التابعة للمدينة المحددة
                            alhayiNames = selectedCity.alhayi_names;

                            // قم بتمرير الأحياء إلى showNeighborhoodBottomSheet

                            cityController.text = filteredCities[index];
                            alhayiController.clear();
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAlhayiNamesBottomSheet(
      BuildContext context, List<Alhayi> alhayiNames) {
    List<String> alhayiNamesList =
        alhayiNames.map((alhayi) => alhayi.name).toList();
    List<String> filteredAlhayiNames = List.from(alhayiNamesList);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  style: TextStyle(color: context.iconColor),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(
                      Icons.search,
                      color: context.primaryColor,
                    ),
                    hintStyle: TextStyle(color: context.iconColor),
                  ),
                  onChanged: (value) {
                    setState(() {
                      filteredAlhayiNames = alhayiNamesList
                          .where((alhayi) => alhayi
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: alhayiNames.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (cityController.text.isEmpty)
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoaderWidget(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "قم باختيار المدينة أولاً",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: context.iconColor),
                                  )
                                ],
                              )
                            else
                              Center(
                                child: Text(
                                  "لم يتم إضافة أحياء في هذه المدينة",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: context.iconColor),
                                ),
                              )
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredAlhayiNames.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: Icon(
                              Icons.pin_drop_rounded,
                              color: context.primaryColor,
                              size: 30,
                            ),
                            title: Text(
                              filteredAlhayiNames[index],
                              style: TextStyle(color: context.iconColor),
                            ),
                            onTap: () {
                              // احتفظ بالحي المحدد أو قم بتنفيذ الإجراء المناسب
                              alhayiController.text =
                                  filteredAlhayiNames[index];
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        });
      },
    );
  }

  void showProductTypesBottomSheet(
      BuildContext context, List<ProductType> productTypes) {
    List<String> productTypesNames =
        productTypes.map((productType) => productType.name).toList();
    List<String> filteredProductTypes = List.from(productTypesNames);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: context.iconColor),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.primaryColor,
                      ),
                      hintStyle: TextStyle(color: context.iconColor),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredProductTypes = productTypesNames
                            .where((productType) => productType
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProductTypes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(
                          Icons.production_quantity_limits,
                          color: context.primaryColor,
                          size: 30,
                        ),
                        title: Text(
                          filteredProductTypes[index],
                          style: TextStyle(color: context.iconColor),
                        ),
                        onTap: () {
                          setState(() {
                            productTypeController.text =
                                filteredProductTypes[index];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showModelCodesBottomSheet(
      BuildContext context, List<ModelCode> modelCodes) {
    List<String> modelCodesNames =
        modelCodes.map((modelCode) => modelCode.code).toList();
    List<String> filteredModelCodes = List.from(modelCodesNames);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    style: TextStyle(color: context.iconColor),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.primaryColor,
                      ),
                      hintStyle: TextStyle(color: context.iconColor),
                    ),
                    onChanged: (value) {
                      setState(() {
                        filteredModelCodes = modelCodesNames
                            .where((productType) => productType
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredModelCodes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        leading: Icon(
                          Icons.print,
                          color: context.primaryColor,
                          size: 30,
                        ),
                        title: Text(
                          filteredModelCodes[index],
                          style: TextStyle(color: context.iconColor),
                        ),
                        onTap: () {
                          setState(() {
                            modelCodeController.text =
                                filteredModelCodes[index];
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.typeForm == "store" ? "حجز طلب صيانة" : "تعديل طلب الصيانة",
        textColor: white,
        showBack: false,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        actions: [],
      ),
      body: (isLoading)
          ? Center(
              child: LoaderWidget(),
            )
          : SingleChildScrollView(
              child: SizedBox(
                // width: context.width(),
                height: context.height(),
                child: Material(
                  child: Stepper(
                    type: StepperType.horizontal,
                    controlsBuilder:
                        (BuildContext context, ControlsDetails controls) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              color: context.accentColor,
                              text: _currentStep != 0 ? 'السابق' : 'رجوع',
                              textColor: Colors.white,
                              onTap: controls.onStepCancel,
                            ).expand(),
                            SizedBox(width: 10.0),
                            AppButton(
                              color: context.primaryColor,
                              text: _currentStep != 4 ? 'التالي' : 'ارسال',
                              textColor: Colors.white,
                              onTap: controls.onStepContinue,
                            ).expand(),
                            // TextButton(
                            //   onPressed: controls.onStepContinue,
                            //   child: Text('التالي'),
                            // ),
                          ],
                        ),
                      );
                    },
                    physics: ScrollPhysics(),
                    currentStep: _currentStep,
                    onStepTapped: (step) => tapped(step),
                    onStepContinue: continued,
                    onStepCancel: cancel,
                    steps: <Step>[
                      Step(
                        title: new Text(''),
                        label: new Text('العنوان'),
                        content: Form(
                          key: _formKey0,
                          child: Column(
                            children: [
                              // GestureDetector(
                              //   child: ListTile(
                              //     onTap: () {
                              //       showCityBottomSheet(context);
                              //     },
                              //   ),
                              // ),
                              // DropdownButtonFormField<String>(
                              //   value: selectedValue,
                              //   onChanged: (String? newValue) {
                              //     setState(() {
                              //       selectedValue = newValue;
                              //     });
                              //   },
                              //   decoration: InputDecoration(
                              //     labelText: 'اللون',
                              //     border: OutlineInputBorder(),
                              //     filled: true,
                              //     fillColor: Colors.grey[200],
                              //   ),
                              //   items: <String>[
                              //     'أحمر',
                              //     'أخضر',
                              //     'أزرق',
                              //     'أصفر'
                              //   ].map<DropdownMenuItem<String>>((String value) {
                              //     return DropdownMenuItem<String>(
                              //       value: value,
                              //       child: Text(value),
                              //     );
                              //   }).toList(),
                              // ),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                // keyboardType: TextInputType.none,
                                readOnly: true,
                                onTap: () {
                                  showCityBottomSheet(context, cities);
                                },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'المدينة',
                                    prefixIcon: Icon(
                                      Icons.location_city_outlined,
                                      color: context.primaryColor,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: cityController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال مدينة الصيانة';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                readOnly: true,
                                onTap: () {
                                  showAlhayiNamesBottomSheet(
                                      context, alhayiNames);
                                },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'الحي',
                                    prefixIcon: Icon(
                                      Icons.pin_drop_rounded,
                                      color: context.primaryColor,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: alhayiController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال الحي';
                                  }
                                  return null;
                                },
                              ),
                              // TextFormField(
                              //   decoration: InputDecoration(labelText: 'العنوان'),
                              //   controller: addressController,
                              //   validator: (value) {
                              //     if (value == null || value.isEmpty) {
                              //       return 'يرجى إدخال العنوان';
                              //     }
                              //     return null;
                              //   },
                              // ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                readOnly: true,
                                onTap: () {
                                  showProductTypesBottomSheet(
                                      context, productTypes);
                                },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'نوع المنتج',
                                    prefixIcon: Icon(
                                      Icons.production_quantity_limits,
                                      color: context.primaryColor,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: productTypeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال نوع المنتج';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        isActive: _currentStep == 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: new Text(''),
                        label: new Text('العميل'),
                        content: Form(
                          key: _formKey1,
                          child: Column(
                            children: [
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: InputDecoration(
                                    labelText: 'اسم العميل',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: customerNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال اسم العميل';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: InputDecoration(
                                    labelText: 'رقم الهاتف المحمول',
                                    prefixIcon: Icon(
                                      Icons.phone_android_outlined,
                                      color: context.primaryColor,
                                    ),
                                    suffix:
                                        Text('+${selectedCountry.phoneCode}'),
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.phone,
                                controller: mobileNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال رقم الهاتف المحمول';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              Align(
                                  child: FittedBox(
                                      child: new Text(
                                    'عدد الأجهزة',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  )),
                                  alignment: Alignment.topRight),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15.0),
                                          bottomRight: Radius.circular(15.0)),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.remove,
                                        color: context.scaffoldBackgroundColor,
                                      ),
                                      onPressed: decrement,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 140,
                                    child: TextFormField(
                                      onTapOutside: (PointerDownEvent event) {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      controller: devicesNumberController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      // enabled: false,
                                      style: TextStyle(fontSize: 20),
                                      onChanged: (value) {
                                        devicesNumber = int.parse(value);
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'يرجى إدخال عدد الأجهزة';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: context.primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(15.0),
                                          bottomLeft: Radius.circular(15.0)),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.add,
                                        color: context.scaffoldBackgroundColor,
                                      ),
                                      onPressed: increment,
                                    ),
                                  ),
                                ],
                              ),
                              ExcludeSemantics(
                                child: CheckboxListTile(
                                  checkboxShape: RoundedRectangleBorder(
                                      borderRadius: radius(4)),
                                  autofocus: false,
                                  activeColor: context.primaryColor,
                                  checkColor: appStore.isDarkMode
                                      ? context.iconColor
                                      : context.cardColor,
                                  value: isSelected,
                                  onChanged: (val) async {
                                    isSelected = !isSelected;
                                    setState(() {});
                                  },
                                  title: Align(
                                    alignment: Alignment.centerRight,
                                    child: RichTextWidget(
                                      list: [
                                        TextSpan(
                                            text: '${language.lblAgree} ',
                                            style:
                                                secondaryTextStyle(size: 14)),
                                        TextSpan(
                                          text: language.lblTermsOfService,
                                          style: boldTextStyle(
                                              color: primaryColor, size: 14),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              commonLaunchUrl(
                                                  TERMS_CONDITION_URL,
                                                  launchMode: LaunchMode
                                                      .externalApplication);
                                            },
                                        ),
                                        TextSpan(
                                            text: ' & ',
                                            style: secondaryTextStyle()),
                                        TextSpan(
                                          text: language.privacyPolicy,
                                          style: boldTextStyle(
                                              color: primaryColor, size: 14),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              commonLaunchUrl(
                                                  PRIVACY_POLICY_URL,
                                                  launchMode: LaunchMode
                                                      .externalApplication);
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isActive: _currentStep == 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: new Text(''),
                        label: new Text('التحقق'),
                        content: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              32.height,
                              Directionality(
                                textDirection: ui.TextDirection.ltr,
                                child: Pinput(
                                  length: 6,
                                  controller: pinController,
                                  onCompleted: (pin) {
                                    // sentOTP = pin;
                                    verifyOTP(pin);
                                  },
                                  onChanged: (s) {
                                    // sentOTP = s;
                                    // log(sentOTP);
                                  },
                                ),
                              )
                              // OTPTextField(
                              //   pinLength: 6,
                              //   textStyle: primaryTextStyle(),
                              //   decoration: inputDecoration(context).copyWith(
                              //     counter: Offstage(),
                              //   ),
                              // onChanged: (s) {
                              //   // sentOTP = s;
                              //   log(sentOTP);
                              // },
                              //   onCompleted: (pin) {
                              //     // sentOTP = pin;
                              //     // verifyOTP(pin);
                              //     setState(() => _currentStep += 1);
                              //   },
                              // ).fit(),
                            ],
                          ),
                        ),
                        isActive: _currentStep == 2,
                        state: _currentStep > 2
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: new Text(''),
                        label: new Text('المنتج'),
                        content: Form(
                          key: _formKey3,
                          child: Column(
                            children: [
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                // keyboardType: TextInputType.none,
                                readOnly: true,
                                onTap: () {
                                  showModelCodesBottomSheet(
                                      context, modelCodes);
                                },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'رمز الموديل',
                                    prefixIcon: Icon(
                                      Icons.local_printshop_rounded,
                                      color: context.primaryColor,
                                    ),
                                    suffixIcon: Icon(
                                      Icons.arrow_drop_down_circle,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: modelCodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال رمز الموديل';
                                  }
                                  return null;
                                },
                              ),
                              // SizedBox(height: 10.0),
                              ExcludeSemantics(
                                child: CheckboxListTile(
                                  checkboxShape: RoundedRectangleBorder(
                                      borderRadius: radius(4)),
                                  autofocus: false,
                                  activeColor: context.primaryColor,
                                  checkColor: appStore.isDarkMode
                                      ? context.iconColor
                                      : context.cardColor,
                                  value: _isNotTwoYears,
                                  onChanged: (val) async {
                                    _isNotTwoYears = !_isNotTwoYears;
                                    setState(() {});
                                  },
                                  title: Align(
                                    alignment: Alignment.centerRight,
                                    child: RichTextWidget(
                                      list: [
                                        TextSpan(
                                            text: 'الجهاز لم يكمل السنتين',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'الرقم التسلسلي',
                                    prefixIcon: Icon(
                                      Icons.qr_code,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: serialNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال الرقم التسلسلي';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                decoration: InputDecoration(
                                    labelText: 'الوصف',
                                    prefixIcon: Icon(
                                      Icons.description_outlined,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: descriptionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال الوصف';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              Align(
                                  child: FittedBox(
                                      child: new Text(
                                    "صورة الموديل:",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  )),
                                  alignment: Alignment.topRight),

                              GestureDetector(
                                onTap: () => _showImagePicker(context, "model"),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                    color: cardColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      model_image != null
                                          ? Image.file(model_image!)
                                          : SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Icon(
                                          Icons.attach_file,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Align(
                                  child: FittedBox(
                                      child: new Text(
                                    "صورة الفاتورة:",
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  )),
                                  alignment: Alignment.topRight),

                              GestureDetector(
                                onTap: () =>
                                    _showImagePicker(context, "invoice"),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                    color: cardColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      invoice_image != null
                                          ? Image.file(invoice_image!)
                                          : SizedBox(),
                                      Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Icon(
                                          Icons.attach_file,
                                          size: 30,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0),

                              // ElevatedButton(
                              //   onPressed: () => getImage(),
                              //   // onPressed: () => _showImagePicker(context),
                              //   child: const Text('اختيار صورة'),
                              // ),
                            ],
                          ),
                        ),
                        isActive: _currentStep == 3,
                        state: _currentStep > 3
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: new Text(''),
                        label: new Text('الموعد'),
                        content: Form(
                          key: _formKey4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    showDateTimePicker(context: context),
                                child: const Text('اختيار موعد'),
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                // keyboardType: TextInputType.none,
                                readOnly: true,
                                enabled: false,
                                // onTap: () {
                                //   showModelCodesBottomSheet(
                                //       context, modelCodes);
                                // },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'التاريخ:',
                                    border: OutlineInputBorder()),
                                controller: dateCodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى اختيار الموعد";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
                                onTapOutside: (PointerDownEvent event) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                },
                                // keyboardType: TextInputType.none,
                                readOnly: true,
                                enabled: false,
                                // onTap: () {
                                //   showModelCodesBottomSheet(
                                //       context, modelCodes);
                                // },
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'الوقت:',
                                    border: OutlineInputBorder()),
                                controller: timeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "يرجى اختيار الموعد";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        isActive: _currentStep == 4,
                        state: _currentStep > 4
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  List<City> cities = [];
  List<Alhayi> alhayiNames = [];

  List<ProductType> productTypes = [];
  List<ModelCode> modelCodes = [];
  // bool isLoding = true;
  bool isLoading = true;

  Future<void> fetchCities() async {
    try {
      List<City> fetchedCities = await CityService.fetchCities();
      setState(() {
        cities = fetchedCities;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchProductTypes() async {
    try {
      List<ProductType> fetchedProductTypes =
          await ProductTypeService.fetchProductTypes();
      setState(() {
        productTypes = fetchedProductTypes;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> fetchModelCodes() async {
    try {
      List<ModelCode> fetchedModelCodes =
          await ModelCodeService.fetchModelCodes();
      setState(() {
        modelCodes = fetchedModelCodes;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void navigateToCityDetails(int cityId) async {
    try {
      City cityDetails = await CityService.fetchCityDetails(cityId);
      // تنفيذ أي تحكم تريده بالبيانات مثل عرضها في صفحة جديدة
      print(cityDetails);
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<DateTime?> showDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= _date;
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDate),
    );
    setState(() {
      _date = selectedTime == null
          ? selectedDate
          : DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );

      dateCodeController.text = DateFormat("yyyy-MM-dd").format(_date);
      timeController.text = DateFormat.jm().format(_date);
    });

    print(DateFormat("yyyy-MM-dd").format(_date));
    print(DateFormat.jm().format(_date));

    return _date;
  }
}
