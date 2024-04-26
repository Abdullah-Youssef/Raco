class AldamanModel {
  AldamanModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.mobileNumber,
    required this.modelCode,
    required this.serialNumber,
    this.modelImage,
    this.invoiceImage,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
  });
  late int id;
  late final String userId;
  late final String customerName;
  late final String mobileNumber;
  late final String modelCode;
  late final String serialNumber;
  late final Null modelImage;
  late final Null invoiceImage;
  late final String createdAt;
  late final String updatedAt;
  late final Null customer;

  AldamanModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    customerName = json['customer_name'];
    mobileNumber = json['mobile_number'];
    modelCode = json['model_code'];
    serialNumber = json['serial_number'];
    modelImage = null;
    invoiceImage = null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customer = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['customer_name'] = customerName;
    _data['mobile_number'] = mobileNumber;
    _data['model_code'] = modelCode;
    _data['serial_number'] = serialNumber;
    _data['model_image'] = modelImage;
    _data['invoice_image'] = invoiceImage;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['customer'] = customer;
    return _data;
  }
}
