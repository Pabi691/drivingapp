import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Password'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _isLoading ? null : () {
                  if (_formKey.currentState!.validate()) {
                    _login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                          'Login',
                          style: TextStyle(color: Colors.blue, fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: Colors.blue.shade700,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
