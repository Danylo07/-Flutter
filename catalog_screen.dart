import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/books_data.dart';
import '../routes.dart';

/// Каталог з фільтром за жанром. Жанр — параметр запиту `?genre=...`,
/// тож фільтр переживає deep link і перезапуск маршруту.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, this.genre});

  final String? genre;

  @override
  Widget build(BuildContext context) {
    final selected = allGenres.contains(genre) ? genre : null;
    final books = booksByGenre(selected);
    return Scaffold(
      appBar: AppBar(title: const Text('Каталог')),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _GenreChip(label: 'Усі', genre: null, selected: selected == null),
                for (final g in allGenres)
                  _GenreChip(label: g, genre: g, selected: selected == g),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: const Icon(Icons.auto_stories_outlined),
                  title: Text(book.title),
                  subtitle: Text('${book.author} · ${book.genre}'),
                  trailing: const Icon(Icons.chevron_right),
                  // push зберігає стек: «Назад» поверне до відфільтрованого списку.
                  onTap: () => context.push(AppRoutes.book(book.id)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreChip extends StatelessWidget {
  const _GenreChip({
    required this.label,
    required this.genre,
    required this.selected,
  });

  final String label;
  final String? genre;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => context.go(AppRoutes.catalog(genre: genre)),
      ),
    );
  }
}
