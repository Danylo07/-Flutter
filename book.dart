import 'package:flutter/foundation.dart';

@immutable
class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.year,
    required this.description,
  });

  final int id;
  final String title;
  final String author;
  final String genre;
  final int year;
  final String description;
}
