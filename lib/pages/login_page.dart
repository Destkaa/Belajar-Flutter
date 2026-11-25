import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/api_exception.dart';
import '../services/auth_service.dart';
import 'home.dart'; // Dashboard (HomePages)
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _passFocus = FocusNode();
  final _auth = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;

  static const Color primaryBlue = Color(0xFF0758ED);
  static const Color inkColor = Color(0xFF151515);
  static const Color mutedColor = Color(0xFF6B7280);
  static const Color backgroundColor = Color(0xFFF0F2F6);
  static const Color errorColor = Color(0xFFD92D20);

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Logic
  // ---------------------------------------------------------------------------

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? errorColor : const Color(0xFF12B76A),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.login(
        email: _emailC.text.trim(),
        password: _passC.text,
      );

      if (!mounted) return;
      TextInput.finishAutofillContext();

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => const HomePages(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (_) {
      if (mounted) _showMessage('Terjadi kesalahan tak terduga');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        child: Stack(
          children: [
            // Latar gradasi lembut
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFEAF1FF),
                      Colors.white,
                      primaryBlue.withValues(alpha: 0.06),
                    ],
                  ),
                ),
              ),
            ),

            // Lingkaran solid di pojok kanan atas
            Positioned(
              top: -70,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue,
                      primaryBlue.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
            ),

            // Cincin putih di atas lingkaran
            Positioned(
              top: -90,
              right: -85,
              child: Container(
                width: 245,
                height: 245,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.55),
                    width: 14,
                  ),
                ),
              ),
            ),

            // Cincin tipis di kiri bawah
            Positioned(
              bottom: -95,
              left: -70,
              child: Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.35),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Teks
            Positioned(
              left: 26,
              bottom: 36,
              right: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Create better\ntogether.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.8,
                      color: inkColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Join our community',
                    style: TextStyle(
                      fontSize: 13,
                      color: mutedColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(fontSize: 13, color: mutedColor),
      floatingLabelStyle: const TextStyle(
        fontSize: 13,
        color: primaryBlue,
        fontWeight: FontWeight.w600,
      ),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFA0A6B1)),
      errorStyle: const TextStyle(fontSize: 11.5, color: errorColor),
      prefixIcon: Icon(icon, size: 20),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.error)) return errorColor;
        if (states.contains(WidgetState.focused)) return primaryBlue;
        return const Color(0xFF9AA1AD);
      }),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      enabledBorder: border(const Color(0xFFE5E7EB)),
      disabledBorder: border(const Color(0xFFE5E7EB)),
      focusedBorder: border(primaryBlue, 1.6),
      errorBorder: border(errorColor),
      focusedErrorBorder: border(errorColor, 1.6),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailC,
      enabled: !_loading,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: _validateEmail,
      onFieldSubmitted: (_) => _passFocus.requestFocus(),
      style: const TextStyle(fontSize: 14, color: inkColor),
      cursorColor: primaryBlue,
      decoration: _inputDecoration(
        label: 'Email',
        hint: 'nama@email.com',
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passC,
      focusNode: _passFocus,
      enabled: !_loading,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.password],
      validator: _validatePassword,
      onFieldSubmitted: (_) => _login(),
      style: const TextStyle(fontSize: 14, color: inkColor),
      cursorColor: primaryBlue,
      decoration: _inputDecoration(
        label: 'Password',
        hint: 'Masukkan password',
        icon: Icons.lock_outline,
        suffix: IconButton(
          tooltip: _obscurePassword ? 'Tampilkan password' : 'Sembunyikan password',
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          disabledBackgroundColor: primaryBlue.withValues(alpha: 0.7),
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _loading
              ? const SizedBox(
                  key: ValueKey('loading'),
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : const Text(
                  'Sign in',
                  key: ValueKey('label'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Center(
      child: TextButton(
        onPressed: _loading
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          splashFactory: NoSplash.splashFactory,
        ),
        child: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 13, color: mutedColor),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B2A4E).withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 14),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: inkColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Log in untuk melanjutkan',
                      style: TextStyle(fontSize: 13, color: mutedColor),
                    ),
                    const SizedBox(height: 22),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 10),
                    _buildRegisterLink(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              // Satu animasi masuk saat halaman dibuka
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) => Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, 24 * (1 - t)),
                    child: child,
                  ),
                ),
                child: _buildCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}