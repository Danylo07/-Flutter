import 'package:flutter/foundation.dart';

/// Дані читача: ім'я та номер читацького квитка (6 цифр).
class ProfileModel extends ChangeNotifier {
  String _name = '';
  String _cardNumber = '';

  String get name => _name;
  String get cardNumber => _cardNumber;
  bool get isFilled => _name.isNotEmpty && _cardNumber.isNotEmpty;

  /// Перевірка формату квитка: рівно 6 цифр.
  static bool isValidCardNumber(String value) =>
      RegExp(r'^\d{6}$').hasMatch(value.trim());

  void update({required String name, required String cardNumber}) {
    final newName = name.trim();
    final newCard = cardNumber.trim();
    if (newName == _name && newCard == _cardNumber) return;
    _name = newName;
    _cardNumber = newCard;
    notifyListeners();
  }
}
