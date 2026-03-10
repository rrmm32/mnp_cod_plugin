import 'client.dart';
import 'models/branch.dart';
import 'models/location.dart';

class LocationService {
  final MnpApiClient _client;

  const LocationService(this._client);

  Future<List<BranchCity>> getCities({required bool all}) async {
    final path = all ? '/Branches/Get_Cities_All' : '/Branches/Get_Cities';
    final response = await _client.get(path);
    final list = _extractList(response);
    return list.map(BranchCity.fromJson).toList();
  }

  Future<List<Location>> getLocations() async {
    final response = await _client.get('/Locations/Get_locations');
    final list = _extractList(response);
    return list.map(Location.fromJson).toList();
  }

  List<Map<String, dynamic>> _extractList(Map<String, dynamic> response) {
    final raw = response['data'] ?? response['Data'] ?? response['result'] ?? response;
    if (raw is List) {
      return raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (raw is Map<String, dynamic>) {
      return [raw];
    }
    return const [];
  }
}
