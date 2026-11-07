// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppL10nVi extends AppL10n {
  AppL10nVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'FitPro - Mâm đủ';

  @override
  String get appTagline => 'Thực đơn tuần đủ đạm, đi chợ đúng ngân sách.';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonCancel => 'Huỷ';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonUndo => 'Hoàn tác';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonEstimate => 'ước tính';

  @override
  String get commonEstimateNote =>
      'Giá là ước tính, có thể khác khi bạn đi chợ.';

  @override
  String commonKcal(Object count) {
    return '$count kcal';
  }

  @override
  String commonGram(Object count) {
    return '$count g';
  }

  @override
  String commonVnd(Object count) {
    return '$count ₫';
  }

  @override
  String commonDaysCount(Object count) {
    return '$count ngày';
  }

  @override
  String commonMealsCount(Object count) {
    return '$count bữa';
  }

  @override
  String commonPeopleCount(Object count) {
    return '$count người';
  }

  @override
  String onboardingProgressLabel(Object count) {
    return 'Bước $count trên 10';
  }

  @override
  String get onboardingGoalTitle => 'Bạn muốn đạt mục tiêu nào?';

  @override
  String get onboardingGoalLose => 'Giảm mỡ';

  @override
  String get onboardingGoalHold => 'Giữ cân';

  @override
  String get onboardingGoalBuild => 'Tăng cơ';

  @override
  String get onboardingBodyTitle => 'Cho mình biết về cơ thể bạn';

  @override
  String get onboardingBodySex => 'Giới tính';

  @override
  String get onboardingBodyAge => 'Tuổi';

  @override
  String get onboardingBodyHeight => 'Chiều cao';

  @override
  String get onboardingBodyWeight => 'Cân nặng';

  @override
  String get onboardingBodyActivityTitle => 'Bạn vận động mỗi tuần thế nào?';

  @override
  String get onboardingBodyActivitySedentary => 'Ít vận động';

  @override
  String get onboardingBodyActivityLight => 'Nhẹ, 1–2 buổi';

  @override
  String get onboardingBodyActivityModerate => 'Vừa, 3–4 buổi';

  @override
  String get onboardingBodyActivityHigh => 'Nhiều, 5–6 buổi';

  @override
  String get onboardingBodyActivityAthlete => 'Rất nhiều, vận động viên';

  @override
  String get onboardingTargetsTitle => 'Chỉ tiêu mỗi ngày của bạn';

  @override
  String get onboardingTargetsEditNote =>
      'Bạn có thể tự nhập số khác. Chỉ tiêu áp dụng từ tuần kế tiếp.';

  @override
  String onboardingTargetsProteinFloor(Object count) {
    return 'Protein tối thiểu $count';
  }

  @override
  String onboardingTargetsKcalBand(Object v1, Object v2) {
    return 'Calo trong khoảng $v1–$v2';
  }

  @override
  String get onboardingTargetsManual => 'Tự nhập chỉ tiêu';

  @override
  String get onboardingTargetsFormula => 'Dùng công thức mặc định';

  @override
  String get onboardingStoreTitle => 'Bạn hay đi chợ ở đâu?';

  @override
  String get onboardingStoreNote =>
      'Giá là ước tính. Cửa hàng quyết định bảng giá và quy cách bao bì.';

  @override
  String get onboardingStoreOther => 'Nơi khác';

  @override
  String get onboardingBudgetTitle =>
      'Mỗi tuần bạn muốn chi bao nhiêu cho đi chợ?';

  @override
  String get onboardingBudgetPerWeek => 'mỗi tuần';

  @override
  String get onboardingBudgetLevelSave =>
      'Tiết kiệm — chủ yếu là thực phẩm cơ bản, đơn giản';

  @override
  String get onboardingBudgetLevelMedium =>
      'Vừa phải — có thêm đạm và rau đa dạng';

  @override
  String get onboardingBudgetLevelComfort =>
      'Thoải mái — ưu tiên đạm và nguyên liệu tươi';

  @override
  String onboardingBudgetMealsRef(Object count) {
    return 'Tuần này có $count bữa.';
  }

  @override
  String get onboardingHouseholdTitle => 'Ai sẽ ăn cùng bạn?';

  @override
  String get onboardingHouseholdAdults => 'Người lớn';

  @override
  String get onboardingHouseholdChildren => 'Trẻ em';

  @override
  String get onboardingHouseholdNote =>
      'Mục tiêu dinh dưỡng vẫn là của riêng bạn, dù ai ngồi cùng mâm.';

  @override
  String get onboardingMealsTitle => 'Lên thực đơn những bữa nào?';

  @override
  String get onboardingMealsHint => 'Tắt những gì bạn không muốn lên thực đơn.';

  @override
  String get onboardingMealsBreakfast => 'Bữa sáng';

  @override
  String get onboardingMealsLunch => 'Bữa trưa';

  @override
  String get onboardingMealsDinner => 'Bữa tối';

  @override
  String get onboardingMealsSnackAm => 'Bữa phụ sáng';

  @override
  String get onboardingMealsSnackPm => 'Bữa phụ chiều';

  @override
  String get onboardingMealsSelf => 'Tự lo';

  @override
  String get onboardingMealsOff => 'Không lên món';

  @override
  String get onboardingMealsHot => 'Nóng';

  @override
  String get onboardingMealsPacked => 'Mang đi';

  @override
  String get onboardingMealsSweet => 'Ngọt';

  @override
  String get onboardingMealsSavory => 'Mặn';

  @override
  String get onboardingDietTitle => 'Bạn có kiêng gì không?';

  @override
  String get onboardingDietHint => 'Chọn tất cả những gì đúng với bạn.';

  @override
  String get onboardingDietNone => 'Không kiêng gì — toàn bộ kho nguyên liệu';

  @override
  String get onboardingDietVegetarian => 'Ăn chay';

  @override
  String get onboardingDietVegan => 'Thuần chay';

  @override
  String get onboardingDietPescatarian => 'Ăn chay có cá';

  @override
  String get onboardingDietLowCarb => 'Ít tinh bột';

  @override
  String get onboardingDietNoPork => 'Không thịt lợn';

  @override
  String get onboardingDietNoRedMeat => 'Không thịt đỏ';

  @override
  String get onboardingDietNoGluten => 'Không gluten';

  @override
  String get onboardingDietNoDairy => 'Không sữa';

  @override
  String get onboardingDietNoEgg => 'Không trứng';

  @override
  String get onboardingDietNoPeanut => 'Không lạc';

  @override
  String get onboardingDietNoTreeNut => 'Không hạt cây';

  @override
  String get onboardingDietNoSeed => 'Không hạt giống & vừng';

  @override
  String get onboardingDietNoSesame => 'Không vừng';

  @override
  String get onboardingDietNoSoy => 'Không đậu nành';

  @override
  String get onboardingDietNoFish => 'Không cá';

  @override
  String get onboardingDietNoShellfish => 'Không giáp xác, nhuyễn thể';

  @override
  String get onboardingDietConflictVeg => 'Chỉ chọn một kiểu ăn chay.';

  @override
  String get onboardingDislikeTitle =>
      'Có gì bạn không bao giờ muốn thấy trên thực đơn?';

  @override
  String get onboardingDislikeSearch => 'Tìm nguyên liệu';

  @override
  String get onboardingDislikeNone => 'Chưa có món nào bị loại.';

  @override
  String get onboardingSwipeTitle => 'Vuốt để chọn món bạn thích';

  @override
  String get onboardingSwipeLike => 'Thích';

  @override
  String get onboardingSwipeDislike => 'Không thích';

  @override
  String get onboardingSwipeUndo => 'Hoàn tác';

  @override
  String get onboardingSwipeSkip => 'Thay thế';

  @override
  String get onboardingEquipmentTitle => 'Bếp nhà bạn có những gì?';

  @override
  String get onboardingEquipmentStove => 'Bếp';

  @override
  String get onboardingEquipmentRiceCooker => 'Nồi cơm điện';

  @override
  String get onboardingEquipmentMicrowave => 'Lò vi sóng';

  @override
  String get onboardingEquipmentAirFryer => 'Nồi chiên không dầu';

  @override
  String get onboardingEquipmentOven => 'Lò nướng';

  @override
  String get onboardingEquipmentPressureCooker => 'Nồi áp suất';

  @override
  String get onboardingEquipmentBlender => 'Máy xay';

  @override
  String get onboardingSummaryTitle => 'Đây là thiết lập của bạn';

  @override
  String get onboardingSummaryEdit => 'Sửa';

  @override
  String get onboardingSummaryCreate => 'Tạo thực đơn tuần';

  @override
  String get onboardingGeneratingTitle => 'Đang lên thực đơn';

  @override
  String get onboardingGeneratingChecklist =>
      'Kiểm tra protein từng ngày, calo, ngân sách';

  @override
  String get onboardingGeneratingWait => 'Thường mất vài giây.';

  @override
  String get planTitle => 'Kế hoạch';

  @override
  String planWeekRange(Object range) {
    return 'Tuần $range';
  }

  @override
  String get planMealCookOnce => 'Nấu 1 lần cho 2 bữa';

  @override
  String get planMealReused => 'Lặp lại có chủ đích';

  @override
  String get planDayProteinOk => 'Đủ protein';

  @override
  String planDayProteinLow(Object count) {
    return 'Thiếu $count g protein';
  }

  @override
  String get planDayKcalOk => 'Calo trong dải';

  @override
  String get planDayKcalOut => 'Calo ngoài dải';

  @override
  String planBannerPartial(Object v1, Object v2) {
    return 'Có $v1 ngày chưa đạt. $v2';
  }

  @override
  String get planBannerPartialDetail =>
      'Mình vẫn giữ thực đơn và tối ưu phần còn lại.';

  @override
  String get planBannerEdit => 'Xem chi tiết';

  @override
  String get planEmptyTitle => 'Chưa có thực đơn';

  @override
  String get planEmptyBody =>
      'Hoàn tất thiết lập để mình lên thực đơn tuần đầu tiên.';

  @override
  String get planEmptyCta => 'Thiết lập ngay';

  @override
  String get planEatOut => 'Ăn ngoài';

  @override
  String get planSkip => 'Bỏ bữa';

  @override
  String get planSwap => 'Đổi món này';

  @override
  String get recipeServingsYours => 'Phần của bạn';

  @override
  String get recipeServingsWhole => 'Cả nồi';

  @override
  String get recipeStepsTitle => 'Các bước';

  @override
  String get recipeStepsDone => 'Đã xong';

  @override
  String get recipeCookMode => 'Chế độ nấu';

  @override
  String get recipeCookModeKeepOn => 'Màn hình sẽ không tắt khi đang nấu.';

  @override
  String get recipeEquipment => 'Dụng cụ cần có';

  @override
  String recipeTime(Object count) {
    return '$count phút';
  }

  @override
  String get recipeCalcLink => 'Cách chúng mình tính';

  @override
  String get recipeSwapIngredient => 'Đổi nguyên liệu';

  @override
  String get calcTitle => 'Cách chúng mình tính';

  @override
  String get calcIntro =>
      'Mỗi con số đều truy được về nguồn dữ liệu. Không có con số nào do AI đoán.';

  @override
  String get calcRowIngredient => 'Nguyên liệu';

  @override
  String get calcRowGrams => 'Gram';

  @override
  String get calcRowKcal => 'Calo';

  @override
  String get calcRowProtein => 'Protein';

  @override
  String get calcRowSource => 'Nguồn';

  @override
  String get calcTotal => 'Tổng';

  @override
  String calcSourceUsda(Object count) {
    return 'USDA FoodData Central, mã $count';
  }

  @override
  String get calcSourceNote =>
      'Dữ liệu USDA thuộc miền công cộng (CC0). Giá trị trên 100 g phần ăn được.';

  @override
  String get shoppingTitle => 'Đi chợ';

  @override
  String get shoppingTotal => 'Tổng ước tính';

  @override
  String get shoppingWeekCost => 'Chi phí món ăn tuần này';

  @override
  String get shoppingTillCost => 'Ước tính trả tại quầy';

  @override
  String shoppingLeftover(Object count) {
    return 'Dư $count g';
  }

  @override
  String shoppingShelfLife(Object count) {
    return 'Dùng trong $count ngày';
  }

  @override
  String get shoppingShare => 'Chia sẻ danh sách';

  @override
  String get shoppingCopied => 'Đã chép vào bộ nhớ tạm.';

  @override
  String get shoppingPantryHave => 'Đã có sẵn';

  @override
  String get shoppingEmptyTitle => 'Chưa có danh sách';

  @override
  String get shoppingEmptyBody => 'Tạo thực đơn tuần để có danh sách đi chợ.';

  @override
  String get swapTitle => 'Đổi món này';

  @override
  String swapDeltaKcal(Object count) {
    return 'Calo $count kcal';
  }

  @override
  String swapDeltaProtein(Object count) {
    return 'Protein $count g';
  }

  @override
  String swapDeltaCost(Object count) {
    return 'Chi phí $count ₫';
  }

  @override
  String get swapKeepDay => 'Ngày này vẫn đạt.';

  @override
  String get swapNoOption => 'Không tìm được món phù hợp hơn.';

  @override
  String get eatOutTitle => 'Ăn ngoài';

  @override
  String get eatOutBody => 'Phần còn lại của ngày vẫn giữ nguyên.';

  @override
  String get eatOutUndo => 'Bỏ đánh dấu ăn ngoài';

  @override
  String get blockTitle => 'Không hợp với tôi';

  @override
  String get blockBody => 'Món này sẽ không xuất hiện trong các tuần sau.';

  @override
  String get blockConfirm => 'Không lên món này nữa';

  @override
  String get restTitle => 'Lên lại phần còn lại';

  @override
  String get restBody => 'Giữ các bữa đã nấu, lên lại những bữa còn lại.';

  @override
  String get accountTitle => 'Bạn';

  @override
  String get accountEditProfile => 'Sửa thiết lập';

  @override
  String get accountSavedPlans => 'Tuần đã lưu';

  @override
  String get accountSavedPlansEmpty => 'Chưa có tuần nào được lưu.';

  @override
  String get accountNextWeek => 'Tạo tuần tới';

  @override
  String get accountClearData => 'Xoá toàn bộ dữ liệu';

  @override
  String get accountClearDataConfirm1 => 'Xoá toàn bộ dữ liệu trên máy này?';

  @override
  String get accountClearDataConfirm2 =>
      'Thao tác này không hoàn tác được. Bạn chắc chứ?';

  @override
  String get accountPrivacy => 'Dữ liệu chỉ lưu trên máy của bạn.';

  @override
  String get accountDisclaimer =>
      'Thông tin chỉ để tham khảo, không thay thế tư vấn y tế.';

  @override
  String get accountSources => 'Nguồn dữ liệu';

  @override
  String get errorsGenericTitle => 'Có lỗi xảy ra';

  @override
  String get errorsGenericBody => 'Mình chưa lên được thực đơn. Thử lại nhé.';

  @override
  String get errorsNetworkBody =>
      'Không có mạng. Dữ liệu vẫn được giữ trên máy.';

  @override
  String get errorsBudgetTooLowBody =>
      'Ngân sách này khó đủ đạm cho cả tuần. Thử tăng ngân sách hoặc giảm chỉ tiêu.';

  @override
  String get emptyGeneric => 'Chưa có gì ở đây.';

  @override
  String get profileDisclaimerBody =>
      'FitPro - Mâm đủ không phải lời khuyên y tế. Thực đơn và chỉ tiêu protein, calo được tính theo công thức phổ biến và dữ liệu thành phần thực phẩm; chúng không chẩn đoán, không điều trị và không thay thế bác sĩ hay chuyên gia dinh dưỡng.\n\nĐặc biệt, hãy hỏi bác sĩ trước khi thay đổi chế độ ăn nếu bạn:\n• đang mắc hoặc nghi ngờ bệnh tiểu đường, bệnh tim mạch, bệnh thận, rối loạn ăn uống hoặc đang dùng thuốc cần theo dõi bữa ăn;\n• có hội chứng buồng trứng đa nang (PCOS) hoặc đang mang thai, cho con bú;\n• dưới 18 tuổi;\n• có dị ứng thực phẩm đã được chẩn đoán. Bộ lọc dị ứng là công cụ hỗ trợ, không thay cho việc đọc nhãn sản phẩm thực tế.\n\nCác lựa chọn \"Nhiều chất xơ\", \"Ít đường\", \"Tốt cho tim mạch\", \"Ít béo\" chỉ là ưu tiên khi chọn món, không phải chỉ định điều trị.';

  @override
  String get budgetTierEconomy => 'Tiết kiệm';

  @override
  String get budgetTierEconomyDesc => 'Chủ yếu là thực phẩm cơ bản, đơn giản.';

  @override
  String get budgetTierModerate => 'Vừa phải';

  @override
  String get budgetTierModerateDesc => 'Có thêm đạm và rau đa dạng.';

  @override
  String get budgetTierComfortable => 'Thoải mái';

  @override
  String get budgetTierComfortableDesc => 'Ưu tiên đạm và nguyên liệu tươi.';

  @override
  String get healthNhieuXo => 'Nhiều chất xơ';

  @override
  String get healthNhieuXoDesc =>
      'Ưu tiên món có nhiều rau, đậu và ngũ cốc nguyên cám.';

  @override
  String get healthItDuong => 'Ít đường';

  @override
  String get healthItDuongDesc =>
      'Ưu tiên món không thêm đường và ít tinh bột.';

  @override
  String get healthTotChoTim => 'Tốt cho tim mạch';

  @override
  String get healthTotChoTimDesc =>
      'Ưu tiên món có cá béo, nhiều xơ và ít chiên ngập dầu.';

  @override
  String get healthItBeo => 'Ít béo';

  @override
  String get healthItBeoDesc =>
      'Ưu tiên món có ít chất béo trong tổng năng lượng.';

  @override
  String get healthDisclaimer =>
      'Các lựa chọn này chỉ là ưu tiên mềm khi chọn món, không phải lời khuyên y tế. Hỏi bác sĩ hoặc chuyên gia dinh dưỡng nếu bạn cần chế độ ăn riêng.';

  @override
  String get imagePlaceholder => 'Ảnh món đang được chuẩn bị';

  @override
  String get errorsNetworkTitle => 'Không kết nối được';

  @override
  String get errorsOfflineRetry => 'Thử lại khi có mạng';

  @override
  String get freemiumWeekLimit =>
      'Bản miễn phí giữ một tuần đang chạy. Tạo tuần mới mỗi tuần một lần.';

  @override
  String freemiumSwapLimit(Object count) {
    return 'Bạn đã đổi $count / 3 món trong tuần này.';
  }

  @override
  String get freemiumRestoreLocked =>
      'Lên lại phần còn lại của tuần cần Premium.';

  @override
  String get freemiumTrialCta => 'Dùng thử 7 ngày miễn phí';

  @override
  String get freemiumTrialBody =>
      'Dùng đầy đủ tính năng trong 7 ngày. Sau đó chuyển về bản miễn phí, dữ liệu vẫn giữ nguyên.';

  @override
  String get freemiumUpgradeCta => 'Xem gói Premium';

  @override
  String get tabPlan => 'Kế hoạch';

  @override
  String get tabShopping => 'Đi chợ';

  @override
  String get tabProfile => 'Bạn';

  @override
  String get placeholderPlan => 'Tuần của bạn sẽ hiện ở đây.';

  @override
  String get placeholderShopping => 'Danh sách đi chợ sẽ hiện ở đây.';

  @override
  String get placeholderProfile =>
      'Chỉ tiêu và lựa chọn của bạn sẽ hiện ở đây.';

  @override
  String get connectionTitle => 'Kết nối máy chủ';

  @override
  String get connectionOk => 'Đã kết nối';

  @override
  String get connectionFail => 'Chưa kết nối được máy chủ';

  @override
  String get connectionChecking => 'Đang kiểm tra…';

  @override
  String apiBaseUrl(Object url) {
    return 'Địa chỉ máy chủ: $url';
  }

  @override
  String get galleryTitle => 'Thư viện thành phần';

  @override
  String get commonDecrease => 'Giảm';

  @override
  String get commonIncrease => 'Tăng';

  @override
  String get galleryOpen => 'Mở thư viện thành phần (chỉ bản debug)';

  @override
  String get dishRoleFullMeal => 'Món trọn suất';

  @override
  String get dishRoleMain => 'Món chính';

  @override
  String get dishRoleSoup => 'Canh';

  @override
  String get dishRoleSideVeg => 'Rau';

  @override
  String get dishRoleCarbBase => 'Cơm';

  @override
  String get dishRoleDessert => 'Tráng miệng';

  @override
  String get dishRoleExtra => 'Món thêm';

  @override
  String get macroProtein => 'Protein';

  @override
  String get macroKcal => 'Calo';

  @override
  String get macroCarb => 'Tinh bột';

  @override
  String get macroFat => 'Béo';

  @override
  String get galleryImageNull => 'Ảnh trống (image = null)';

  @override
  String onboardingProgressOf(Object v1, Object v2) {
    return 'Bước $v1 trên $v2';
  }

  @override
  String validationRange(Object v1, Object v2, Object v3) {
    return '$v1 từ $v2 đến $v3';
  }

  @override
  String get unitYears => 'tuổi';

  @override
  String get unitCm => 'cm';

  @override
  String get unitKg => 'kg';

  @override
  String get unitKcal => 'kcal';

  @override
  String get unitG => 'g';

  @override
  String get onboardingGoalHint =>
      'Mục tiêu quyết định lượng calo và protein bạn cần mỗi ngày.';

  @override
  String get onboardingGoalLoseHint =>
      'Ăn ít hơn mức duy trì một chút, vẫn đủ đạm để giữ cơ.';

  @override
  String get onboardingGoalHoldHint => 'Ăn vừa đủ để giữ cân nặng hiện tại.';

  @override
  String get onboardingGoalBuildHint =>
      'Ăn dư một chút và nhiều đạm để tăng cơ.';

  @override
  String get onboardingBodySexMale => 'Nam';

  @override
  String get onboardingBodySexFemale => 'Nữ';

  @override
  String get onboardingBodyHint =>
      'Chỉ dùng để tính chỉ tiêu. App không hỏi tên hay email.';

  @override
  String get onboardingTargetsKcalLabel => 'Calo mỗi ngày';

  @override
  String get onboardingTargetsProteinLabel => 'Protein tối thiểu mỗi ngày';

  @override
  String get onboardingTargetsHowTitle => 'Cách mình tính';

  @override
  String onboardingTargetsStepBmr(Object value) {
    return 'Năng lượng nghỉ ngơi (BMR): $value kcal';
  }

  @override
  String onboardingTargetsStepTdee(Object v1, Object v2) {
    return '× hệ số vận động $v1 = $v2 kcal mỗi ngày (TDEE)';
  }

  @override
  String onboardingTargetsStepGoal(Object v1, Object v2, Object v3) {
    return '× hệ số mục tiêu $v1 = $v2 kcal, làm tròn 50 kcal → $v3 kcal';
  }

  @override
  String onboardingTargetsStepProtein(Object v1, Object v2, Object v3) {
    return 'Protein: $v1 g/kg × cân nặng tham chiếu $v2 kg = $v3 g';
  }

  @override
  String onboardingTargetsStepProteinCap(Object v1, Object v2) {
    return 'Trần 35% calo là $v1 g nên dùng $v2 g';
  }

  @override
  String onboardingTargetsStepProteinFloor(Object v1, Object v2) {
    return 'Sàn tối thiểu $v1 g cao hơn trần nên dùng $v2 g';
  }

  @override
  String get onboardingTargetsManualHint =>
      'Nhập số bạn muốn. Mình vẫn lập thực đơn trong dải calo ±5%.';

  @override
  String get onboardingTargetsManualKcal => 'Calo mỗi ngày (kcal)';

  @override
  String get onboardingTargetsManualProtein => 'Protein tối thiểu (g)';

  @override
  String get onboardingTargetsManualMode => 'Tự nhập';

  @override
  String get onboardingTargetsFormulaMode => 'Theo công thức';

  @override
  String get onboardingTargetsBandNote =>
      'Thực đơn mỗi ngày nằm trong dải calo ±5% và đạt protein tối thiểu.';

  @override
  String onboardingStoreSurvey(Object date) {
    return 'Giá khảo sát ngày $date';
  }

  @override
  String get onboardingBudgetNote =>
      'Ngân sách là chi phí món ăn trong tuần (phần nguyên liệu thực sự dùng). Lần đi chợ đầu có thể cao hơn vì mua nguyên chai dầu, nước mắm, gạo…';

  @override
  String onboardingBudgetEstimate(Object amount) {
    return 'Gợi ý cho bạn: $amount';
  }

  @override
  String onboardingBudgetMin(Object amount) {
    return 'Tối thiểu $amount';
  }

  @override
  String onboardingBudgetMax(Object amount) {
    return 'Tối đa $amount';
  }

  @override
  String get onboardingHouseholdAdultsHint => 'Từ 1 đến 6 người';

  @override
  String get onboardingHouseholdChildrenHint =>
      'Từ 0 đến 4 bé, mỗi bé ăn khoảng 0,6 phần người lớn';

  @override
  String get onboardingMealsOn => 'Lên thực đơn';

  @override
  String onboardingMealsPerSlot(Object v1, Object v2) {
    return '~$v1 kcal · $v2 g protein';
  }

  @override
  String onboardingMealsFooter(Object v1, Object v2) {
    return 'Mỗi bữa ~$v1 kcal và $v2 g protein';
  }

  @override
  String get onboardingMealsNeedOne =>
      'Cần giữ ít nhất một bữa chính (sáng, trưa hoặc tối) được lên thực đơn.';

  @override
  String get onboardingMealsSelfHint =>
      'Mình giữ lại phần chỉ tiêu cho bữa này, không lên món.';

  @override
  String get onboardingMealsOffHint =>
      'Chỉ tiêu được chia lại cho các bữa còn lại.';

  @override
  String get onboardingDietKindTitle => 'Kiểu ăn';

  @override
  String get onboardingDietExcludeTitle => 'Loại bỏ hoàn toàn';

  @override
  String get onboardingDietExcludeHint =>
      'Nguyên liệu bị loại sẽ không bao giờ xuất hiện trong thực đơn.';

  @override
  String get onboardingDietScopeTitle => 'Phạm vi loại bỏ';

  @override
  String get onboardingDietLeaningsTitle => 'Xu hướng nấu ăn';

  @override
  String get onboardingDietLeaningsNote =>
      'Chỉ là ưu tiên mềm khi chọn món, không phải lời khuyên y tế.';

  @override
  String get onboardingDislikeSuggestions => 'Gợi ý nhanh';

  @override
  String get onboardingDislikeSelected => 'Đã loại';

  @override
  String get onboardingDislikeNoResult => 'Không tìm thấy nguyên liệu này.';

  @override
  String onboardingDislikeRemove(Object name) {
    return 'Bỏ loại $name';
  }

  @override
  String get onboardingSwipeHint =>
      'Vuốt phải nếu thích, vuốt trái nếu muốn ít hơn.';

  @override
  String onboardingSwipeProgress(Object v1, Object v2) {
    return 'Thẻ $v1/$v2';
  }

  @override
  String get onboardingSwipeResultTitle => 'Khẩu vị của bạn';

  @override
  String get onboardingSwipeLiked => 'Bạn thích';

  @override
  String get onboardingSwipeLess => 'Ít hơn';

  @override
  String get onboardingSwipeNone => 'Chưa chọn';

  @override
  String get onboardingSwipeAgain => 'Vuốt lại';

  @override
  String get onboardingSwipeSoft =>
      'Đây chỉ là ưu tiên mềm; bạn có thể đổi bất cứ lúc nào.';

  @override
  String get onboardingEquipmentHint => 'Chọn tất cả thiết bị bạn có.';

  @override
  String get onboardingEquipmentNeedOne => 'Cần chọn ít nhất một thiết bị nấu.';

  @override
  String get onboardingSummaryGoal => 'Mục tiêu';

  @override
  String get onboardingSummaryProtein => 'Protein tối thiểu';

  @override
  String get onboardingSummaryKcal => 'Calo mỗi ngày';

  @override
  String get onboardingSummaryMeals => 'Số bữa';

  @override
  String get onboardingSummaryLeanings => 'Xu hướng';

  @override
  String get onboardingSummaryExcluded => 'Đã loại';

  @override
  String get onboardingSummaryKitchen => 'Căn bếp';

  @override
  String get onboardingSummaryBudget => 'Ngân sách';

  @override
  String get onboardingSummaryNone => 'Không có';

  @override
  String onboardingSummaryMealsValue(Object count) {
    return '$count bữa mỗi ngày';
  }

  @override
  String onboardingSummaryBudgetLow(Object v1, Object v2) {
    return 'Ngân sách $v1 thấp hơn mức tối thiểu gợi ý $v2 cho lựa chọn của bạn. Bạn vẫn có thể tạo tuần, nhưng có thể thiếu đạm hoặc vượt ngân sách.';
  }

  @override
  String onboardingSummaryBudgetLowReason(Object v1, Object v2) {
    return 'Sau các lựa chọn chế độ ăn và dụng cụ, mức tối thiểu gợi ý là $v1 (lúc chọn ngân sách là $v2). Bạn vẫn có thể tạo tuần, nhưng có thể thiếu đạm hoặc vượt ngân sách.';
  }

  @override
  String onboardingSummaryUseMinAmount(Object min) {
    return 'Dùng $min';
  }

  @override
  String get onboardingSummaryUseMin => 'Dùng mức tối thiểu';

  @override
  String get onboardingSummaryLowCarb => 'Ít tinh bột';

  @override
  String get onboardingGeneratingFail => 'Chưa tạo được thực đơn';

  @override
  String get weekday1 => 'Thứ Hai';

  @override
  String get weekday2 => 'Thứ Ba';

  @override
  String get weekday3 => 'Thứ Tư';

  @override
  String get weekday4 => 'Thứ Năm';

  @override
  String get weekday5 => 'Thứ Sáu';

  @override
  String get weekday6 => 'Thứ Bảy';

  @override
  String get weekday7 => 'Chủ nhật';

  @override
  String get planGreetingMorning => 'Chào buổi sáng';

  @override
  String get planGreetingAfternoon => 'Chào buổi chiều';

  @override
  String get planGreetingEvening => 'Chào buổi tối';

  @override
  String get planStartsTomorrow => 'Tuần của bạn bắt đầu từ ngày mai';

  @override
  String planStartsOn(Object date) {
    return 'Tuần của bạn bắt đầu từ $date';
  }

  @override
  String planDayNumber(Object n) {
    return 'Hôm nay là ngày $n';
  }

  @override
  String get planWeekEnded => 'Tuần của bạn đã kết thúc';

  @override
  String get planBannerOk => 'Mọi ngày đều đạt protein và calo.';

  @override
  String planShortfallProtein(Object v1, Object v2) {
    return '$v1 thiếu $v2 g protein';
  }

  @override
  String planShortfallKcalLow(Object v1, Object v2) {
    return '$v1 thiếu $v2 kcal';
  }

  @override
  String planShortfallKcalHigh(Object v1, Object v2) {
    return '$v1 dư $v2 kcal';
  }

  @override
  String planShortfallMissingSlot(Object count) {
    return '$count bữa chưa có món';
  }

  @override
  String planBudgetOver(Object amount) {
    return 'Chi phí tuần vượt ngân sách $amount';
  }

  @override
  String planCookMinutes(Object minutes) {
    return '$minutes phút';
  }

  @override
  String planDayTotals(Object v1, Object v2) {
    return '$v1 g protein · $v2 kcal';
  }

  @override
  String planCookOnceN(Object count) {
    return 'Nấu 1 lần cho $count bữa';
  }

  @override
  String get planSelf => 'Tôi tự lo';

  @override
  String get planUnfilled => 'Chưa có món cho bữa này';

  @override
  String planDessertLine(Object name) {
    return 'Tráng miệng: $name';
  }

  @override
  String get planDayToday => 'Hôm nay';

  @override
  String get planGoSettings => 'Thiết lập lại';

  @override
  String get mealNotFound => 'Không tìm thấy bữa này trong tuần của bạn.';

  @override
  String mealContext(Object v1, Object v2) {
    return '$v1 · $v2';
  }

  @override
  String get mealMamTitle => 'Các món trong mâm';

  @override
  String get mealExtrasTitle => 'Thêm vào bữa';

  @override
  String get mealOpenRecipe => 'Mở công thức';

  @override
  String get recipeIngredientsTitle => 'Nguyên liệu';

  @override
  String get recipeNotForMe => 'Không hợp với tôi';

  @override
  String get recipeBlocked =>
      'Mình sẽ không chọn món này ở các tuần sau. Bạn có thể bỏ chặn ở tab Bạn.';

  @override
  String recipeStepToggle(Object v1, Object v2) {
    return 'Bước $v1: $v2';
  }

  @override
  String recipeUnitApprox(Object v1, Object v2) {
    return '≈ $v1 $v2';
  }

  @override
  String get recipeNoSteps => 'Món này chưa có hướng dẫn nấu.';

  @override
  String calcFormula(Object v1, Object v2) {
    return '$v1 g × $v2 kcal/100 g';
  }

  @override
  String calcSourceVn(Object code) {
    return 'Bảng TPDD VN 2007 · mã $code';
  }

  @override
  String calcSourceFallback(Object v1, Object v2) {
    return '$v1 · mã $v2';
  }

  @override
  String calcDessertRow(Object name) {
    return '$name (tráng miệng)';
  }

  @override
  String get calcTotalNote => 'Tổng bằng đúng số trên chip ở màn bữa.';

  @override
  String get calcExtrasHeading => 'Món thêm';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get shopFoodCost => 'Chi phí món ăn tuần này';

  @override
  String get shopFoodCostHint => 'Phần nguyên liệu bạn thực sự dùng.';

  @override
  String get shopTillCost => 'Ước tính trả tại quầy';

  @override
  String get shopTillCostHint => 'Tính theo gói bán sẵn, gồm cả phần dư.';

  @override
  String get shopEstimateTag => 'ước tính';

  @override
  String shopSurveyDate(Object date) {
    return 'Giá khảo sát ngày $date';
  }

  @override
  String shopBudgetLine(Object amount) {
    return 'Ngân sách tuần $amount';
  }

  @override
  String shopBudgetUnder(Object amount) {
    return 'Còn trong ngân sách, dư $amount';
  }

  @override
  String shopBudgetOver(Object amount) {
    return 'Vượt ngân sách $amount';
  }

  @override
  String shopProgress(Object v1, Object v2) {
    return 'Đã mua $v1/$v2 món';
  }

  @override
  String shopNeedG(Object grams) {
    return 'Cần $grams g';
  }

  @override
  String get shopPantryToggle => 'Nhà có sẵn';

  @override
  String get shopPantryNeed => 'Cần mua';

  @override
  String shopPantrySection(Object count) {
    return 'Nhà đã có sẵn ($count)';
  }

  @override
  String get shopPantryNote => 'Món nhà có sẵn không tính vào chi phí.';

  @override
  String shopBoughtSemantics(Object name) {
    return 'Đã mua $name';
  }

  @override
  String get shopShare => 'Chia sẻ danh sách';

  @override
  String shopShareTitle(Object v1, Object v2) {
    return 'Danh sách đi chợ $v1 – $v2';
  }

  @override
  String shopShareTotal(Object amount) {
    return 'Ước tính trả tại quầy: $amount';
  }

  @override
  String get shopFallbackPrice => 'Giá chợ ước tính';

  @override
  String get shopAllDone => 'Đã mua đủ danh sách.';

  @override
  String get changeMealTitle => 'Thay đổi bữa này';

  @override
  String get changeSwapMeal => 'Đổi món này';

  @override
  String get changeEatOut => 'Ăn ngoài / bỏ bữa';

  @override
  String get changeSwapSheetTitle => 'Đổi món cho bữa này';

  @override
  String get changeSwapHint => 'Chỉ gợi ý món hợp với lựa chọn của bạn.';

  @override
  String get changeSwapLoading => 'Đang tìm món thay thế…';

  @override
  String get changeSwapNoneKeep =>
      'Không có món nào giữ ngày này đạt chỉ tiêu. Đây là các món gần đạt nhất, bạn cân nhắc nhé.';

  @override
  String get changeSwapEmpty => 'Chưa có món thay thế phù hợp cho bữa này.';

  @override
  String get changeKeepsDay => 'Ngày vẫn đạt';

  @override
  String get changeBreaksDay => 'Ngày sẽ không đạt';

  @override
  String get changePick => 'Chọn món này';

  @override
  String changeDeltaProtein(Object delta) {
    return '$delta g protein';
  }

  @override
  String changeDeltaKcal(Object delta) {
    return '$delta kcal';
  }

  @override
  String changeDeltaCost(Object delta) {
    return '$delta ₫';
  }

  @override
  String get changeSwapped => 'Đã đổi món';

  @override
  String changeIngSwapTitle(Object name) {
    return 'Đổi nguyên liệu: $name';
  }

  @override
  String get changeIngSwapHint =>
      'Chỉ hiện nguyên liệu cùng nhóm, vẫn giữ protein của bữa trong khoảng ±5%.';

  @override
  String get changeIngSwapEmpty => 'Không có nguyên liệu thay thế phù hợp.';

  @override
  String changeIngSwapAction(Object name) {
    return 'Đổi nguyên liệu $name';
  }

  @override
  String get changeIngSwapped => 'Đã đổi nguyên liệu';

  @override
  String changeIngNow(Object name) {
    return 'Hiện tại: $name';
  }

  @override
  String get changeOutSheetTitle => 'Bữa này bạn…';

  @override
  String get changeOutEatHint =>
      'Mình bỏ bữa này khỏi tổng ngày và rút nguyên liệu khỏi danh sách đi chợ.';

  @override
  String get changeOutSkip => 'Bỏ bữa';

  @override
  String get changeOutSkipHint =>
      'Giống ăn ngoài: ngày này không bị tính là không đạt.';

  @override
  String get changeOutDone => 'Đã đánh dấu bữa này';

  @override
  String get changeUndone => 'Đã hoàn tác';

  @override
  String get changeBusy => 'Đang xử lý…';

  @override
  String get changeFailed => 'Chưa thực hiện được. Bạn thử lại nhé.';

  @override
  String get changeBlockTitle => 'Món này không hợp với bạn?';

  @override
  String get changeBlockBody =>
      'Mình sẽ không chọn món này nữa. Các ngày sau hôm nay được lên lại; ngày đã qua và hôm nay giữ nguyên.';

  @override
  String get changeBlockAndReplan => 'Chặn và lên lại';

  @override
  String get changeBlockOnly => 'Chỉ chặn, không lên lại';

  @override
  String get planSkipped => 'Bỏ bữa';

  @override
  String get planOutDay => 'Có bữa ngoài';

  @override
  String get planReplanTitle => 'Đã lên lại tuần';

  @override
  String get planReplanButton => 'Lên lại phần còn lại của tuần';

  @override
  String get planReplanConfirmTitle => 'Lên lại phần còn lại của tuần?';

  @override
  String get planReplanConfirmBody =>
      'Các ngày đã qua và hôm nay giữ nguyên. Tuần hiện tại được lưu vào Tuần đã lưu.';

  @override
  String get planReplanConfirm => 'Lên lại';

  @override
  String get planRelaxed => 'Tuần này đã nới xu hướng nấu ăn để đạt chỉ tiêu.';

  @override
  String get profileEditSave => 'Lưu';

  @override
  String get profileEditSaved =>
      'Đã lưu. Lựa chọn mới áp dụng cho tuần tạo kế tiếp.';

  @override
  String get profileSectionChoices => 'Chỉ tiêu và lựa chọn';

  @override
  String get profileChoicesHint =>
      'Thay đổi áp dụng cho tuần tạo kế tiếp. Tuần hiện tại giữ nguyên cho đến khi bạn lên lại.';

  @override
  String get profileDirtyTitle => 'Có lựa chọn chưa áp dụng';

  @override
  String get profileDirtyBody =>
      'Tuần hiện tại vẫn theo lựa chọn cũ. Bấm \"Lên lại tuần này\" để áp dụng.';

  @override
  String get profileReplanButton => 'Lên lại tuần này với lựa chọn mới';

  @override
  String get profileNextWeekButton => 'Tạo tuần mới với lựa chọn hiện tại';

  @override
  String get profileNextWeekHint => 'Tuần hiện tại đã kết thúc.';

  @override
  String get profileNextWeekDone => 'Đã tạo tuần mới';

  @override
  String get profileRowBody => 'Cơ thể';

  @override
  String get profileRowActivity => 'Vận động';

  @override
  String get profileRowTargets => 'Chỉ tiêu mỗi ngày';

  @override
  String get profileRowStore => 'Cửa hàng';

  @override
  String get profileRowHousehold => 'Người ăn';

  @override
  String get profileRowTaste => 'Khẩu vị món ăn';

  @override
  String profileBodyValue(Object v1, Object v2, Object v3, Object v4) {
    return '$v1 · $v2 tuổi · $v3 cm · $v4 kg';
  }

  @override
  String profileTargetsValue(Object v1, Object v2) {
    return '$v1 g protein · $v2 kcal';
  }

  @override
  String get profileTargetsManual => 'tự nhập';

  @override
  String profileHouseholdValue(Object v1, Object v2) {
    return '$v1 người lớn, $v2 trẻ em';
  }

  @override
  String profileTasteValue(Object count) {
    return 'Đã xem $count món';
  }

  @override
  String get profileSectionBlocked => 'Món đã chặn';

  @override
  String profileBlockedValue(Object count) {
    return '$count món';
  }

  @override
  String get profileBlockedHint =>
      'Món bị chặn sẽ không xuất hiện ở các tuần sau.';

  @override
  String get profileBlockedEmpty => 'Bạn chưa chặn món nào.';

  @override
  String get profileUnblock => 'Bỏ chặn';

  @override
  String profileUnblockLabel(Object name) {
    return 'Bỏ chặn $name';
  }

  @override
  String profileUnblocked(Object name) {
    return 'Đã bỏ chặn $name';
  }

  @override
  String profileSavedValue(Object count) {
    return '$count tuần';
  }

  @override
  String profileSavedWeek(Object v1, Object v2) {
    return 'Tuần $v1 – $v2';
  }

  @override
  String profileSavedAt(Object date) {
    return 'Lưu ngày $date';
  }

  @override
  String get profileSectionAbout => 'Thông tin';

  @override
  String get profileDisclaimerTitle => 'Miễn trừ y tế';

  @override
  String get profilePricesTitle => 'Giá là ước tính';

  @override
  String get profilePrivacyTitle => 'Quyền riêng tư';

  @override
  String get profileSourcesBody =>
      'Dữ liệu dinh dưỡng lấy từ USDA FoodData Central (U.S. Department of Agriculture, Agricultural Research Service. FoodData Central, 2019. https://fdc.nal.usda.gov/). Dữ liệu thuộc miền công cộng theo CC0 1.0; chúng mình ghi nguồn theo đề nghị của USDA. Các mã FDC ID hiển thị ở \"Cách chúng mình tính\".\n\nMột số nguyên liệu dùng bản ghi gần đúng (proxy), ví dụ cá basa dùng số liệu cá da trơn, nước mắm chay dùng số liệu xì dầu. Các mục này được đánh dấu trong dữ liệu và sẽ được thay khi có nguồn đúng hơn.\n\nSố liệu là giá trị trên 100 g phần ăn được, có thể chênh lệch so với sản phẩm thực tế (giống, cách nấu, nhãn hàng). Các con số là ước tính để lập kế hoạch.\n\nGiá lấy từ khảo sát tại cửa hàng, ghi ngày khảo sát ở từng cửa hàng.';

  @override
  String get profilePricesBody =>
      'Giá hiển thị trong FitPro - Mâm đủ là ước tính tại thời điểm khảo sát (ghi ngày ở từng cửa hàng). Giá thực tế ở cửa hàng có thể khác do khuyến mãi, khu vực và thời điểm. Ứng dụng không kết nối với hệ thống bán hàng của cửa hàng và không đặt hàng thay bạn.\n\nChi phí \"Ước tính trả tại quầy\" làm tròn lên theo gói mua, không phải tổng tiền bạn sẽ trả.';

  @override
  String get profilePrivacyBody =>
      'Thông tin cơ thể, lựa chọn ăn uống, thực đơn và danh sách đi chợ của bạn được lưu trên máy này. Ứng dụng không có tài khoản và không dùng công cụ phân tích hành vi.\n\nKhi tạo hoặc đổi thực đơn, thông tin cơ thể và lựa chọn của bạn được gửi tới máy chủ của ứng dụng chỉ để tính toán; máy chủ không lưu lại.\n\nBạn có thể xóa toàn bộ dữ liệu trên máy ở tab Bạn. Thao tác này không hoàn tác được.\n\nNếu sau này có tài khoản hoặc đồng bộ, chính sách này sẽ được cập nhật và bạn sẽ được hỏi lại trước khi có thay đổi.';

  @override
  String get profileSectionData => 'Dữ liệu của bạn';

  @override
  String get profileClearHint =>
      'Xóa thiết lập, thực đơn, danh sách đi chợ và tuần đã lưu khỏi máy này.';

  @override
  String get profileClearContinue => 'Tiếp tục';

  @override
  String get profileClearConfirm => 'Xóa tất cả';

  @override
  String shoppingBudgetFoodUnder(Object amount) {
    return 'Chi phí món ăn tuần này nằm trong ngân sách (dư $amount).';
  }

  @override
  String shoppingBudgetFoodOver(Object amount) {
    return 'Chi phí món ăn tuần này vượt ngân sách $amount.';
  }

  @override
  String shoppingBudgetTillInfo(Object amount) {
    return 'Lần đi chợ này ước tính $amount, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau.';
  }

  @override
  String shopPantryIfBuy(Object amount) {
    return 'Nếu phải mua: +$amount ₫';
  }

  @override
  String get onboardingRiceTitle => 'Thói quen ăn cơm';

  @override
  String get onboardingRiceQuestion =>
      'Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?';

  @override
  String get onboardingRiceNote =>
      'Chỉ áp cho bạn. Người lớn khác ăn mức Vừa, trẻ em ăn 0,6 suất.';

  @override
  String get onboardingRiceIt => '½ chén (~75 g)';

  @override
  String get onboardingRiceVua => '1 chén (~150 g)';

  @override
  String get onboardingRiceNhieu => '2 chén (~300 g)';

  @override
  String get onboardingRiceRatNhieu => '3 chén trở lên (~450 g)';

  @override
  String get onboardingRiceWarning =>
      'Với mức calo hiện tại, một số bữa sẽ phải bớt cơm. Bạn vẫn có thể giữ lựa chọn này.';

  @override
  String mealRiceReduced(Object v1, Object v2, Object v3) {
    return 'Bữa này cơm còn khoảng $v1 g (bạn chọn $v2 g) để vẫn đủ đạm trong mức $v3 kcal của bạn.';
  }

  @override
  String mealRiceCups(Object v1, Object v2) {
    return '$v1 chén cơm (~$v2 g)';
  }

  @override
  String mealRiceReducedCups(Object cups) {
    return 'Bữa này bớt còn $cups chén cơm để giữ đúng calo.';
  }

  @override
  String get mealRiceSummaryLowCarb => 'Ít tinh bột: mâm không có cơm';

  @override
  String get profileRiceHabitTitle => 'Thói quen ăn cơm';
}
