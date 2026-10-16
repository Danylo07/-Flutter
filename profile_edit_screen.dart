import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';

/// Форма профілю з PopScope: вихід із незбереженими змінами — лише
/// після підтвердження в діалозі.
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cardController;
  late String _savedName;
  late String _savedCard;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileModel>();
    _savedName = profile.name;
    _savedCard = profile.cardNumber;
    _nameController = TextEditingController(text: _savedName)
      ..addListener(_onChanged);
    _cardController = TextEditingController(text: _savedCard)
      ..addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  // Перерахунок canPop при кожній зміні тексту.
  void _onChanged() => setState(() {});

  bool get _isDirty =>
      _nameController.text.trim() != _savedName ||
      _cardController.text.trim() != _savedCard;

  Future<bool> _confirmDiscard() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Вийти без збереження?'),
        content: const Text('У формі є незбережені зміни. Їх буде втрачено.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Залишитись'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Дозволяє вихід і закриває екран після перебудови (щоб PopScope
  /// вже мав canPop = true).
  void _exit() {
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileModel>().update(
          name: _nameController.text,
          cardNumber: _cardController.text,
        );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Профіль збережено')));
    _exit();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await _confirmDiscard();
        if (leave) _exit();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Редагування профілю')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
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
                  decoration: const InputDecoration(
                    labelText: 'Номер читацького квитка',
                    helperText: '6 цифр',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      ProfileModel.isValidCardNumber(value ?? '')
                          ? null
                          : 'Квиток має містити рівно 6 цифр',
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Зберегти'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
