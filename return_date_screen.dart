import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/books_data.dart';
import '../utils/dates.dart';

/// Вибір дати повернення (завтра … +30 днів).
/// Початкова дата приходить параметром запиту `?initial=РРРР-ММ-ДД`,
/// результат повертається через `context.pop(date)`.
class ReturnDateScreen extends StatefulWidget {
  const ReturnDateScreen({super.key, required this.bookId, this.initial});

  final String bookId;
  final DateTime? initial;

  @override
  State<ReturnDateScreen> createState() => _ReturnDateScreenState();
}

class _ReturnDateScreenState extends State<ReturnDateScreen> {
  late final DateTime _first;
  late final DateTime _last;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    final today = dateOnly(DateTime.now());
    _first = addDays(today, 1);
    _last = addDays(today, 30);
    final candidate = widget.initial;
    final isValid = candidate != null &&
        !candidate.isBefore(_first) &&
        !candidate.isAfter(_last);
    _selected = isValid ? candidate : addDays(today, 14);
  }

  @override
  Widget build(BuildContext context) {
    final book = findBookById(widget.bookId);
    return Scaffold(
      appBar: AppBar(title: const Text('Дата повернення')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (book != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  book.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            CalendarDatePicker(
              initialDate: _selected,
              firstDate: _first,
              lastDate: _last,
              onDateChanged: (date) =>
                  setState(() => _selected = dateOnly(date)),
            ),
            const Spacer(),
            FilledButton(
              // Повертаємо значення на екран бронювання.
              onPressed: () => context.pop(_selected),
              child: Text('Обрати ${formatDate(_selected)}'),
            ),
          ],
        ),
      ),
    );
  }
}
