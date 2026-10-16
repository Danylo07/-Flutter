import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/reservations_model.dart';
import '../routes.dart';
import '../utils/dates.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = context.watch<ReservationsModel>().items;
    final isLoggedIn = context.watch<AuthModel>().isLoggedIn;
    return Scaffold(
      appBar: AppBar(title: const Text('Мої книги')),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLoggedIn
                          ? 'Заброньованих книг ще немає.'
                          : 'Увійдіть, щоб бронювати книги.',
                      textAlign: TextAlign.center,
                    ),
                    if (!isLoggedIn) ...[
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () => context
                            .go(AppRoutes.loginFrom(AppRoutes.myBooks)),
                        child: const Text('Увійти'),
                      ),
                    ],
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  leading: const Icon(Icons.bookmark),
                  title: Text(item.book.title),
                  subtitle: Text(
                    'Повернути до ${formatDate(item.returnDate)}',
                  ),
                  trailing: IconButton(
                    tooltip: 'Скасувати бронювання',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        context.read<ReservationsModel>().cancel(item.book.id),
                  ),
                  onTap: () => context.push(AppRoutes.book(item.book.id)),
                );
              },
            ),
    );
  }
}
