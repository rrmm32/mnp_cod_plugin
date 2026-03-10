import 'dart:convert';

import 'package:http/http.dart' as http;

import 'booking_service.dart';
import 'location_service.dart';
import 'models/branch.dart';
import 'models/booking_models.dart';
import 'models/location.dart';
import 'models/tracking_models.dart';
import 'tracking_service.dart';

class MnpApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  const MnpApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() =>
      'MnpApiException(statusCode: $statusCode, message: $message, details: $details)';
}

class MnpAuthConfig {
  final String username;
  final String password;
  final String accountNo;
  final String? locationId;
  final String? subAccountId;
  final String? insertType;
  final String? returnLocation;

  const MnpAuthConfig({
    required this.username,
    required this.password,
    required this.accountNo,
    this.locationId,
    this.subAccountId,
    this.insertType,
    this.returnLocation,
  });

  Map<String, dynamic> toApiFields() {
    return {
      'username': username,
      'password': password,
      'AccountNo': accountNo,
      if (locationId != null) 'locationID': locationId,
      if (subAccountId != null) 'subAccountId': subAccountId,
      if (insertType != null) 'InsertType': insertType,
      if (returnLocation != null) 'ReturnLocation': returnLocation,
    };
  }
}

class MnpApiClient {
  static const String defaultBaseUrl = 'https://mnpcourier.com/mycodapi/api';
  static const String defaultTrackingBaseUrl = 'https://tracking.mulphilog.com.pk/api';

  final String baseUrl;
  final String trackingBaseUrl;
  final MnpAuthConfig auth;
  final http.Client _httpClient;

  late final BookingService _bookingService;
  late final TrackingService _trackingService;
  late final LocationService _locationService;

  MnpApiClient({
    required String username,
    required String password,
    required String accountNo,
    String? locationId,
    String? subAccountId,
    String? insertType,
    String? returnLocation,
    this.baseUrl = defaultBaseUrl,
    this.trackingBaseUrl = defaultTrackingBaseUrl,
    http.Client? httpClient,
  })  : auth = MnpAuthConfig(
          username: username,
          password: password,
          accountNo: accountNo,
          locationId: locationId,
          subAccountId: subAccountId,
          insertType: insertType,
          returnLocation: returnLocation,
        ),
        _httpClient = httpClient ?? http.Client() {
    _bookingService = BookingService(this);
    _trackingService = TrackingService(this);
    _locationService = LocationService(this);
  }

  Future<ApiEnvelope<Map<String, dynamic>>> createBooking(
    BookingRequest request,
  ) =>
      _bookingService.createBooking(request);

  Future<ApiEnvelope<List<Map<String, dynamic>>>> createBulkBooking(
    BulkBookingRequest request,
  ) =>
      _bookingService.createBulkBooking(request);

  Future<ApiEnvelope<Map<String, dynamic>>> voidConsignment(
    VoidConsignmentRequest request,
  ) =>
      _bookingService.voidConsignment(request);

  Future<List<BranchCity>> getCities() => _locationService.getCities(all: false);

  Future<List<BranchCity>> getAllCities() => _locationService.getCities(all: true);

  Future<List<Location>> getLocations() => _locationService.getLocations();

  Future<TrackingInfo> getTrackingByCn(String consignmentNumber) =>
      _trackingService.getTrackingByCn(consignmentNumber);

  Future<List<TrackingInfo>> trackBulk(BulkTrackingRequest request) =>
      _trackingService.trackBulk(request);

  Future<Map<String, dynamic>> get(
    String path, {
    bool useTrackingBase = false,
    Map<String, String>? query,
  }) async {
    final base = useTrackingBase ? trackingBaseUrl : baseUrl;
    final uri = Uri.parse('$base$path').replace(queryParameters: query);
    final response = await _httpClient.get(uri, headers: _defaultHeaders());
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool useTrackingBase = false,
  }) async {
    final base = useTrackingBase ? trackingBaseUrl : baseUrl;
    final uri = Uri.parse('$base$path');
    final response = await _httpClient.post(
      uri,
      headers: _defaultHeaders(),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _defaultHeaders() => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    dynamic decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        throw MnpApiException(
          'Unable to parse response body as JSON.',
          statusCode: statusCode,
          details: response.body,
        );
      }
    }

    if (statusCode < 200 || statusCode >= 300) {
      throw MnpApiException(
        'HTTP request failed.',
        statusCode: statusCode,
        details: decoded ?? response.body,
      );
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List) {
      return {'data': decoded};
    }

    return {'data': decoded};
  }

  void close() {
    _httpClient.close();
  }
}
