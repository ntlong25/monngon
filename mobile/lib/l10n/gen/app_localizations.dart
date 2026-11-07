import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('vi')];

  /// No description provided for @appName.
  ///
  /// In vi, this message translates to:
  /// **'FitPro - Mâm đủ'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In vi, this message translates to:
  /// **'Thực đơn tuần đủ đạm, đi chợ đúng ngân sách.'**
  String get appTagline;

  /// No description provided for @commonContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In vi, this message translates to:
  /// **'Xong'**
  String get commonDone;

  /// No description provided for @commonCancel.
  ///
  /// In vi, this message translates to:
  /// **'Huỷ'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xác nhận'**
  String get commonConfirm;

  /// No description provided for @commonRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// No description provided for @commonUndo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get commonUndo;

  /// No description provided for @commonClose.
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// No description provided for @commonEstimate.
  ///
  /// In vi, this message translates to:
  /// **'ước tính'**
  String get commonEstimate;

  /// No description provided for @commonEstimateNote.
  ///
  /// In vi, this message translates to:
  /// **'Giá là ước tính, có thể khác khi bạn đi chợ.'**
  String get commonEstimateNote;

  /// No description provided for @commonKcal.
  ///
  /// In vi, this message translates to:
  /// **'{count} kcal'**
  String commonKcal(Object count);

  /// No description provided for @commonGram.
  ///
  /// In vi, this message translates to:
  /// **'{count} g'**
  String commonGram(Object count);

  /// No description provided for @commonVnd.
  ///
  /// In vi, this message translates to:
  /// **'{count} ₫'**
  String commonVnd(Object count);

  /// No description provided for @commonDaysCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} ngày'**
  String commonDaysCount(Object count);

  /// No description provided for @commonMealsCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} bữa'**
  String commonMealsCount(Object count);

  /// No description provided for @commonPeopleCount.
  ///
  /// In vi, this message translates to:
  /// **'{count} người'**
  String commonPeopleCount(Object count);

  /// No description provided for @onboardingProgressLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bước {count} trên 10'**
  String onboardingProgressLabel(Object count);

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn muốn đạt mục tiêu nào?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalLose.
  ///
  /// In vi, this message translates to:
  /// **'Giảm mỡ'**
  String get onboardingGoalLose;

  /// No description provided for @onboardingGoalHold.
  ///
  /// In vi, this message translates to:
  /// **'Giữ cân'**
  String get onboardingGoalHold;

  /// No description provided for @onboardingGoalBuild.
  ///
  /// In vi, this message translates to:
  /// **'Tăng cơ'**
  String get onboardingGoalBuild;

  /// No description provided for @onboardingBodyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cho mình biết về cơ thể bạn'**
  String get onboardingBodyTitle;

  /// No description provided for @onboardingBodySex.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get onboardingBodySex;

  /// No description provided for @onboardingBodyAge.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get onboardingBodyAge;

  /// No description provided for @onboardingBodyHeight.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao'**
  String get onboardingBodyHeight;

  /// No description provided for @onboardingBodyWeight.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng'**
  String get onboardingBodyWeight;

  /// No description provided for @onboardingBodyActivityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn vận động mỗi tuần thế nào?'**
  String get onboardingBodyActivityTitle;

  /// No description provided for @onboardingBodyActivitySedentary.
  ///
  /// In vi, this message translates to:
  /// **'Ít vận động'**
  String get onboardingBodyActivitySedentary;

  /// No description provided for @onboardingBodyActivityLight.
  ///
  /// In vi, this message translates to:
  /// **'Nhẹ, 1–2 buổi'**
  String get onboardingBodyActivityLight;

  /// No description provided for @onboardingBodyActivityModerate.
  ///
  /// In vi, this message translates to:
  /// **'Vừa, 3–4 buổi'**
  String get onboardingBodyActivityModerate;

  /// No description provided for @onboardingBodyActivityHigh.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều, 5–6 buổi'**
  String get onboardingBodyActivityHigh;

  /// No description provided for @onboardingBodyActivityAthlete.
  ///
  /// In vi, this message translates to:
  /// **'Rất nhiều, vận động viên'**
  String get onboardingBodyActivityAthlete;

  /// No description provided for @onboardingTargetsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tiêu mỗi ngày của bạn'**
  String get onboardingTargetsTitle;

  /// No description provided for @onboardingTargetsEditNote.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể tự nhập số khác. Chỉ tiêu áp dụng từ tuần kế tiếp.'**
  String get onboardingTargetsEditNote;

  /// No description provided for @onboardingTargetsProteinFloor.
  ///
  /// In vi, this message translates to:
  /// **'Protein tối thiểu {count}'**
  String onboardingTargetsProteinFloor(Object count);

  /// No description provided for @onboardingTargetsKcalBand.
  ///
  /// In vi, this message translates to:
  /// **'Calo trong khoảng {v1}–{v2}'**
  String onboardingTargetsKcalBand(Object v1, Object v2);

  /// No description provided for @onboardingTargetsManual.
  ///
  /// In vi, this message translates to:
  /// **'Tự nhập chỉ tiêu'**
  String get onboardingTargetsManual;

  /// No description provided for @onboardingTargetsFormula.
  ///
  /// In vi, this message translates to:
  /// **'Dùng công thức mặc định'**
  String get onboardingTargetsFormula;

  /// No description provided for @onboardingStoreTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn hay đi chợ ở đâu?'**
  String get onboardingStoreTitle;

  /// No description provided for @onboardingStoreNote.
  ///
  /// In vi, this message translates to:
  /// **'Giá là ước tính. Cửa hàng quyết định bảng giá và quy cách bao bì.'**
  String get onboardingStoreNote;

  /// No description provided for @onboardingStoreOther.
  ///
  /// In vi, this message translates to:
  /// **'Nơi khác'**
  String get onboardingStoreOther;

  /// No description provided for @onboardingBudgetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi tuần bạn muốn chi bao nhiêu cho đi chợ?'**
  String get onboardingBudgetTitle;

  /// No description provided for @onboardingBudgetPerWeek.
  ///
  /// In vi, this message translates to:
  /// **'mỗi tuần'**
  String get onboardingBudgetPerWeek;

  /// No description provided for @onboardingBudgetLevelSave.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm — chủ yếu là thực phẩm cơ bản, đơn giản'**
  String get onboardingBudgetLevelSave;

  /// No description provided for @onboardingBudgetLevelMedium.
  ///
  /// In vi, this message translates to:
  /// **'Vừa phải — có thêm đạm và rau đa dạng'**
  String get onboardingBudgetLevelMedium;

  /// No description provided for @onboardingBudgetLevelComfort.
  ///
  /// In vi, this message translates to:
  /// **'Thoải mái — ưu tiên đạm và nguyên liệu tươi'**
  String get onboardingBudgetLevelComfort;

  /// No description provided for @onboardingBudgetMealsRef.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này có {count} bữa.'**
  String onboardingBudgetMealsRef(Object count);

  /// No description provided for @onboardingHouseholdTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ai sẽ ăn cùng bạn?'**
  String get onboardingHouseholdTitle;

  /// No description provided for @onboardingHouseholdAdults.
  ///
  /// In vi, this message translates to:
  /// **'Người lớn'**
  String get onboardingHouseholdAdults;

  /// No description provided for @onboardingHouseholdChildren.
  ///
  /// In vi, this message translates to:
  /// **'Trẻ em'**
  String get onboardingHouseholdChildren;

  /// No description provided for @onboardingHouseholdNote.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu dinh dưỡng vẫn là của riêng bạn, dù ai ngồi cùng mâm.'**
  String get onboardingHouseholdNote;

  /// No description provided for @onboardingMealsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lên thực đơn những bữa nào?'**
  String get onboardingMealsTitle;

  /// No description provided for @onboardingMealsHint.
  ///
  /// In vi, this message translates to:
  /// **'Tắt những gì bạn không muốn lên thực đơn.'**
  String get onboardingMealsHint;

  /// No description provided for @onboardingMealsBreakfast.
  ///
  /// In vi, this message translates to:
  /// **'Bữa sáng'**
  String get onboardingMealsBreakfast;

  /// No description provided for @onboardingMealsLunch.
  ///
  /// In vi, this message translates to:
  /// **'Bữa trưa'**
  String get onboardingMealsLunch;

  /// No description provided for @onboardingMealsDinner.
  ///
  /// In vi, this message translates to:
  /// **'Bữa tối'**
  String get onboardingMealsDinner;

  /// No description provided for @onboardingMealsSnackAm.
  ///
  /// In vi, this message translates to:
  /// **'Bữa phụ sáng'**
  String get onboardingMealsSnackAm;

  /// No description provided for @onboardingMealsSnackPm.
  ///
  /// In vi, this message translates to:
  /// **'Bữa phụ chiều'**
  String get onboardingMealsSnackPm;

  /// No description provided for @onboardingMealsSelf.
  ///
  /// In vi, this message translates to:
  /// **'Tự lo'**
  String get onboardingMealsSelf;

  /// No description provided for @onboardingMealsOff.
  ///
  /// In vi, this message translates to:
  /// **'Không lên món'**
  String get onboardingMealsOff;

  /// No description provided for @onboardingMealsHot.
  ///
  /// In vi, this message translates to:
  /// **'Nóng'**
  String get onboardingMealsHot;

  /// No description provided for @onboardingMealsPacked.
  ///
  /// In vi, this message translates to:
  /// **'Mang đi'**
  String get onboardingMealsPacked;

  /// No description provided for @onboardingMealsSweet.
  ///
  /// In vi, this message translates to:
  /// **'Ngọt'**
  String get onboardingMealsSweet;

  /// No description provided for @onboardingMealsSavory.
  ///
  /// In vi, this message translates to:
  /// **'Mặn'**
  String get onboardingMealsSavory;

  /// No description provided for @onboardingDietTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có kiêng gì không?'**
  String get onboardingDietTitle;

  /// No description provided for @onboardingDietHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả những gì đúng với bạn.'**
  String get onboardingDietHint;

  /// No description provided for @onboardingDietNone.
  ///
  /// In vi, this message translates to:
  /// **'Không kiêng gì — toàn bộ kho nguyên liệu'**
  String get onboardingDietNone;

  /// No description provided for @onboardingDietVegetarian.
  ///
  /// In vi, this message translates to:
  /// **'Ăn chay'**
  String get onboardingDietVegetarian;

  /// No description provided for @onboardingDietVegan.
  ///
  /// In vi, this message translates to:
  /// **'Thuần chay'**
  String get onboardingDietVegan;

  /// No description provided for @onboardingDietPescatarian.
  ///
  /// In vi, this message translates to:
  /// **'Ăn chay có cá'**
  String get onboardingDietPescatarian;

  /// No description provided for @onboardingDietLowCarb.
  ///
  /// In vi, this message translates to:
  /// **'Ít tinh bột'**
  String get onboardingDietLowCarb;

  /// No description provided for @onboardingDietNoPork.
  ///
  /// In vi, this message translates to:
  /// **'Không thịt lợn'**
  String get onboardingDietNoPork;

  /// No description provided for @onboardingDietNoRedMeat.
  ///
  /// In vi, this message translates to:
  /// **'Không thịt đỏ'**
  String get onboardingDietNoRedMeat;

  /// No description provided for @onboardingDietNoGluten.
  ///
  /// In vi, this message translates to:
  /// **'Không gluten'**
  String get onboardingDietNoGluten;

  /// No description provided for @onboardingDietNoDairy.
  ///
  /// In vi, this message translates to:
  /// **'Không sữa'**
  String get onboardingDietNoDairy;

  /// No description provided for @onboardingDietNoEgg.
  ///
  /// In vi, this message translates to:
  /// **'Không trứng'**
  String get onboardingDietNoEgg;

  /// No description provided for @onboardingDietNoPeanut.
  ///
  /// In vi, this message translates to:
  /// **'Không lạc'**
  String get onboardingDietNoPeanut;

  /// No description provided for @onboardingDietNoTreeNut.
  ///
  /// In vi, this message translates to:
  /// **'Không hạt cây'**
  String get onboardingDietNoTreeNut;

  /// No description provided for @onboardingDietNoSeed.
  ///
  /// In vi, this message translates to:
  /// **'Không hạt giống & vừng'**
  String get onboardingDietNoSeed;

  /// No description provided for @onboardingDietNoSesame.
  ///
  /// In vi, this message translates to:
  /// **'Không vừng'**
  String get onboardingDietNoSesame;

  /// No description provided for @onboardingDietNoSoy.
  ///
  /// In vi, this message translates to:
  /// **'Không đậu nành'**
  String get onboardingDietNoSoy;

  /// No description provided for @onboardingDietNoFish.
  ///
  /// In vi, this message translates to:
  /// **'Không cá'**
  String get onboardingDietNoFish;

  /// No description provided for @onboardingDietNoShellfish.
  ///
  /// In vi, this message translates to:
  /// **'Không giáp xác, nhuyễn thể'**
  String get onboardingDietNoShellfish;

  /// No description provided for @onboardingDietConflictVeg.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ chọn một kiểu ăn chay.'**
  String get onboardingDietConflictVeg;

  /// No description provided for @onboardingDislikeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có gì bạn không bao giờ muốn thấy trên thực đơn?'**
  String get onboardingDislikeTitle;

  /// No description provided for @onboardingDislikeSearch.
  ///
  /// In vi, this message translates to:
  /// **'Tìm nguyên liệu'**
  String get onboardingDislikeSearch;

  /// No description provided for @onboardingDislikeNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món nào bị loại.'**
  String get onboardingDislikeNone;

  /// No description provided for @onboardingSwipeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Vuốt để chọn món bạn thích'**
  String get onboardingSwipeTitle;

  /// No description provided for @onboardingSwipeLike.
  ///
  /// In vi, this message translates to:
  /// **'Thích'**
  String get onboardingSwipeLike;

  /// No description provided for @onboardingSwipeDislike.
  ///
  /// In vi, this message translates to:
  /// **'Không thích'**
  String get onboardingSwipeDislike;

  /// No description provided for @onboardingSwipeUndo.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get onboardingSwipeUndo;

  /// No description provided for @onboardingSwipeSkip.
  ///
  /// In vi, this message translates to:
  /// **'Thay thế'**
  String get onboardingSwipeSkip;

  /// No description provided for @onboardingEquipmentTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bếp nhà bạn có những gì?'**
  String get onboardingEquipmentTitle;

  /// No description provided for @onboardingEquipmentStove.
  ///
  /// In vi, this message translates to:
  /// **'Bếp'**
  String get onboardingEquipmentStove;

  /// No description provided for @onboardingEquipmentRiceCooker.
  ///
  /// In vi, this message translates to:
  /// **'Nồi cơm điện'**
  String get onboardingEquipmentRiceCooker;

  /// No description provided for @onboardingEquipmentMicrowave.
  ///
  /// In vi, this message translates to:
  /// **'Lò vi sóng'**
  String get onboardingEquipmentMicrowave;

  /// No description provided for @onboardingEquipmentAirFryer.
  ///
  /// In vi, this message translates to:
  /// **'Nồi chiên không dầu'**
  String get onboardingEquipmentAirFryer;

  /// No description provided for @onboardingEquipmentOven.
  ///
  /// In vi, this message translates to:
  /// **'Lò nướng'**
  String get onboardingEquipmentOven;

  /// No description provided for @onboardingEquipmentPressureCooker.
  ///
  /// In vi, this message translates to:
  /// **'Nồi áp suất'**
  String get onboardingEquipmentPressureCooker;

  /// No description provided for @onboardingEquipmentBlender.
  ///
  /// In vi, this message translates to:
  /// **'Máy xay'**
  String get onboardingEquipmentBlender;

  /// No description provided for @onboardingSummaryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đây là thiết lập của bạn'**
  String get onboardingSummaryTitle;

  /// No description provided for @onboardingSummaryEdit.
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get onboardingSummaryEdit;

  /// No description provided for @onboardingSummaryCreate.
  ///
  /// In vi, this message translates to:
  /// **'Tạo thực đơn tuần'**
  String get onboardingSummaryCreate;

  /// No description provided for @onboardingGeneratingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đang lên thực đơn'**
  String get onboardingGeneratingTitle;

  /// No description provided for @onboardingGeneratingChecklist.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra protein từng ngày, calo, ngân sách'**
  String get onboardingGeneratingChecklist;

  /// No description provided for @onboardingGeneratingWait.
  ///
  /// In vi, this message translates to:
  /// **'Thường mất vài giây.'**
  String get onboardingGeneratingWait;

  /// No description provided for @planTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch'**
  String get planTitle;

  /// No description provided for @planWeekRange.
  ///
  /// In vi, this message translates to:
  /// **'Tuần {range}'**
  String planWeekRange(Object range);

  /// No description provided for @planMealCookOnce.
  ///
  /// In vi, this message translates to:
  /// **'Nấu 1 lần cho 2 bữa'**
  String get planMealCookOnce;

  /// No description provided for @planMealReused.
  ///
  /// In vi, this message translates to:
  /// **'Lặp lại có chủ đích'**
  String get planMealReused;

  /// No description provided for @planDayProteinOk.
  ///
  /// In vi, this message translates to:
  /// **'Đủ protein'**
  String get planDayProteinOk;

  /// No description provided for @planDayProteinLow.
  ///
  /// In vi, this message translates to:
  /// **'Thiếu {count} g protein'**
  String planDayProteinLow(Object count);

  /// No description provided for @planDayKcalOk.
  ///
  /// In vi, this message translates to:
  /// **'Calo trong dải'**
  String get planDayKcalOk;

  /// No description provided for @planDayKcalOut.
  ///
  /// In vi, this message translates to:
  /// **'Calo ngoài dải'**
  String get planDayKcalOut;

  /// No description provided for @planBannerPartial.
  ///
  /// In vi, this message translates to:
  /// **'Có {v1} ngày chưa đạt. {v2}'**
  String planBannerPartial(Object v1, Object v2);

  /// No description provided for @planBannerPartialDetail.
  ///
  /// In vi, this message translates to:
  /// **'Mình vẫn giữ thực đơn và tối ưu phần còn lại.'**
  String get planBannerPartialDetail;

  /// No description provided for @planBannerEdit.
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết'**
  String get planBannerEdit;

  /// No description provided for @planEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thực đơn'**
  String get planEmptyTitle;

  /// No description provided for @planEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tất thiết lập để mình lên thực đơn tuần đầu tiên.'**
  String get planEmptyBody;

  /// No description provided for @planEmptyCta.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập ngay'**
  String get planEmptyCta;

  /// No description provided for @planEatOut.
  ///
  /// In vi, this message translates to:
  /// **'Ăn ngoài'**
  String get planEatOut;

  /// No description provided for @planSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ bữa'**
  String get planSkip;

  /// No description provided for @planSwap.
  ///
  /// In vi, this message translates to:
  /// **'Đổi món này'**
  String get planSwap;

  /// No description provided for @recipeServingsYours.
  ///
  /// In vi, this message translates to:
  /// **'Phần của bạn'**
  String get recipeServingsYours;

  /// No description provided for @recipeServingsWhole.
  ///
  /// In vi, this message translates to:
  /// **'Cả nồi'**
  String get recipeServingsWhole;

  /// No description provided for @recipeStepsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Các bước'**
  String get recipeStepsTitle;

  /// No description provided for @recipeStepsDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get recipeStepsDone;

  /// No description provided for @recipeCookMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ nấu'**
  String get recipeCookMode;

  /// No description provided for @recipeCookModeKeepOn.
  ///
  /// In vi, this message translates to:
  /// **'Màn hình sẽ không tắt khi đang nấu.'**
  String get recipeCookModeKeepOn;

  /// No description provided for @recipeEquipment.
  ///
  /// In vi, this message translates to:
  /// **'Dụng cụ cần có'**
  String get recipeEquipment;

  /// No description provided for @recipeTime.
  ///
  /// In vi, this message translates to:
  /// **'{count} phút'**
  String recipeTime(Object count);

  /// No description provided for @recipeCalcLink.
  ///
  /// In vi, this message translates to:
  /// **'Cách chúng mình tính'**
  String get recipeCalcLink;

  /// No description provided for @recipeSwapIngredient.
  ///
  /// In vi, this message translates to:
  /// **'Đổi nguyên liệu'**
  String get recipeSwapIngredient;

  /// No description provided for @calcTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách chúng mình tính'**
  String get calcTitle;

  /// No description provided for @calcIntro.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi con số đều truy được về nguồn dữ liệu. Không có con số nào do AI đoán.'**
  String get calcIntro;

  /// No description provided for @calcRowIngredient.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên liệu'**
  String get calcRowIngredient;

  /// No description provided for @calcRowGrams.
  ///
  /// In vi, this message translates to:
  /// **'Gram'**
  String get calcRowGrams;

  /// No description provided for @calcRowKcal.
  ///
  /// In vi, this message translates to:
  /// **'Calo'**
  String get calcRowKcal;

  /// No description provided for @calcRowProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein'**
  String get calcRowProtein;

  /// No description provided for @calcRowSource.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn'**
  String get calcRowSource;

  /// No description provided for @calcTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get calcTotal;

  /// No description provided for @calcSourceUsda.
  ///
  /// In vi, this message translates to:
  /// **'USDA FoodData Central, mã {count}'**
  String calcSourceUsda(Object count);

  /// No description provided for @calcSourceNote.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu USDA thuộc miền công cộng (CC0). Giá trị trên 100 g phần ăn được.'**
  String get calcSourceNote;

  /// No description provided for @shoppingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đi chợ'**
  String get shoppingTitle;

  /// No description provided for @shoppingTotal.
  ///
  /// In vi, this message translates to:
  /// **'Tổng ước tính'**
  String get shoppingTotal;

  /// No description provided for @shoppingWeekCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí món ăn tuần này'**
  String get shoppingWeekCost;

  /// No description provided for @shoppingTillCost.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính trả tại quầy'**
  String get shoppingTillCost;

  /// No description provided for @shoppingLeftover.
  ///
  /// In vi, this message translates to:
  /// **'Dư {count} g'**
  String shoppingLeftover(Object count);

  /// No description provided for @shoppingShelfLife.
  ///
  /// In vi, this message translates to:
  /// **'Dùng trong {count} ngày'**
  String shoppingShelfLife(Object count);

  /// No description provided for @shoppingShare.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ danh sách'**
  String get shoppingShare;

  /// No description provided for @shoppingCopied.
  ///
  /// In vi, this message translates to:
  /// **'Đã chép vào bộ nhớ tạm.'**
  String get shoppingCopied;

  /// No description provided for @shoppingPantryHave.
  ///
  /// In vi, this message translates to:
  /// **'Đã có sẵn'**
  String get shoppingPantryHave;

  /// No description provided for @shoppingEmptyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có danh sách'**
  String get shoppingEmptyTitle;

  /// No description provided for @shoppingEmptyBody.
  ///
  /// In vi, this message translates to:
  /// **'Tạo thực đơn tuần để có danh sách đi chợ.'**
  String get shoppingEmptyBody;

  /// No description provided for @swapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi món này'**
  String get swapTitle;

  /// No description provided for @swapDeltaKcal.
  ///
  /// In vi, this message translates to:
  /// **'Calo {count} kcal'**
  String swapDeltaKcal(Object count);

  /// No description provided for @swapDeltaProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein {count} g'**
  String swapDeltaProtein(Object count);

  /// No description provided for @swapDeltaCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí {count} ₫'**
  String swapDeltaCost(Object count);

  /// No description provided for @swapKeepDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày này vẫn đạt.'**
  String get swapKeepDay;

  /// No description provided for @swapNoOption.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm được món phù hợp hơn.'**
  String get swapNoOption;

  /// No description provided for @eatOutTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ăn ngoài'**
  String get eatOutTitle;

  /// No description provided for @eatOutBody.
  ///
  /// In vi, this message translates to:
  /// **'Phần còn lại của ngày vẫn giữ nguyên.'**
  String get eatOutBody;

  /// No description provided for @eatOutUndo.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ đánh dấu ăn ngoài'**
  String get eatOutUndo;

  /// No description provided for @blockTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không hợp với tôi'**
  String get blockTitle;

  /// No description provided for @blockBody.
  ///
  /// In vi, this message translates to:
  /// **'Món này sẽ không xuất hiện trong các tuần sau.'**
  String get blockBody;

  /// No description provided for @blockConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Không lên món này nữa'**
  String get blockConfirm;

  /// No description provided for @restTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại phần còn lại'**
  String get restTitle;

  /// No description provided for @restBody.
  ///
  /// In vi, this message translates to:
  /// **'Giữ các bữa đã nấu, lên lại những bữa còn lại.'**
  String get restBody;

  /// No description provided for @accountTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get accountTitle;

  /// No description provided for @accountEditProfile.
  ///
  /// In vi, this message translates to:
  /// **'Sửa thiết lập'**
  String get accountEditProfile;

  /// No description provided for @accountSavedPlans.
  ///
  /// In vi, this message translates to:
  /// **'Tuần đã lưu'**
  String get accountSavedPlans;

  /// No description provided for @accountSavedPlansEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tuần nào được lưu.'**
  String get accountSavedPlansEmpty;

  /// No description provided for @accountNextWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tuần tới'**
  String get accountNextWeek;

  /// No description provided for @accountClearData.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ dữ liệu'**
  String get accountClearData;

  /// No description provided for @accountClearDataConfirm1.
  ///
  /// In vi, this message translates to:
  /// **'Xoá toàn bộ dữ liệu trên máy này?'**
  String get accountClearDataConfirm1;

  /// No description provided for @accountClearDataConfirm2.
  ///
  /// In vi, this message translates to:
  /// **'Thao tác này không hoàn tác được. Bạn chắc chứ?'**
  String get accountClearDataConfirm2;

  /// No description provided for @accountPrivacy.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu chỉ lưu trên máy của bạn.'**
  String get accountPrivacy;

  /// No description provided for @accountDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin chỉ để tham khảo, không thay thế tư vấn y tế.'**
  String get accountDisclaimer;

  /// No description provided for @accountSources.
  ///
  /// In vi, this message translates to:
  /// **'Nguồn dữ liệu'**
  String get accountSources;

  /// No description provided for @errorsGenericTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra'**
  String get errorsGenericTitle;

  /// No description provided for @errorsGenericBody.
  ///
  /// In vi, this message translates to:
  /// **'Mình chưa lên được thực đơn. Thử lại nhé.'**
  String get errorsGenericBody;

  /// No description provided for @errorsNetworkBody.
  ///
  /// In vi, this message translates to:
  /// **'Không có mạng. Dữ liệu vẫn được giữ trên máy.'**
  String get errorsNetworkBody;

  /// No description provided for @errorsBudgetTooLowBody.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách này khó đủ đạm cho cả tuần. Thử tăng ngân sách hoặc giảm chỉ tiêu.'**
  String get errorsBudgetTooLowBody;

  /// No description provided for @emptyGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì ở đây.'**
  String get emptyGeneric;

  /// No description provided for @profileDisclaimerBody.
  ///
  /// In vi, this message translates to:
  /// **'FitPro - Mâm đủ không phải lời khuyên y tế. Thực đơn và chỉ tiêu protein, calo được tính theo công thức phổ biến và dữ liệu thành phần thực phẩm; chúng không chẩn đoán, không điều trị và không thay thế bác sĩ hay chuyên gia dinh dưỡng.\n\nĐặc biệt, hãy hỏi bác sĩ trước khi thay đổi chế độ ăn nếu bạn:\n• đang mắc hoặc nghi ngờ bệnh tiểu đường, bệnh tim mạch, bệnh thận, rối loạn ăn uống hoặc đang dùng thuốc cần theo dõi bữa ăn;\n• có hội chứng buồng trứng đa nang (PCOS) hoặc đang mang thai, cho con bú;\n• dưới 18 tuổi;\n• có dị ứng thực phẩm đã được chẩn đoán. Bộ lọc dị ứng là công cụ hỗ trợ, không thay cho việc đọc nhãn sản phẩm thực tế.\n\nCác lựa chọn \"Nhiều chất xơ\", \"Ít đường\", \"Tốt cho tim mạch\", \"Ít béo\" chỉ là ưu tiên khi chọn món, không phải chỉ định điều trị.'**
  String get profileDisclaimerBody;

  /// No description provided for @budgetTierEconomy.
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get budgetTierEconomy;

  /// No description provided for @budgetTierEconomyDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chủ yếu là thực phẩm cơ bản, đơn giản.'**
  String get budgetTierEconomyDesc;

  /// No description provided for @budgetTierModerate.
  ///
  /// In vi, this message translates to:
  /// **'Vừa phải'**
  String get budgetTierModerate;

  /// No description provided for @budgetTierModerateDesc.
  ///
  /// In vi, this message translates to:
  /// **'Có thêm đạm và rau đa dạng.'**
  String get budgetTierModerateDesc;

  /// No description provided for @budgetTierComfortable.
  ///
  /// In vi, this message translates to:
  /// **'Thoải mái'**
  String get budgetTierComfortable;

  /// No description provided for @budgetTierComfortableDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên đạm và nguyên liệu tươi.'**
  String get budgetTierComfortableDesc;

  /// No description provided for @healthNhieuXo.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều chất xơ'**
  String get healthNhieuXo;

  /// No description provided for @healthNhieuXoDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên món có nhiều rau, đậu và ngũ cốc nguyên cám.'**
  String get healthNhieuXoDesc;

  /// No description provided for @healthItDuong.
  ///
  /// In vi, this message translates to:
  /// **'Ít đường'**
  String get healthItDuong;

  /// No description provided for @healthItDuongDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên món không thêm đường và ít tinh bột.'**
  String get healthItDuongDesc;

  /// No description provided for @healthTotChoTim.
  ///
  /// In vi, this message translates to:
  /// **'Tốt cho tim mạch'**
  String get healthTotChoTim;

  /// No description provided for @healthTotChoTimDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên món có cá béo, nhiều xơ và ít chiên ngập dầu.'**
  String get healthTotChoTimDesc;

  /// No description provided for @healthItBeo.
  ///
  /// In vi, this message translates to:
  /// **'Ít béo'**
  String get healthItBeo;

  /// No description provided for @healthItBeoDesc.
  ///
  /// In vi, this message translates to:
  /// **'Ưu tiên món có ít chất béo trong tổng năng lượng.'**
  String get healthItBeoDesc;

  /// No description provided for @healthDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'Các lựa chọn này chỉ là ưu tiên mềm khi chọn món, không phải lời khuyên y tế. Hỏi bác sĩ hoặc chuyên gia dinh dưỡng nếu bạn cần chế độ ăn riêng.'**
  String get healthDisclaimer;

  /// No description provided for @imagePlaceholder.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh món đang được chuẩn bị'**
  String get imagePlaceholder;

  /// No description provided for @errorsNetworkTitle.
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được'**
  String get errorsNetworkTitle;

  /// No description provided for @errorsOfflineRetry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại khi có mạng'**
  String get errorsOfflineRetry;

  /// No description provided for @freemiumWeekLimit.
  ///
  /// In vi, this message translates to:
  /// **'Bản miễn phí giữ một tuần đang chạy. Tạo tuần mới mỗi tuần một lần.'**
  String get freemiumWeekLimit;

  /// No description provided for @freemiumSwapLimit.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đổi {count} / 3 món trong tuần này.'**
  String freemiumSwapLimit(Object count);

  /// No description provided for @freemiumRestoreLocked.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại phần còn lại của tuần cần Premium.'**
  String get freemiumRestoreLocked;

  /// No description provided for @freemiumTrialCta.
  ///
  /// In vi, this message translates to:
  /// **'Dùng thử 7 ngày miễn phí'**
  String get freemiumTrialCta;

  /// No description provided for @freemiumTrialBody.
  ///
  /// In vi, this message translates to:
  /// **'Dùng đầy đủ tính năng trong 7 ngày. Sau đó chuyển về bản miễn phí, dữ liệu vẫn giữ nguyên.'**
  String get freemiumTrialBody;

  /// No description provided for @freemiumUpgradeCta.
  ///
  /// In vi, this message translates to:
  /// **'Xem gói Premium'**
  String get freemiumUpgradeCta;

  /// No description provided for @tabPlan.
  ///
  /// In vi, this message translates to:
  /// **'Kế hoạch'**
  String get tabPlan;

  /// No description provided for @tabShopping.
  ///
  /// In vi, this message translates to:
  /// **'Đi chợ'**
  String get tabShopping;

  /// No description provided for @tabProfile.
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get tabProfile;

  /// No description provided for @placeholderPlan.
  ///
  /// In vi, this message translates to:
  /// **'Tuần của bạn sẽ hiện ở đây.'**
  String get placeholderPlan;

  /// No description provided for @placeholderShopping.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách đi chợ sẽ hiện ở đây.'**
  String get placeholderShopping;

  /// No description provided for @placeholderProfile.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tiêu và lựa chọn của bạn sẽ hiện ở đây.'**
  String get placeholderProfile;

  /// No description provided for @connectionTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kết nối máy chủ'**
  String get connectionTitle;

  /// No description provided for @connectionOk.
  ///
  /// In vi, this message translates to:
  /// **'Đã kết nối'**
  String get connectionOk;

  /// No description provided for @connectionFail.
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối được máy chủ'**
  String get connectionFail;

  /// No description provided for @connectionChecking.
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra…'**
  String get connectionChecking;

  /// No description provided for @apiBaseUrl.
  ///
  /// In vi, this message translates to:
  /// **'Địa chỉ máy chủ: {url}'**
  String apiBaseUrl(Object url);

  /// No description provided for @galleryTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thư viện thành phần'**
  String get galleryTitle;

  /// No description provided for @commonDecrease.
  ///
  /// In vi, this message translates to:
  /// **'Giảm'**
  String get commonDecrease;

  /// No description provided for @commonIncrease.
  ///
  /// In vi, this message translates to:
  /// **'Tăng'**
  String get commonIncrease;

  /// No description provided for @galleryOpen.
  ///
  /// In vi, this message translates to:
  /// **'Mở thư viện thành phần (chỉ bản debug)'**
  String get galleryOpen;

  /// No description provided for @dishRoleFullMeal.
  ///
  /// In vi, this message translates to:
  /// **'Món trọn suất'**
  String get dishRoleFullMeal;

  /// No description provided for @dishRoleMain.
  ///
  /// In vi, this message translates to:
  /// **'Món chính'**
  String get dishRoleMain;

  /// No description provided for @dishRoleSoup.
  ///
  /// In vi, this message translates to:
  /// **'Canh'**
  String get dishRoleSoup;

  /// No description provided for @dishRoleSideVeg.
  ///
  /// In vi, this message translates to:
  /// **'Rau'**
  String get dishRoleSideVeg;

  /// No description provided for @dishRoleCarbBase.
  ///
  /// In vi, this message translates to:
  /// **'Cơm'**
  String get dishRoleCarbBase;

  /// No description provided for @dishRoleDessert.
  ///
  /// In vi, this message translates to:
  /// **'Tráng miệng'**
  String get dishRoleDessert;

  /// No description provided for @dishRoleExtra.
  ///
  /// In vi, this message translates to:
  /// **'Món thêm'**
  String get dishRoleExtra;

  /// No description provided for @macroProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein'**
  String get macroProtein;

  /// No description provided for @macroKcal.
  ///
  /// In vi, this message translates to:
  /// **'Calo'**
  String get macroKcal;

  /// No description provided for @macroCarb.
  ///
  /// In vi, this message translates to:
  /// **'Tinh bột'**
  String get macroCarb;

  /// No description provided for @macroFat.
  ///
  /// In vi, this message translates to:
  /// **'Béo'**
  String get macroFat;

  /// No description provided for @galleryImageNull.
  ///
  /// In vi, this message translates to:
  /// **'Ảnh trống (image = null)'**
  String get galleryImageNull;

  /// No description provided for @onboardingProgressOf.
  ///
  /// In vi, this message translates to:
  /// **'Bước {v1} trên {v2}'**
  String onboardingProgressOf(Object v1, Object v2);

  /// No description provided for @validationRange.
  ///
  /// In vi, this message translates to:
  /// **'{v1} từ {v2} đến {v3}'**
  String validationRange(Object v1, Object v2, Object v3);

  /// No description provided for @unitYears.
  ///
  /// In vi, this message translates to:
  /// **'tuổi'**
  String get unitYears;

  /// No description provided for @unitCm.
  ///
  /// In vi, this message translates to:
  /// **'cm'**
  String get unitCm;

  /// No description provided for @unitKg.
  ///
  /// In vi, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitKcal.
  ///
  /// In vi, this message translates to:
  /// **'kcal'**
  String get unitKcal;

  /// No description provided for @unitG.
  ///
  /// In vi, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @onboardingGoalHint.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu quyết định lượng calo và protein bạn cần mỗi ngày.'**
  String get onboardingGoalHint;

  /// No description provided for @onboardingGoalLoseHint.
  ///
  /// In vi, this message translates to:
  /// **'Ăn ít hơn mức duy trì một chút, vẫn đủ đạm để giữ cơ.'**
  String get onboardingGoalLoseHint;

  /// No description provided for @onboardingGoalHoldHint.
  ///
  /// In vi, this message translates to:
  /// **'Ăn vừa đủ để giữ cân nặng hiện tại.'**
  String get onboardingGoalHoldHint;

  /// No description provided for @onboardingGoalBuildHint.
  ///
  /// In vi, this message translates to:
  /// **'Ăn dư một chút và nhiều đạm để tăng cơ.'**
  String get onboardingGoalBuildHint;

  /// No description provided for @onboardingBodySexMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get onboardingBodySexMale;

  /// No description provided for @onboardingBodySexFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get onboardingBodySexFemale;

  /// No description provided for @onboardingBodyHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ dùng để tính chỉ tiêu. App không hỏi tên hay email.'**
  String get onboardingBodyHint;

  /// No description provided for @onboardingTargetsKcalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Calo mỗi ngày'**
  String get onboardingTargetsKcalLabel;

  /// No description provided for @onboardingTargetsProteinLabel.
  ///
  /// In vi, this message translates to:
  /// **'Protein tối thiểu mỗi ngày'**
  String get onboardingTargetsProteinLabel;

  /// No description provided for @onboardingTargetsHowTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách mình tính'**
  String get onboardingTargetsHowTitle;

  /// No description provided for @onboardingTargetsStepBmr.
  ///
  /// In vi, this message translates to:
  /// **'Năng lượng nghỉ ngơi (BMR): {value} kcal'**
  String onboardingTargetsStepBmr(Object value);

  /// No description provided for @onboardingTargetsStepTdee.
  ///
  /// In vi, this message translates to:
  /// **'× hệ số vận động {v1} = {v2} kcal mỗi ngày (TDEE)'**
  String onboardingTargetsStepTdee(Object v1, Object v2);

  /// No description provided for @onboardingTargetsStepGoal.
  ///
  /// In vi, this message translates to:
  /// **'× hệ số mục tiêu {v1} = {v2} kcal, làm tròn 50 kcal → {v3} kcal'**
  String onboardingTargetsStepGoal(Object v1, Object v2, Object v3);

  /// No description provided for @onboardingTargetsStepProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein: {v1} g/kg × cân nặng tham chiếu {v2} kg = {v3} g'**
  String onboardingTargetsStepProtein(Object v1, Object v2, Object v3);

  /// No description provided for @onboardingTargetsStepProteinCap.
  ///
  /// In vi, this message translates to:
  /// **'Trần 35% calo là {v1} g nên dùng {v2} g'**
  String onboardingTargetsStepProteinCap(Object v1, Object v2);

  /// No description provided for @onboardingTargetsStepProteinFloor.
  ///
  /// In vi, this message translates to:
  /// **'Sàn tối thiểu {v1} g cao hơn trần nên dùng {v2} g'**
  String onboardingTargetsStepProteinFloor(Object v1, Object v2);

  /// No description provided for @onboardingTargetsManualHint.
  ///
  /// In vi, this message translates to:
  /// **'Nhập số bạn muốn. Mình vẫn lập thực đơn trong dải calo ±5%.'**
  String get onboardingTargetsManualHint;

  /// No description provided for @onboardingTargetsManualKcal.
  ///
  /// In vi, this message translates to:
  /// **'Calo mỗi ngày (kcal)'**
  String get onboardingTargetsManualKcal;

  /// No description provided for @onboardingTargetsManualProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein tối thiểu (g)'**
  String get onboardingTargetsManualProtein;

  /// No description provided for @onboardingTargetsManualMode.
  ///
  /// In vi, this message translates to:
  /// **'Tự nhập'**
  String get onboardingTargetsManualMode;

  /// No description provided for @onboardingTargetsFormulaMode.
  ///
  /// In vi, this message translates to:
  /// **'Theo công thức'**
  String get onboardingTargetsFormulaMode;

  /// No description provided for @onboardingTargetsBandNote.
  ///
  /// In vi, this message translates to:
  /// **'Thực đơn mỗi ngày nằm trong dải calo ±5% và đạt protein tối thiểu.'**
  String get onboardingTargetsBandNote;

  /// No description provided for @onboardingStoreSurvey.
  ///
  /// In vi, this message translates to:
  /// **'Giá khảo sát ngày {date}'**
  String onboardingStoreSurvey(Object date);

  /// No description provided for @onboardingBudgetNote.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách là chi phí món ăn trong tuần (phần nguyên liệu thực sự dùng). Lần đi chợ đầu có thể cao hơn vì mua nguyên chai dầu, nước mắm, gạo…'**
  String get onboardingBudgetNote;

  /// No description provided for @onboardingBudgetEstimate.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý cho bạn: {amount}'**
  String onboardingBudgetEstimate(Object amount);

  /// No description provided for @onboardingBudgetMin.
  ///
  /// In vi, this message translates to:
  /// **'Tối thiểu {amount}'**
  String onboardingBudgetMin(Object amount);

  /// No description provided for @onboardingBudgetMax.
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {amount}'**
  String onboardingBudgetMax(Object amount);

  /// No description provided for @onboardingHouseholdAdultsHint.
  ///
  /// In vi, this message translates to:
  /// **'Từ 1 đến 6 người'**
  String get onboardingHouseholdAdultsHint;

  /// No description provided for @onboardingHouseholdChildrenHint.
  ///
  /// In vi, this message translates to:
  /// **'Từ 0 đến 4 bé, mỗi bé ăn khoảng 0,6 phần người lớn'**
  String get onboardingHouseholdChildrenHint;

  /// No description provided for @onboardingMealsOn.
  ///
  /// In vi, this message translates to:
  /// **'Lên thực đơn'**
  String get onboardingMealsOn;

  /// No description provided for @onboardingMealsPerSlot.
  ///
  /// In vi, this message translates to:
  /// **'~{v1} kcal · {v2} g protein'**
  String onboardingMealsPerSlot(Object v1, Object v2);

  /// No description provided for @onboardingMealsFooter.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi bữa ~{v1} kcal và {v2} g protein'**
  String onboardingMealsFooter(Object v1, Object v2);

  /// No description provided for @onboardingMealsNeedOne.
  ///
  /// In vi, this message translates to:
  /// **'Cần giữ ít nhất một bữa chính (sáng, trưa hoặc tối) được lên thực đơn.'**
  String get onboardingMealsNeedOne;

  /// No description provided for @onboardingMealsSelfHint.
  ///
  /// In vi, this message translates to:
  /// **'Mình giữ lại phần chỉ tiêu cho bữa này, không lên món.'**
  String get onboardingMealsSelfHint;

  /// No description provided for @onboardingMealsOffHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tiêu được chia lại cho các bữa còn lại.'**
  String get onboardingMealsOffHint;

  /// No description provided for @onboardingDietKindTitle.
  ///
  /// In vi, this message translates to:
  /// **'Kiểu ăn'**
  String get onboardingDietKindTitle;

  /// No description provided for @onboardingDietExcludeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Loại bỏ hoàn toàn'**
  String get onboardingDietExcludeTitle;

  /// No description provided for @onboardingDietExcludeHint.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên liệu bị loại sẽ không bao giờ xuất hiện trong thực đơn.'**
  String get onboardingDietExcludeHint;

  /// No description provided for @onboardingDietScopeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Phạm vi loại bỏ'**
  String get onboardingDietScopeTitle;

  /// No description provided for @onboardingDietLeaningsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng nấu ăn'**
  String get onboardingDietLeaningsTitle;

  /// No description provided for @onboardingDietLeaningsNote.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ là ưu tiên mềm khi chọn món, không phải lời khuyên y tế.'**
  String get onboardingDietLeaningsNote;

  /// No description provided for @onboardingDislikeSuggestions.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý nhanh'**
  String get onboardingDislikeSuggestions;

  /// No description provided for @onboardingDislikeSelected.
  ///
  /// In vi, this message translates to:
  /// **'Đã loại'**
  String get onboardingDislikeSelected;

  /// No description provided for @onboardingDislikeNoResult.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nguyên liệu này.'**
  String get onboardingDislikeNoResult;

  /// No description provided for @onboardingDislikeRemove.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ loại {name}'**
  String onboardingDislikeRemove(Object name);

  /// No description provided for @onboardingSwipeHint.
  ///
  /// In vi, this message translates to:
  /// **'Vuốt phải nếu thích, vuốt trái nếu muốn ít hơn.'**
  String get onboardingSwipeHint;

  /// No description provided for @onboardingSwipeProgress.
  ///
  /// In vi, this message translates to:
  /// **'Thẻ {v1}/{v2}'**
  String onboardingSwipeProgress(Object v1, Object v2);

  /// No description provided for @onboardingSwipeResultTitle.
  ///
  /// In vi, this message translates to:
  /// **'Khẩu vị của bạn'**
  String get onboardingSwipeResultTitle;

  /// No description provided for @onboardingSwipeLiked.
  ///
  /// In vi, this message translates to:
  /// **'Bạn thích'**
  String get onboardingSwipeLiked;

  /// No description provided for @onboardingSwipeLess.
  ///
  /// In vi, this message translates to:
  /// **'Ít hơn'**
  String get onboardingSwipeLess;

  /// No description provided for @onboardingSwipeNone.
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn'**
  String get onboardingSwipeNone;

  /// No description provided for @onboardingSwipeAgain.
  ///
  /// In vi, this message translates to:
  /// **'Vuốt lại'**
  String get onboardingSwipeAgain;

  /// No description provided for @onboardingSwipeSoft.
  ///
  /// In vi, this message translates to:
  /// **'Đây chỉ là ưu tiên mềm; bạn có thể đổi bất cứ lúc nào.'**
  String get onboardingSwipeSoft;

  /// No description provided for @onboardingEquipmentHint.
  ///
  /// In vi, this message translates to:
  /// **'Chọn tất cả thiết bị bạn có.'**
  String get onboardingEquipmentHint;

  /// No description provided for @onboardingEquipmentNeedOne.
  ///
  /// In vi, this message translates to:
  /// **'Cần chọn ít nhất một thiết bị nấu.'**
  String get onboardingEquipmentNeedOne;

  /// No description provided for @onboardingSummaryGoal.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get onboardingSummaryGoal;

  /// No description provided for @onboardingSummaryProtein.
  ///
  /// In vi, this message translates to:
  /// **'Protein tối thiểu'**
  String get onboardingSummaryProtein;

  /// No description provided for @onboardingSummaryKcal.
  ///
  /// In vi, this message translates to:
  /// **'Calo mỗi ngày'**
  String get onboardingSummaryKcal;

  /// No description provided for @onboardingSummaryMeals.
  ///
  /// In vi, this message translates to:
  /// **'Số bữa'**
  String get onboardingSummaryMeals;

  /// No description provided for @onboardingSummaryLeanings.
  ///
  /// In vi, this message translates to:
  /// **'Xu hướng'**
  String get onboardingSummaryLeanings;

  /// No description provided for @onboardingSummaryExcluded.
  ///
  /// In vi, this message translates to:
  /// **'Đã loại'**
  String get onboardingSummaryExcluded;

  /// No description provided for @onboardingSummaryKitchen.
  ///
  /// In vi, this message translates to:
  /// **'Căn bếp'**
  String get onboardingSummaryKitchen;

  /// No description provided for @onboardingSummaryBudget.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách'**
  String get onboardingSummaryBudget;

  /// No description provided for @onboardingSummaryNone.
  ///
  /// In vi, this message translates to:
  /// **'Không có'**
  String get onboardingSummaryNone;

  /// No description provided for @onboardingSummaryMealsValue.
  ///
  /// In vi, this message translates to:
  /// **'{count} bữa mỗi ngày'**
  String onboardingSummaryMealsValue(Object count);

  /// No description provided for @onboardingSummaryBudgetLow.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách {v1} thấp hơn mức tối thiểu gợi ý {v2} cho lựa chọn của bạn. Bạn vẫn có thể tạo tuần, nhưng có thể thiếu đạm hoặc vượt ngân sách.'**
  String onboardingSummaryBudgetLow(Object v1, Object v2);

  /// No description provided for @onboardingSummaryBudgetLowReason.
  ///
  /// In vi, this message translates to:
  /// **'Sau các lựa chọn chế độ ăn và dụng cụ, mức tối thiểu gợi ý là {v1} (lúc chọn ngân sách là {v2}). Bạn vẫn có thể tạo tuần, nhưng có thể thiếu đạm hoặc vượt ngân sách.'**
  String onboardingSummaryBudgetLowReason(Object v1, Object v2);

  /// No description provided for @onboardingSummaryUseMinAmount.
  ///
  /// In vi, this message translates to:
  /// **'Dùng {min}'**
  String onboardingSummaryUseMinAmount(Object min);

  /// No description provided for @onboardingSummaryUseMin.
  ///
  /// In vi, this message translates to:
  /// **'Dùng mức tối thiểu'**
  String get onboardingSummaryUseMin;

  /// No description provided for @onboardingSummaryLowCarb.
  ///
  /// In vi, this message translates to:
  /// **'Ít tinh bột'**
  String get onboardingSummaryLowCarb;

  /// No description provided for @onboardingGeneratingFail.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tạo được thực đơn'**
  String get onboardingGeneratingFail;

  /// No description provided for @weekday1.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Hai'**
  String get weekday1;

  /// No description provided for @weekday2.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Ba'**
  String get weekday2;

  /// No description provided for @weekday3.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Tư'**
  String get weekday3;

  /// No description provided for @weekday4.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Năm'**
  String get weekday4;

  /// No description provided for @weekday5.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Sáu'**
  String get weekday5;

  /// No description provided for @weekday6.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Bảy'**
  String get weekday6;

  /// No description provided for @weekday7.
  ///
  /// In vi, this message translates to:
  /// **'Chủ nhật'**
  String get weekday7;

  /// No description provided for @planGreetingMorning.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi sáng'**
  String get planGreetingMorning;

  /// No description provided for @planGreetingAfternoon.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi chiều'**
  String get planGreetingAfternoon;

  /// No description provided for @planGreetingEvening.
  ///
  /// In vi, this message translates to:
  /// **'Chào buổi tối'**
  String get planGreetingEvening;

  /// No description provided for @planStartsTomorrow.
  ///
  /// In vi, this message translates to:
  /// **'Tuần của bạn bắt đầu từ ngày mai'**
  String get planStartsTomorrow;

  /// No description provided for @planStartsOn.
  ///
  /// In vi, this message translates to:
  /// **'Tuần của bạn bắt đầu từ {date}'**
  String planStartsOn(Object date);

  /// No description provided for @planDayNumber.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay là ngày {n}'**
  String planDayNumber(Object n);

  /// No description provided for @planWeekEnded.
  ///
  /// In vi, this message translates to:
  /// **'Tuần của bạn đã kết thúc'**
  String get planWeekEnded;

  /// No description provided for @planBannerOk.
  ///
  /// In vi, this message translates to:
  /// **'Mọi ngày đều đạt protein và calo.'**
  String get planBannerOk;

  /// No description provided for @planShortfallProtein.
  ///
  /// In vi, this message translates to:
  /// **'{v1} thiếu {v2} g protein'**
  String planShortfallProtein(Object v1, Object v2);

  /// No description provided for @planShortfallKcalLow.
  ///
  /// In vi, this message translates to:
  /// **'{v1} thiếu {v2} kcal'**
  String planShortfallKcalLow(Object v1, Object v2);

  /// No description provided for @planShortfallKcalHigh.
  ///
  /// In vi, this message translates to:
  /// **'{v1} dư {v2} kcal'**
  String planShortfallKcalHigh(Object v1, Object v2);

  /// No description provided for @planShortfallMissingSlot.
  ///
  /// In vi, this message translates to:
  /// **'{count} bữa chưa có món'**
  String planShortfallMissingSlot(Object count);

  /// No description provided for @planBudgetOver.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí tuần vượt ngân sách {amount}'**
  String planBudgetOver(Object amount);

  /// No description provided for @planCookMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{minutes} phút'**
  String planCookMinutes(Object minutes);

  /// No description provided for @planDayTotals.
  ///
  /// In vi, this message translates to:
  /// **'{v1} g protein · {v2} kcal'**
  String planDayTotals(Object v1, Object v2);

  /// No description provided for @planCookOnceN.
  ///
  /// In vi, this message translates to:
  /// **'Nấu 1 lần cho {count} bữa'**
  String planCookOnceN(Object count);

  /// No description provided for @planSelf.
  ///
  /// In vi, this message translates to:
  /// **'Tôi tự lo'**
  String get planSelf;

  /// No description provided for @planUnfilled.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món cho bữa này'**
  String get planUnfilled;

  /// No description provided for @planDessertLine.
  ///
  /// In vi, this message translates to:
  /// **'Tráng miệng: {name}'**
  String planDessertLine(Object name);

  /// No description provided for @planDayToday.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get planDayToday;

  /// No description provided for @planGoSettings.
  ///
  /// In vi, this message translates to:
  /// **'Thiết lập lại'**
  String get planGoSettings;

  /// No description provided for @mealNotFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bữa này trong tuần của bạn.'**
  String get mealNotFound;

  /// No description provided for @mealContext.
  ///
  /// In vi, this message translates to:
  /// **'{v1} · {v2}'**
  String mealContext(Object v1, Object v2);

  /// No description provided for @mealMamTitle.
  ///
  /// In vi, this message translates to:
  /// **'Các món trong mâm'**
  String get mealMamTitle;

  /// No description provided for @mealExtrasTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào bữa'**
  String get mealExtrasTitle;

  /// No description provided for @mealOpenRecipe.
  ///
  /// In vi, this message translates to:
  /// **'Mở công thức'**
  String get mealOpenRecipe;

  /// No description provided for @recipeIngredientsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nguyên liệu'**
  String get recipeIngredientsTitle;

  /// No description provided for @recipeNotForMe.
  ///
  /// In vi, this message translates to:
  /// **'Không hợp với tôi'**
  String get recipeNotForMe;

  /// No description provided for @recipeBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Mình sẽ không chọn món này ở các tuần sau. Bạn có thể bỏ chặn ở tab Bạn.'**
  String get recipeBlocked;

  /// No description provided for @recipeStepToggle.
  ///
  /// In vi, this message translates to:
  /// **'Bước {v1}: {v2}'**
  String recipeStepToggle(Object v1, Object v2);

  /// No description provided for @recipeUnitApprox.
  ///
  /// In vi, this message translates to:
  /// **'≈ {v1} {v2}'**
  String recipeUnitApprox(Object v1, Object v2);

  /// No description provided for @recipeNoSteps.
  ///
  /// In vi, this message translates to:
  /// **'Món này chưa có hướng dẫn nấu.'**
  String get recipeNoSteps;

  /// No description provided for @calcFormula.
  ///
  /// In vi, this message translates to:
  /// **'{v1} g × {v2} kcal/100 g'**
  String calcFormula(Object v1, Object v2);

  /// No description provided for @calcSourceVn.
  ///
  /// In vi, this message translates to:
  /// **'Bảng TPDD VN 2007 · mã {code}'**
  String calcSourceVn(Object code);

  /// No description provided for @calcSourceFallback.
  ///
  /// In vi, this message translates to:
  /// **'{v1} · mã {v2}'**
  String calcSourceFallback(Object v1, Object v2);

  /// No description provided for @calcDessertRow.
  ///
  /// In vi, this message translates to:
  /// **'{name} (tráng miệng)'**
  String calcDessertRow(Object name);

  /// No description provided for @calcTotalNote.
  ///
  /// In vi, this message translates to:
  /// **'Tổng bằng đúng số trên chip ở màn bữa.'**
  String get calcTotalNote;

  /// No description provided for @calcExtrasHeading.
  ///
  /// In vi, this message translates to:
  /// **'Món thêm'**
  String get calcExtrasHeading;

  /// No description provided for @commonLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải…'**
  String get commonLoading;

  /// No description provided for @shopFoodCost.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí món ăn tuần này'**
  String get shopFoodCost;

  /// No description provided for @shopFoodCostHint.
  ///
  /// In vi, this message translates to:
  /// **'Phần nguyên liệu bạn thực sự dùng.'**
  String get shopFoodCostHint;

  /// No description provided for @shopTillCost.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính trả tại quầy'**
  String get shopTillCost;

  /// No description provided for @shopTillCostHint.
  ///
  /// In vi, this message translates to:
  /// **'Tính theo gói bán sẵn, gồm cả phần dư.'**
  String get shopTillCostHint;

  /// No description provided for @shopEstimateTag.
  ///
  /// In vi, this message translates to:
  /// **'ước tính'**
  String get shopEstimateTag;

  /// No description provided for @shopSurveyDate.
  ///
  /// In vi, this message translates to:
  /// **'Giá khảo sát ngày {date}'**
  String shopSurveyDate(Object date);

  /// No description provided for @shopBudgetLine.
  ///
  /// In vi, this message translates to:
  /// **'Ngân sách tuần {amount}'**
  String shopBudgetLine(Object amount);

  /// No description provided for @shopBudgetUnder.
  ///
  /// In vi, this message translates to:
  /// **'Còn trong ngân sách, dư {amount}'**
  String shopBudgetUnder(Object amount);

  /// No description provided for @shopBudgetOver.
  ///
  /// In vi, this message translates to:
  /// **'Vượt ngân sách {amount}'**
  String shopBudgetOver(Object amount);

  /// No description provided for @shopProgress.
  ///
  /// In vi, this message translates to:
  /// **'Đã mua {v1}/{v2} món'**
  String shopProgress(Object v1, Object v2);

  /// No description provided for @shopNeedG.
  ///
  /// In vi, this message translates to:
  /// **'Cần {grams} g'**
  String shopNeedG(Object grams);

  /// No description provided for @shopPantryToggle.
  ///
  /// In vi, this message translates to:
  /// **'Nhà có sẵn'**
  String get shopPantryToggle;

  /// No description provided for @shopPantryNeed.
  ///
  /// In vi, this message translates to:
  /// **'Cần mua'**
  String get shopPantryNeed;

  /// No description provided for @shopPantrySection.
  ///
  /// In vi, this message translates to:
  /// **'Nhà đã có sẵn ({count})'**
  String shopPantrySection(Object count);

  /// No description provided for @shopPantryNote.
  ///
  /// In vi, this message translates to:
  /// **'Món nhà có sẵn không tính vào chi phí.'**
  String get shopPantryNote;

  /// No description provided for @shopBoughtSemantics.
  ///
  /// In vi, this message translates to:
  /// **'Đã mua {name}'**
  String shopBoughtSemantics(Object name);

  /// No description provided for @shopShare.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ danh sách'**
  String get shopShare;

  /// No description provided for @shopShareTitle.
  ///
  /// In vi, this message translates to:
  /// **'Danh sách đi chợ {v1} – {v2}'**
  String shopShareTitle(Object v1, Object v2);

  /// No description provided for @shopShareTotal.
  ///
  /// In vi, this message translates to:
  /// **'Ước tính trả tại quầy: {amount}'**
  String shopShareTotal(Object amount);

  /// No description provided for @shopFallbackPrice.
  ///
  /// In vi, this message translates to:
  /// **'Giá chợ ước tính'**
  String get shopFallbackPrice;

  /// No description provided for @shopAllDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã mua đủ danh sách.'**
  String get shopAllDone;

  /// No description provided for @changeMealTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi bữa này'**
  String get changeMealTitle;

  /// No description provided for @changeSwapMeal.
  ///
  /// In vi, this message translates to:
  /// **'Đổi món này'**
  String get changeSwapMeal;

  /// No description provided for @changeEatOut.
  ///
  /// In vi, this message translates to:
  /// **'Ăn ngoài / bỏ bữa'**
  String get changeEatOut;

  /// No description provided for @changeSwapSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi món cho bữa này'**
  String get changeSwapSheetTitle;

  /// No description provided for @changeSwapHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ gợi ý món hợp với lựa chọn của bạn.'**
  String get changeSwapHint;

  /// No description provided for @changeSwapLoading.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm món thay thế…'**
  String get changeSwapLoading;

  /// No description provided for @changeSwapNoneKeep.
  ///
  /// In vi, this message translates to:
  /// **'Không có món nào giữ ngày này đạt chỉ tiêu. Đây là các món gần đạt nhất, bạn cân nhắc nhé.'**
  String get changeSwapNoneKeep;

  /// No description provided for @changeSwapEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có món thay thế phù hợp cho bữa này.'**
  String get changeSwapEmpty;

  /// No description provided for @changeKeepsDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày vẫn đạt'**
  String get changeKeepsDay;

  /// No description provided for @changeBreaksDay.
  ///
  /// In vi, this message translates to:
  /// **'Ngày sẽ không đạt'**
  String get changeBreaksDay;

  /// No description provided for @changePick.
  ///
  /// In vi, this message translates to:
  /// **'Chọn món này'**
  String get changePick;

  /// No description provided for @changeDeltaProtein.
  ///
  /// In vi, this message translates to:
  /// **'{delta} g protein'**
  String changeDeltaProtein(Object delta);

  /// No description provided for @changeDeltaKcal.
  ///
  /// In vi, this message translates to:
  /// **'{delta} kcal'**
  String changeDeltaKcal(Object delta);

  /// No description provided for @changeDeltaCost.
  ///
  /// In vi, this message translates to:
  /// **'{delta} ₫'**
  String changeDeltaCost(Object delta);

  /// No description provided for @changeSwapped.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi món'**
  String get changeSwapped;

  /// No description provided for @changeIngSwapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đổi nguyên liệu: {name}'**
  String changeIngSwapTitle(Object name);

  /// No description provided for @changeIngSwapHint.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiện nguyên liệu cùng nhóm, vẫn giữ protein của bữa trong khoảng ±5%.'**
  String get changeIngSwapHint;

  /// No description provided for @changeIngSwapEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Không có nguyên liệu thay thế phù hợp.'**
  String get changeIngSwapEmpty;

  /// No description provided for @changeIngSwapAction.
  ///
  /// In vi, this message translates to:
  /// **'Đổi nguyên liệu {name}'**
  String changeIngSwapAction(Object name);

  /// No description provided for @changeIngSwapped.
  ///
  /// In vi, this message translates to:
  /// **'Đã đổi nguyên liệu'**
  String get changeIngSwapped;

  /// No description provided for @changeIngNow.
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại: {name}'**
  String changeIngNow(Object name);

  /// No description provided for @changeOutSheetTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bữa này bạn…'**
  String get changeOutSheetTitle;

  /// No description provided for @changeOutEatHint.
  ///
  /// In vi, this message translates to:
  /// **'Mình bỏ bữa này khỏi tổng ngày và rút nguyên liệu khỏi danh sách đi chợ.'**
  String get changeOutEatHint;

  /// No description provided for @changeOutSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ bữa'**
  String get changeOutSkip;

  /// No description provided for @changeOutSkipHint.
  ///
  /// In vi, this message translates to:
  /// **'Giống ăn ngoài: ngày này không bị tính là không đạt.'**
  String get changeOutSkipHint;

  /// No description provided for @changeOutDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã đánh dấu bữa này'**
  String get changeOutDone;

  /// No description provided for @changeUndone.
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn tác'**
  String get changeUndone;

  /// No description provided for @changeBusy.
  ///
  /// In vi, this message translates to:
  /// **'Đang xử lý…'**
  String get changeBusy;

  /// No description provided for @changeFailed.
  ///
  /// In vi, this message translates to:
  /// **'Chưa thực hiện được. Bạn thử lại nhé.'**
  String get changeFailed;

  /// No description provided for @changeBlockTitle.
  ///
  /// In vi, this message translates to:
  /// **'Món này không hợp với bạn?'**
  String get changeBlockTitle;

  /// No description provided for @changeBlockBody.
  ///
  /// In vi, this message translates to:
  /// **'Mình sẽ không chọn món này nữa. Các ngày sau hôm nay được lên lại; ngày đã qua và hôm nay giữ nguyên.'**
  String get changeBlockBody;

  /// No description provided for @changeBlockAndReplan.
  ///
  /// In vi, this message translates to:
  /// **'Chặn và lên lại'**
  String get changeBlockAndReplan;

  /// No description provided for @changeBlockOnly.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ chặn, không lên lại'**
  String get changeBlockOnly;

  /// No description provided for @planSkipped.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ bữa'**
  String get planSkipped;

  /// No description provided for @planOutDay.
  ///
  /// In vi, this message translates to:
  /// **'Có bữa ngoài'**
  String get planOutDay;

  /// No description provided for @planReplanTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đã lên lại tuần'**
  String get planReplanTitle;

  /// No description provided for @planReplanButton.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại phần còn lại của tuần'**
  String get planReplanButton;

  /// No description provided for @planReplanConfirmTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại phần còn lại của tuần?'**
  String get planReplanConfirmTitle;

  /// No description provided for @planReplanConfirmBody.
  ///
  /// In vi, this message translates to:
  /// **'Các ngày đã qua và hôm nay giữ nguyên. Tuần hiện tại được lưu vào Tuần đã lưu.'**
  String get planReplanConfirmBody;

  /// No description provided for @planReplanConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại'**
  String get planReplanConfirm;

  /// No description provided for @planRelaxed.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này đã nới xu hướng nấu ăn để đạt chỉ tiêu.'**
  String get planRelaxed;

  /// No description provided for @profileEditSave.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get profileEditSave;

  /// No description provided for @profileEditSaved.
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu. Lựa chọn mới áp dụng cho tuần tạo kế tiếp.'**
  String get profileEditSaved;

  /// No description provided for @profileSectionChoices.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tiêu và lựa chọn'**
  String get profileSectionChoices;

  /// No description provided for @profileChoicesHint.
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi áp dụng cho tuần tạo kế tiếp. Tuần hiện tại giữ nguyên cho đến khi bạn lên lại.'**
  String get profileChoicesHint;

  /// No description provided for @profileDirtyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Có lựa chọn chưa áp dụng'**
  String get profileDirtyTitle;

  /// No description provided for @profileDirtyBody.
  ///
  /// In vi, this message translates to:
  /// **'Tuần hiện tại vẫn theo lựa chọn cũ. Bấm \"Lên lại tuần này\" để áp dụng.'**
  String get profileDirtyBody;

  /// No description provided for @profileReplanButton.
  ///
  /// In vi, this message translates to:
  /// **'Lên lại tuần này với lựa chọn mới'**
  String get profileReplanButton;

  /// No description provided for @profileNextWeekButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tuần mới với lựa chọn hiện tại'**
  String get profileNextWeekButton;

  /// No description provided for @profileNextWeekHint.
  ///
  /// In vi, this message translates to:
  /// **'Tuần hiện tại đã kết thúc.'**
  String get profileNextWeekHint;

  /// No description provided for @profileNextWeekDone.
  ///
  /// In vi, this message translates to:
  /// **'Đã tạo tuần mới'**
  String get profileNextWeekDone;

  /// No description provided for @profileRowBody.
  ///
  /// In vi, this message translates to:
  /// **'Cơ thể'**
  String get profileRowBody;

  /// No description provided for @profileRowActivity.
  ///
  /// In vi, this message translates to:
  /// **'Vận động'**
  String get profileRowActivity;

  /// No description provided for @profileRowTargets.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tiêu mỗi ngày'**
  String get profileRowTargets;

  /// No description provided for @profileRowStore.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng'**
  String get profileRowStore;

  /// No description provided for @profileRowHousehold.
  ///
  /// In vi, this message translates to:
  /// **'Người ăn'**
  String get profileRowHousehold;

  /// No description provided for @profileRowTaste.
  ///
  /// In vi, this message translates to:
  /// **'Khẩu vị món ăn'**
  String get profileRowTaste;

  /// No description provided for @profileBodyValue.
  ///
  /// In vi, this message translates to:
  /// **'{v1} · {v2} tuổi · {v3} cm · {v4} kg'**
  String profileBodyValue(Object v1, Object v2, Object v3, Object v4);

  /// No description provided for @profileTargetsValue.
  ///
  /// In vi, this message translates to:
  /// **'{v1} g protein · {v2} kcal'**
  String profileTargetsValue(Object v1, Object v2);

  /// No description provided for @profileTargetsManual.
  ///
  /// In vi, this message translates to:
  /// **'tự nhập'**
  String get profileTargetsManual;

  /// No description provided for @profileHouseholdValue.
  ///
  /// In vi, this message translates to:
  /// **'{v1} người lớn, {v2} trẻ em'**
  String profileHouseholdValue(Object v1, Object v2);

  /// No description provided for @profileTasteValue.
  ///
  /// In vi, this message translates to:
  /// **'Đã xem {count} món'**
  String profileTasteValue(Object count);

  /// No description provided for @profileSectionBlocked.
  ///
  /// In vi, this message translates to:
  /// **'Món đã chặn'**
  String get profileSectionBlocked;

  /// No description provided for @profileBlockedValue.
  ///
  /// In vi, this message translates to:
  /// **'{count} món'**
  String profileBlockedValue(Object count);

  /// No description provided for @profileBlockedHint.
  ///
  /// In vi, this message translates to:
  /// **'Món bị chặn sẽ không xuất hiện ở các tuần sau.'**
  String get profileBlockedHint;

  /// No description provided for @profileBlockedEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa chặn món nào.'**
  String get profileBlockedEmpty;

  /// No description provided for @profileUnblock.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chặn'**
  String get profileUnblock;

  /// No description provided for @profileUnblockLabel.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chặn {name}'**
  String profileUnblockLabel(Object name);

  /// No description provided for @profileUnblocked.
  ///
  /// In vi, this message translates to:
  /// **'Đã bỏ chặn {name}'**
  String profileUnblocked(Object name);

  /// No description provided for @profileSavedValue.
  ///
  /// In vi, this message translates to:
  /// **'{count} tuần'**
  String profileSavedValue(Object count);

  /// No description provided for @profileSavedWeek.
  ///
  /// In vi, this message translates to:
  /// **'Tuần {v1} – {v2}'**
  String profileSavedWeek(Object v1, Object v2);

  /// No description provided for @profileSavedAt.
  ///
  /// In vi, this message translates to:
  /// **'Lưu ngày {date}'**
  String profileSavedAt(Object date);

  /// No description provided for @profileSectionAbout.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get profileSectionAbout;

  /// No description provided for @profileDisclaimerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Miễn trừ y tế'**
  String get profileDisclaimerTitle;

  /// No description provided for @profilePricesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giá là ước tính'**
  String get profilePricesTitle;

  /// No description provided for @profilePrivacyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư'**
  String get profilePrivacyTitle;

  /// No description provided for @profileSourcesBody.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu dinh dưỡng lấy từ USDA FoodData Central (U.S. Department of Agriculture, Agricultural Research Service. FoodData Central, 2019. https://fdc.nal.usda.gov/). Dữ liệu thuộc miền công cộng theo CC0 1.0; chúng mình ghi nguồn theo đề nghị của USDA. Các mã FDC ID hiển thị ở \"Cách chúng mình tính\".\n\nMột số nguyên liệu dùng bản ghi gần đúng (proxy), ví dụ cá basa dùng số liệu cá da trơn, nước mắm chay dùng số liệu xì dầu. Các mục này được đánh dấu trong dữ liệu và sẽ được thay khi có nguồn đúng hơn.\n\nSố liệu là giá trị trên 100 g phần ăn được, có thể chênh lệch so với sản phẩm thực tế (giống, cách nấu, nhãn hàng). Các con số là ước tính để lập kế hoạch.\n\nGiá lấy từ khảo sát tại cửa hàng, ghi ngày khảo sát ở từng cửa hàng.'**
  String get profileSourcesBody;

  /// No description provided for @profilePricesBody.
  ///
  /// In vi, this message translates to:
  /// **'Giá hiển thị trong FitPro - Mâm đủ là ước tính tại thời điểm khảo sát (ghi ngày ở từng cửa hàng). Giá thực tế ở cửa hàng có thể khác do khuyến mãi, khu vực và thời điểm. Ứng dụng không kết nối với hệ thống bán hàng của cửa hàng và không đặt hàng thay bạn.\n\nChi phí \"Ước tính trả tại quầy\" làm tròn lên theo gói mua, không phải tổng tiền bạn sẽ trả.'**
  String get profilePricesBody;

  /// No description provided for @profilePrivacyBody.
  ///
  /// In vi, this message translates to:
  /// **'Thông tin cơ thể, lựa chọn ăn uống, thực đơn và danh sách đi chợ của bạn được lưu trên máy này. Ứng dụng không có tài khoản và không dùng công cụ phân tích hành vi.\n\nKhi tạo hoặc đổi thực đơn, thông tin cơ thể và lựa chọn của bạn được gửi tới máy chủ của ứng dụng chỉ để tính toán; máy chủ không lưu lại.\n\nBạn có thể xóa toàn bộ dữ liệu trên máy ở tab Bạn. Thao tác này không hoàn tác được.\n\nNếu sau này có tài khoản hoặc đồng bộ, chính sách này sẽ được cập nhật và bạn sẽ được hỏi lại trước khi có thay đổi.'**
  String get profilePrivacyBody;

  /// No description provided for @profileSectionData.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu của bạn'**
  String get profileSectionData;

  /// No description provided for @profileClearHint.
  ///
  /// In vi, this message translates to:
  /// **'Xóa thiết lập, thực đơn, danh sách đi chợ và tuần đã lưu khỏi máy này.'**
  String get profileClearHint;

  /// No description provided for @profileClearContinue.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get profileClearContinue;

  /// No description provided for @profileClearConfirm.
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả'**
  String get profileClearConfirm;

  /// No description provided for @shoppingBudgetFoodUnder.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí món ăn tuần này nằm trong ngân sách (dư {amount}).'**
  String shoppingBudgetFoodUnder(Object amount);

  /// No description provided for @shoppingBudgetFoodOver.
  ///
  /// In vi, this message translates to:
  /// **'Chi phí món ăn tuần này vượt ngân sách {amount}.'**
  String shoppingBudgetFoodOver(Object amount);

  /// No description provided for @shoppingBudgetTillInfo.
  ///
  /// In vi, this message translates to:
  /// **'Lần đi chợ này ước tính {amount}, cao hơn ngân sách vì mua nguyên gói; phần dư dùng tiếp cho tuần sau.'**
  String shoppingBudgetTillInfo(Object amount);

  /// No description provided for @shopPantryIfBuy.
  ///
  /// In vi, this message translates to:
  /// **'Nếu phải mua: +{amount} ₫'**
  String shopPantryIfBuy(Object amount);

  /// No description provided for @onboardingRiceTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen ăn cơm'**
  String get onboardingRiceTitle;

  /// No description provided for @onboardingRiceQuestion.
  ///
  /// In vi, this message translates to:
  /// **'Mỗi bữa trưa/tối bạn thường ăn mấy chén cơm?'**
  String get onboardingRiceQuestion;

  /// No description provided for @onboardingRiceNote.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ áp cho bạn. Người lớn khác ăn mức Vừa, trẻ em ăn 0,6 suất.'**
  String get onboardingRiceNote;

  /// No description provided for @onboardingRiceIt.
  ///
  /// In vi, this message translates to:
  /// **'½ chén (~75 g)'**
  String get onboardingRiceIt;

  /// No description provided for @onboardingRiceVua.
  ///
  /// In vi, this message translates to:
  /// **'1 chén (~150 g)'**
  String get onboardingRiceVua;

  /// No description provided for @onboardingRiceNhieu.
  ///
  /// In vi, this message translates to:
  /// **'2 chén (~300 g)'**
  String get onboardingRiceNhieu;

  /// No description provided for @onboardingRiceRatNhieu.
  ///
  /// In vi, this message translates to:
  /// **'3 chén trở lên (~450 g)'**
  String get onboardingRiceRatNhieu;

  /// No description provided for @onboardingRiceWarning.
  ///
  /// In vi, this message translates to:
  /// **'Với mức calo hiện tại, một số bữa sẽ phải bớt cơm. Bạn vẫn có thể giữ lựa chọn này.'**
  String get onboardingRiceWarning;

  /// No description provided for @mealRiceReduced.
  ///
  /// In vi, this message translates to:
  /// **'Bữa này cơm còn khoảng {v1} g (bạn chọn {v2} g) để vẫn đủ đạm trong mức {v3} kcal của bạn.'**
  String mealRiceReduced(Object v1, Object v2, Object v3);

  /// No description provided for @mealRiceCups.
  ///
  /// In vi, this message translates to:
  /// **'{v1} chén cơm (~{v2} g)'**
  String mealRiceCups(Object v1, Object v2);

  /// No description provided for @mealRiceReducedCups.
  ///
  /// In vi, this message translates to:
  /// **'Bữa này bớt còn {cups} chén cơm để giữ đúng calo.'**
  String mealRiceReducedCups(Object cups);

  /// No description provided for @mealRiceSummaryLowCarb.
  ///
  /// In vi, this message translates to:
  /// **'Ít tinh bột: mâm không có cơm'**
  String get mealRiceSummaryLowCarb;

  /// No description provided for @profileRiceHabitTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thói quen ăn cơm'**
  String get profileRiceHabitTitle;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'vi':
      return AppL10nVi();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
