import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../navigation/screens/main_navigation_screen.dart';

/// Palet warna terinspirasi estetika Jepang:
/// merah torii, krem washi paper, aksen hitam sumi-e.
class _JpColors {
  static const torii = Color(0xFFBC3B3B);
  static const toriiDark = Color(0xFF8C2A2A);
  static const washi = Color(0xFFFAF3E8);
  static const sumi = Color(0xFF2B2320);
  static const sumiMuted = Color(0xFF8A7B6E);
  static const sakura = Color(0xFFF2C9C9);
  static const gold = Color(0xFFC9A44C);
}

enum _AuthMode { login, register }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;
  String? _infoMessage;

  late final Stream<AuthState> _authStateStream;

  @override
  void initState() {
    super.initState();
    // Dengarkan perubahan status login (dipicu setelah redirect balik dari Google,
    // atau setelah login/register email berhasil).
    _authStateStream = Supabase.instance.client.auth.onAuthStateChange;
    // SESUDAH
    _authStateStream.listen((data) {
      final session = data.session;
      if (session != null && mounted) {
        final email = session.user.email ?? 'User';
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => MainNavigationScreen(username: email),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchMode(_AuthMode mode) {
    setState(() {
      _mode = mode;
      _errorMessage = null;
      _infoMessage = null;
    });
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_mode == _AuthMode.login) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        // Navigasi ditangani oleh listener onAuthStateChange.
      } else {
        final res = await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        if (!mounted) return;
        if (res.session == null) {
          // Project dengan email confirmation aktif: belum langsung login.
          setState(() {
            _infoMessage =
                'Akun dibuat. Cek email kamu untuk konfirmasi, lalu masuk.';
            _mode = _AuthMode.login;
          });
        }
        // Kalau res.session != null, listener onAuthStateChange akan navigasi otomatis.
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _infoMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.basjep://login-callback/',
      );
      // Setelah ini, browser akan terbuka. Navigasi ke Dashboard
      // ditangani otomatis oleh listener onAuthStateChange di initState.
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Gagal masuk dengan Google. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      backgroundColor: _JpColors.washi,
      body: SafeArea(
        child: Stack(
          children: [
            // Aksen lingkaran merah muda tipis di kanan atas.
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _JpColors.sakura.withOpacity(0.5),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Aksen "torii gate" sederhana dari garis.
                    Row(
                      children: [
                        Container(width: 28, height: 4, color: _JpColors.torii),
                        const SizedBox(width: 6),
                        Container(width: 4, height: 28, color: _JpColors.torii),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Text(
                      isLogin ? 'おかえりなさい' : 'はじめまして',
                      style: const TextStyle(
                        fontSize: 15,
                        color: _JpColors.gold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLogin ? 'Selamat Datang Kembali' : 'Buat Akun Baru',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _JpColors.sumi,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLogin
                          ? 'Masuk untuk melanjutkan belajar bahasa Jepang'
                          : 'Daftar untuk mulai belajar bahasa Jepang',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _JpColors.sumiMuted,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Toggle Login / Register
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _JpColors.sakura, width: 1.5),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ModeTab(
                              label: 'Masuk',
                              selected: isLogin,
                              onTap: () => _switchMode(_AuthMode.login),
                            ),
                          ),
                          Expanded(
                            child: _ModeTab(
                              label: 'Daftar',
                              selected: !isLogin,
                              onTap: () => _switchMode(_AuthMode.register),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: _JpColors.sumi),
                      decoration: _inputDecoration('Email', Icons.mail_outline),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        if (!value.contains('@')) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: isLogin
                          ? TextInputAction.done
                          : TextInputAction.next,
                      style: const TextStyle(color: _JpColors.sumi),
                      onFieldSubmitted: isLogin ? (_) => _handleSubmit() : null,
                      decoration:
                          _inputDecoration(
                            'Password',
                            Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _JpColors.sumiMuted,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (!isLogin && value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),

                    if (!isLogin) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirm,
                        textInputAction: TextInputAction.done,
                        style: const TextStyle(color: _JpColors.sumi),
                        onFieldSubmitted: (_) => _handleSubmit(),
                        decoration:
                            _inputDecoration(
                              'Konfirmasi Password',
                              Icons.lock_outline,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: _JpColors.sumiMuted,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                            ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: _JpColors.torii,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    if (_infoMessage != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _infoMessage!,
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _JpColors.torii,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                isLogin ? 'Masuk' : 'Daftar',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: _JpColors.sumiMuted.withOpacity(0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'atau',
                            style: TextStyle(
                              color: _JpColors.sumiMuted.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: _JpColors.sumiMuted.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _isGoogleLoading
                            ? null
                            : _handleGoogleSignIn,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: _JpColors.sumiMuted.withOpacity(0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _isGoogleLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/google_logo.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Lanjutkan dengan Google',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: _JpColors.sumi,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _JpColors.sumiMuted.withOpacity(0.7)),
      prefixIcon: Icon(icon, color: _JpColors.sumiMuted),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _JpColors.sumiMuted.withOpacity(0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: _JpColors.sumiMuted.withOpacity(0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _JpColors.torii, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _JpColors.torii),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _JpColors.torii : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _JpColors.sumiMuted,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
