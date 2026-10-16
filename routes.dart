import 'utils/dates.dart';

/// Єдине місце, де збираються адреси маршрутів. Екрани не склеюють рядки самі.
abstract final class AppRoutes {
  static const login = '/login';
  static const myBooks = '/my-books';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';

  /// `/catalog` або `/catalog?genre=...` (параметр запиту).
  static String catalog({String? genre}) => genre == null
      ? '/catalog'
      : Uri(path: '/catalog', queryParameters: {'genre': genre}).toString();

  /// `/catalog/book/:bookId` (параметр шляху).
  static String book(int id) => '/catalog/book/$id';

  /// `/catalog/book/:bookId/reserve` — захищений маршрут.
  static String reserve(int id) => '${book(id)}/reserve';

  /// `/catalog/book/:bookId/reserve/return-date?initial=РРРР-ММ-ДД`.
  static String returnDate(int id, {DateTime? initial}) {
    final path = '${reserve(id)}/return-date';
    if (initial == null) return path;
    return Uri(path: path, queryParameters: {'initial': isoDate(initial)})
        .toString();
  }

  /// `/login?from=<адреса, куди йшов користувач>`.
  static String loginFrom(String from) =>
      Uri(path: login, queryParameters: {'from': from}).toString();
}
