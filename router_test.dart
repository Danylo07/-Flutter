import 'package:college_library/models/auth_model.dart';
import 'package:college_library/models/profile_model.dart';
import 'package:college_library/models/reservations_model.dart';
import 'package:college_library/router.dart';
import 'package:college_library/screens/book_screen.dart';
import 'package:college_library/screens/catalog_screen.dart';
import 'package:college_library/screens/login_screen.dart';
import 'package:college_library/screens/not_found_screen.dart';
import 'package:college_library/screens/reserve_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  late AuthModel auth;
  late ProfileModel profile;
  late ReservationsModel reservations;
  late GoRouter router;

  Future<void> pumpApp(WidgetTester tester, {String initial = '/catalog'}) async {
    auth = AuthModel();
    profile = ProfileModel();
    reservations = ReservationsModel();
    router = createRouter(auth, initialLocation: initial);
    addTearDown(() {
      router.dispose();
      auth.dispose();
      profile.dispose();
      reservations.dispose();
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthModel>.value(value: auth),
          ChangeNotifierProvider<ProfileModel>.value(value: profile),
          ChangeNotifierProvider<ReservationsModel>.value(value: reservations),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder navLabel(String text) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(text),
      );

  testWidgets('стартує з каталогу', (tester) async {
    await pumpApp(tester);
    expect(find.byType(CatalogScreen), findsOneWidget);
  });

  testWidgets('невідома адреса → errorBuilder', (tester) async {
    await pumpApp(tester);
    router.go('/no/such/page');
    await tester.pumpAndSettle();
    expect(find.byType(NotFoundScreen), findsOneWidget);
  });

  testWidgets('deep link на книгу: «Назад» веде до каталогу', (tester) async {
    await pumpApp(tester, initial: '/catalog/book/3');
    expect(find.byType(BookScreen), findsOneWidget);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(CatalogScreen), findsOneWidget);
  });

  testWidgets('гість: бронювання → вхід → повернення до бронювання',
      (tester) async {
    await pumpApp(tester);
    router.go('/catalog/book/2/reserve');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(ReserveScreen), findsNothing);

    auth.login();
    await tester.pumpAndSettle();
    expect(find.byType(ReserveScreen), findsOneWidget);
  });

  testWidgets('вкладка «Каталог» зберігає відкриту книгу', (tester) async {
    await pumpApp(tester);
    router.push('/catalog/book/4');
    await tester.pumpAndSettle();
    expect(find.byType(BookScreen), findsOneWidget);

    await tester.tap(navLabel('Профіль'));
    await tester.pumpAndSettle();
    expect(find.byType(BookScreen), findsNothing);

    await tester.tap(navLabel('Каталог'));
    await tester.pumpAndSettle();
    expect(find.byType(BookScreen), findsOneWidget);
  });

  testWidgets('PopScope: незбережені зміни потребують підтвердження',
      (tester) async {
    await pumpApp(tester, initial: '/profile');
    await tester.tap(find.text('Редагувати профіль'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Іван');
    await tester.pump();

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Вийти без збереження?'), findsOneWidget);

    await tester.tap(find.text('Залишитись'));
    await tester.pumpAndSettle();
    expect(find.text('Вийти без збереження?'), findsNothing);
    expect(find.text('Редагування профілю'), findsOneWidget);
  });
}
