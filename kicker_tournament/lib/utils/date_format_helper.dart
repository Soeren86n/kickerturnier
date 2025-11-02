import 'package:intl/intl.dart';

class Utils {
  static final DateFormat _dateTimeFormat = DateFormat('dd.MM.yyyy HH:mm');

  static String formatDateTime(DateTime dt) =>
      _dateTimeFormat.format(dt.toLocal());
}
