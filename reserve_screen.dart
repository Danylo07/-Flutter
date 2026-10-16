import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/books_data.dart';
import '../models/reservations_model.dart';
import '../routes.dart';
import '../utils/dates.dart';

/// Захищений екран бронювання (відкривається поверх нижньої панелі).
/// Дату повернення обирають на окремому екрані, який повертає
/// результат через `context.push<DateTime>` → `context.pop(date)`.
class ReserveScreen extends StatefulWidget {
  const ReserveScreen({super.key, required this.bookId});

  final String bookId;

  @override
  State<ReserveScreen> createState() => _ReserveScreenState();
}

class _ReserveScreenState extends State<ReserveScreen> {
  DateTime? _returnDate;

  Future<void> _pickDate() async {
    final id = int.parse(widget.bookId);
    final picked = await context.push<DateTime>(
      AppRoutes.returnDate(id, initial: _returnDate),
    );
    if (picked != null && mounted) {
      setState(() => _returnDate = picked);
    }
  }

  void _confirm() {
    final book = findBookById(widget.bookId);
    final date = _returnDate;
    if (book == null || date == null) return;
    context.read<ReservationsModel>().reserve(book, date);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('«${book.title}» заброньовано до ${formatDate(date)}')),
      );
    context.go(AppRoutes.myBooks);
  }

  @override
  Widget build(BuildContext context) {
    final book = findBookById(widget.bookId);
    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Бронювання')),
        body: const Center(child: Text('Книгу не знайдено')),
      );
    }
    final existing = context.watch<ReservationsModel>().forBook(book.id);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Бронювання')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: theme.textTheme.titleLarge),
                    Text(book.author),
                    const Divider(height: 24),
                    if (existing != null)
                      Text(
                        'Ця книга вже заброньована до ${formatDate(existing.returnDate)}.',
                      )
                    else ...[
                      Text(
                        _returnDate == null
                            ? 'Дату повернення не обрано'
                            : 'Повернути до ${formatDate(_returnDate!)}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.event),
                        label: Text(
                          _returnDate == null ? 'Обрати дату' : 'Змінити дату',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed:
                  existing == null && _returnDate != null ? _confirm : null,
              child: const Text('Підтвердити бронювання'),
            ),
          ],
        ),
      ),
    );
  }
}
