import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

int? parseQuranPage(String value) {
  const arabic = '٠١٢٣٤٥٦٧٨٩';
  const persian = '۰۱۲۳۴۵۶۷۸۹';
  final normalized = value.trim().split('').map((digit) {
    final index = arabic.indexOf(digit);
    if (index >= 0) return '$index';
    final alternate = persian.indexOf(digit);
    return alternate >= 0 ? '$alternate' : digit;
  }).join();
  final page = int.tryParse(normalized);
  return page != null && page >= 1 && page <= 604 ? page : null;
}

class QuranPageJumpDialog extends StatefulWidget {
  const QuranPageJumpDialog({required this.currentPage, super.key});
  final int currentPage;
  @override
  State<QuranPageJumpDialog> createState() => _QuranPageJumpDialogState();
}

class _QuranPageJumpDialogState extends State<QuranPageJumpDialog> {
  final _form = GlobalKey<FormState>();
  late final _input = TextEditingController(text: '${widget.currentPage}');
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, parseQuranPage(_input.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.jumpToPage),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _input,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(labelText: strings.pageRange),
          onFieldSubmitted: (_) => _submit(),
          validator: (value) =>
              parseQuranPage(value ?? '') == null ? strings.pageRange : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.close),
        ),
        TextButton(onPressed: _submit, child: Text(strings.openPage)),
      ],
    );
  }
}
