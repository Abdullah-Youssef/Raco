class BookingMaintenanceModel {
  BookingMaintenanceModel({
    required this.id,
    required this.userId,
    required this.city,
    required this.alhayi,
    required this.address,
    required this.productType,
    required this.customerName,
    required this.mobileNumber,
    required this.devicesNumber,
    required this.modelCode,
    required this.IsTwoYears,
    required this.serialNumber,
    required this.description,
    this.modelImage,
    this.invoiceImage,
    required this.date,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.customer,
  });
  late int id;
  late final String userId;
  late final String city;
  late final String alhayi;
  late final String address;
  late final String productType;
  late final String customerName;
  late final String mobileNumber;
  late final int devicesNumber;
  late final String modelCode;
  late final bool IsTwoYears;
  late final String serialNumber;
  late final String description;
  late final Null modelImage;
  late final Null invoiceImage;
  late final String date;
  late final String status;
  late final String createdAt;
  late final String updatedAt;
  late final Null customer;

  BookingMaintenanceModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    city = json['city'];
    alhayi = json['alhayi'];
    address = json['address'];
    productType = json['product_type'];
    customerName = json['customer_name'];
    mobileNumber = json['mobile_number'];
    devicesNumber = json['devices_number'];
    modelCode = json['model_code'];
    IsTwoYears = json['Is_two_years'];
    serialNumber = json['serial_number'];
    description = json['description'];
    modelImage = null;
    invoiceImage = null;
    date = json['date'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    customer = null;
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['user_id'] = userId;
    _data['city'] = city;
    _data['alhayi'] = alhayi;
    _data['address'] = address;
    _data['product_type'] = productType;
    _data['customer_name'] = customerName;
    _data['mobile_number'] = mobileNumber;
    _data['devices_number'] = devicesNumber;
    _data['model_code'] = modelCode;
    _data['Is_two_years'] = IsTwoYears;
    _data['serial_number'] = serialNumber;
    _data['description'] = description;
    _data['model_image'] = modelImage;
    _data['invoice_image'] = invoiceImage;
    _data['date'] = date;
    _data['status'] = status;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    _data['customer'] = customer;
    return _data;
  }
}
