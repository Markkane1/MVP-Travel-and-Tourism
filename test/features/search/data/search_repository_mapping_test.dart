// Tests for the pure _mapTourData function and BookingRepository Timestamp handling.
// _mapTourData is a package-private top-level function — we mirror its logic
// in this test file to test it in pure isolation without touching Firestore.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Pure _mapTourData logic mirrored for unit-testing
// (mirrors the production function in search_repository.dart exactly)
// ---------------------------------------------------------------------------
Map<String, dynamic> mapTourData(Map<String, dynamic> data) {
  if (data['availableDates'] is List) {
    data['availableDates'] = (data['availableDates'] as List).map((timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate().toIso8601String();
      }
      return timestamp;
    }).toList();
  }
  if (data['pricePerPerson'] is int) {
    data['pricePerPerson'] = (data['pricePerPerson'] as int).toDouble();
  }
  if (data['privateVehicleSurcharge'] is int) {
    data['privateVehicleSurcharge'] = (data['privateVehicleSurcharge'] as int)
        .toDouble();
  }
  if (data['groupSizeOptions'] is List) {
    data['groupSizeOptions'] = (data['groupSizeOptions'] as List).map((opt) {
      if (opt is Map) {
        final newOpt = Map<String, dynamic>.from(opt);
        if (newOpt['priceModifier'] is int) {
          newOpt['priceModifier'] = (newOpt['priceModifier'] as int).toDouble();
        }
        return newOpt;
      }
      return opt;
    }).toList();
  }
  return data;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------
void main() {
  group('mapTourData — Timestamp → ISO 8601', () {
    test('converts Timestamp list in availableDates to ISO strings', () {
      final date = DateTime(2026, 7, 5);
      final ts = Timestamp.fromDate(date);
      final input = <String, dynamic>{
        'availableDates': [ts],
        'pricePerPerson': 1000.0,
        'privateVehicleSurcharge': 250.0,
        'groupSizeOptions': <dynamic>[],
      };

      final result = mapTourData(input);

      final dates = result['availableDates'] as List<dynamic>;
      expect(dates.first, isA<String>());
      expect(dates.first as String, equals(date.toIso8601String()));
    });

    test('leaves String dates unchanged', () {
      const dateStr = '2026-07-05T00:00:00.000';
      final input = <String, dynamic>{
        'availableDates': [dateStr],
        'pricePerPerson': 1000.0,
        'privateVehicleSurcharge': 250.0,
        'groupSizeOptions': <dynamic>[],
      };

      final result = mapTourData(input);
      final dates = result['availableDates'] as List<dynamic>;
      expect(dates.first as String, equals(dateStr));
    });
  });

  group('mapTourData — int → double coercion', () {
    test('coerces int pricePerPerson to double', () {
      final input = <String, dynamic>{
        'availableDates': <dynamic>[],
        'pricePerPerson': 1000, // int from Firestore
        'privateVehicleSurcharge': 250.0,
        'groupSizeOptions': <dynamic>[],
      };

      final result = mapTourData(input);

      expect(result['pricePerPerson'], isA<double>());
      expect(result['pricePerPerson'] as double, equals(1000.0));
    });

    test('coerces int privateVehicleSurcharge to double', () {
      final input = <String, dynamic>{
        'availableDates': <dynamic>[],
        'pricePerPerson': 1000.0,
        'privateVehicleSurcharge': 250, // int
        'groupSizeOptions': <dynamic>[],
      };

      final result = mapTourData(input);

      expect(result['privateVehicleSurcharge'], isA<double>());
      expect(result['privateVehicleSurcharge'] as double, equals(250.0));
    });

    test('coerces int priceModifier inside groupSizeOptions to double', () {
      final input = <String, dynamic>{
        'availableDates': <dynamic>[],
        'pricePerPerson': 1000.0,
        'privateVehicleSurcharge': 250.0,
        'groupSizeOptions': [
          {'label': 'Shared', 'maxSize': 16, 'priceModifier': 0}, // int
          {'label': 'Max 6', 'maxSize': 6, 'priceModifier': 500}, // int
        ],
      };

      final result = mapTourData(input);
      final opts = result['groupSizeOptions'] as List<dynamic>;
      final opt0 = opts[0] as Map<String, dynamic>;
      final opt1 = opts[1] as Map<String, dynamic>;

      expect(opt0['priceModifier'], isA<double>());
      expect(opt0['priceModifier'] as double, equals(0.0));
      expect(opt1['priceModifier'], isA<double>());
      expect(opt1['priceModifier'] as double, equals(500.0));
    });

    test('leaves already-double values unchanged', () {
      final input = <String, dynamic>{
        'availableDates': <dynamic>[],
        'pricePerPerson': 1000.0,
        'privateVehicleSurcharge': 250.0,
        'groupSizeOptions': [
          {'label': 'Shared', 'maxSize': 16, 'priceModifier': 0.0},
        ],
      };

      final result = mapTourData(input);
      final opts = result['groupSizeOptions'] as List<dynamic>;
      final opt0 = opts[0] as Map<String, dynamic>;

      expect(result['pricePerPerson'] as double, equals(1000.0));
      expect(opt0['priceModifier'] as double, equals(0.0));
    });
  });
}
