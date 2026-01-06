class DateHelper {
  /// Checks if the date YYYYMMDD is complete (no zeros in year, month, or day).
  static bool isDateComplete(String date) {
    if (date.length != 8) return false;
    final y = date.substring(0, 4);
    final m = date.substring(4, 6);
    final d = date.substring(6, 8);
    return y != "0000" && m != "00" && d != "00";
  }

  /// Checks if the date YYYYMMDD is a valid calendar date.
  /// If it's incomplete, it returns true (no validation required for partial dates).
  static bool isValidDate(String date) {
    if (!isDateComplete(date)) return true;

    try {
      final y = int.parse(date.substring(0, 4));
      final m = int.parse(date.substring(4, 6));
      final d = int.parse(date.substring(6, 8));

      // DateTime constructor correctly handles day overflow by rolling into next month
      // e.g. DateTime(2024, 2, 30) becomes March 1st.
      // So we must check if the parts match after construction.
      final dt = DateTime(y, m, d);
      return dt.year == y && dt.month == m && dt.day == d;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the date is either incomplete or valid.
  static bool isDateOk(String date) {
    if (!isDateComplete(date)) return true;
    return isValidDate(date);
  }
}
