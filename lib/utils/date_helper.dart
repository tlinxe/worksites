import 'package:flutter/material.dart';

class DateHelper {
  static DateTime? parse(String? value) {
    return value != null ? DateTime.parse(value) : null;
  }

  static bool isToday(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays == 0;
  }

  static bool isTomorrow(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays == 1;
  }

  static bool isShortly(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now())).inDays > 1;
  }

  static Duration difference(DateTime date) {
    return toDate(date).difference(toDate(DateTime.now()));
  }

  static bool isBetween(DateTime? start, DateTime? end) {
    if (start != null && isBeforeNow(start)) {
      return false;
    }
    if (end != null && isAfterNow(end)) {
      return false;
    }
    return true;
  }

  static bool isAfterNow(DateTime date, {DateTime? now}) {
    return toDate(now ?? DateTime.now()).isAfter(toDate(date));
  }

  static bool isBeforeNow(DateTime date, {DateTime? now}) {
    return toDate(now ?? DateTime.now()).isBefore(toDate(date));
  }

  static DateTime toDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day, 0, 0, 0);
  }

  static String formatCompactDate(BuildContext context, DateTime? date) {
    if (date != null) {
      return MaterialLocalizations.of(context).formatCompactDate(date);
    }
    return '';
  }

  static String formatMediumDate(BuildContext context, DateTime? date) {
    if (date != null) {
      return MaterialLocalizations.of(context).formatMediumDate(date);
    }
    return '';
  }
}
