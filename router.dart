import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'models/auth_model.dart';
import 'routes.dart';
import 'screens/app_shell.dart';
import 'screens/book_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_books_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reserve_screen.dart';
import 'screens/return_date_screen.dart';
import 'utils/dates.dart';

/// Збирає GoRouter. [auth] — і джерело істини для guard-а, і
/// `refreshListenable`: будь-яка зміна входу перераховує redirect.
GoRouter createRouter(AuthModel auth, {String initialLocation = '/catalog'}) {
  // Кореневий навігатор: на ньому відкриваються екрани «поверх» нижньої панелі.
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    refreshListenable: auth,
    redirect: (context, state) => _guard(auth, state.uri),
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) =>
            LoginScreen(from: state.uri.queryParameters['from']),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // Вкладка 1 — «Каталог».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalog',
                builder: (context, state) => CatalogScreen(
                  genre: state.uri.queryParameters['genre'], // параметр запиту
                ),
                routes: [
                  GoRoute(
                    path: 'book/:bookId', // параметр шляху
                    builder: (context, state) => BookScreen(
                      bookId: state.pathParameters['bookId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'reserve', // захищений (див. _guard)
                        parentNavigatorKey: rootKey, // поверх нижньої панелі
                        builder: (context, state) => ReserveScreen(
                          bookId: state.pathParameters['bookId']!,
                        ),
                        routes: [
                          GoRoute(
                            path: 'return-date',
                            parentNavigatorKey: rootKey,
                            builder: (context, state) => ReturnDateScreen(
                              bookId: state.pathParameters['bookId']!,
                              initial: tryParseIsoDate(
                                state.uri.queryParameters['initial'],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Вкладка 2 — «Мої книги».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myBooks,
                builder: (context, state) => const MyBooksScreen(),
              ),
            ],
          ),
          // Вкладка 3 — «Профіль».
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    builder: (context, state) => const ProfileEditScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Охоронець маршрутів.
///  * гість на захищеній адресі → `/login?from=<повна адреса>`;
///  * користувач, що вже увійшов, на `/login` → повернення на `from`.
String? _guard(AuthModel auth, Uri uri) {
  if (!auth.isLoggedIn && _isProtected(uri)) {
    return AppRoutes.loginFrom(uri.toString());
  }
  if (auth.isLoggedIn && uri.path == AppRoutes.login) {
    return _safeFrom(uri.queryParameters['from']);
  }
  return null;
}

/// Захищені: `/catalog/book/:bookId/reserve` і все під ним.
bool _isProtected(Uri uri) => uri.pathSegments.contains('reserve');

/// Приймаємо лише внутрішні адреси: без `//host`, без повернення на /login.
String _safeFrom(String? from) {
  if (from == null ||
      !from.startsWith('/') ||
      from.startsWith('//') ||
      from.startsWith(AppRoutes.login)) {
    return AppRoutes.catalog();
  }
  return from;
}
