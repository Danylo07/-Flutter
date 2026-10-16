import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/auth_model.dart';
import 'models/profile_model.dart';
import 'models/reservations_model.dart';
import 'router.dart';

void main() => runApp(const LibraryApp());

class LibraryApp extends StatefulWidget {
  const LibraryApp({super.key});

  @override
  State<LibraryApp> createState() => _LibraryAppState();
}

class _LibraryAppState extends State<LibraryApp> {
  // Моделі й роутер живуть стільки ж, скільки застосунок: роутеру потрібен
  // AuthModel ще до першого build, тому створюємо їх тут.
  final AuthModel _auth = AuthModel();
  final ProfileModel _profile = ProfileModel();
  final ReservationsModel _reservations = ReservationsModel();
  late final GoRouter _router = createRouter(_auth);

  @override
  void dispose() {
    _router.dispose();
    _auth.dispose();
    _profile.dispose();
    _reservations.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthModel>.value(value: _auth),
        ChangeNotifierProvider<ProfileModel>.value(value: _profile),
        ChangeNotifierProvider<ReservationsModel>.value(value: _reservations),
      ],
      child: MaterialApp.router(
        title: 'Бібліотека коледжу',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        routerConfig: _router,
      ),
    );
  }
}
