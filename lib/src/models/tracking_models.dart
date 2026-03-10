class TrackingRequest {
  final String consignmentNumber;

  const TrackingRequest({required this.consignmentNumber});

  Map<String, dynamic> toJson() => {
        'consignmentNumber': consignmentNumber,
      };
}

class BulkTrackingRequest {
  final List<String> consignmentNumbers;

  const BulkTrackingRequest({required this.consignmentNumbers});

  Map<String, dynamic> toJson() => {
        'consignmentNumbers': consignmentNumbers,
      };
}

class TrackingEvent {
  final String? status;
  final String? description;
  final DateTime? date;
  final String? location;
  final Map<String, dynamic> raw;

  const TrackingEvent({
    this.status,
    this.description,
    this.date,
    this.location,
    required this.raw,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      status: (json['status'] ?? json['Status'])?.toString(),
      description:
          (json['description'] ?? json['Description'] ?? json['Activity'])?.toString(),
      date: _parseDate(json['date'] ?? json['Date'] ?? json['ActivityDate']),
      location: (json['location'] ?? json['Location'] ?? json['Branch'])?.toString(),
      raw: json,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class TrackingInfo {
  final String consignmentNumber;
  final String? currentStatus;
  final List<TrackingEvent> events;
  final Map<String, dynamic> raw;

  const TrackingInfo({
    required this.consignmentNumber,
    this.currentStatus,
    required this.events,
    required this.raw,
  });

  factory TrackingInfo.fromJson(Map<String, dynamic> json) {
    final consignment =
        (json['consignmentNumber'] ?? json['ConsignmentNumber'] ?? json['CN'])
                ?.toString() ??
            '';

    final eventRaw = json['events'] ?? json['Events'] ?? json['trackingDetail'] ?? [];
    final events = eventRaw is List
        ? eventRaw
            .whereType<Map>()
            .map((e) => TrackingEvent.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <TrackingEvent>[];

    return TrackingInfo(
      consignmentNumber: consignment,
      currentStatus: (json['currentStatus'] ?? json['CurrentStatus'] ?? json['Status'])
          ?.toString(),
      events: events,
      raw: json,
    );
  }
}
