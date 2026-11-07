import 'package:fitpro_mamdu/api/generated/models.dart';
import 'package:fitpro_mamdu/core/format.dart';
import 'package:fitpro_mamdu/features/meal/meal_data.dart';
import 'package:fitpro_mamdu/l10n/gen/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l = lookupAppL10n(const Locale('vi'));
  const info = {
    'com_trang': IngredientInfoDto(
      name: 'Cơm trắng (đã nấu chín)',
      purchaseAs: PurchaseAs(ingredientId: 'gao_te', factor: 0.36),
    ),
    'gao_te': IngredientInfoDto(name: 'Gạo tẻ (sống)', defaultPantry: true),
    'trung_ga': IngredientInfoDto(
      name: 'Trứng gà',
      householdUnits: [HouseholdUnit(unit: 'quả', grams: 50)],
    ),
  };

  List<IngredientRow> rows(List<GramLine> yours) => buildRows(
    l: l,
    yours: yours,
    standard: const {},
    info: info,
    adults: 1,
    children: 0,
    formatCount: formatDecimal,
  );

  test('riceName bỏ ghi chú trong ngoặc, viết thường chữ đầu', () {
    expect(riceName('Gạo tẻ (sống)'), 'gạo tẻ');
    expect(riceName('Gạo lứt (sống)'), 'gạo lứt');
    expect(riceName('Gạo'), 'gạo');
  });

  test('D-SHP-02: dòng cơm chín ghi "≈ X g gạo tẻ" theo hệ số quy đổi', () {
    final r = rows(const [GramLine(ingredientId: 'com_trang', grams: 200)]);
    expect(r.single.unit, '≈ 72 g gạo tẻ');
  });

  test(
    'nguyên liệu có đơn vị gia đình vẫn ghi "≈ 2 quả", không có thì không ghi',
    () {
      final r = rows(const [
        GramLine(ingredientId: 'trung_ga', grams: 100),
        GramLine(ingredientId: 'gao_te', grams: 100),
      ]);
      expect(r[0].unit, '≈ 2 quả');
      expect(r[1].unit, isNull);
    },
  );
}
