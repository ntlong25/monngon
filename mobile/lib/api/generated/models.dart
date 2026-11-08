// GENERATED FILE — KHÔNG SỬA TAY. Sinh bởi mobile/tool/gen_client.py từ backend/openapi/openapi.json.
// ignore_for_file: unnecessary_cast, prefer_const_constructors, unused_element, unnecessary_this

/// Schema `AisleGroup`.
class AisleGroup {
  const AisleGroup({this.aisle = '', this.items = const []});

  factory AisleGroup.fromJson(Map<String, dynamic> json) => AisleGroup(
    aisle: json['aisle'] == null ? '' : json['aisle'] as String,
    items: json['items'] == null
        ? const []
        : (json['items'] as List<dynamic>)
              .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList(),
  );

  final String aisle;
  final List<ShoppingItem> items;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  AisleGroup copyWith({String? aisle, List<ShoppingItem>? items}) =>
      AisleGroup(aisle: aisle ?? this.aisle, items: items ?? this.items);

  Map<String, dynamic> toJson() => {
    'aisle': aisle,
    'items': items.map((e) => e.toJson()).toList(),
  };
}

/// Schema `ApplySwapRequest`.
class ApplySwapRequest {
  const ApplySwapRequest({
    this.state = const PlanStateDto(),
    this.date = '',
    this.slot = '',
    this.recipeId = '',
  });

  factory ApplySwapRequest.fromJson(Map<String, dynamic> json) =>
      ApplySwapRequest(
        state: json['state'] == null
            ? const PlanStateDto()
            : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
        date: json['date'] == null ? '' : json['date'] as String,
        slot: json['slot'] == null ? '' : json['slot'] as String,
        recipeId: json['recipe_id'] == null ? '' : json['recipe_id'] as String,
      );

  final PlanStateDto state;
  final String date;
  final String slot;
  final String recipeId;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ApplySwapRequest copyWith({
    PlanStateDto? state,
    String? date,
    String? slot,
    String? recipeId,
  }) => ApplySwapRequest(
    state: state ?? this.state,
    date: date ?? this.date,
    slot: slot ?? this.slot,
    recipeId: recipeId ?? this.recipeId,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'date': date,
    'slot': slot,
    'recipe_id': recipeId,
  };
}

/// Schema `BudgetRangeRequest`.
class BudgetRangeRequest {
  const BudgetRangeRequest({
    this.targets,
    this.preferences,
    this.storeId,
    this.adults,
    this.children,
    this.slots,
  });

  factory BudgetRangeRequest.fromJson(Map<String, dynamic> json) =>
      BudgetRangeRequest(
        targets: json['targets'] == null
            ? null
            : BudgetTargetsDto.fromJson(
                json['targets'] as Map<String, dynamic>,
              ),
        preferences: json['preferences'] == null
            ? null
            : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
        storeId: json['store_id'] == null ? null : json['store_id'] as String,
        adults: json['adults'] == null ? null : (json['adults'] as num).toInt(),
        children: json['children'] == null
            ? null
            : (json['children'] as num).toInt(),
        slots: json['slots'] == null
            ? null
            : SlotsConfig.fromJson(json['slots'] as Map<String, dynamic>),
      );

  final BudgetTargetsDto? targets;
  final Preferences? preferences;
  final String? storeId;
  final int? adults;
  final int? children;
  final SlotsConfig? slots;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  BudgetRangeRequest copyWith({
    BudgetTargetsDto? targets,
    Preferences? preferences,
    String? storeId,
    int? adults,
    int? children,
    SlotsConfig? slots,
  }) => BudgetRangeRequest(
    targets: targets ?? this.targets,
    preferences: preferences ?? this.preferences,
    storeId: storeId ?? this.storeId,
    adults: adults ?? this.adults,
    children: children ?? this.children,
    slots: slots ?? this.slots,
  );

  Map<String, dynamic> toJson() => {
    if (targets != null) 'targets': targets?.toJson(),
    if (preferences != null) 'preferences': preferences?.toJson(),
    if (storeId != null) 'store_id': storeId,
    if (adults != null) 'adults': adults,
    if (children != null) 'children': children,
    if (slots != null) 'slots': slots?.toJson(),
  };
}

/// Schema `BudgetRangeResponse`.
class BudgetRangeResponse {
  const BudgetRangeResponse({
    this.minVnd = 0,
    this.maxVnd = 0,
    this.stepVnd = 0,
    this.estimateVnd = 0,
    this.tiers = const [],
    this.basis = '',
  });

  factory BudgetRangeResponse.fromJson(
    Map<String, dynamic> json,
  ) => BudgetRangeResponse(
    minVnd: json['min_vnd'] == null ? 0 : (json['min_vnd'] as num).toDouble(),
    maxVnd: json['max_vnd'] == null ? 0 : (json['max_vnd'] as num).toDouble(),
    stepVnd: json['step_vnd'] == null
        ? 0
        : (json['step_vnd'] as num).toDouble(),
    estimateVnd: json['estimate_vnd'] == null
        ? 0
        : (json['estimate_vnd'] as num).toDouble(),
    tiers: json['tiers'] == null
        ? const []
        : (json['tiers'] as List<dynamic>)
              .map((e) => BudgetTierDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    basis: json['basis'] == null ? '' : json['basis'] as String,
  );

  final double minVnd;
  final double maxVnd;
  final double stepVnd;
  final double estimateVnd;
  final List<BudgetTierDto> tiers;
  final String basis;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  BudgetRangeResponse copyWith({
    double? minVnd,
    double? maxVnd,
    double? stepVnd,
    double? estimateVnd,
    List<BudgetTierDto>? tiers,
    String? basis,
  }) => BudgetRangeResponse(
    minVnd: minVnd ?? this.minVnd,
    maxVnd: maxVnd ?? this.maxVnd,
    stepVnd: stepVnd ?? this.stepVnd,
    estimateVnd: estimateVnd ?? this.estimateVnd,
    tiers: tiers ?? this.tiers,
    basis: basis ?? this.basis,
  );

  Map<String, dynamic> toJson() => {
    'min_vnd': minVnd,
    'max_vnd': maxVnd,
    'step_vnd': stepVnd,
    'estimate_vnd': estimateVnd,
    'tiers': tiers.map((e) => e.toJson()).toList(),
    'basis': basis,
  };
}

/// Schema `BudgetTargetsDto`.
class BudgetTargetsDto {
  const BudgetTargetsDto({this.kcalTarget, this.proteinG});

  factory BudgetTargetsDto.fromJson(Map<String, dynamic> json) =>
      BudgetTargetsDto(
        kcalTarget: json['kcal_target'] == null
            ? null
            : (json['kcal_target'] as num).toDouble(),
        proteinG: json['protein_g'] == null
            ? null
            : (json['protein_g'] as num).toDouble(),
      );

  final double? kcalTarget;
  final double? proteinG;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  BudgetTargetsDto copyWith({double? kcalTarget, double? proteinG}) =>
      BudgetTargetsDto(
        kcalTarget: kcalTarget ?? this.kcalTarget,
        proteinG: proteinG ?? this.proteinG,
      );

  Map<String, dynamic> toJson() => {
    if (kcalTarget != null) 'kcal_target': kcalTarget,
    if (proteinG != null) 'protein_g': proteinG,
  };
}

/// Schema `BudgetTierDto`.
class BudgetTierDto {
  const BudgetTierDto({this.key = '', this.fromVnd = 0, this.toVnd = 0});

  factory BudgetTierDto.fromJson(Map<String, dynamic> json) => BudgetTierDto(
    key: json['key'] == null ? '' : json['key'] as String,
    fromVnd: json['from_vnd'] == null
        ? 0
        : (json['from_vnd'] as num).toDouble(),
    toVnd: json['to_vnd'] == null ? 0 : (json['to_vnd'] as num).toDouble(),
  );

  final String key;
  final double fromVnd;
  final double toVnd;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  BudgetTierDto copyWith({String? key, double? fromVnd, double? toVnd}) =>
      BudgetTierDto(
        key: key ?? this.key,
        fromVnd: fromVnd ?? this.fromVnd,
        toVnd: toVnd ?? this.toVnd,
      );

  Map<String, dynamic> toJson() => {
    'key': key,
    'from_vnd': fromVnd,
    'to_vnd': toVnd,
  };
}

/// Schema `DayTotals`.
class DayTotals {
  const DayTotals({
    this.kcal = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
  });

  factory DayTotals.fromJson(Map<String, dynamic> json) => DayTotals(
    kcal: json['kcal'] == null ? 0 : (json['kcal'] as num).toDouble(),
    proteinG: json['protein_g'] == null
        ? 0
        : (json['protein_g'] as num).toDouble(),
    carbG: json['carb_g'] == null ? 0 : (json['carb_g'] as num).toDouble(),
    fatG: json['fat_g'] == null ? 0 : (json['fat_g'] as num).toDouble(),
  );

  final double kcal;
  final double proteinG;
  final double carbG;
  final double fatG;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  DayTotals copyWith({
    double? kcal,
    double? proteinG,
    double? carbG,
    double? fatG,
  }) => DayTotals(
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbG: carbG ?? this.carbG,
    fatG: fatG ?? this.fatG,
  );

  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'protein_g': proteinG,
    'carb_g': carbG,
    'fat_g': fatG,
  };
}

/// Schema `DayValidation`.
class DayValidation {
  const DayValidation({
    this.date = '',
    this.ok = false,
    this.exempt = false,
    this.proteinShortG = 0,
    this.kcalDelta = 0,
  });

  factory DayValidation.fromJson(Map<String, dynamic> json) => DayValidation(
    date: json['date'] == null ? '' : json['date'] as String,
    ok: json['ok'] == null ? false : json['ok'] as bool,
    exempt: json['exempt'] == null ? false : json['exempt'] as bool,
    proteinShortG: json['protein_short_g'] == null
        ? 0
        : (json['protein_short_g'] as num).toDouble(),
    kcalDelta: json['kcal_delta'] == null
        ? 0
        : (json['kcal_delta'] as num).toDouble(),
  );

  final String date;
  final bool ok;
  final bool exempt;
  final double proteinShortG;
  final double kcalDelta;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  DayValidation copyWith({
    String? date,
    bool? ok,
    bool? exempt,
    double? proteinShortG,
    double? kcalDelta,
  }) => DayValidation(
    date: date ?? this.date,
    ok: ok ?? this.ok,
    exempt: exempt ?? this.exempt,
    proteinShortG: proteinShortG ?? this.proteinShortG,
    kcalDelta: kcalDelta ?? this.kcalDelta,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'ok': ok,
    'exempt': exempt,
    'protein_short_g': proteinShortG,
    'kcal_delta': kcalDelta,
  };
}

/// Schema `Dish`.
class Dish {
  const Dish({
    this.role = '',
    this.recipeId,
    this.name = '',
    this.grams = const [],
    this.macros = const Macros(),
  });

  factory Dish.fromJson(Map<String, dynamic> json) => Dish(
    role: json['role'] == null ? '' : json['role'] as String,
    recipeId: json['recipe_id'] == null ? null : json['recipe_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    grams: json['grams'] == null
        ? const []
        : (json['grams'] as List<dynamic>)
              .map((e) => GramLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    macros: json['macros'] == null
        ? const Macros()
        : Macros.fromJson(json['macros'] as Map<String, dynamic>),
  );

  final String role;
  final String? recipeId;
  final String name;
  final List<GramLine> grams;
  final Macros macros;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Dish copyWith({
    String? role,
    String? recipeId,
    String? name,
    List<GramLine>? grams,
    Macros? macros,
  }) => Dish(
    role: role ?? this.role,
    recipeId: recipeId ?? this.recipeId,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    macros: macros ?? this.macros,
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    if (recipeId != null) 'recipe_id': recipeId,
    'name': name,
    'grams': grams.map((e) => e.toJson()).toList(),
    'macros': macros.toJson(),
  };
}

/// Schema `EatOutRequest`.
class EatOutRequest {
  const EatOutRequest({
    this.state = const PlanStateDto(),
    this.date = '',
    this.slot = '',
    this.mode = '',
  });

  factory EatOutRequest.fromJson(Map<String, dynamic> json) => EatOutRequest(
    state: json['state'] == null
        ? const PlanStateDto()
        : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
    date: json['date'] == null ? '' : json['date'] as String,
    slot: json['slot'] == null ? '' : json['slot'] as String,
    mode: json['mode'] == null ? '' : json['mode'] as String,
  );

  final PlanStateDto state;
  final String date;
  final String slot;
  final String mode;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  EatOutRequest copyWith({
    PlanStateDto? state,
    String? date,
    String? slot,
    String? mode,
  }) => EatOutRequest(
    state: state ?? this.state,
    date: date ?? this.date,
    slot: slot ?? this.slot,
    mode: mode ?? this.mode,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'date': date,
    'slot': slot,
    'mode': mode,
  };
}

/// Schema `GramLine`.
class GramLine {
  const GramLine({this.ingredientId = '', this.grams = 0});

  factory GramLine.fromJson(Map<String, dynamic> json) => GramLine(
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
  );

  final String ingredientId;
  final double grams;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  GramLine copyWith({String? ingredientId, double? grams}) => GramLine(
    ingredientId: ingredientId ?? this.ingredientId,
    grams: grams ?? this.grams,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'grams': grams,
  };
}

/// Schema `HouseholdUnit`.
class HouseholdUnit {
  const HouseholdUnit({this.unit = '', this.grams = 0});

  factory HouseholdUnit.fromJson(Map<String, dynamic> json) => HouseholdUnit(
    unit: json['unit'] == null ? '' : json['unit'] as String,
    grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
  );

  final String unit;
  final double grams;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  HouseholdUnit copyWith({String? unit, double? grams}) =>
      HouseholdUnit(unit: unit ?? this.unit, grams: grams ?? this.grams);

  Map<String, dynamic> toJson() => {'unit': unit, 'grams': grams};
}

/// Schema `HttpValidationProblemDetails`.
class HttpValidationProblemDetails {
  const HttpValidationProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
    this.errors = const {},
  });

