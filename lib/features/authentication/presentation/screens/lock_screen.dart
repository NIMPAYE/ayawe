import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../../../../core/theme/app_colors.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String? _errorMessage;

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    try {
      await context.read<SecurityProvider>().unlockWithPin(_pin);
    } catch (e) {
      setState(() {
        _pin = '';
        _errorMessage = 'PIN incorrect. Réessayez.';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SecurityProvider>();
      if (provider.isBiometricEnabled) {
        provider.unlockWithBiometrics();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Blur (Glassmorphism)
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: isDark 
                  ? AppColors.darkBackground.withAlpha(200) 
                  : AppColors.lightBackground.withAlpha(200),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.asset(
                      'assets/ayawe.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Ayawe sécurisé',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Entrez votre code PIN pour continuer',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 48),

                // PIN Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    bool isFilled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled
                              ? AppColors.primary
                              : theme.colorScheme.primary.withAlpha(100),
                          width: 2,
                        ),
                        boxShadow: isFilled ? [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 8,
                            spreadRadius: 2,
                          )
                        ] : null,
                      ),
                    );
                  }),
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.poppins(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Number Pad
                _buildNumberPad(context),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    final provider = context.watch<SecurityProvider>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var j = 1; j <= 3; j++)
                    _buildNumberButton((i * 3 + j).toString()),
                ],
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Biometric button
              SizedBox(
                width: 75,
                height: 75,
                child: provider.isBiometricEnabled
                    ? IconButton(
                        onPressed: () => provider.unlockWithBiometrics(),
                        icon: FaIcon(
                          FontAwesomeIcons.fingerprint,
                          color: AppColors.primary,
                          size: 32,
                        ),
                      )
                    : null,
              ),
              _buildNumberButton('0'),
              // Delete button
              SizedBox(
                width: 75,
                height: 75,
                child: IconButton(
                  onPressed: _onDelete,
                  icon: Icon(
                    Icons.backspace_rounded, 
                    size: 28,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark 
            ? Colors.white.withAlpha(15) 
            : Colors.black.withAlpha(5),
          border: Border.all(
            color: isDark 
              ? Colors.white.withAlpha(40) 
              : Colors.black.withAlpha(20),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

