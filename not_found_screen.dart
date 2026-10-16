import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes.dart';

/// Показується через `errorBuilder` для невідомої адреси.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key, required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сторінку не знайдено')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.explore_off_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Адреси «$location» не існує.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go(AppRoutes.catalog()),
                child: const Text('До каталогу'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
