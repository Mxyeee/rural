import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:frontend/src/features/auth/presentation/sign_in_screen.dart';
import 'package:frontend/src/features/auth/presentation/sign_up_screen.dart';
import 'package:frontend/src/features/home/presentation/home_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authRepository = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/signIn',

    redirect: (context, state) {
      final isLoggedIn = authRepository.isAuthenticated;
      final isSignInRoute = state.uri.path == '/signIn';
      final isSignUpRoute = state.uri.path == '/signUp';
      final isHomeRoute = state.uri.path == '/home';

      if (isLoggedIn && (isSignInRoute || isSignUpRoute)) {
        return '/home';
      }

      if (!isLoggedIn && isHomeRoute) {
        return '/signIn';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],

    errorBuilder: (context, state) => const SignInScreen(),
  );
}
