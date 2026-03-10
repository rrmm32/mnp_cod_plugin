import 'client.dart';
import 'models/tracking_models.dart';

class TrackingService {
  final MnpApiClient _client;

  const TrackingService(this._client);

  Future<TrackingInfo> getTrackingByCn(String consignmentNumber) async {
    final response = await _client.get(
      '/CNTracking',
      useTrackingBase: true,
      query: {'cn': consignmentNumber},
    );

    final raw = response['data'] ?? response['Data'] ?? response;
    if (raw is Map<String, dynamic>) {
      return TrackingInfo.fromJson(raw);
    }
    throw MnpApiException('Unexpected response format for CN tracking.', details: response);
  }

  Future<List<TrackingInfo>> trackBulk(BulkTrackingRequest request) async {
    final response = await _client.post(
      '/Tracking/Bulk_Consignment_Tracking_New',
      {
        ..._client.auth.toApiFields(),
        ...request.toJson(),
      },
    );

    final raw = response['data'] ?? response['Data'] ?? response['result'] ?? [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => TrackingInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (raw is Map<String, dynamic>) {
      return [TrackingInfo.fromJson(raw)];
    }

    return const [];
  }
}
