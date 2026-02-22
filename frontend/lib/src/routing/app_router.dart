import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/src/features/auth/data/auth_repository.dart';
import 'package:frontend/src/features/auth/presentation/sign_in_screen.dart';
import 'package:frontend/src/features/auth/presentation/sign_up_screen.dart';
import 'package:frontend/src/features/home/presentation/home_screen.dart';
import 'package:frontend/src/features/listing/presentation/generate_listing_screen.dart';
import 'package:frontend/src/features/listing/presentation/loading_screen.dart';
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

      final publicRoutes = ['/signIn', '/signUp'];
      final isPublic = publicRoutes.contains(state.uri.path);

      if (!isLoggedIn && !isPublic) {
        return '/signIn';
      }

      if (isLoggedIn && isPublic) {
        return '/home';
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
      GoRoute(
        path: '/generateListing',
        builder: (context, state) => const GenerateListingScreen(),
      ),
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingScreen(),
      ),
    ],

    errorBuilder: (context, state) => const SignInScreen(),
  );
}
