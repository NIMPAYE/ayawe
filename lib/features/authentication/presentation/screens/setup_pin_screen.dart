import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/security_provider.dart';
import '../../../../core/theme/app_colors.dart';

class SetupPinScreen extends StatefulWidget {
  const SetupPinScreen({super.key});

  @override
  State<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends State<SetupPinScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _errorMessage;

  void _onNumberPressed(String number) {
    setState(() => _errorMessage = null);
    
    if (!_isConfirming) {
      if (_pin.length < 4) {
        setState(() => _pin += number);
        if (_pin.length == 4) {
          setState(() => _isConfirming = true);
        }
      }
    } else {
      if (_confirmPin.length < 4) {
        setState(() => _confirmPin += number);
        if (_confirmPin.length == 4) {
          _finalizeSetup();
        }
      }
    }
  }

  void _onDelete() {
    setState(() {
      if (_isConfirming) {
        if (_confirmPin.isEmpty) {
          _isConfirming = false;
          _pin = _pin.substring(0, _pin.length - 1);
        } else {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else if (_pin.isNotEmpty) {
        _pin = _pin.substring(0, _pin.length - 1);
      }
      _errorMessage = null;
    });
  }

  Future<void> _finalizeSetup() async {
    if (_pin == _confirmPin) {
      await context.read<SecurityProvider>().toggleSecurity(true, _pin);
      if (mounted) Navigator.pop(context);
    } else {
      setState(() {
        _confirmPin = '';
        _errorMessage = 'Les codes PIN ne correspondent pas. Réessayez.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurer le PIN'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              _isConfirming ? 'Confirmez votre PIN' : 'Choisissez un code PIN',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce code protégera l\'accès à vos données',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),

            // PIN Dots
            _buildPinDots(_isConfirming ? _confirmPin : _pin),

            if (_errorMessage != null) ...[
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 13),
                ),
              ),
            ],

            const Spacer(),
            _buildNumberPad(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots(String pinToDisplay) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < pinToDisplay.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled
                ? theme.colorScheme.primary
                : theme.colorScheme.primary.withAlpha(40),
            border: Border.all(
              color: isFilled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
            const SizedBox(width: 70), // Empty space
            _buildNumberButton('0'),
            SizedBox(
              width: 70,
              height: 70,
              child: IconButton(
                onPressed: _onDelete,
                icon: const Icon(Icons.backspace_outlined, size: 24),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return InkWell(
      onTap: () => _onNumberPressed(number),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withAlpha(50),
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
