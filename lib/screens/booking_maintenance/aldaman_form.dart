import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../component/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/constant.dart';
import 'aldaman_service.dart';

class AldamanForm extends StatefulWidget {
  // final Function(String? otpCode) onTap;
  const AldamanForm({
    super.key,
  });

  @override
  State<AldamanForm> createState() => _AldamanFormState();
}

class _AldamanFormState extends State<AldamanForm> {
  final _formKey0 = GlobalKey<FormState>();
  final _formKey1 = GlobalKey<FormState>();
  // قيم الحقول الافتراضية
  TextEditingController customerNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController modelCodeController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();

  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    customerNameController.dispose();
    mobileNumberController.dispose();
    modelCodeController.dispose();
    serialNumberController.dispose();
    super.dispose();
  }

  void submitForm() async {
    String customerName = customerNameController.text;
    String mobileNumber = mobileNumberController.text;
    String modelCode = modelCodeController.text;
    String serialNumber = serialNumberController.text;
    String? model_img =
        model_image == null ? null : getStringImage(model_image);
    String? invoice_img =
        invoice_image == null ? null : getStringImage(invoice_image);
    // قم بإنشاء خريطة بيانات النموذج
    Map<String, dynamic> aldamanData = {
      'user_id': appStore.uid,
      'customer_name': customerName,
      'mobile_number': mobileNumber,
      'model_code': modelCode,
      'serial_number': serialNumber,
      'model_image': model_img,
      'invoice_image': invoice_img,
      'created_at': '',
      'updated_at': '',
    };
    // استدعاء دالة إنشاء طلب الصيانة
    createAldaman(aldamanData);
    //  createBookingMaintenance(bookingData)
    // .then((value) => sendBookingSMS(bookingId));
  }

  int _currentStep = 0;
  tapped(int step) {
    setState(() => _currentStep = step);
  }

  continued() async {
    if (_currentStep == 0) {
      if (_formKey0.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else if (_currentStep == 2) {
      setState(() => _currentStep += 1);
    } else if (_currentStep == 3) {
      setState(() => _currentStep += 1);
    } else if (_currentStep == 4) {
      submitForm();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('تم الإرسال'),
              content: Text('تم تسجيل بيانات الضمان بنجاح'),
              actions: [
                TextButton(
                  onPressed: () {
                    customerNameController.clear();
                    mobileNumberController.clear();
                    modelCodeController.clear();
                    serialNumberController.clear();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text('حسناً'),
                ),
              ],
            );
            // }
          });

      // إظهار نافذة التأكيد
      // ...
    }
  }

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
        return Column(
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "تسجيل الضمان",
        textColor: white,
        showBack: false,
        textSize: APP_BAR_TEXT_SIZE,
        elevation: 3.0,
        color: context.primaryColor,
        actions: [],
      ),
      body: (_isLoading)
          ? Center(
              child: LoaderWidget(),
            )
          : SingleChildScrollView(
              child: SizedBox(
                // width: context.width(),
                height: context.height(),
                child: Material(
                  child: Stepper(
                    type: StepperType.vertical,
                    controlsBuilder:
                        (BuildContext context, ControlsDetails controls) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppButton(
                              color: context.iconColor,
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
                        title: new Text('بيانات العميل'),
                        // label: new Text('العميل'),
                        content: Form(
                          key: _formKey0,
                          child: Column(
                            children: [
                              TextFormField(
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
                                decoration: InputDecoration(
                                    labelText: 'رقم الهاتف المحمول',
                                    prefixIcon: Icon(
                                      Icons.phone_android_outlined,
                                      color: context.primaryColor,
                                    ),
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
                            ],
                          ),
                        ),
                        isActive: _currentStep == 0,
                        state: _currentStep > 0
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                        title: new Text('بيانات الموديل'),
                        // label: new Text('المنتج'),
                        content: Form(
                          key: _formKey1,
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                    // enabled: false,
                                    labelText: 'كود الموديل',
                                    prefixIcon: Icon(
                                      Icons.local_printshop_rounded,
                                      color: context.primaryColor,
                                    ),
                                    border: OutlineInputBorder()),
                                controller: modelCodeController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'يرجى إدخال كود الموديل';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 10.0),
                              TextFormField(
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
                            ],
                          ),
                        ),
                        isActive: _currentStep == 1,
                        state: _currentStep > 1
                            ? StepState.complete
                            : StepState.disabled,
                      ),
                      Step(
                          title: new Text('صورة الموديل'),
                          // label: new Text(''),
                          isActive: _currentStep == 2,
                          state: _currentStep > 2
                              ? StepState.complete
                              : StepState.disabled,
                          content: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _showImagePicker(context, "model"),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                    color: context.cardColor,
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
                            ],
                          )),
                      Step(
                          title: new Text('صورة الفاتورة'),
                          // label: new Text(''),
                          isActive: _currentStep == 3,
                          state: _currentStep > 3
                              ? StepState.complete
                              : StepState.disabled,
                          content: Column(
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    _showImagePicker(context, "invoice"),
                                child: Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                    color: context.cardColor,
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
                            ],
                          )),
                      Step(
                          title: new Text('اكتمل'),
                          // label: new Text(''),
                          isActive: _currentStep == 3,
                          state: _currentStep > 3
                              ? StepState.complete
                              : StepState.disabled,
                          content: Column(
                            children: [
                              Align(
                                  child: FittedBox(
                                      child: new Text(
                                    "اضغط على ارسال لتسجيل بيانات الضمان",
                                    style: TextStyle(
                                        fontSize: 18, color: completed),
                                  )),
                                  alignment: Alignment.topRight),
                              SizedBox(height: 10.0),
                            ],
                          ))
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
