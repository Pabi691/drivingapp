import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart'; 


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Login',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              _usernameController, 
              'Email',
              errorText: _emailError,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              _passwordController,
              'Password',
              obscureText: _obscureText,
              suffixIcon: _buildPasswordIcon(),
              errorText: _passwordError,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                if (_formKey.currentState!.validate()) {
                  _login();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot your password?',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _emailError = null;
      _passwordError = null;
    });

    try {
      await context.read<AuthProvider>().login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;

      context.go('/get-started');
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString().toLowerCase();
      setState(() {
        if (errorStr.contains('not found') || errorStr.contains('registered')) {
          _emailError = 'Instructor not found';
        } else if (errorStr.contains('password')) {
          _passwordError = 'Wrong password';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscureText = false,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your $label';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }

  Widget _buildPasswordIcon() {
    return IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        color: Colors.white70,
      ),
      onPressed: () {
        setState(() => _obscureText = !_obscureText);
      },
    );
  }
}
