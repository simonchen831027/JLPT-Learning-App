/// SQLite value conversions shared by Phase 1 persistence code.
abstract final class PersistenceValues {
  /// Persist an instant in UTC without depending on the device timezone.
  static String encodeInstant(DateTime value) =>
      value.toUtc().toIso8601String();

  static DateTime decodeInstant(String value) {
    if (!value.endsWith('Z')) {
      throw FormatException('Persisted instant must use UTC (Z).', value);
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null || !parsed.isUtc) {
      throw FormatException('Invalid persisted UTC instant.', value);
    }
    return parsed;
  }

  /// Validate a calendar date without assigning a time or timezone to it.
  static String dateOnly(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) throw FormatException('Invalid date-only value.', value);

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final calendarDate = DateTime.utc(year, month, day);
    if (calendarDate.year != year ||
        calendarDate.month != month ||
        calendarDate.day != day) {
      throw FormatException('Invalid calendar date.', value);
    }
    return value;
  }
}