  factory HttpValidationProblemDetails.fromJson(Map<String, dynamic> json) =>
      HttpValidationProblemDetails(
        type: json['type'] == null ? null : json['type'] as String,
        title: json['title'] == null ? null : json['title'] as String,
        status: json['status'] == null ? null : (json['status'] as num).toInt(),
        detail: json['detail'] == null ? null : json['detail'] as String,
        instance: json['instance'] == null ? null : json['instance'] as String,
        errors: json['errors'] == null
            ? const {}
            : (json['errors'] as Map<String, dynamic>).map(
                (k, v) =>
                    MapEntry(k, (v as List<dynamic>).cast<String>().toList()),
              ),
      );

  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;
  final Map<String, List<String>> errors;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  HttpValidationProblemDetails copyWith({
    String? type,
    String? title,
    int? status,
    String? detail,
    String? instance,
    Map<String, List<String>>? errors,
  }) => HttpValidationProblemDetails(
    type: type ?? this.type,
    title: title ?? this.title,
    status: status ?? this.status,
    detail: detail ?? this.detail,
    instance: instance ?? this.instance,
    errors: errors ?? this.errors,
  );

  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (title != null) 'title': title,
    if (status != null) 'status': status,
    if (detail != null) 'detail': detail,
    if (instance != null) 'instance': instance,
    'errors': errors.map((k, v) => MapEntry(k, v)),
  };
}

/// Schema `IngredientDto`.
class IngredientDto {
  const IngredientDto({
    this.id = '',
    this.name = '',
    this.aisle = '',
    this.householdUnits = const [],
    this.defaultPantry = false,
  });

  factory IngredientDto.fromJson(Map<String, dynamic> json) => IngredientDto(
    id: json['id'] == null ? '' : json['id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    aisle: json['aisle'] == null ? '' : json['aisle'] as String,
    householdUnits: json['household_units'] == null
        ? const []
        : (json['household_units'] as List<dynamic>)
              .map((e) => HouseholdUnit.fromJson(e as Map<String, dynamic>))
              .toList(),
    defaultPantry: json['default_pantry'] == null
        ? false
        : json['default_pantry'] as bool,
  );

  final String id;
  final String name;
  final String aisle;
  final List<HouseholdUnit> householdUnits;
  final bool defaultPantry;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  IngredientDto copyWith({
    String? id,
    String? name,
    String? aisle,
    List<HouseholdUnit>? householdUnits,
    bool? defaultPantry,
  }) => IngredientDto(
    id: id ?? this.id,
    name: name ?? this.name,
    aisle: aisle ?? this.aisle,
    householdUnits: householdUnits ?? this.householdUnits,
    defaultPantry: defaultPantry ?? this.defaultPantry,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'aisle': aisle,
    'household_units': householdUnits.map((e) => e.toJson()).toList(),
    'default_pantry': defaultPantry,
  };
}

/// Schema `IngredientInfoDto`.
class IngredientInfoDto {
  const IngredientInfoDto({
    this.name = '',
    this.aisle = '',
    this.householdUnits = const [],
    this.defaultPantry = false,
    this.purchaseAs,
  });

  factory IngredientInfoDto.fromJson(Map<String, dynamic> json) =>
      IngredientInfoDto(
        name: json['name'] == null ? '' : json['name'] as String,
        aisle: json['aisle'] == null ? '' : json['aisle'] as String,
        householdUnits: json['household_units'] == null
            ? const []
            : (json['household_units'] as List<dynamic>)
                  .map((e) => HouseholdUnit.fromJson(e as Map<String, dynamic>))
                  .toList(),
        defaultPantry: json['default_pantry'] == null
            ? false
            : json['default_pantry'] as bool,
        purchaseAs: json['purchase_as'] == null
            ? null
            : PurchaseAs.fromJson(json['purchase_as'] as Map<String, dynamic>),
      );

  final String name;
  final String aisle;
  final List<HouseholdUnit> householdUnits;
  final bool defaultPantry;
  final PurchaseAs? purchaseAs;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  IngredientInfoDto copyWith({
    String? name,
    String? aisle,
    List<HouseholdUnit>? householdUnits,
    bool? defaultPantry,
    PurchaseAs? purchaseAs,
  }) => IngredientInfoDto(
    name: name ?? this.name,
    aisle: aisle ?? this.aisle,
    householdUnits: householdUnits ?? this.householdUnits,
    defaultPantry: defaultPantry ?? this.defaultPantry,
    purchaseAs: purchaseAs ?? this.purchaseAs,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'aisle': aisle,
    'household_units': householdUnits.map((e) => e.toJson()).toList(),
    'default_pantry': defaultPantry,
    if (purchaseAs != null) 'purchase_as': purchaseAs?.toJson(),
  };
}

/// Schema `IngredientOption`.
class IngredientOption {
  const IngredientOption({
    this.ingredientId = '',
    this.name = '',
    this.grams = 0,
    this.deltaProteinG = 0,
    this.deltaKcal = 0,
    this.deltaCostVnd = 0,
    this.keepsDayOk = false,
  });

  factory IngredientOption.fromJson(Map<String, dynamic> json) =>
      IngredientOption(
        ingredientId: json['ingredient_id'] == null
            ? ''
            : json['ingredient_id'] as String,
        name: json['name'] == null ? '' : json['name'] as String,
        grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
        deltaProteinG: json['delta_protein_g'] == null
            ? 0
            : (json['delta_protein_g'] as num).toDouble(),
        deltaKcal: json['delta_kcal'] == null
            ? 0
            : (json['delta_kcal'] as num).toDouble(),
        deltaCostVnd: json['delta_cost_vnd'] == null
            ? 0
            : (json['delta_cost_vnd'] as num).toDouble(),
        keepsDayOk: json['keeps_day_ok'] == null
            ? false
            : json['keeps_day_ok'] as bool,
      );

  final String ingredientId;
  final String name;
  final double grams;
  final double deltaProteinG;
  final double deltaKcal;
  final double deltaCostVnd;
  final bool keepsDayOk;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  IngredientOption copyWith({
    String? ingredientId,
    String? name,
    double? grams,
    double? deltaProteinG,
    double? deltaKcal,
    double? deltaCostVnd,
    bool? keepsDayOk,
  }) => IngredientOption(
    ingredientId: ingredientId ?? this.ingredientId,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    deltaProteinG: deltaProteinG ?? this.deltaProteinG,
    deltaKcal: deltaKcal ?? this.deltaKcal,
    deltaCostVnd: deltaCostVnd ?? this.deltaCostVnd,
    keepsDayOk: keepsDayOk ?? this.keepsDayOk,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'name': name,
    'grams': grams,
    'delta_protein_g': deltaProteinG,
    'delta_kcal': deltaKcal,
    'delta_cost_vnd': deltaCostVnd,
    'keeps_day_ok': keepsDayOk,
  };
}

/// Schema `IngredientOptions`.
class IngredientOptions {
  const IngredientOptions({
    this.date = '',
    this.slot = '',
    this.ingredientId = '',
    this.swapGroup = '',
    this.options = const [],
  });

  factory IngredientOptions.fromJson(
    Map<String, dynamic> json,
  ) => IngredientOptions(
    date: json['date'] == null ? '' : json['date'] as String,
    slot: json['slot'] == null ? '' : json['slot'] as String,
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    swapGroup: json['swap_group'] == null ? '' : json['swap_group'] as String,
    options: json['options'] == null
        ? const []
        : (json['options'] as List<dynamic>)
              .map((e) => IngredientOption.fromJson(e as Map<String, dynamic>))
              .toList(),
  );

  final String date;
  final String slot;
  final String ingredientId;
  final String swapGroup;
  final List<IngredientOption> options;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  IngredientOptions copyWith({
    String? date,
    String? slot,
    String? ingredientId,
    String? swapGroup,
    List<IngredientOption>? options,
  }) => IngredientOptions(
    date: date ?? this.date,
    slot: slot ?? this.slot,
    ingredientId: ingredientId ?? this.ingredientId,
    swapGroup: swapGroup ?? this.swapGroup,
    options: options ?? this.options,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'slot': slot,
    'ingredient_id': ingredientId,
    'swap_group': swapGroup,
    'options': options.map((e) => e.toJson()).toList(),
  };
}

/// Schema `IngredientOptionsRequest`.
class IngredientOptionsRequest {
  const IngredientOptionsRequest({
    this.state = const PlanStateDto(),
    this.date = '',
    this.slot = '',
    this.ingredientId = '',
  });

  factory IngredientOptionsRequest.fromJson(Map<String, dynamic> json) =>
      IngredientOptionsRequest(
        state: json['state'] == null
            ? const PlanStateDto()
            : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
        date: json['date'] == null ? '' : json['date'] as String,
        slot: json['slot'] == null ? '' : json['slot'] as String,
        ingredientId: json['ingredient_id'] == null
            ? ''
            : json['ingredient_id'] as String,
      );

  final PlanStateDto state;
  final String date;
  final String slot;
  final String ingredientId;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  IngredientOptionsRequest copyWith({
    PlanStateDto? state,
    String? date,
    String? slot,
    String? ingredientId,
  }) => IngredientOptionsRequest(
    state: state ?? this.state,
    date: date ?? this.date,
    slot: slot ?? this.slot,
    ingredientId: ingredientId ?? this.ingredientId,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'date': date,
    'slot': slot,
    'ingredient_id': ingredientId,
  };
}

/// Schema `MacroLine`.
class MacroLine {
  const MacroLine({
    this.ingredientId = '',
    this.name = '',
    this.grams = 0,
    this.macros = const Macros(),
    this.source = const Source(),
  });

  factory MacroLine.fromJson(Map<String, dynamic> json) => MacroLine(
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
    macros: json['macros'] == null
        ? const Macros()
        : Macros.fromJson(json['macros'] as Map<String, dynamic>),
    source: json['source'] == null
        ? const Source()
        : Source.fromJson(json['source'] as Map<String, dynamic>),
  );

  final String ingredientId;
  final String name;
  final double grams;
  final Macros macros;
  final Source source;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  MacroLine copyWith({
    String? ingredientId,
    String? name,
    double? grams,
    Macros? macros,
    Source? source,
  }) => MacroLine(
    ingredientId: ingredientId ?? this.ingredientId,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    macros: macros ?? this.macros,
    source: source ?? this.source,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'name': name,
    'grams': grams,
    'macros': macros.toJson(),
    'source': source.toJson(),
  };
}

/// Schema `MacroResult`.
class MacroResult {
  const MacroResult({this.total = const Macros(), this.lines = const []});

  factory MacroResult.fromJson(Map<String, dynamic> json) => MacroResult(
    total: json['total'] == null
        ? const Macros()
        : Macros.fromJson(json['total'] as Map<String, dynamic>),
    lines: json['lines'] == null
        ? const []
        : (json['lines'] as List<dynamic>)
              .map((e) => MacroLine.fromJson(e as Map<String, dynamic>))
              .toList(),
  );

  final Macros total;
  final List<MacroLine> lines;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  MacroResult copyWith({Macros? total, List<MacroLine>? lines}) =>
      MacroResult(total: total ?? this.total, lines: lines ?? this.lines);

  Map<String, dynamic> toJson() => {
    'total': total.toJson(),
    'lines': lines.map((e) => e.toJson()).toList(),
  };
}

/// Schema `Macros`.
class Macros {
  const Macros({
    this.kcal = 0,
    this.proteinG = 0,
    this.carbG = 0,
    this.fatG = 0,
    this.fiberG = 0,
  });

  factory Macros.fromJson(Map<String, dynamic> json) => Macros(
    kcal: json['kcal'] == null ? 0 : (json['kcal'] as num).toDouble(),
    proteinG: json['protein_g'] == null
        ? 0
        : (json['protein_g'] as num).toDouble(),
    carbG: json['carb_g'] == null ? 0 : (json['carb_g'] as num).toDouble(),
    fatG: json['fat_g'] == null ? 0 : (json['fat_g'] as num).toDouble(),
    fiberG: json['fiber_g'] == null ? 0 : (json['fiber_g'] as num).toDouble(),
  );

  final double kcal;
  final double proteinG;
  final double carbG;
  final double fatG;
  final double fiberG;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Macros copyWith({
    double? kcal,
    double? proteinG,
    double? carbG,
    double? fatG,
    double? fiberG,
  }) => Macros(
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    carbG: carbG ?? this.carbG,
    fatG: fatG ?? this.fatG,
    fiberG: fiberG ?? this.fiberG,
  );

  Map<String, dynamic> toJson() => {
    'kcal': kcal,
    'protein_g': proteinG,
    'carb_g': carbG,
    'fat_g': fatG,
    'fiber_g': fiberG,
  };
}

/// Schema `MealNote`.
class MealNote {
  const MealNote({this.code = '', this.targetG, this.actualG, this.reason});

  factory MealNote.fromJson(Map<String, dynamic> json) => MealNote(
    code: json['code'] == null ? '' : json['code'] as String,
    targetG: json['target_g'] == null
        ? null
        : (json['target_g'] as num).toDouble(),
    actualG: json['actual_g'] == null
        ? null
        : (json['actual_g'] as num).toDouble(),
    reason: json['reason'] == null ? null : json['reason'] as String,
  );

  final String code;
  final double? targetG;
  final double? actualG;
  final String? reason;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  MealNote copyWith({
    String? code,
    double? targetG,
    double? actualG,
    String? reason,
  }) => MealNote(
    code: code ?? this.code,
    targetG: targetG ?? this.targetG,
    actualG: actualG ?? this.actualG,
    reason: reason ?? this.reason,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    if (targetG != null) 'target_g': targetG,
    if (actualG != null) 'actual_g': actualG,
    if (reason != null) 'reason': reason,
  };
}

/// Schema `MealTrace`.
class MealTrace {
  const MealTrace({
    this.date = '',
    this.slot = '',
    this.recipeId = '',
    this.lines = const [],
    this.extras = const [],
    this.dessert = const [],
    this.total = const Macros(),
  });

