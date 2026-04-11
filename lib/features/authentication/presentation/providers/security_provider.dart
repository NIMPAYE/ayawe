import 'package:flutter/material.dart';
import '../../../../core/services/security_service.dart';

class SecurityProvider extends ChangeNotifier with WidgetsBindingObserver {
  final SecurityService _securityService;

  bool _isLocked = false;
  bool _isSecurityEnabled = false;
  bool _isBiometricEnabled = false;
  bool _hasPin = false;

  SecurityProvider(this._securityService) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  bool get isLocked => _isLocked;
  bool get isSecurityEnabled => _isSecurityEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get hasPin => _hasPin;

  Future<void> _init() async {
    _hasPin = await _securityService.hasPin();
    _isBiometricEnabled = await _securityService.isBiometricsEnabled();
    _isSecurityEnabled = _hasPin;
    
    // Lock on app start if security is enabled
    if (_isSecurityEnabled) {
      _isLocked = true;
    }
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (_isSecurityEnabled) {
        _isLocked = true;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> unlockWithPin(String pin) async {
    final savedPin = await _securityService.getPin();
    if (savedPin == pin) {
      _isLocked = false;
      notifyListeners();
    } else {
      throw Exception('PIN incorrect');
    }
  }

  Future<void> unlockWithBiometrics() async {
    if (!_isBiometricEnabled) return;

    final authenticated = await _securityService.authenticateWithBiometrics(
      reason: 'Déverrouillez Ayawe pour accéder à vos finances',
    );

    if (authenticated) {
      _isLocked = false;
      notifyListeners();
    }
  }

  Future<void> toggleSecurity(bool enable, String? pin) async {
    if (enable && pin != null) {
      await _securityService.savePin(pin);
      _hasPin = true;
      _isSecurityEnabled = true;
    } else {
      await _securityService.deletePin();
      await _securityService.setBiometricsEnabled(false);
      _hasPin = false;
      _isSecurityEnabled = false;
      _isBiometricEnabled = false;
    }
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enable) async {
    await _securityService.setBiometricsEnabled(enable);
    _isBiometricEnabled = enable;
    notifyListeners();
  }
}
