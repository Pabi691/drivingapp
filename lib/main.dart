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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = _buildRouter(_authProvider);
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _authProvider.checkAuth();
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => PupilProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => MoneyProvider()),
      ],
      child: MaterialApp.router(
        title: 'Driving School App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routerConfig: _router,
      ),
    );
  }

  GoRouter _buildRouter(AuthProvider authProvider) {
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
