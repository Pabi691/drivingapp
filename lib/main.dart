
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'instructor_app/auth/auth_service.dart';
import 'instructor_app/auth/login_screen.dart';
import 'instructor_app/auth/welcome_screen.dart';
import 'instructor_app/auth/get_started_screen.dart';
import 'instructor_app/screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return MaterialApp.router(
            title: 'Driving School App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: _buildRouter(authService),
          );
        },
      ),
    );
  }

  GoRouter _buildRouter(AuthService authService) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/get-started',
          builder: (context, state) => const GetStartedScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final isAuthenticated = authService.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/' || state.matchedLocation == '/login' || state.matchedLocation == '/get-started';

        if (!isAuthenticated && !isLoggingIn) {
          return '/'; // Redirect to welcome screen if not authenticated
        }

        if (isAuthenticated && isLoggingIn) {
          return '/dashboard'; // Redirect to dashboard if authenticated and on a login screen
        }

        return null; // No redirect needed
      },
    );
  }
}
