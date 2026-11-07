import '../../api/generated/models.dart';

/// Khoảng hợp lệ của chỉ số cơ thể (US-1.1 AC1, khớp kiểm tra phía API).
abstract final class Limits {
  static const age = (min: 14, max: 90);
  static const heightCm = (min: 120, max: 220);
  static const weightKg = (min: 30, max: 250);
  static const adults = (min: 1, max: 6);
  static const children = (min: 0, max: 4);

  /// Tự nhập chỉ tiêu: khoảng rộng hợp lý để chặn lỗi gõ nhầm.
  static const manualKcal = (min: 800, max: 6000);
  static const manualProteinG = (min: 20, max: 400);
}

enum ProfileField { age, heightCm, weightKg, manualKcal, manualProtein }

/// Kiểm tra hồ sơ cục bộ; trả về các trường lỗi (rỗng = hợp lệ). Không gọi API khi còn lỗi.
Set<ProfileField> validateProfile(Profile p) {
  final bad = <ProfileField>{};
  bool outside(num v, ({int min, int max}) r) => v < r.min || v > r.max;
  if (outside(p.age, Limits.age)) bad.add(ProfileField.age);
  if (outside(p.heightCm, Limits.heightCm)) bad.add(ProfileField.heightCm);
  if (outside(p.weightKg, Limits.weightKg)) bad.add(ProfileField.weightKg);
  if (p.targetMode == 'manual') {
    final k = p.manualKcal;
    final pr = p.manualProteinG;
    if (k == null || outside(k, Limits.manualKcal)) {
      bad.add(ProfileField.manualKcal);
    }
    if (pr == null || outside(pr, Limits.manualProteinG)) {
      bad.add(ProfileField.manualProtein);
    }
  }
  return bad;
}

/// Phân tích chuỗi người dùng gõ thành số (chấp nhận dấu phẩy thập phân kiểu Việt).
double? parseNumber(String s) =>
    double.tryParse(s.trim().replaceAll(',', '.').replaceAll(' ', ''));

/// Còn ít nhất 1 bữa chính (sáng/trưa/tối) được lên thực đơn? (US-1.3 AC4)
bool hasPlannedMainMeal(SlotsConfig s) =>
    s.breakfast == 'on' || s.lunch == 'on' || s.dinner == 'on';

/// Có ít nhất một thiết bị nấu (US-1.5 AC3)?
bool hasCookingDevice(List<String> equipment) => equipment.any(
  (e) => const {
    'bep',
    'noi_com_dien',
    'lo_vi_song',
    'noi_chien_khong_dau',
    'lo_nuong',
    'noi_ap_suat',
  }.contains(e),
);
