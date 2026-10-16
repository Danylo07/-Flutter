/// Дата без часу (локальна опівніч).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Додає дні до календарної дати (без проблем з переходом на літній час).
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

String _two(int n) => n.toString().padLeft(2, '0');

/// 5 листопада 2026 -> «05.11.2026».
String formatDate(DateTime d) => '${_two(d.day)}.${_two(d.month)}.${d.year}';

/// «2026-11-05» — формат для параметра запиту.
String isoDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

/// Розбирає «2026-11-05»; для сміття повертає `null`.
DateTime? tryParseIsoDate(String? value) {
  if (value == null) return null;
  final parsed = DateTime.tryParse(value);
  return parsed == null ? null : dateOnly(parsed);
}
