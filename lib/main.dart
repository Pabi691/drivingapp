import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'instructor_app/auth/auth_provider.dart';
import 'instructor_app/auth/login_screen.dart';
import 'instructor_app/auth/welcome_screen.dart';
import 'instructor_app/auth/get_started_screen.dart';
import 'instructor_app/screens/dashboard_screen.dart';
import 'instructor_app/screens/profile_screen.dart';

import 'instructor_app/providers/pupil_provider.dart';
import 'instructor_app/providers/booking_provider.dart';
import 'instructor_app/providers/money_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PupilProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MoneyProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Driving School App',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            routerConfig: _router(authProvider),
          );
        },
      ),
    );
  }

  GoRouter _router(AuthProvider authProvider) {
    return GoRouter(
      refreshListenable: authProvider,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const WelcomeScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/get-started',
          builder: (context, state) => const GetStartedScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
       GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],

      /// 🔐 AUTH GUARD
      redirect: (context, state) {
        final loggedIn = authProvider.isAuthenticated;
        final loggingIn = state.matchedLocation == '/' ||
            state.matchedLocation == '/login' ||
            state.matchedLocation == '/get-started';

        if (!loggedIn && !loggingIn) {
          return '/';
        }

        if (loggedIn && loggingIn) {
          return '/dashboard';
        }

        return null;
      },
    );
  }
}
