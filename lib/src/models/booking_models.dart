class BookingRequest {
  final Map<String, dynamic> data;

  const BookingRequest(this.data);

  Map<String, dynamic> toJson() => data;
}

class BulkBookingRequest {
  final List<Map<String, dynamic>> bookings;

  const BulkBookingRequest(this.bookings);

  Map<String, dynamic> toJson() => {'bookings': bookings};
}

class VoidConsignmentRequest {
  final String consignmentNumber;

  const VoidConsignmentRequest({required this.consignmentNumber});

  Map<String, dynamic> toJson() => {
        'ConsignmentNumber': consignmentNumber,
      };
}

class ApiEnvelope<T> {
  final bool success;
  final String message;
  final T? data;

  const ApiEnvelope({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw)? parser,
  ) {
    final rawData = json.containsKey('data')
        ? json['data']
        : json.containsKey('Data')
            ? json['Data']
            : json.containsKey('result')
                ? json['result']
                : json['Result'];

    return ApiEnvelope<T>(
      success: _asBool(
        json['success'] ?? json['Success'] ?? json['isSuccess'] ?? json['IsSuccess'],
      ),
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: parser == null ? rawData as T? : parser(rawData),
    );
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'success';
    }
    return false;
  }
}
