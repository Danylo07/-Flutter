import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/books_data.dart';
import '../models/reservations_model.dart';
import '../routes.dart';
import '../utils/dates.dart';

/// Картка книги. Отримує лише `bookId` з адреси (без `extra`),
/// тому однаково працює і зі списку, і з deep link.
class BookScreen extends StatelessWidget {
  const BookScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    final book = findBookById(bookId);
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Книгу не знайдено')),
        body: Center(
          child: Text('Книги з номером «$bookId» немає в каталозі.'),
        ),
      );
    }
    final reservation = context.watch<ReservationsModel>().forBook(book.id);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(book.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.auto_stories,
                        size: 96,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(book.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 4),
                    Text(book.author, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: Text(book.genre)),
                        Chip(label: Text('${book.year}')),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(book.description),
                  ],
                ),
              ),
            ),
            if (reservation != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.event_available),
                  title: const Text('Заброньовано'),
                  subtitle: Text(
                    'Повернути до ${formatDate(reservation.returnDate)}',
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Забронювати'),
                  // go (не push): охоронець redirect надішле гостя на /login,
                  // а після входу поверне саме сюди.
                  onPressed: () => context.go(AppRoutes.reserve(book.id)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