  factory MealTrace.fromJson(Map<String, dynamic> json) => MealTrace(
    date: json['date'] == null ? '' : json['date'] as String,
    slot: json['slot'] == null ? '' : json['slot'] as String,
    recipeId: json['recipe_id'] == null ? '' : json['recipe_id'] as String,
    lines: json['lines'] == null
        ? const []
        : (json['lines'] as List<dynamic>)
              .map((e) => TraceLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    extras: json['extras'] == null
        ? const []
        : (json['extras'] as List<dynamic>)
              .map((e) => TraceLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    dessert: json['dessert'] == null
        ? const []
        : (json['dessert'] as List<dynamic>)
              .map((e) => TraceLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    total: json['total'] == null
        ? const Macros()
        : Macros.fromJson(json['total'] as Map<String, dynamic>),
  );

  final String date;
  final String slot;
  final String recipeId;
  final List<TraceLine> lines;
  final List<TraceLine> extras;
  final List<TraceLine> dessert;
  final Macros total;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  MealTrace copyWith({
    String? date,
    String? slot,
    String? recipeId,
    List<TraceLine>? lines,
    List<TraceLine>? extras,
    List<TraceLine>? dessert,
    Macros? total,
  }) => MealTrace(
    date: date ?? this.date,
    slot: slot ?? this.slot,
    recipeId: recipeId ?? this.recipeId,
    lines: lines ?? this.lines,
    extras: extras ?? this.extras,
    dessert: dessert ?? this.dessert,
    total: total ?? this.total,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'slot': slot,
    'recipe_id': recipeId,
    'lines': lines.map((e) => e.toJson()).toList(),
    'extras': extras.map((e) => e.toJson()).toList(),
    'dessert': dessert.map((e) => e.toJson()).toList(),
    'total': total.toJson(),
  };
}

/// Schema `OptionDto`.
class OptionDto {
  const OptionDto({
    this.id = '',
    this.name = '',
    this.bans = const [],
    this.description = '',
    this.group = '',
  });

  factory OptionDto.fromJson(Map<String, dynamic> json) => OptionDto(
    id: json['id'] == null ? '' : json['id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    bans: json['bans'] == null
        ? const []
        : (json['bans'] as List<dynamic>).cast<String>().toList(),
    description: json['description'] == null
        ? ''
        : json['description'] as String,
    group: json['group'] == null ? '' : json['group'] as String,
  );

  final String id;
  final String name;
  final List<String> bans;
  final String description;
  final String group;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  OptionDto copyWith({
    String? id,
    String? name,
    List<String>? bans,
    String? description,
    String? group,
  }) => OptionDto(
    id: id ?? this.id,
    name: name ?? this.name,
    bans: bans ?? this.bans,
    description: description ?? this.description,
    group: group ?? this.group,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'bans': bans,
    'description': description,
    'group': group,
  };
}

/// Schema `PlanDay`.
class PlanDay {
  const PlanDay({
    this.date = '',
    this.meals = const [],
    this.totals = const DayTotals(),
  });

  factory PlanDay.fromJson(Map<String, dynamic> json) => PlanDay(
    date: json['date'] == null ? '' : json['date'] as String,
    meals: json['meals'] == null
        ? const []
        : (json['meals'] as List<dynamic>)
              .map((e) => PlanMeal.fromJson(e as Map<String, dynamic>))
              .toList(),
    totals: json['totals'] == null
        ? const DayTotals()
        : DayTotals.fromJson(json['totals'] as Map<String, dynamic>),
  );

  final String date;
  final List<PlanMeal> meals;
  final DayTotals totals;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PlanDay copyWith({String? date, List<PlanMeal>? meals, DayTotals? totals}) =>
      PlanDay(
        date: date ?? this.date,
        meals: meals ?? this.meals,
        totals: totals ?? this.totals,
      );

  Map<String, dynamic> toJson() => {
    'date': date,
    'meals': meals.map((e) => e.toJson()).toList(),
    'totals': totals.toJson(),
  };
}

/// Schema `PlanMeal`.
class PlanMeal {
  const PlanMeal({
    this.date = '',
    this.slot = '',
    this.status = '',
    this.recipeId,
    this.grams = const [],
    this.standardGrams = const [],
    this.extras = const [],
    this.substitutions = const [],
    this.macros = const Macros(),
    this.batchGroupId,
    this.forcedZeroCarb = false,
    this.scaleInfeasible = false,
    this.dishes,
    this.dessertId,
    this.dessert,
    this.warnings,
    this.rice,
    this.notes,
  });

  factory PlanMeal.fromJson(Map<String, dynamic> json) => PlanMeal(
    date: json['date'] == null ? '' : json['date'] as String,
    slot: json['slot'] == null ? '' : json['slot'] as String,
    status: json['status'] == null ? '' : json['status'] as String,
    recipeId: json['recipe_id'] == null ? null : json['recipe_id'] as String,
    grams: json['grams'] == null
        ? const []
        : (json['grams'] as List<dynamic>)
              .map((e) => GramLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    standardGrams: json['standard_grams'] == null
        ? const []
        : (json['standard_grams'] as List<dynamic>)
              .map((e) => GramLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    extras: json['extras'] == null
        ? const []
        : (json['extras'] as List<dynamic>)
              .map((e) => GramLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    substitutions: json['substitutions'] == null
        ? const []
        : (json['substitutions'] as List<dynamic>)
              .map((e) => Substitution.fromJson(e as Map<String, dynamic>))
              .toList(),
    macros: json['macros'] == null
        ? const Macros()
        : Macros.fromJson(json['macros'] as Map<String, dynamic>),
    batchGroupId: json['batch_group_id'] == null
        ? null
        : json['batch_group_id'] as String,
    forcedZeroCarb: json['forced_zero_carb'] == null
        ? false
        : json['forced_zero_carb'] as bool,
    scaleInfeasible: json['scale_infeasible'] == null
        ? false
        : json['scale_infeasible'] as bool,
    dishes: json['dishes'] == null
        ? null
        : (json['dishes'] as List<dynamic>)
              .map((e) => Dish.fromJson(e as Map<String, dynamic>))
              .toList(),
    dessertId: json['dessert_id'] == null ? null : json['dessert_id'] as String,
    dessert: json['dessert'] == null
        ? null
        : (json['dessert'] as List<dynamic>)
              .map((e) => GramLine.fromJson(e as Map<String, dynamic>))
              .toList(),
    warnings: json['warnings'] == null
        ? null
        : (json['warnings'] as List<dynamic>).cast<String>().toList(),
    rice: json['rice'] == null
        ? null
        : RiceInfo.fromJson(json['rice'] as Map<String, dynamic>),
    notes: json['notes'] == null
        ? null
        : (json['notes'] as List<dynamic>)
              .map((e) => MealNote.fromJson(e as Map<String, dynamic>))
              .toList(),
  );

  final String date;
  final String slot;
  final String status;
  final String? recipeId;
  final List<GramLine> grams;
  final List<GramLine> standardGrams;
  final List<GramLine> extras;
  final List<Substitution> substitutions;
  final Macros macros;
  final String? batchGroupId;
  final bool forcedZeroCarb;
  final bool scaleInfeasible;
  final List<Dish>? dishes;
  final String? dessertId;
  final List<GramLine>? dessert;
  final List<String>? warnings;
  final RiceInfo? rice;
  final List<MealNote>? notes;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PlanMeal copyWith({
    String? date,
    String? slot,
    String? status,
    String? recipeId,
    List<GramLine>? grams,
    List<GramLine>? standardGrams,
    List<GramLine>? extras,
    List<Substitution>? substitutions,
    Macros? macros,
    String? batchGroupId,
    bool? forcedZeroCarb,
    bool? scaleInfeasible,
    List<Dish>? dishes,
    String? dessertId,
    List<GramLine>? dessert,
    List<String>? warnings,
    RiceInfo? rice,
    List<MealNote>? notes,
  }) => PlanMeal(
    date: date ?? this.date,
    slot: slot ?? this.slot,
    status: status ?? this.status,
    recipeId: recipeId ?? this.recipeId,
    grams: grams ?? this.grams,
    standardGrams: standardGrams ?? this.standardGrams,
    extras: extras ?? this.extras,
    substitutions: substitutions ?? this.substitutions,
    macros: macros ?? this.macros,
    batchGroupId: batchGroupId ?? this.batchGroupId,
    forcedZeroCarb: forcedZeroCarb ?? this.forcedZeroCarb,
    scaleInfeasible: scaleInfeasible ?? this.scaleInfeasible,
    dishes: dishes ?? this.dishes,
    dessertId: dessertId ?? this.dessertId,
    dessert: dessert ?? this.dessert,
    warnings: warnings ?? this.warnings,
    rice: rice ?? this.rice,
    notes: notes ?? this.notes,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'slot': slot,
    'status': status,
    if (recipeId != null) 'recipe_id': recipeId,
    'grams': grams.map((e) => e.toJson()).toList(),
    'standard_grams': standardGrams.map((e) => e.toJson()).toList(),
    'extras': extras.map((e) => e.toJson()).toList(),
    'substitutions': substitutions.map((e) => e.toJson()).toList(),
    'macros': macros.toJson(),
    if (batchGroupId != null) 'batch_group_id': batchGroupId,
    'forced_zero_carb': forcedZeroCarb,
    'scale_infeasible': scaleInfeasible,
    if (dishes != null) 'dishes': dishes!.map((e) => e.toJson()).toList(),
    if (dessertId != null) 'dessert_id': dessertId,
    if (dessert != null) 'dessert': dessert!.map((e) => e.toJson()).toList(),
    if (warnings != null) 'warnings': warnings,
    if (rice != null) 'rice': rice?.toJson(),
    if (notes != null) 'notes': notes!.map((e) => e.toJson()).toList(),
  };
}

/// Schema `PlanRequest`.
class PlanRequest {
  const PlanRequest({
    this.profile = const Profile(),
    this.preferences = const Preferences(),
    this.startDate = '',
    this.seed,
    this.mealStyle = '',
    this.includeDessert = false,
  });

  factory PlanRequest.fromJson(Map<String, dynamic> json) => PlanRequest(
    profile: json['profile'] == null
        ? const Profile()
        : Profile.fromJson(json['profile'] as Map<String, dynamic>),
    preferences: json['preferences'] == null
        ? const Preferences()
        : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
    startDate: json['start_date'] == null ? '' : json['start_date'] as String,
    seed: json['seed'] == null ? null : (json['seed'] as num).toInt(),
    mealStyle: json['meal_style'] == null ? '' : json['meal_style'] as String,
    includeDessert: json['include_dessert'] == null
        ? false
        : json['include_dessert'] as bool,
  );

  final Profile profile;
  final Preferences preferences;
  final String startDate;
  final int? seed;
  final String mealStyle;
  final bool includeDessert;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PlanRequest copyWith({
    Profile? profile,
    Preferences? preferences,
    String? startDate,
    int? seed,
    String? mealStyle,
    bool? includeDessert,
  }) => PlanRequest(
    profile: profile ?? this.profile,
    preferences: preferences ?? this.preferences,
    startDate: startDate ?? this.startDate,
    seed: seed ?? this.seed,
    mealStyle: mealStyle ?? this.mealStyle,
    includeDessert: includeDessert ?? this.includeDessert,
  );

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'preferences': preferences.toJson(),
    'start_date': startDate,
    if (seed != null) 'seed': seed,
    'meal_style': mealStyle,
    'include_dessert': includeDessert,
  };
}

/// Schema `PlanResponse`.
class PlanResponse {
  const PlanResponse({
    this.targets = const Targets(),
    this.plan = const WeekPlan(),
    this.trace = const [],
    this.dataVersion = '',
    this.recipes = const {},
    this.ingredients = const {},
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) => PlanResponse(
    targets: json['targets'] == null
        ? const Targets()
        : Targets.fromJson(json['targets'] as Map<String, dynamic>),
    plan: json['plan'] == null
        ? const WeekPlan()
        : WeekPlan.fromJson(json['plan'] as Map<String, dynamic>),
    trace: json['trace'] == null
        ? const []
        : (json['trace'] as List<dynamic>)
              .map((e) => MealTrace.fromJson(e as Map<String, dynamic>))
              .toList(),
    dataVersion: json['data_version'] == null
        ? ''
        : json['data_version'] as String,
    recipes: json['recipes'] == null
        ? const {}
        : (json['recipes'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, Recipe.fromJson(v as Map<String, dynamic>)),
          ),
    ingredients: json['ingredients'] == null
        ? const {}
        : (json['ingredients'] as Map<String, dynamic>).map(
            (k, v) => MapEntry(
              k,
              IngredientInfoDto.fromJson(v as Map<String, dynamic>),
            ),
          ),
  );

  final Targets targets;
  final WeekPlan plan;
  final List<MealTrace> trace;
  final String dataVersion;
  final Map<String, Recipe> recipes;
  final Map<String, IngredientInfoDto> ingredients;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PlanResponse copyWith({
    Targets? targets,
    WeekPlan? plan,
    List<MealTrace>? trace,
    String? dataVersion,
    Map<String, Recipe>? recipes,
    Map<String, IngredientInfoDto>? ingredients,
  }) => PlanResponse(
    targets: targets ?? this.targets,
    plan: plan ?? this.plan,
    trace: trace ?? this.trace,
    dataVersion: dataVersion ?? this.dataVersion,
    recipes: recipes ?? this.recipes,
    ingredients: ingredients ?? this.ingredients,
  );

  Map<String, dynamic> toJson() => {
    'targets': targets.toJson(),
    'plan': plan.toJson(),
    'trace': trace.map((e) => e.toJson()).toList(),
    'data_version': dataVersion,
    'recipes': recipes.map((k, v) => MapEntry(k, v.toJson())),
    'ingredients': ingredients.map((k, v) => MapEntry(k, v.toJson())),
  };
}

/// Schema `PlanStateDto`.
class PlanStateDto {
  const PlanStateDto({
    this.profile = const Profile(),
    this.preferences = const Preferences(),
    this.plan = const WeekPlan(),
    this.includeDessert = false,
  });

  factory PlanStateDto.fromJson(Map<String, dynamic> json) => PlanStateDto(
    profile: json['profile'] == null
        ? const Profile()
        : Profile.fromJson(json['profile'] as Map<String, dynamic>),
    preferences: json['preferences'] == null
        ? const Preferences()
        : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
    plan: json['plan'] == null
        ? const WeekPlan()
        : WeekPlan.fromJson(json['plan'] as Map<String, dynamic>),
    includeDessert: json['include_dessert'] == null
        ? false
        : json['include_dessert'] as bool,
  );

  final Profile profile;
  final Preferences preferences;
  final WeekPlan plan;
  final bool includeDessert;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PlanStateDto copyWith({
    Profile? profile,
    Preferences? preferences,
    WeekPlan? plan,
    bool? includeDessert,
  }) => PlanStateDto(
    profile: profile ?? this.profile,
    preferences: preferences ?? this.preferences,
    plan: plan ?? this.plan,
    includeDessert: includeDessert ?? this.includeDessert,
  );

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'preferences': preferences.toJson(),
    'plan': plan.toJson(),
    'include_dessert': includeDessert,
  };
}

/// Schema `Preferences`.
class Preferences {
  const Preferences({
    this.storeId = '',
    this.weeklyBudgetVnd = 0,
    this.adults = 0,
    this.children = 0,
    this.slots = const SlotsConfig(),
    this.diet = '',
    this.lowCarb = false,
    this.exclusions = const [],
    this.dislikedIngredientIds = const [],
    this.healthLeanings = const [],
    this.cuisineLikes = const [],
    this.cuisineLess = const [],
    this.equipment = const [],
    this.blockedRecipeIds = const [],
    this.riceHabit = '',
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => Preferences(
    storeId: json['store_id'] == null ? '' : json['store_id'] as String,
    weeklyBudgetVnd: json['weekly_budget_vnd'] == null
        ? 0
        : (json['weekly_budget_vnd'] as num).toDouble(),
    adults: json['adults'] == null ? 0 : (json['adults'] as num).toInt(),
    children: json['children'] == null ? 0 : (json['children'] as num).toInt(),
    slots: json['slots'] == null
        ? const SlotsConfig()
        : SlotsConfig.fromJson(json['slots'] as Map<String, dynamic>),
    diet: json['diet'] == null ? '' : json['diet'] as String,
    lowCarb: json['low_carb'] == null ? false : json['low_carb'] as bool,
    exclusions: json['exclusions'] == null
        ? const []
        : (json['exclusions'] as List<dynamic>).cast<String>().toList(),
    dislikedIngredientIds: json['disliked_ingredient_ids'] == null
        ? const []
        : (json['disliked_ingredient_ids'] as List<dynamic>)
              .cast<String>()
              .toList(),
    healthLeanings: json['health_leanings'] == null
        ? const []
        : (json['health_leanings'] as List<dynamic>).cast<String>().toList(),
    cuisineLikes: json['cuisine_likes'] == null
        ? const []
        : (json['cuisine_likes'] as List<dynamic>).cast<String>().toList(),
    cuisineLess: json['cuisine_less'] == null
        ? const []
        : (json['cuisine_less'] as List<dynamic>).cast<String>().toList(),
    equipment: json['equipment'] == null
        ? const []
        : (json['equipment'] as List<dynamic>).cast<String>().toList(),
    blockedRecipeIds: json['blocked_recipe_ids'] == null
        ? const []
        : (json['blocked_recipe_ids'] as List<dynamic>).cast<String>().toList(),
    riceHabit: json['rice_habit'] == null ? '' : json['rice_habit'] as String,
  );

  final String storeId;
  final double weeklyBudgetVnd;
  final int adults;
  final int children;
  final SlotsConfig slots;
  final String diet;
  final bool lowCarb;
  final List<String> exclusions;
  final List<String> dislikedIngredientIds;
  final List<String> healthLeanings;
  final List<String> cuisineLikes;
  final List<String> cuisineLess;
  final List<String> equipment;
  final List<String> blockedRecipeIds;
  final String riceHabit;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Preferences copyWith({
    String? storeId,
    double? weeklyBudgetVnd,
    int? adults,
    int? children,
    SlotsConfig? slots,
    String? diet,
    bool? lowCarb,
    List<String>? exclusions,
    List<String>? dislikedIngredientIds,
    List<String>? healthLeanings,
    List<String>? cuisineLikes,
    List<String>? cuisineLess,
    List<String>? equipment,
    List<String>? blockedRecipeIds,
    String? riceHabit,
  }) => Preferences(
    storeId: storeId ?? this.storeId,
    weeklyBudgetVnd: weeklyBudgetVnd ?? this.weeklyBudgetVnd,
    adults: adults ?? this.adults,
    children: children ?? this.children,
    slots: slots ?? this.slots,
    diet: diet ?? this.diet,
    lowCarb: lowCarb ?? this.lowCarb,
    exclusions: exclusions ?? this.exclusions,
    dislikedIngredientIds: dislikedIngredientIds ?? this.dislikedIngredientIds,
    healthLeanings: healthLeanings ?? this.healthLeanings,
    cuisineLikes: cuisineLikes ?? this.cuisineLikes,
    cuisineLess: cuisineLess ?? this.cuisineLess,
    equipment: equipment ?? this.equipment,
    blockedRecipeIds: blockedRecipeIds ?? this.blockedRecipeIds,
    riceHabit: riceHabit ?? this.riceHabit,
  );

  Map<String, dynamic> toJson() => {
    'store_id': storeId,
    'weekly_budget_vnd': weeklyBudgetVnd,
    'adults': adults,
    'children': children,
    'slots': slots.toJson(),
    'diet': diet,
    'low_carb': lowCarb,
    'exclusions': exclusions,
    'disliked_ingredient_ids': dislikedIngredientIds,
    'health_leanings': healthLeanings,
    'cuisine_likes': cuisineLikes,
    'cuisine_less': cuisineLess,
    'equipment': equipment,
    'blocked_recipe_ids': blockedRecipeIds,
    'rice_habit': riceHabit,
  };
}

/// Schema `ProblemDetails`.
class ProblemDetails {
  const ProblemDetails({
    this.type,
    this.title,
    this.status,
    this.detail,
    this.instance,
  });

  factory ProblemDetails.fromJson(Map<String, dynamic> json) => ProblemDetails(
    type: json['type'] == null ? null : json['type'] as String,
    title: json['title'] == null ? null : json['title'] as String,
    status: json['status'] == null ? null : (json['status'] as num).toInt(),
    detail: json['detail'] == null ? null : json['detail'] as String,
    instance: json['instance'] == null ? null : json['instance'] as String,
  );

  final String? type;
  final String? title;
  final int? status;
  final String? detail;
  final String? instance;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ProblemDetails copyWith({
    String? type,
    String? title,
    int? status,
    String? detail,
    String? instance,
  }) => ProblemDetails(
    type: type ?? this.type,
    title: title ?? this.title,
    status: status ?? this.status,
    detail: detail ?? this.detail,
    instance: instance ?? this.instance,
  );

  Map<String, dynamic> toJson() => {
    if (type != null) 'type': type,
    if (title != null) 'title': title,
    if (status != null) 'status': status,
    if (detail != null) 'detail': detail,
    if (instance != null) 'instance': instance,
  };
}

/// Schema `Profile`.
class Profile {
  const Profile({
    this.goal = '',
    this.sex = '',
    this.age = 0,
    this.heightCm = 0,
    this.weightKg = 0,
    this.activity = '',
    this.targetMode = '',
    this.manualKcal,
    this.manualProteinG,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    goal: json['goal'] == null ? '' : json['goal'] as String,
    sex: json['sex'] == null ? '' : json['sex'] as String,
    age: json['age'] == null ? 0 : (json['age'] as num).toDouble(),
    heightCm: json['height_cm'] == null
        ? 0
        : (json['height_cm'] as num).toDouble(),
    weightKg: json['weight_kg'] == null
        ? 0
        : (json['weight_kg'] as num).toDouble(),
    activity: json['activity'] == null ? '' : json['activity'] as String,
    targetMode: json['target_mode'] == null
        ? ''
        : json['target_mode'] as String,
    manualKcal: json['manual_kcal'] == null
        ? null
        : (json['manual_kcal'] as num).toDouble(),
    manualProteinG: json['manual_protein_g'] == null
        ? null
        : (json['manual_protein_g'] as num).toDouble(),
  );

  final String goal;
  final String sex;
  final double age;
  final double heightCm;
  final double weightKg;
  final String activity;
  final String targetMode;
  final double? manualKcal;
  final double? manualProteinG;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Profile copyWith({
    String? goal,
    String? sex,
    double? age,
    double? heightCm,
    double? weightKg,
    String? activity,
    String? targetMode,
    double? manualKcal,
    double? manualProteinG,
  }) => Profile(
    goal: goal ?? this.goal,
    sex: sex ?? this.sex,
    age: age ?? this.age,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    activity: activity ?? this.activity,
    targetMode: targetMode ?? this.targetMode,
    manualKcal: manualKcal ?? this.manualKcal,
    manualProteinG: manualProteinG ?? this.manualProteinG,
  );

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'sex': sex,
    'age': age,
    'height_cm': heightCm,
    'weight_kg': weightKg,
    'activity': activity,
    'target_mode': targetMode,
    if (manualKcal != null) 'manual_kcal': manualKcal,
    if (manualProteinG != null) 'manual_protein_g': manualProteinG,
  };
}

/// Schema `PurchaseAs`.
class PurchaseAs {
  const PurchaseAs({this.ingredientId = '', this.factor = 0});

  factory PurchaseAs.fromJson(Map<String, dynamic> json) => PurchaseAs(
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    factor: json['factor'] == null ? 0 : (json['factor'] as num).toDouble(),
  );

  final String ingredientId;
  final double factor;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  PurchaseAs copyWith({String? ingredientId, double? factor}) => PurchaseAs(
    ingredientId: ingredientId ?? this.ingredientId,
    factor: factor ?? this.factor,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'factor': factor,
  };
}

/// Schema `Recipe`.
class Recipe {
  const Recipe({
    this.id = '',
    this.name = '',
    this.mealTypes = const [],
    this.lunchStyle = const [],
    this.snackStyle,
    this.cuisineTags = const [],
    this.healthTags = const [],
    this.equipment = const [],
    this.cookMinutes = 0,
    this.batchable = false,
    this.isLowCarb = false,
    this.ingredients = const [],
    this.steps = const [],
    this.image,
    this.dishRole = '',
    this.pairsWith = const [],
    this.portable = false,
    this.lowCarbOk = false,
    this.imageGroup,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'] == null ? '' : json['id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    mealTypes: json['meal_types'] == null
        ? const []
        : (json['meal_types'] as List<dynamic>).cast<String>().toList(),
    lunchStyle: json['lunch_style'] == null
        ? const []
        : (json['lunch_style'] as List<dynamic>).cast<String>().toList(),
    snackStyle: json['snack_style'] == null
        ? null
        : json['snack_style'] as String,
    cuisineTags: json['cuisine_tags'] == null
        ? const []
        : (json['cuisine_tags'] as List<dynamic>).cast<String>().toList(),
    healthTags: json['health_tags'] == null
        ? const []
        : (json['health_tags'] as List<dynamic>).cast<String>().toList(),
    equipment: json['equipment'] == null
        ? const []
        : (json['equipment'] as List<dynamic>).cast<String>().toList(),
    cookMinutes: json['cook_minutes'] == null
        ? 0
        : (json['cook_minutes'] as num).toDouble(),
    batchable: json['batchable'] == null ? false : json['batchable'] as bool,
    isLowCarb: json['is_low_carb'] == null
        ? false
        : json['is_low_carb'] as bool,
    ingredients: json['ingredients'] == null
        ? const []
        : (json['ingredients'] as List<dynamic>)
              .map((e) => RecipeIngredient.fromJson(e as Map<String, dynamic>))
              .toList(),
    steps: json['steps'] == null
        ? const []
        : (json['steps'] as List<dynamic>).cast<String>().toList(),
    image: json['image'] == null ? null : json['image'] as String,
    dishRole: json['dish_role'] == null ? '' : json['dish_role'] as String,
    pairsWith: json['pairs_with'] == null
        ? const []
        : (json['pairs_with'] as List<dynamic>).cast<String>().toList(),
    portable: json['portable'] == null ? false : json['portable'] as bool,
    lowCarbOk: json['low_carb_ok'] == null
        ? false
        : json['low_carb_ok'] as bool,
    imageGroup: json['image_group'] == null
        ? null
        : json['image_group'] as String,
  );

  final String id;
  final String name;
  final List<String> mealTypes;
  final List<String> lunchStyle;
  final String? snackStyle;
  final List<String> cuisineTags;
  final List<String> healthTags;
  final List<String> equipment;
  final double cookMinutes;
  final bool batchable;
  final bool isLowCarb;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final String? image;
  final String dishRole;
  final List<String> pairsWith;
  final bool portable;
  final bool lowCarbOk;
  final String? imageGroup;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Recipe copyWith({
    String? id,
    String? name,
    List<String>? mealTypes,
    List<String>? lunchStyle,
    String? snackStyle,
    List<String>? cuisineTags,
    List<String>? healthTags,
    List<String>? equipment,
    double? cookMinutes,
    bool? batchable,
    bool? isLowCarb,
    List<RecipeIngredient>? ingredients,
    List<String>? steps,
    String? image,
    String? dishRole,
    List<String>? pairsWith,
    bool? portable,
    bool? lowCarbOk,
    String? imageGroup,
  }) => Recipe(
    id: id ?? this.id,
    name: name ?? this.name,
    mealTypes: mealTypes ?? this.mealTypes,
    lunchStyle: lunchStyle ?? this.lunchStyle,
    snackStyle: snackStyle ?? this.snackStyle,
    cuisineTags: cuisineTags ?? this.cuisineTags,
    healthTags: healthTags ?? this.healthTags,
    equipment: equipment ?? this.equipment,
    cookMinutes: cookMinutes ?? this.cookMinutes,
    batchable: batchable ?? this.batchable,
    isLowCarb: isLowCarb ?? this.isLowCarb,
    ingredients: ingredients ?? this.ingredients,
    steps: steps ?? this.steps,
    image: image ?? this.image,
    dishRole: dishRole ?? this.dishRole,
    pairsWith: pairsWith ?? this.pairsWith,
    portable: portable ?? this.portable,
    lowCarbOk: lowCarbOk ?? this.lowCarbOk,
    imageGroup: imageGroup ?? this.imageGroup,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'meal_types': mealTypes,
    'lunch_style': lunchStyle,
    if (snackStyle != null) 'snack_style': snackStyle,
    'cuisine_tags': cuisineTags,
    'health_tags': healthTags,
    'equipment': equipment,
    'cook_minutes': cookMinutes,
    'batchable': batchable,
    'is_low_carb': isLowCarb,
    'ingredients': ingredients.map((e) => e.toJson()).toList(),
    'steps': steps,
    if (image != null) 'image': image,
    'dish_role': dishRole,
    'pairs_with': pairsWith,
    'portable': portable,
    'low_carb_ok': lowCarbOk,
    if (imageGroup != null) 'image_group': imageGroup,
  };
}

/// Schema `RecipeDetailResponse`.
class RecipeDetailResponse {
  const RecipeDetailResponse({
    this.recipe = const Recipe(),
    this.macros = const MacroResult(),
  });

  factory RecipeDetailResponse.fromJson(Map<String, dynamic> json) =>
      RecipeDetailResponse(
        recipe: json['recipe'] == null
            ? const Recipe()
            : Recipe.fromJson(json['recipe'] as Map<String, dynamic>),
        macros: json['macros'] == null
            ? const MacroResult()
            : MacroResult.fromJson(json['macros'] as Map<String, dynamic>),
      );

  final Recipe recipe;
  final MacroResult macros;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RecipeDetailResponse copyWith({Recipe? recipe, MacroResult? macros}) =>
      RecipeDetailResponse(
        recipe: recipe ?? this.recipe,
        macros: macros ?? this.macros,
      );

  Map<String, dynamic> toJson() => {
    'recipe': recipe.toJson(),
    'macros': macros.toJson(),
  };
}

/// Schema `RecipeIngredient`.
class RecipeIngredient {
  const RecipeIngredient({
    this.ingredientId = '',
    this.grams = 0,
    this.role = '',
    this.minG = 0,
    this.maxG = 0,
    this.swapGroup,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) =>
      RecipeIngredient(
        ingredientId: json['ingredient_id'] == null
            ? ''
            : json['ingredient_id'] as String,
        grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
        role: json['role'] == null ? '' : json['role'] as String,
        minG: json['min_g'] == null ? 0 : (json['min_g'] as num).toDouble(),
        maxG: json['max_g'] == null ? 0 : (json['max_g'] as num).toDouble(),
        swapGroup: json['swap_group'] == null
            ? null
            : json['swap_group'] as String,
      );

  final String ingredientId;
  final double grams;
  final String role;
  final double minG;
  final double maxG;
  final String? swapGroup;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RecipeIngredient copyWith({
    String? ingredientId,
    double? grams,
    String? role,
    double? minG,
    double? maxG,
    String? swapGroup,
  }) => RecipeIngredient(
    ingredientId: ingredientId ?? this.ingredientId,
    grams: grams ?? this.grams,
    role: role ?? this.role,
    minG: minG ?? this.minG,
    maxG: maxG ?? this.maxG,
    swapGroup: swapGroup ?? this.swapGroup,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'grams': grams,
    'role': role,
    'min_g': minG,
    'max_g': maxG,
    if (swapGroup != null) 'swap_group': swapGroup,
  };
}

/// Schema `ReferenceResponse`.
class ReferenceResponse {
  const ReferenceResponse({
    this.dataVersion = '',
    this.stores = const [],
    this.equipment = const [],
    this.exclusions = const [],
    this.diets = const [],
    this.swipeCards = const [],
    this.healthLeanings = const [],
    this.dislikeSuggestions = const [],
    this.aisles = const {},
    this.recipeCount = 0,
    this.ingredientCount = 0,
  });

  factory ReferenceResponse.fromJson(Map<String, dynamic> json) =>
      ReferenceResponse(
        dataVersion: json['data_version'] == null
            ? ''
            : json['data_version'] as String,
        stores: json['stores'] == null
            ? const []
            : (json['stores'] as List<dynamic>)
                  .map((e) => StoreDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        equipment: json['equipment'] == null
            ? const []
            : (json['equipment'] as List<dynamic>)
                  .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        exclusions: json['exclusions'] == null
            ? const []
            : (json['exclusions'] as List<dynamic>)
                  .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        diets: json['diets'] == null
            ? const []
            : (json['diets'] as List<dynamic>)
                  .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        swipeCards: json['swipe_cards'] == null
            ? const []
            : (json['swipe_cards'] as List<dynamic>)
                  .map((e) => SwipeCardDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        healthLeanings: json['health_leanings'] == null
            ? const []
            : (json['health_leanings'] as List<dynamic>)
                  .map((e) => OptionDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        dislikeSuggestions: json['dislike_suggestions'] == null
            ? const []
            : (json['dislike_suggestions'] as List<dynamic>)
                  .map((e) => IngredientDto.fromJson(e as Map<String, dynamic>))
                  .toList(),
        aisles: json['aisles'] == null
            ? const {}
            : (json['aisles'] as Map<String, dynamic>).map(
                (k, v) => MapEntry(k, v as String),
              ),
        recipeCount: json['recipe_count'] == null
            ? 0
            : (json['recipe_count'] as num).toInt(),
        ingredientCount: json['ingredient_count'] == null
            ? 0
            : (json['ingredient_count'] as num).toInt(),
      );

  final String dataVersion;
  final List<StoreDto> stores;
  final List<OptionDto> equipment;
  final List<OptionDto> exclusions;
  final List<OptionDto> diets;
  final List<SwipeCardDto> swipeCards;
  final List<OptionDto> healthLeanings;
  final List<IngredientDto> dislikeSuggestions;
  final Map<String, String> aisles;
  final int recipeCount;
  final int ingredientCount;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ReferenceResponse copyWith({
    String? dataVersion,
    List<StoreDto>? stores,
    List<OptionDto>? equipment,
    List<OptionDto>? exclusions,
    List<OptionDto>? diets,
    List<SwipeCardDto>? swipeCards,
    List<OptionDto>? healthLeanings,
    List<IngredientDto>? dislikeSuggestions,
    Map<String, String>? aisles,
    int? recipeCount,
    int? ingredientCount,
  }) => ReferenceResponse(
    dataVersion: dataVersion ?? this.dataVersion,
    stores: stores ?? this.stores,
    equipment: equipment ?? this.equipment,
    exclusions: exclusions ?? this.exclusions,
    diets: diets ?? this.diets,
    swipeCards: swipeCards ?? this.swipeCards,
    healthLeanings: healthLeanings ?? this.healthLeanings,
    dislikeSuggestions: dislikeSuggestions ?? this.dislikeSuggestions,
    aisles: aisles ?? this.aisles,
    recipeCount: recipeCount ?? this.recipeCount,
    ingredientCount: ingredientCount ?? this.ingredientCount,
  );

  Map<String, dynamic> toJson() => {
    'data_version': dataVersion,
    'stores': stores.map((e) => e.toJson()).toList(),
    'equipment': equipment.map((e) => e.toJson()).toList(),
    'exclusions': exclusions.map((e) => e.toJson()).toList(),
    'diets': diets.map((e) => e.toJson()).toList(),
    'swipe_cards': swipeCards.map((e) => e.toJson()).toList(),
    'health_leanings': healthLeanings.map((e) => e.toJson()).toList(),
    'dislike_suggestions': dislikeSuggestions.map((e) => e.toJson()).toList(),
    'aisles': aisles,
    'recipe_count': recipeCount,
    'ingredient_count': ingredientCount,
  };
}

/// Schema `RegenerateRestRequest`.
class RegenerateRestRequest {
  const RegenerateRestRequest({
    this.state = const PlanStateDto(),
    this.today = '',
    this.seed,
  });

  factory RegenerateRestRequest.fromJson(Map<String, dynamic> json) =>
      RegenerateRestRequest(
        state: json['state'] == null
            ? const PlanStateDto()
            : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
        today: json['today'] == null ? '' : json['today'] as String,
        seed: json['seed'] == null ? null : (json['seed'] as num).toInt(),
      );

  final PlanStateDto state;
  final String today;
  final int? seed;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RegenerateRestRequest copyWith({
    PlanStateDto? state,
    String? today,
    int? seed,
  }) => RegenerateRestRequest(
    state: state ?? this.state,
    today: today ?? this.today,
    seed: seed ?? this.seed,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'today': today,
    if (seed != null) 'seed': seed,
  };
}

/// Schema `RiceFeasibilityItem`.
class RiceFeasibilityItem {
  const RiceFeasibilityItem({
    this.habit = '',
    this.targetG = 0,
    this.targetCups = 0,
    this.feasibleG = 0,
    this.feasibleCups = 0,
    this.feasible = false,
    this.reason,
    this.mealsPlanned,
    this.mealsWithFullRice,
    this.mealsWithRice,
    this.budgetVnd,
    this.budgetNeededVnd,
  });

  factory RiceFeasibilityItem.fromJson(Map<String, dynamic> json) =>
      RiceFeasibilityItem(
        habit: json['habit'] == null ? '' : json['habit'] as String,
        targetG: json['target_g'] == null
            ? 0
            : (json['target_g'] as num).toDouble(),
        targetCups: json['target_cups'] == null
            ? 0
            : (json['target_cups'] as num).toDouble(),
        feasibleG: json['feasible_g'] == null
            ? 0
            : (json['feasible_g'] as num).toDouble(),
        feasibleCups: json['feasible_cups'] == null
            ? 0
            : (json['feasible_cups'] as num).toDouble(),
        feasible: json['feasible'] == null ? false : json['feasible'] as bool,
        reason: json['reason'] == null ? null : json['reason'] as String,
        mealsPlanned: json['meals_planned'] == null
            ? null
            : (json['meals_planned'] as num).toInt(),
        mealsWithFullRice: json['meals_with_full_rice'] == null
            ? null
            : (json['meals_with_full_rice'] as num).toInt(),
        mealsWithRice: json['meals_with_rice'] == null
            ? null
            : (json['meals_with_rice'] as num).toInt(),
        budgetVnd: json['budget_vnd'] == null
            ? null
            : (json['budget_vnd'] as num).toDouble(),
        budgetNeededVnd: json['budget_needed_vnd'] == null
            ? null
            : (json['budget_needed_vnd'] as num).toDouble(),
      );

  final String habit;
  final double targetG;
  final double targetCups;
  final double feasibleG;
  final double feasibleCups;
  final bool feasible;
  final String? reason;
  final int? mealsPlanned;
  final int? mealsWithFullRice;
  final int? mealsWithRice;
  final double? budgetVnd;
  final double? budgetNeededVnd;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RiceFeasibilityItem copyWith({
    String? habit,
    double? targetG,
    double? targetCups,
    double? feasibleG,
    double? feasibleCups,
    bool? feasible,
    String? reason,
    int? mealsPlanned,
    int? mealsWithFullRice,
    int? mealsWithRice,
    double? budgetVnd,
    double? budgetNeededVnd,
  }) => RiceFeasibilityItem(
    habit: habit ?? this.habit,
    targetG: targetG ?? this.targetG,
    targetCups: targetCups ?? this.targetCups,
    feasibleG: feasibleG ?? this.feasibleG,
    feasibleCups: feasibleCups ?? this.feasibleCups,
    feasible: feasible ?? this.feasible,
    reason: reason ?? this.reason,
    mealsPlanned: mealsPlanned ?? this.mealsPlanned,
    mealsWithFullRice: mealsWithFullRice ?? this.mealsWithFullRice,
    mealsWithRice: mealsWithRice ?? this.mealsWithRice,
    budgetVnd: budgetVnd ?? this.budgetVnd,
    budgetNeededVnd: budgetNeededVnd ?? this.budgetNeededVnd,
  );

  Map<String, dynamic> toJson() => {
    'habit': habit,
    'target_g': targetG,
    'target_cups': targetCups,
    'feasible_g': feasibleG,
    'feasible_cups': feasibleCups,
    'feasible': feasible,
    if (reason != null) 'reason': reason,
    if (mealsPlanned != null) 'meals_planned': mealsPlanned,
    if (mealsWithFullRice != null) 'meals_with_full_rice': mealsWithFullRice,
    if (mealsWithRice != null) 'meals_with_rice': mealsWithRice,
    if (budgetVnd != null) 'budget_vnd': budgetVnd,
    if (budgetNeededVnd != null) 'budget_needed_vnd': budgetNeededVnd,
  };
}

/// Schema `RiceFeasibilityRequest`.
class RiceFeasibilityRequest {
  const RiceFeasibilityRequest({
    this.profile = const Profile(),
    this.slots = const SlotsConfig(),
    this.preferences,
    this.startDate,
    this.seed,
  });

  factory RiceFeasibilityRequest.fromJson(Map<String, dynamic> json) =>
      RiceFeasibilityRequest(
        profile: json['profile'] == null
            ? const Profile()
            : Profile.fromJson(json['profile'] as Map<String, dynamic>),
        slots: json['slots'] == null
            ? const SlotsConfig()
            : SlotsConfig.fromJson(json['slots'] as Map<String, dynamic>),
        preferences: json['preferences'] == null
            ? null
            : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
        startDate: json['start_date'] == null
            ? null
            : json['start_date'] as String,
        seed: json['seed'] == null ? null : (json['seed'] as num).toInt(),
      );

  final Profile profile;
  final SlotsConfig slots;
  final Preferences? preferences;
  final String? startDate;
  final int? seed;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RiceFeasibilityRequest copyWith({
    Profile? profile,
    SlotsConfig? slots,
    Preferences? preferences,
    String? startDate,
    int? seed,
  }) => RiceFeasibilityRequest(
    profile: profile ?? this.profile,
    slots: slots ?? this.slots,
    preferences: preferences ?? this.preferences,
    startDate: startDate ?? this.startDate,
    seed: seed ?? this.seed,
  );

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'slots': slots.toJson(),
    if (preferences != null) 'preferences': preferences?.toJson(),
    if (startDate != null) 'start_date': startDate,
    if (seed != null) 'seed': seed,
  };
}

/// Schema `RiceFeasibilityResponse`.
class RiceFeasibilityResponse {
  const RiceFeasibilityResponse({
    this.targets = const Targets(),
    this.habits = const [],
  });

  factory RiceFeasibilityResponse.fromJson(Map<String, dynamic> json) =>
      RiceFeasibilityResponse(
        targets: json['targets'] == null
            ? const Targets()
            : Targets.fromJson(json['targets'] as Map<String, dynamic>),
        habits: json['habits'] == null
            ? const []
            : (json['habits'] as List<dynamic>)
                  .map(
                    (e) =>
                        RiceFeasibilityItem.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
      );

  final Targets targets;
  final List<RiceFeasibilityItem> habits;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RiceFeasibilityResponse copyWith({
    Targets? targets,
    List<RiceFeasibilityItem>? habits,
  }) => RiceFeasibilityResponse(
    targets: targets ?? this.targets,
    habits: habits ?? this.habits,
  );

  Map<String, dynamic> toJson() => {
    'targets': targets.toJson(),
    'habits': habits.map((e) => e.toJson()).toList(),
  };
}

/// Schema `RiceInfo`.
class RiceInfo {
  const RiceInfo({
    this.habit = '',
    this.targetG = 0,
    this.actualG = 0,
    this.kind = '',
    this.riceEquivG = 0,
  });

  factory RiceInfo.fromJson(Map<String, dynamic> json) => RiceInfo(
    habit: json['habit'] == null ? '' : json['habit'] as String,
    targetG: json['target_g'] == null
        ? 0
        : (json['target_g'] as num).toDouble(),
    actualG: json['actual_g'] == null
        ? 0
        : (json['actual_g'] as num).toDouble(),
    kind: json['kind'] == null ? '' : json['kind'] as String,
    riceEquivG: json['rice_equiv_g'] == null
        ? 0
        : (json['rice_equiv_g'] as num).toDouble(),
  );

  final String habit;
  final double targetG;
  final double actualG;
  final String kind;
  final double riceEquivG;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  RiceInfo copyWith({
    String? habit,
    double? targetG,
    double? actualG,
    String? kind,
    double? riceEquivG,
  }) => RiceInfo(
    habit: habit ?? this.habit,
    targetG: targetG ?? this.targetG,
    actualG: actualG ?? this.actualG,
    kind: kind ?? this.kind,
    riceEquivG: riceEquivG ?? this.riceEquivG,
  );

  Map<String, dynamic> toJson() => {
    'habit': habit,
    'target_g': targetG,
    'actual_g': actualG,
    'kind': kind,
    'rice_equiv_g': riceEquivG,
  };
}

/// Schema `ShoppingItem`.
class ShoppingItem {
  const ShoppingItem({
    this.ingredientId = '',
    this.name = '',
    this.aisle = '',
    this.needG = 0,
    this.packs = 0,
    this.packG = 0,
    this.packLabel = '',
    this.priceVndPerPack = 0,
    this.usedCostVnd = 0,
    this.tillCostVnd = 0,
    this.leftoverG = 0,
    this.leftoverDays = 0,
    this.priceStoreId = '',
    this.priceFallback = false,
    this.displayQty,
    this.isDefaultPantry,
    this.isPantry,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    aisle: json['aisle'] == null ? '' : json['aisle'] as String,
    needG: json['need_g'] == null ? 0 : (json['need_g'] as num).toDouble(),
    packs: json['packs'] == null ? 0 : (json['packs'] as num).toInt(),
    packG: json['pack_g'] == null ? 0 : (json['pack_g'] as num).toDouble(),
    packLabel: json['pack_label'] == null ? '' : json['pack_label'] as String,
    priceVndPerPack: json['price_vnd_per_pack'] == null
        ? 0
        : (json['price_vnd_per_pack'] as num).toDouble(),
    usedCostVnd: json['used_cost_vnd'] == null
        ? 0
        : (json['used_cost_vnd'] as num).toDouble(),
    tillCostVnd: json['till_cost_vnd'] == null
        ? 0
        : (json['till_cost_vnd'] as num).toDouble(),
    leftoverG: json['leftover_g'] == null
        ? 0
        : (json['leftover_g'] as num).toDouble(),
    leftoverDays: json['leftover_days'] == null
        ? 0
        : (json['leftover_days'] as num).toDouble(),
    priceStoreId: json['price_store_id'] == null
        ? ''
        : json['price_store_id'] as String,
    priceFallback: json['price_fallback'] == null
        ? false
        : json['price_fallback'] as bool,
    displayQty: json['display_qty'] == null
        ? null
        : json['display_qty'] as String,
    isDefaultPantry: json['is_default_pantry'] == null
        ? null
        : json['is_default_pantry'] as bool,
    isPantry: json['is_pantry'] == null ? null : json['is_pantry'] as bool,
  );

  final String ingredientId;
  final String name;
  final String aisle;
  final double needG;
  final int packs;
  final double packG;
  final String packLabel;
  final double priceVndPerPack;
  final double usedCostVnd;
  final double tillCostVnd;
  final double leftoverG;
  final double leftoverDays;
  final String priceStoreId;
  final bool priceFallback;
  final String? displayQty;
  final bool? isDefaultPantry;
  final bool? isPantry;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ShoppingItem copyWith({
    String? ingredientId,
    String? name,
    String? aisle,
    double? needG,
    int? packs,
    double? packG,
    String? packLabel,
    double? priceVndPerPack,
    double? usedCostVnd,
    double? tillCostVnd,
    double? leftoverG,
    double? leftoverDays,
    String? priceStoreId,
    bool? priceFallback,
    String? displayQty,
    bool? isDefaultPantry,
    bool? isPantry,
  }) => ShoppingItem(
    ingredientId: ingredientId ?? this.ingredientId,
    name: name ?? this.name,
    aisle: aisle ?? this.aisle,
    needG: needG ?? this.needG,
    packs: packs ?? this.packs,
    packG: packG ?? this.packG,
    packLabel: packLabel ?? this.packLabel,
    priceVndPerPack: priceVndPerPack ?? this.priceVndPerPack,
    usedCostVnd: usedCostVnd ?? this.usedCostVnd,
    tillCostVnd: tillCostVnd ?? this.tillCostVnd,
    leftoverG: leftoverG ?? this.leftoverG,
    leftoverDays: leftoverDays ?? this.leftoverDays,
    priceStoreId: priceStoreId ?? this.priceStoreId,
    priceFallback: priceFallback ?? this.priceFallback,
    displayQty: displayQty ?? this.displayQty,
    isDefaultPantry: isDefaultPantry ?? this.isDefaultPantry,
    isPantry: isPantry ?? this.isPantry,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'name': name,
    'aisle': aisle,
    'need_g': needG,
    'packs': packs,
    'pack_g': packG,
    'pack_label': packLabel,
    'price_vnd_per_pack': priceVndPerPack,
    'used_cost_vnd': usedCostVnd,
    'till_cost_vnd': tillCostVnd,
    'leftover_g': leftoverG,
    'leftover_days': leftoverDays,
    'price_store_id': priceStoreId,
    'price_fallback': priceFallback,
    if (displayQty != null) 'display_qty': displayQty,
    if (isDefaultPantry != null) 'is_default_pantry': isDefaultPantry,
    if (isPantry != null) 'is_pantry': isPantry,
  };
}

/// Schema `ShoppingLineDto`.
class ShoppingLineDto {
  const ShoppingLineDto({
    this.ingredientId = '',
    this.grams = 0,
    this.standardGrams = 0,
  });

  factory ShoppingLineDto.fromJson(Map<String, dynamic> json) =>
      ShoppingLineDto(
        ingredientId: json['ingredient_id'] == null
            ? ''
            : json['ingredient_id'] as String,
        grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
        standardGrams: json['standard_grams'] == null
            ? 0
            : (json['standard_grams'] as num).toDouble(),
      );

  final String ingredientId;
  final double grams;
  final double standardGrams;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ShoppingLineDto copyWith({
    String? ingredientId,
    double? grams,
    double? standardGrams,
  }) => ShoppingLineDto(
    ingredientId: ingredientId ?? this.ingredientId,
    grams: grams ?? this.grams,
    standardGrams: standardGrams ?? this.standardGrams,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'grams': grams,
    'standard_grams': standardGrams,
  };
}

/// Schema `ShoppingList`.
class ShoppingList {
  const ShoppingList({
    this.items = const [],
    this.byAisle = const [],
    this.skippedPantry = const [],
    this.weekFoodCost = 0,
    this.tillCost = 0,
    this.pantryCostIfBuyVnd,
  });

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
    items: json['items'] == null
        ? const []
        : (json['items'] as List<dynamic>)
              .map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>))
              .toList(),
    byAisle: json['by_aisle'] == null
        ? const []
        : (json['by_aisle'] as List<dynamic>)
              .map((e) => AisleGroup.fromJson(e as Map<String, dynamic>))
              .toList(),
    skippedPantry: json['skipped_pantry'] == null
        ? const []
        : (json['skipped_pantry'] as List<dynamic>).cast<String>().toList(),
    weekFoodCost: json['week_food_cost'] == null
        ? 0
        : (json['week_food_cost'] as num).toDouble(),
    tillCost: json['till_cost'] == null
        ? 0
        : (json['till_cost'] as num).toDouble(),
    pantryCostIfBuyVnd: json['pantry_cost_if_buy_vnd'] == null
        ? null
        : (json['pantry_cost_if_buy_vnd'] as num).toDouble(),
  );

  final List<ShoppingItem> items;
  final List<AisleGroup> byAisle;
  final List<String> skippedPantry;
  final double weekFoodCost;
  final double tillCost;
  final double? pantryCostIfBuyVnd;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ShoppingList copyWith({
    List<ShoppingItem>? items,
    List<AisleGroup>? byAisle,
    List<String>? skippedPantry,
    double? weekFoodCost,
    double? tillCost,
    double? pantryCostIfBuyVnd,
  }) => ShoppingList(
    items: items ?? this.items,
    byAisle: byAisle ?? this.byAisle,
    skippedPantry: skippedPantry ?? this.skippedPantry,
    weekFoodCost: weekFoodCost ?? this.weekFoodCost,
    tillCost: tillCost ?? this.tillCost,
    pantryCostIfBuyVnd: pantryCostIfBuyVnd ?? this.pantryCostIfBuyVnd,
  );

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'by_aisle': byAisle.map((e) => e.toJson()).toList(),
    'skipped_pantry': skippedPantry,
    'week_food_cost': weekFoodCost,
    'till_cost': tillCost,
    if (pantryCostIfBuyVnd != null)
      'pantry_cost_if_buy_vnd': pantryCostIfBuyVnd,
  };
}

/// Schema `ShoppingListRequest`.
class ShoppingListRequest {
  const ShoppingListRequest({
    this.meals = const [],
    this.storeId = '',
    this.adults = 0,
    this.children = 0,
    this.pantryIds,
  });

  factory ShoppingListRequest.fromJson(
    Map<String, dynamic> json,
  ) => ShoppingListRequest(
    meals: json['meals'] == null
        ? const []
        : (json['meals'] as List<dynamic>)
              .map((e) => ShoppingMealDto.fromJson(e as Map<String, dynamic>))
              .toList(),
    storeId: json['store_id'] == null ? '' : json['store_id'] as String,
    adults: json['adults'] == null ? 0 : (json['adults'] as num).toInt(),
    children: json['children'] == null ? 0 : (json['children'] as num).toInt(),
    pantryIds: json['pantry_ids'] == null
        ? null
        : (json['pantry_ids'] as List<dynamic>).cast<String>().toList(),
  );

  final List<ShoppingMealDto> meals;
  final String storeId;
  final int adults;
  final int children;
  final List<String>? pantryIds;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ShoppingListRequest copyWith({
    List<ShoppingMealDto>? meals,
    String? storeId,
    int? adults,
    int? children,
    List<String>? pantryIds,
  }) => ShoppingListRequest(
    meals: meals ?? this.meals,
    storeId: storeId ?? this.storeId,
    adults: adults ?? this.adults,
    children: children ?? this.children,
    pantryIds: pantryIds ?? this.pantryIds,
  );

  Map<String, dynamic> toJson() => {
    'meals': meals.map((e) => e.toJson()).toList(),
    'store_id': storeId,
    'adults': adults,
    'children': children,
    if (pantryIds != null) 'pantry_ids': pantryIds,
  };
}

/// Schema `ShoppingMealDto`.
class ShoppingMealDto {
  const ShoppingMealDto({this.ingredients = const [], this.eatenOut = false});

  factory ShoppingMealDto.fromJson(Map<String, dynamic> json) =>
      ShoppingMealDto(
        ingredients: json['ingredients'] == null
            ? const []
            : (json['ingredients'] as List<dynamic>)
                  .map(
                    (e) => ShoppingLineDto.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
        eatenOut: json['eaten_out'] == null ? false : json['eaten_out'] as bool,
      );

  final List<ShoppingLineDto> ingredients;
  final bool eatenOut;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  ShoppingMealDto copyWith({
    List<ShoppingLineDto>? ingredients,
    bool? eatenOut,
  }) => ShoppingMealDto(
    ingredients: ingredients ?? this.ingredients,
    eatenOut: eatenOut ?? this.eatenOut,
  );

  Map<String, dynamic> toJson() => {
    'ingredients': ingredients.map((e) => e.toJson()).toList(),
    'eaten_out': eatenOut,
  };
}

/// Schema `Shortfall`.
class Shortfall {
  const Shortfall({this.date = '', this.kind = '', this.amount = 0});

  factory Shortfall.fromJson(Map<String, dynamic> json) => Shortfall(
    date: json['date'] == null ? '' : json['date'] as String,
    kind: json['kind'] == null ? '' : json['kind'] as String,
    amount: json['amount'] == null ? 0 : (json['amount'] as num).toDouble(),
  );

  final String date;
  final String kind;
  final double amount;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Shortfall copyWith({String? date, String? kind, double? amount}) => Shortfall(
    date: date ?? this.date,
    kind: kind ?? this.kind,
    amount: amount ?? this.amount,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'kind': kind,
    'amount': amount,
  };
}

/// Schema `SlotTarget`.
class SlotTarget {
  const SlotTarget({
    this.slot = '',
    this.mode = '',
    this.share = 0,
    this.kcal = 0,
    this.proteinG = 0,
    this.planned = false,
  });

  factory SlotTarget.fromJson(Map<String, dynamic> json) => SlotTarget(
    slot: json['slot'] == null ? '' : json['slot'] as String,
    mode: json['mode'] == null ? '' : json['mode'] as String,
    share: json['share'] == null ? 0 : (json['share'] as num).toDouble(),
    kcal: json['kcal'] == null ? 0 : (json['kcal'] as num).toDouble(),
    proteinG: json['protein_g'] == null
        ? 0
        : (json['protein_g'] as num).toDouble(),
    planned: json['planned'] == null ? false : json['planned'] as bool,
  );

  final String slot;
  final String mode;
  final double share;
  final double kcal;
  final double proteinG;
  final bool planned;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SlotTarget copyWith({
    String? slot,
    String? mode,
    double? share,
    double? kcal,
    double? proteinG,
    bool? planned,
  }) => SlotTarget(
    slot: slot ?? this.slot,
    mode: mode ?? this.mode,
    share: share ?? this.share,
    kcal: kcal ?? this.kcal,
    proteinG: proteinG ?? this.proteinG,
    planned: planned ?? this.planned,
  );

  Map<String, dynamic> toJson() => {
    'slot': slot,
    'mode': mode,
    'share': share,
    'kcal': kcal,
    'protein_g': proteinG,
    'planned': planned,
  };
}

/// Schema `SlotsConfig`.
class SlotsConfig {
  const SlotsConfig({
    this.breakfast = '',
    this.lunch = '',
    this.dinner = '',
    this.snackAm = '',
    this.snackPm = '',
    this.lunchStyle = '',
    this.snackPmStyle = '',
  });

  factory SlotsConfig.fromJson(Map<String, dynamic> json) => SlotsConfig(
    breakfast: json['breakfast'] == null ? '' : json['breakfast'] as String,
    lunch: json['lunch'] == null ? '' : json['lunch'] as String,
    dinner: json['dinner'] == null ? '' : json['dinner'] as String,
    snackAm: json['snack_am'] == null ? '' : json['snack_am'] as String,
    snackPm: json['snack_pm'] == null ? '' : json['snack_pm'] as String,
    lunchStyle: json['lunch_style'] == null
        ? ''
        : json['lunch_style'] as String,
    snackPmStyle: json['snack_pm_style'] == null
        ? ''
        : json['snack_pm_style'] as String,
  );

  final String breakfast;
  final String lunch;
  final String dinner;
  final String snackAm;
  final String snackPm;
  final String lunchStyle;
  final String snackPmStyle;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SlotsConfig copyWith({
    String? breakfast,
    String? lunch,
    String? dinner,
    String? snackAm,
    String? snackPm,
    String? lunchStyle,
    String? snackPmStyle,
  }) => SlotsConfig(
    breakfast: breakfast ?? this.breakfast,
    lunch: lunch ?? this.lunch,
    dinner: dinner ?? this.dinner,
    snackAm: snackAm ?? this.snackAm,
    snackPm: snackPm ?? this.snackPm,
    lunchStyle: lunchStyle ?? this.lunchStyle,
    snackPmStyle: snackPmStyle ?? this.snackPmStyle,
  );

  Map<String, dynamic> toJson() => {
    'breakfast': breakfast,
    'lunch': lunch,
    'dinner': dinner,
    'snack_am': snackAm,
    'snack_pm': snackPm,
    'lunch_style': lunchStyle,
    'snack_pm_style': snackPmStyle,
  };
}

/// Schema `SlotsPreviewRequest`.
class SlotsPreviewRequest {
  const SlotsPreviewRequest({
    this.profile = const Profile(),
    this.slots = const SlotsConfig(),
  });

  factory SlotsPreviewRequest.fromJson(Map<String, dynamic> json) =>
      SlotsPreviewRequest(
        profile: json['profile'] == null
            ? const Profile()
            : Profile.fromJson(json['profile'] as Map<String, dynamic>),
        slots: json['slots'] == null
            ? const SlotsConfig()
            : SlotsConfig.fromJson(json['slots'] as Map<String, dynamic>),
      );

  final Profile profile;
  final SlotsConfig slots;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SlotsPreviewRequest copyWith({Profile? profile, SlotsConfig? slots}) =>
      SlotsPreviewRequest(
        profile: profile ?? this.profile,
        slots: slots ?? this.slots,
      );

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'slots': slots.toJson(),
  };
}

/// Schema `SlotsPreviewResponse`.
class SlotsPreviewResponse {
  const SlotsPreviewResponse({
    this.targets = const Targets(),
    this.slots = const [],
  });

  factory SlotsPreviewResponse.fromJson(Map<String, dynamic> json) =>
      SlotsPreviewResponse(
        targets: json['targets'] == null
            ? const Targets()
            : Targets.fromJson(json['targets'] as Map<String, dynamic>),
        slots: json['slots'] == null
            ? const []
            : (json['slots'] as List<dynamic>)
                  .map((e) => SlotTarget.fromJson(e as Map<String, dynamic>))
                  .toList(),
      );

  final Targets targets;
  final List<SlotTarget> slots;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SlotsPreviewResponse copyWith({Targets? targets, List<SlotTarget>? slots}) =>
      SlotsPreviewResponse(
        targets: targets ?? this.targets,
        slots: slots ?? this.slots,
      );

  Map<String, dynamic> toJson() => {
    'targets': targets.toJson(),
    'slots': slots.map((e) => e.toJson()).toList(),
  };
}

/// Schema `Source`.
class Source {
  const Source({this.db = '', this.code = '', this.note = ''});

  factory Source.fromJson(Map<String, dynamic> json) => Source(
    db: json['db'] == null ? '' : json['db'] as String,
    code: json['code'] == null ? '' : json['code'] as String,
    note: json['note'] == null ? '' : json['note'] as String,
  );

  final String db;
  final String code;
  final String note;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Source copyWith({String? db, String? code, String? note}) => Source(
    db: db ?? this.db,
    code: code ?? this.code,
    note: note ?? this.note,
  );

  Map<String, dynamic> toJson() => {'db': db, 'code': code, 'note': note};
}

/// Schema `StoreDto`.
class StoreDto {
  const StoreDto({this.id = '', this.name = '', this.priceSurveyDate});

  factory StoreDto.fromJson(Map<String, dynamic> json) => StoreDto(
    id: json['id'] == null ? '' : json['id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    priceSurveyDate: json['price_survey_date'] == null
        ? null
        : json['price_survey_date'] as String,
  );

  final String id;
  final String name;
  final String? priceSurveyDate;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  StoreDto copyWith({String? id, String? name, String? priceSurveyDate}) =>
      StoreDto(
        id: id ?? this.id,
        name: name ?? this.name,
        priceSurveyDate: priceSurveyDate ?? this.priceSurveyDate,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    if (priceSurveyDate != null) 'price_survey_date': priceSurveyDate,
  };
}

/// Schema `Substitution`.
class Substitution {
  const Substitution({this.from = '', this.to = ''});

  factory Substitution.fromJson(Map<String, dynamic> json) => Substitution(
    from: json['from'] == null ? '' : json['from'] as String,
    to: json['to'] == null ? '' : json['to'] as String,
  );

  final String from;
  final String to;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Substitution copyWith({String? from, String? to}) =>
      Substitution(from: from ?? this.from, to: to ?? this.to);

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

/// Schema `SwapDish`.
class SwapDish {
  const SwapDish({this.role = '', this.recipeId = '', this.name = ''});

  factory SwapDish.fromJson(Map<String, dynamic> json) => SwapDish(
    role: json['role'] == null ? '' : json['role'] as String,
    recipeId: json['recipe_id'] == null ? '' : json['recipe_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
  );

  final String role;
  final String recipeId;
  final String name;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwapDish copyWith({String? role, String? recipeId, String? name}) => SwapDish(
    role: role ?? this.role,
    recipeId: recipeId ?? this.recipeId,
    name: name ?? this.name,
  );

  Map<String, dynamic> toJson() => {
    'role': role,
    'recipe_id': recipeId,
    'name': name,
  };
}

/// Schema `SwapIngredientRequest`.
class SwapIngredientRequest {
  const SwapIngredientRequest({
    this.state = const PlanStateDto(),
    this.date = '',
    this.slot = '',
    this.fromIngredientId = '',
    this.toIngredientId = '',
  });

  factory SwapIngredientRequest.fromJson(Map<String, dynamic> json) =>
      SwapIngredientRequest(
        state: json['state'] == null
            ? const PlanStateDto()
            : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
        date: json['date'] == null ? '' : json['date'] as String,
        slot: json['slot'] == null ? '' : json['slot'] as String,
        fromIngredientId: json['from_ingredient_id'] == null
            ? ''
            : json['from_ingredient_id'] as String,
        toIngredientId: json['to_ingredient_id'] == null
            ? ''
            : json['to_ingredient_id'] as String,
      );

  final PlanStateDto state;
  final String date;
  final String slot;
  final String fromIngredientId;
  final String toIngredientId;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwapIngredientRequest copyWith({
    PlanStateDto? state,
    String? date,
    String? slot,
    String? fromIngredientId,
    String? toIngredientId,
  }) => SwapIngredientRequest(
    state: state ?? this.state,
    date: date ?? this.date,
    slot: slot ?? this.slot,
    fromIngredientId: fromIngredientId ?? this.fromIngredientId,
    toIngredientId: toIngredientId ?? this.toIngredientId,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'date': date,
    'slot': slot,
    'from_ingredient_id': fromIngredientId,
    'to_ingredient_id': toIngredientId,
  };
}

/// Schema `SwapSuggestion`.
class SwapSuggestion {
  const SwapSuggestion({
    this.recipeId = '',
    this.name = '',
    this.dishes = const [],
    this.macros = const Macros(),
    this.deltaProteinG = 0,
    this.deltaKcal = 0,
    this.deltaCostVnd = 0,
    this.keepsDayOk = false,
    this.dayProteinG = 0,
    this.dayKcal = 0,
  });

  factory SwapSuggestion.fromJson(Map<String, dynamic> json) => SwapSuggestion(
    recipeId: json['recipe_id'] == null ? '' : json['recipe_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    dishes: json['dishes'] == null
        ? const []
        : (json['dishes'] as List<dynamic>)
              .map((e) => SwapDish.fromJson(e as Map<String, dynamic>))
              .toList(),
    macros: json['macros'] == null
        ? const Macros()
        : Macros.fromJson(json['macros'] as Map<String, dynamic>),
    deltaProteinG: json['delta_protein_g'] == null
        ? 0
        : (json['delta_protein_g'] as num).toDouble(),
    deltaKcal: json['delta_kcal'] == null
        ? 0
        : (json['delta_kcal'] as num).toDouble(),
    deltaCostVnd: json['delta_cost_vnd'] == null
        ? 0
        : (json['delta_cost_vnd'] as num).toDouble(),
    keepsDayOk: json['keeps_day_ok'] == null
        ? false
        : json['keeps_day_ok'] as bool,
    dayProteinG: json['day_protein_g'] == null
        ? 0
        : (json['day_protein_g'] as num).toDouble(),
    dayKcal: json['day_kcal'] == null
        ? 0
        : (json['day_kcal'] as num).toDouble(),
  );

  final String recipeId;
  final String name;
  final List<SwapDish> dishes;
  final Macros macros;
  final double deltaProteinG;
  final double deltaKcal;
  final double deltaCostVnd;
  final bool keepsDayOk;
  final double dayProteinG;
  final double dayKcal;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwapSuggestion copyWith({
    String? recipeId,
    String? name,
    List<SwapDish>? dishes,
    Macros? macros,
    double? deltaProteinG,
    double? deltaKcal,
    double? deltaCostVnd,
    bool? keepsDayOk,
    double? dayProteinG,
    double? dayKcal,
  }) => SwapSuggestion(
    recipeId: recipeId ?? this.recipeId,
    name: name ?? this.name,
    dishes: dishes ?? this.dishes,
    macros: macros ?? this.macros,
    deltaProteinG: deltaProteinG ?? this.deltaProteinG,
    deltaKcal: deltaKcal ?? this.deltaKcal,
    deltaCostVnd: deltaCostVnd ?? this.deltaCostVnd,
    keepsDayOk: keepsDayOk ?? this.keepsDayOk,
    dayProteinG: dayProteinG ?? this.dayProteinG,
    dayKcal: dayKcal ?? this.dayKcal,
  );

  Map<String, dynamic> toJson() => {
    'recipe_id': recipeId,
    'name': name,
    'dishes': dishes.map((e) => e.toJson()).toList(),
    'macros': macros.toJson(),
    'delta_protein_g': deltaProteinG,
    'delta_kcal': deltaKcal,
    'delta_cost_vnd': deltaCostVnd,
    'keeps_day_ok': keepsDayOk,
    'day_protein_g': dayProteinG,
    'day_kcal': dayKcal,
  };
}

/// Schema `SwapSuggestions`.
class SwapSuggestions {
  const SwapSuggestions({
    this.date = '',
    this.slot = '',
    this.currentRecipeId = '',
    this.anyKeepsDay = false,
    this.items = const [],
    this.recipes = const {},
  });

  factory SwapSuggestions.fromJson(Map<String, dynamic> json) =>
      SwapSuggestions(
        date: json['date'] == null ? '' : json['date'] as String,
        slot: json['slot'] == null ? '' : json['slot'] as String,
        currentRecipeId: json['current_recipe_id'] == null
            ? ''
            : json['current_recipe_id'] as String,
        anyKeepsDay: json['any_keeps_day'] == null
            ? false
            : json['any_keeps_day'] as bool,
        items: json['items'] == null
            ? const []
            : (json['items'] as List<dynamic>)
                  .map(
                    (e) => SwapSuggestion.fromJson(e as Map<String, dynamic>),
                  )
                  .toList(),
        recipes: json['recipes'] == null
            ? const {}
            : (json['recipes'] as Map<String, dynamic>).map(
                (k, v) =>
                    MapEntry(k, Recipe.fromJson(v as Map<String, dynamic>)),
              ),
      );

  final String date;
  final String slot;
  final String currentRecipeId;
  final bool anyKeepsDay;
  final List<SwapSuggestion> items;
  final Map<String, Recipe> recipes;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwapSuggestions copyWith({
    String? date,
    String? slot,
    String? currentRecipeId,
    bool? anyKeepsDay,
    List<SwapSuggestion>? items,
    Map<String, Recipe>? recipes,
  }) => SwapSuggestions(
    date: date ?? this.date,
    slot: slot ?? this.slot,
    currentRecipeId: currentRecipeId ?? this.currentRecipeId,
    anyKeepsDay: anyKeepsDay ?? this.anyKeepsDay,
    items: items ?? this.items,
    recipes: recipes ?? this.recipes,
  );

  Map<String, dynamic> toJson() => {
    'date': date,
    'slot': slot,
    'current_recipe_id': currentRecipeId,
    'any_keeps_day': anyKeepsDay,
    'items': items.map((e) => e.toJson()).toList(),
    'recipes': recipes.map((k, v) => MapEntry(k, v.toJson())),
  };
}

/// Schema `SwapSuggestionsRequest`.
class SwapSuggestionsRequest {
  const SwapSuggestionsRequest({
    this.state = const PlanStateDto(),
    this.date = '',
    this.slot = '',
    this.limit,
  });

  factory SwapSuggestionsRequest.fromJson(Map<String, dynamic> json) =>
      SwapSuggestionsRequest(
        state: json['state'] == null
            ? const PlanStateDto()
            : PlanStateDto.fromJson(json['state'] as Map<String, dynamic>),
        date: json['date'] == null ? '' : json['date'] as String,
        slot: json['slot'] == null ? '' : json['slot'] as String,
        limit: json['limit'] == null ? null : (json['limit'] as num).toInt(),
      );

  final PlanStateDto state;
  final String date;
  final String slot;
  final int? limit;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwapSuggestionsRequest copyWith({
    PlanStateDto? state,
    String? date,
    String? slot,
    int? limit,
  }) => SwapSuggestionsRequest(
    state: state ?? this.state,
    date: date ?? this.date,
    slot: slot ?? this.slot,
    limit: limit ?? this.limit,
  );

  Map<String, dynamic> toJson() => {
    'state': state.toJson(),
    'date': date,
    'slot': slot,
    if (limit != null) 'limit': limit,
  };
}

/// Schema `SwipeCardDto`.
class SwipeCardDto {
  const SwipeCardDto({
    this.id = '',
    this.tag = '',
    this.title = '',
    this.subtitle = '',
    this.sampleRecipeIds = const [],
  });

  factory SwipeCardDto.fromJson(Map<String, dynamic> json) => SwipeCardDto(
    id: json['id'] == null ? '' : json['id'] as String,
    tag: json['tag'] == null ? '' : json['tag'] as String,
    title: json['title'] == null ? '' : json['title'] as String,
    subtitle: json['subtitle'] == null ? '' : json['subtitle'] as String,
    sampleRecipeIds: json['sample_recipe_ids'] == null
        ? const []
        : (json['sample_recipe_ids'] as List<dynamic>).cast<String>().toList(),
  );

  final String id;
  final String tag;
  final String title;
  final String subtitle;
  final List<String> sampleRecipeIds;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  SwipeCardDto copyWith({
    String? id,
    String? tag,
    String? title,
    String? subtitle,
    List<String>? sampleRecipeIds,
  }) => SwipeCardDto(
    id: id ?? this.id,
    tag: tag ?? this.tag,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    sampleRecipeIds: sampleRecipeIds ?? this.sampleRecipeIds,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag': tag,
    'title': title,
    'subtitle': subtitle,
    'sample_recipe_ids': sampleRecipeIds,
  };
}

/// Schema `TargetSteps`.
class TargetSteps {
  const TargetSteps({
    this.bmr = 0,
    this.activityFactor = 0,
    this.tdee = 0,
    this.goalFactor = 0,
    this.kcalUnrounded = 0,
    this.referenceWeightKg = 0,
    this.proteinGPerKg = 0,
    this.proteinRawG = 0,
    this.proteinCapG = 0,
    this.proteinFloorG = 0,
    this.proteinLimitedBy = '',
  });

  factory TargetSteps.fromJson(Map<String, dynamic> json) => TargetSteps(
    bmr: json['bmr'] == null ? 0 : (json['bmr'] as num).toDouble(),
    activityFactor: json['activity_factor'] == null
        ? 0
        : (json['activity_factor'] as num).toDouble(),
    tdee: json['tdee'] == null ? 0 : (json['tdee'] as num).toDouble(),
    goalFactor: json['goal_factor'] == null
        ? 0
        : (json['goal_factor'] as num).toDouble(),
    kcalUnrounded: json['kcal_unrounded'] == null
        ? 0
        : (json['kcal_unrounded'] as num).toDouble(),
    referenceWeightKg: json['reference_weight_kg'] == null
        ? 0
        : (json['reference_weight_kg'] as num).toDouble(),
    proteinGPerKg: json['protein_g_per_kg'] == null
        ? 0
        : (json['protein_g_per_kg'] as num).toDouble(),
    proteinRawG: json['protein_raw_g'] == null
        ? 0
        : (json['protein_raw_g'] as num).toDouble(),
    proteinCapG: json['protein_cap_g'] == null
        ? 0
        : (json['protein_cap_g'] as num).toDouble(),
    proteinFloorG: json['protein_floor_g'] == null
        ? 0
        : (json['protein_floor_g'] as num).toDouble(),
    proteinLimitedBy: json['protein_limited_by'] == null
        ? ''
        : json['protein_limited_by'] as String,
  );

  final double bmr;
  final double activityFactor;
  final double tdee;
  final double goalFactor;
  final double kcalUnrounded;
  final double referenceWeightKg;
  final double proteinGPerKg;
  final double proteinRawG;
  final double proteinCapG;
  final double proteinFloorG;
  final String proteinLimitedBy;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  TargetSteps copyWith({
    double? bmr,
    double? activityFactor,
    double? tdee,
    double? goalFactor,
    double? kcalUnrounded,
    double? referenceWeightKg,
    double? proteinGPerKg,
    double? proteinRawG,
    double? proteinCapG,
    double? proteinFloorG,
    String? proteinLimitedBy,
  }) => TargetSteps(
    bmr: bmr ?? this.bmr,
    activityFactor: activityFactor ?? this.activityFactor,
    tdee: tdee ?? this.tdee,
    goalFactor: goalFactor ?? this.goalFactor,
    kcalUnrounded: kcalUnrounded ?? this.kcalUnrounded,
    referenceWeightKg: referenceWeightKg ?? this.referenceWeightKg,
    proteinGPerKg: proteinGPerKg ?? this.proteinGPerKg,
    proteinRawG: proteinRawG ?? this.proteinRawG,
    proteinCapG: proteinCapG ?? this.proteinCapG,
    proteinFloorG: proteinFloorG ?? this.proteinFloorG,
    proteinLimitedBy: proteinLimitedBy ?? this.proteinLimitedBy,
  );

  Map<String, dynamic> toJson() => {
    'bmr': bmr,
    'activity_factor': activityFactor,
    'tdee': tdee,
    'goal_factor': goalFactor,
    'kcal_unrounded': kcalUnrounded,
    'reference_weight_kg': referenceWeightKg,
    'protein_g_per_kg': proteinGPerKg,
    'protein_raw_g': proteinRawG,
    'protein_cap_g': proteinCapG,
    'protein_floor_g': proteinFloorG,
    'protein_limited_by': proteinLimitedBy,
  };
}

/// Schema `Targets`.
class Targets {
  const Targets({
    this.mode = '',
    this.kcalTarget = 0,
    this.kcalMin = 0,
    this.kcalMax = 0,
    this.proteinG = 0,
    this.steps,
  });

  factory Targets.fromJson(Map<String, dynamic> json) => Targets(
    mode: json['mode'] == null ? '' : json['mode'] as String,
    kcalTarget: json['kcal_target'] == null
        ? 0
        : (json['kcal_target'] as num).toDouble(),
    kcalMin: json['kcal_min'] == null
        ? 0
        : (json['kcal_min'] as num).toDouble(),
    kcalMax: json['kcal_max'] == null
        ? 0
        : (json['kcal_max'] as num).toDouble(),
    proteinG: json['protein_g'] == null
        ? 0
        : (json['protein_g'] as num).toDouble(),
    steps: json['steps'] == null
        ? null
        : TargetSteps.fromJson(json['steps'] as Map<String, dynamic>),
  );

  final String mode;
  final double kcalTarget;
  final double kcalMin;
  final double kcalMax;
  final double proteinG;
  final TargetSteps? steps;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  Targets copyWith({
    String? mode,
    double? kcalTarget,
    double? kcalMin,
    double? kcalMax,
    double? proteinG,
    TargetSteps? steps,
  }) => Targets(
    mode: mode ?? this.mode,
    kcalTarget: kcalTarget ?? this.kcalTarget,
    kcalMin: kcalMin ?? this.kcalMin,
    kcalMax: kcalMax ?? this.kcalMax,
    proteinG: proteinG ?? this.proteinG,
    steps: steps ?? this.steps,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode,
    'kcal_target': kcalTarget,
    'kcal_min': kcalMin,
    'kcal_max': kcalMax,
    'protein_g': proteinG,
    if (steps != null) 'steps': steps?.toJson(),
  };
}

/// Schema `TargetsRequest`.
class TargetsRequest {
  const TargetsRequest({this.profile = const Profile()});

  factory TargetsRequest.fromJson(Map<String, dynamic> json) => TargetsRequest(
    profile: json['profile'] == null
        ? const Profile()
        : Profile.fromJson(json['profile'] as Map<String, dynamic>),
  );

  final Profile profile;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  TargetsRequest copyWith({Profile? profile}) =>
      TargetsRequest(profile: profile ?? this.profile);

  Map<String, dynamic> toJson() => {'profile': profile.toJson()};
}

/// Schema `TraceLine`.
class TraceLine {
  const TraceLine({
    this.ingredientId = '',
    this.name = '',
    this.grams = 0,
    this.macros = const Macros(),
    this.source = '',
  });

  factory TraceLine.fromJson(Map<String, dynamic> json) => TraceLine(
    ingredientId: json['ingredient_id'] == null
        ? ''
        : json['ingredient_id'] as String,
    name: json['name'] == null ? '' : json['name'] as String,
    grams: json['grams'] == null ? 0 : (json['grams'] as num).toDouble(),
    macros: json['macros'] == null
        ? const Macros()
        : Macros.fromJson(json['macros'] as Map<String, dynamic>),
    source: json['source'] == null ? '' : json['source'] as String,
  );

  final String ingredientId;
  final String name;
  final double grams;
  final Macros macros;
  final String source;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  TraceLine copyWith({
    String? ingredientId,
    String? name,
    double? grams,
    Macros? macros,
    String? source,
  }) => TraceLine(
    ingredientId: ingredientId ?? this.ingredientId,
    name: name ?? this.name,
    grams: grams ?? this.grams,
    macros: macros ?? this.macros,
    source: source ?? this.source,
  );

  Map<String, dynamic> toJson() => {
    'ingredient_id': ingredientId,
    'name': name,
    'grams': grams,
    'macros': macros.toJson(),
    'source': source,
  };
}

/// Schema `WeekPlan`.
class WeekPlan {
  const WeekPlan({
    this.status = '',
    this.startDate = '',
    this.seed = 0,
    this.days = const [],
    this.validation = const WeekValidation(),
    this.shopping = const ShoppingList(),
    this.budgetVnd = 0,
    this.iterations = 0,
    this.distinctRecipes = 0,
    this.repairs = 0,
    this.unfilledSlots = const [],
    this.mealStyle,
    this.relaxedPreferences,
  });

  factory WeekPlan.fromJson(Map<String, dynamic> json) => WeekPlan(
    status: json['status'] == null ? '' : json['status'] as String,
    startDate: json['start_date'] == null ? '' : json['start_date'] as String,
    seed: json['seed'] == null ? 0 : (json['seed'] as num).toInt(),
    days: json['days'] == null
        ? const []
        : (json['days'] as List<dynamic>)
              .map((e) => PlanDay.fromJson(e as Map<String, dynamic>))
              .toList(),
    validation: json['validation'] == null
        ? const WeekValidation()
        : WeekValidation.fromJson(json['validation'] as Map<String, dynamic>),
    shopping: json['shopping'] == null
        ? const ShoppingList()
        : ShoppingList.fromJson(json['shopping'] as Map<String, dynamic>),
    budgetVnd: json['budget_vnd'] == null
        ? 0
        : (json['budget_vnd'] as num).toDouble(),
    iterations: json['iterations'] == null
        ? 0
        : (json['iterations'] as num).toInt(),
    distinctRecipes: json['distinct_recipes'] == null
        ? 0
        : (json['distinct_recipes'] as num).toInt(),
    repairs: json['repairs'] == null ? 0 : (json['repairs'] as num).toInt(),
    unfilledSlots: json['unfilled_slots'] == null
        ? const []
        : (json['unfilled_slots'] as List<dynamic>).cast<String>().toList(),
    mealStyle: json['meal_style'] == null ? null : json['meal_style'] as String,
    relaxedPreferences: json['relaxed_preferences'] == null
        ? null
        : (json['relaxed_preferences'] as List<dynamic>)
              .cast<String>()
              .toList(),
  );

  final String status;
  final String startDate;
  final int seed;
  final List<PlanDay> days;
  final WeekValidation validation;
  final ShoppingList shopping;
  final double budgetVnd;
  final int iterations;
  final int distinctRecipes;
  final int repairs;
  final List<String> unfilledSlots;
  final String? mealStyle;
  final List<String>? relaxedPreferences;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  WeekPlan copyWith({
    String? status,
    String? startDate,
    int? seed,
    List<PlanDay>? days,
    WeekValidation? validation,
    ShoppingList? shopping,
    double? budgetVnd,
    int? iterations,
    int? distinctRecipes,
    int? repairs,
    List<String>? unfilledSlots,
    String? mealStyle,
    List<String>? relaxedPreferences,
  }) => WeekPlan(
    status: status ?? this.status,
    startDate: startDate ?? this.startDate,
    seed: seed ?? this.seed,
    days: days ?? this.days,
    validation: validation ?? this.validation,
    shopping: shopping ?? this.shopping,
    budgetVnd: budgetVnd ?? this.budgetVnd,
    iterations: iterations ?? this.iterations,
    distinctRecipes: distinctRecipes ?? this.distinctRecipes,
    repairs: repairs ?? this.repairs,
    unfilledSlots: unfilledSlots ?? this.unfilledSlots,
    mealStyle: mealStyle ?? this.mealStyle,
    relaxedPreferences: relaxedPreferences ?? this.relaxedPreferences,
  );

  Map<String, dynamic> toJson() => {
    'status': status,
    'start_date': startDate,
    'seed': seed,
    'days': days.map((e) => e.toJson()).toList(),
    'validation': validation.toJson(),
    'shopping': shopping.toJson(),
    'budget_vnd': budgetVnd,
    'iterations': iterations,
    'distinct_recipes': distinctRecipes,
    'repairs': repairs,
    'unfilled_slots': unfilledSlots,
    if (mealStyle != null) 'meal_style': mealStyle,
    if (relaxedPreferences != null) 'relaxed_preferences': relaxedPreferences,
  };
}

/// Schema `WeekValidation`.
class WeekValidation {
  const WeekValidation({
    this.ok = false,
    this.days = const [],
    this.shortfalls = const [],
    this.daysMissing = 0,
    this.budgetOverVnd = 0,
  });

  factory WeekValidation.fromJson(Map<String, dynamic> json) => WeekValidation(
    ok: json['ok'] == null ? false : json['ok'] as bool,
    days: json['days'] == null
        ? const []
        : (json['days'] as List<dynamic>)
              .map((e) => DayValidation.fromJson(e as Map<String, dynamic>))
              .toList(),
    shortfalls: json['shortfalls'] == null
        ? const []
        : (json['shortfalls'] as List<dynamic>)
              .map((e) => Shortfall.fromJson(e as Map<String, dynamic>))
              .toList(),
    daysMissing: json['days_missing'] == null
        ? 0
        : (json['days_missing'] as num).toInt(),
    budgetOverVnd: json['budget_over_vnd'] == null
        ? 0
        : (json['budget_over_vnd'] as num).toDouble(),
  );

  final bool ok;
  final List<DayValidation> days;
  final List<Shortfall> shortfalls;
  final int daysMissing;
  final double budgetOverVnd;

  /// Bản sao với vài trường đổi (trường nullable không thể đặt lại về null).
  WeekValidation copyWith({
    bool? ok,
    List<DayValidation>? days,
    List<Shortfall>? shortfalls,
    int? daysMissing,
    double? budgetOverVnd,
  }) => WeekValidation(
    ok: ok ?? this.ok,
    days: days ?? this.days,
    shortfalls: shortfalls ?? this.shortfalls,
    daysMissing: daysMissing ?? this.daysMissing,
    budgetOverVnd: budgetOverVnd ?? this.budgetOverVnd,
  );

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'days': days.map((e) => e.toJson()).toList(),
    'shortfalls': shortfalls.map((e) => e.toJson()).toList(),
    'days_missing': daysMissing,
    'budget_over_vnd': budgetOverVnd,
  };
}
