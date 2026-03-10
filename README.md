# mnp_cod_api

A Dart client package for integrating with the M&P Courier COD API.

## Features

- Booking APIs
  - `POST /Booking/InsertBookingData`
  - `POST /Booking/InsertBulkBookingData`
  - `POST /Booking/VoidConsignment`
- Branch APIs
  - `GET /Branches/Get_Cities`
  - `GET /Branches/Get_Cities_All`
- Location API
  - `GET /Locations/Get_locations`
- Tracking APIs
  - `GET https://tracking.mulphilog.com.pk/api/CNTracking`
  - `POST /Tracking/Bulk_Consignment_Tracking_New`

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  mnp_cod_api: ^0.1.0
```

## Usage

```dart
import 'package:mnp_cod_api/mnp_cod_api.dart';

Future<void> main() async {
  final api = MnpApiClient(
    username: 'your-username',
    password: 'your-password',
    accountNo: 'your-account-no',
    locationId: 'your-location-id',
    subAccountId: 'your-sub-account-id',
    insertType: '0',
    returnLocation: 'your-return-location',
  );

  try {
    final bookingResponse = await api.createBooking(
      BookingRequest({
        'ConsigneeName': 'John Doe',
        'ConsigneePhoneNo': '03001234567',
        'ConsigneeAddress': 'Street 1, Lahore',
        'ShipmentTypeID': '1',
        'ServiceTypeID': '1',
      }),
    );

    final cities = await api.getCities();
    final locations = await api.getLocations();

    final tracking = await api.getTrackingByCn('1234567890');

    print(bookingResponse.success);
    print(cities.length);
    print(locations.length);
    print(tracking.currentStatus);
  } on MnpApiException catch (e) {
    print('API error: $e');
  } finally {
    api.close();
  }
}
```

## Error handling

Any non-2xx response throws `MnpApiException` with:

- `statusCode`
- `message`
- `details` (raw API error payload when available)

## Configuration

`MnpApiClient` supports these authentication and payload fields:

- `username`
- `password`
- `accountNo` (sent as `AccountNo`)
- `locationId` (sent as `locationID`)
- `subAccountId`
- `insertType` (sent as `InsertType`)
- `returnLocation` (sent as `ReturnLocation`)

You can also override base URLs:

- `baseUrl` defaults to `https://mnpcourier.com/mycodapi/api`
- `trackingBaseUrl` defaults to `https://tracking.mulphilog.com.pk/api`
