import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Ô nhập số có nhãn, đơn vị và thông báo lỗi tại chỗ (US-1.1 AC1).
///
/// Giữ chữ đang gõ kể cả khi chưa hợp lệ; chỉ gọi [onChanged] với `null` nếu không đọc được số.
class NumberField extends StatefulWidget {
  const NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.unit,
    this.errorText,
    this.decimal = false,
    this.fieldKey,
    super.key,
  });

  final String label;
  final String? unit;
  final double? value;
  final ValueChanged<double?> onChanged;
  final String? errorText;
  final bool decimal;

  /// Khóa của TextField bên trong (cho test).
  final Key? fieldKey;

  @override
  State<NumberField> createState() => _NumberFieldState();
}

class _NumberFieldState extends State<NumberField> {
  late final TextEditingController _c = TextEditingController(
    text: _format(widget.value),
  );

  static String _format(double? v) {
    if (v == null) return '';
    return v == v.roundToDouble() ? v.round().toString() : v.toString();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(NumberField old) {
    super.didUpdateWidget(old);
    // Giá trị đổi từ bên ngoài (không phải do đang gõ) → cập nhật ô.
    final typed = double.tryParse(_c.text.replaceAll(',', '.'));
    if (widget.value != old.value && widget.value != typed) {
      _c.text = _format(widget.value);
    }
  }

  @override
  Widget build(BuildContext context) => TextField(
    key: widget.fieldKey,
    controller: _c,
    keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
    inputFormatters: [
      FilteringTextInputFormatter.allow(
        widget.decimal ? RegExp(r'[0-9.,]') : RegExp(r'[0-9]'),
      ),
    ],
    style: Theme.of(context).textTheme.titleMedium,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixText: widget.unit,
      errorText: widget.errorText,
      errorMaxLines: 2,
      constraints: const BoxConstraints(minHeight: kMinTouch),
    ),
    onChanged: (s) =>
        widget.onChanged(double.tryParse(s.trim().replaceAll(',', '.'))),
  );
}
