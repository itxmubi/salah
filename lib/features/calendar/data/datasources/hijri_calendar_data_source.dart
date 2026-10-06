import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/entities/hijri_date.dart';

class HijriCalendarDataSource {
  HijriCalendarDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  void close() => _client.close();

  Future<HijriDate> convertGregorianDate(DateTime date) async {
    final formatted = DateFormat('dd-MM-yyyy').format(date);
    final uri = Uri.parse('${ApiConstants.aladhanBaseUrl}/gToH/$formatted')
        .replace(
          queryParameters: {'calendarMethod': ApiConstants.hijriCalendarMethod},
        );
    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const FormatException('Hijri date service returned an error.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['code'] != 200) {
      throw const FormatException('Hijri date response was invalid.');
    }
    final data = decoded['data'];
    final hijri = data is Map<String, dynamic> ? data['hijri'] : null;
    if (hijri is! Map<String, dynamic>) {
      throw const FormatException('Hijri date was missing from the response.');
    }
    final day = hijri['day'];
    final year = hijri['year'];
    final month = hijri['month'];
    if (day is! String || year is! String || month is! Map<String, dynamic>) {
      throw const FormatException('Hijri date fields were invalid.');
    }
    final monthName = month['en'];
    if (monthName is! String || monthName.isEmpty) {
      throw const FormatException('Hijri month name was missing.');
    }
    final holidays = hijri['holidays'];
    String? holiday;
    if (holidays is List) {
      for (final item in holidays.whereType<String>()) {
        if (item.isNotEmpty) {
          holiday = item;
          break;
        }
      }
    }
    return HijriDate(
      day: day,
      monthName: monthName,
      year: year,
      holiday: holiday,
    );
  }
}
