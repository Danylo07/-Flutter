import 'package:flutter/foundation.dart';

import 'book.dart';

@immutable
class Reservation {
  const Reservation({required this.book, required this.returnDate});

  final Book book;
  final DateTime returnDate;
}

class ReservationsModel extends ChangeNotifier {
  final List<Reservation> _items = [];

  List<Reservation> get items => List.unmodifiable(_items);

  Reservation? forBook(int bookId) {
    for (final item in _items) {
      if (item.book.id == bookId) return item;
    }
    return null;
  }

  /// Бронює книгу; повторне бронювання тієї ж книги ігнорується.
  /// Повертає `true`, якщо бронювання створено.
  bool reserve(Book book, DateTime returnDate) {
    if (forBook(book.id) != null) return false;
    _items.add(Reservation(book: book, returnDate: returnDate));
    notifyListeners();
    return true;
  }

  void cancel(int bookId) {
    final before = _items.length;
    _items.removeWhere((r) => r.book.id == bookId);
    if (_items.length != before) notifyListeners();
  }
}
