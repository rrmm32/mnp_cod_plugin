import 'client.dart';
import 'models/booking_models.dart';

class BookingService {
  final MnpApiClient _client;

  const BookingService(this._client);

  Future<ApiEnvelope<Map<String, dynamic>>> createBooking(
    BookingRequest request,
  ) async {
    final payload = {
      ..._client.auth.toApiFields(),
      ...request.toJson(),
    };

    final response = await _client.post('/Booking/InsertBookingData', payload);
    return ApiEnvelope.fromJson(
      response,
      (raw) => (raw is Map<String, dynamic>) ? raw : <String, dynamic>{},
    );
  }

  Future<ApiEnvelope<List<Map<String, dynamic>>>> createBulkBooking(
    BulkBookingRequest request,
  ) async {
    final payload = {
      ..._client.auth.toApiFields(),
      ...request.toJson(),
    };

    final response = await _client.post('/Booking/InsertBulkBookingData', payload);
    return ApiEnvelope.fromJson(response, (raw) {
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return <Map<String, dynamic>>[];
    });
  }

  Future<ApiEnvelope<Map<String, dynamic>>> voidConsignment(
    VoidConsignmentRequest request,
  ) async {
    final payload = {
      ..._client.auth.toApiFields(),
      ...request.toJson(),
    };

    final response = await _client.post('/Booking/VoidConsignment', payload);
    return ApiEnvelope.fromJson(
      response,
      (raw) => (raw is Map<String, dynamic>) ? raw : <String, dynamic>{},
    );
  }
}
