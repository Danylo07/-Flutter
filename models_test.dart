import 'package:college_library/models/auth_model.dart';
import 'package:college_library/models/books_data.dart';
import 'package:college_library/models/profile_model.dart';
import 'package:college_library/models/reservations_model.dart';
import 'package:college_library/utils/dates.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('каталог', () {
    test('15–20 книг і кілька жанрів', () {
      expect(allBooks.length, inInclusiveRange(15, 20));
      expect(allGenres.length, greaterThan(1));
    });

    test('унікальні id', () {
      expect(allBooks.map((b) => b.id).toSet().length, allBooks.length);
    });

    test('findBookById: валідний, невідомий і сміття', () {
      expect(findBookById('3')?.id, 3);
      expect(findBookById('999'), isNull);
      expect(findBookById('abc'), isNull);
      expect(findBookById(null), isNull);
    });

    test('booksByGenre: фільтр і невідомий жанр', () {
      final genre = allGenres.first;
      expect(booksByGenre(genre).every((b) => b.genre == genre), isTrue);
      expect(booksByGenre('Невідомий'), allBooks);
      expect(booksByGenre(null), allBooks);
    });
  });

  group('AuthModel', () {
    test('login/logout сповіщають лише при зміні', () {
      final auth = AuthModel();
      addTearDown(auth.dispose);
      var notified = 0;
      auth.addListener(() => notified++);

      auth.logout();
      auth.login();
      auth.login();
      auth.logout();

      expect(notified, 2);
      expect(auth.isLoggedIn, isFalse);
    });
  });

  group('ProfileModel', () {
    test('валідація номера квитка', () {
      expect(ProfileModel.isValidCardNumber('123456'), isTrue);
      expect(ProfileModel.isValidCardNumber(' 123456 '), isTrue);
      expect(ProfileModel.isValidCardNumber('12345'), isFalse);
      expect(ProfileModel.isValidCardNumber('12345a'), isFalse);
    });

    test('update обрізає пробіли', () {
      final profile = ProfileModel();
      addTearDown(profile.dispose);
      profile.update(name: '  Олена ', cardNumber: ' 123456 ');

      expect(profile.name, 'Олена');
      expect(profile.cardNumber, '123456');
      expect(profile.isFilled, isTrue);
    });
  });

  group('ReservationsModel', () {
    test('бронювання, дублікат і скасування', () {
      final model = ReservationsModel();
      addTearDown(model.dispose);
      final date = DateTime(2026, 12, 1);

      expect(model.reserve(allBooks.first, date), isTrue);
      expect(model.reserve(allBooks.first, date), isFalse);
      expect(model.items.length, 1);
      expect(model.forBook(allBooks.first.id)?.returnDate, date);

      model.cancel(allBooks.first.id);
      expect(model.items, isEmpty);
    });
  });

  group('dates', () {
    test('formatDate / isoDate / tryParseIsoDate', () {
      final d = DateTime(2026, 11, 5);
      expect(formatDate(d), '05.11.2026');
      expect(isoDate(d), '2026-11-05');
      expect(tryParseIsoDate('2026-11-05'), d);
      expect(tryParseIsoDate('сміття'), isNull);
      expect(tryParseIsoDate(null), isNull);
    });

    test('addDays переходить через межу місяця', () {
      expect(addDays(DateTime(2026, 1, 30), 3), DateTime(2026, 2, 2));
    });
  });
}
