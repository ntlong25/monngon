import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/debug/gallery_page.dart';
import 'features/meal/calc_page.dart';
import 'features/meal/meal_page.dart';
import 'features/meal/recipe_page.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/onboarding/onboarding_nav.dart';
import 'features/plan/plan_page.dart';
import 'features/profile/profile_page.dart';
import 'features/profile/profile_subpages.dart';
import 'features/shell/app_shell.dart';
import 'features/shopping/shopping_page.dart';
import 'state/providers.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const plan = '/plan';
  static const shopping = '/shopping';
  static const profile = '/profile';
  static const profileBlocked = '/profile-blocked';
  static const profileSaved = '/profile-saved';

  /// Sửa một bước onboarding từ tab Bạn: `/profile-edit/budget`.
  static String profileEdit(String step) => '/profile-edit/$step';

  /// Văn bản: `disclaimer | sources | prices | privacy`.
  static String profileInfo(String doc) => '/profile-info/$doc';

  /// Màn bữa/mâm: `/meal/2026-11-09/lunch`.
  static String meal(String date, String slot) => '/meal/$date/$slot';

  /// Công thức riêng của một món trong mâm.
  static String mealDish(String date, String slot, String recipeId) =>
      '/meal/$date/$slot/dish/${Uri.encodeComponent(recipeId)}';

  /// "Cách chúng mình tính".
  static String mealCalc(String date, String slot) => '/meal/$date/$slot/calc';

  /// Chỉ có ở bản debug.
  static const gallery = '/debug/gallery';
}

/// Chưa xong onboarding → luôn ở màn onboarding (mở lại app vẫn đúng bước); xong rồi thì không quay lại wizard.
String? onboardingRedirect({
  required bool completed,
  required String location,
}) {
  final inWizard = location == Routes.onboarding;
  if (!completed && !inWizard && location != Routes.gallery) {
    return Routes.onboarding;
  }
  if (completed && inWizard) return Routes.plan;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Báo cho GoRouter kiểm lại điều hướng khi trạng thái onboarding đổi.
  final refresh = ValueNotifier<int>(0);
  ref.listen(onboardingProvider.select((s) => s.completed), (_, _) {
    refresh.value++;
  });
  final router = GoRouter(
    initialLocation: Routes.plan,
    refreshListenable: refresh,
    redirect: (context, state) => onboardingRedirect(
      completed: ref.read(onboardingProvider).completed,
      location: state.uri.path,
    ),
    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.plan, builder: (_, _) => const PlanPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.shopping,
                builder: (_, _) => const ShoppingPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/profile-edit/:step',
        builder: (_, state) => ProfileEditPage(
          step: OnboardingStep.values.firstWhere(
            (s) => s.name == state.pathParameters['step'],
            orElse: () => OnboardingStep.goal,
          ),
        ),
      ),
      GoRoute(
        path: Routes.profileBlocked,
        builder: (_, _) => const BlockedPage(),
      ),
      GoRoute(
        path: Routes.profileSaved,
        builder: (_, _) => const SavedWeeksPage(),
      ),
      GoRoute(
        path: '/profile-info/:doc',
        builder: (_, state) =>
            InfoPage(doc: state.pathParameters['doc'] ?? 'disclaimer'),
      ),
      GoRoute(
        path: '/meal/:date/:slot',
        builder: (_, state) => MealPage(
          date: state.pathParameters['date']!,
          slot: state.pathParameters['slot']!,
        ),
        routes: [
          GoRoute(
            path: 'dish/:recipeId',
            builder: (_, state) => RecipePage(
              date: state.pathParameters['date']!,
              slot: state.pathParameters['slot']!,
              recipeId: state.pathParameters['recipeId']!,
            ),
          ),
          GoRoute(
            path: 'calc',
            builder: (_, state) => CalcPage(
              date: state.pathParameters['date']!,
              slot: state.pathParameters['slot']!,
            ),
          ),
        ],
      ),
      if (kDebugMode)
        GoRoute(path: Routes.gallery, builder: (_, _) => const GalleryPage()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
