import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/auth_model.dart';
import '../models/profile_model.dart';
import '../routes.dart';

/// Вхід. Після `auth.login()` роутер сам перенаправляє користувача на
/// адресу з параметра `from` (redirect + refreshListenable) — екран
/// навігацію не викликає.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.from});

  final String? from;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cardController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileModel>();
    _nameController = TextEditingController(text: profile.name);
    _cardController = TextEditingController(text: profile.cardNumber);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileModel>().update(
          name: _nameController.text,
          cardNumber: _cardController.text,
        );
    context.read<AuthModel>().login();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Вхід')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.from != null) ...[
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Для цієї дії потрібен вхід. Після входу ви повернетесь на ${widget.from}.',
                      style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Ім’я',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Вкажіть ім’я'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardController,
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  labelText: 'Номер читацького квитка',
                  helperText: '6 цифр, наприклад 123456',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    ProfileModel.isValidCardNumber(value ?? '')
                        ? null
                        : 'Квиток має містити рівно 6 цифр',
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _submit, child: const Text('Увійти')),
              TextButton(
                onPressed: () => context.go(AppRoutes.catalog()),
                child: const Text('Скасувати'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
