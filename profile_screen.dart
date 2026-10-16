import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';
import '../routes.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileModel>();
    final isLoggedIn = context.watch<AuthModel>().isLoggedIn;
    return Scaffold(
      appBar: AppBar(title: const Text('Профіль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Ім’я'),
                  subtitle: Text(profile.name.isEmpty ? 'не вказано' : profile.name),
                ),
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Читацький квиток'),
                  subtitle: Text(
                    profile.cardNumber.isEmpty ? 'не вказано' : profile.cardNumber,
                  ),
                ),
                ListTile(
                  leading: Icon(isLoggedIn ? Icons.lock_open : Icons.lock_outline),
                  title: const Text('Статус'),
                  subtitle: Text(isLoggedIn ? 'Ви увійшли' : 'Гість'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.profileEdit),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редагувати профіль'),
          ),
          const SizedBox(height: 8),
          if (isLoggedIn)
            OutlinedButton.icon(
              onPressed: () => context.read<AuthModel>().logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Вийти'),
            )
          else
            OutlinedButton.icon(
              onPressed: () =>
                  context.go(AppRoutes.loginFrom(AppRoutes.profile)),
              icon: const Icon(Icons.login),
              label: const Text('Увійти'),
            ),
        ],
      ),
    );
  }
}
