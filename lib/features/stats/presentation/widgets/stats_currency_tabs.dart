import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../accounts/domain/entities/account.dart';

class StatsCurrencyTabs extends StatelessWidget {
  const StatsCurrencyTabs({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Currency selected;
  final ValueChanged<Currency> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget chip(Currency c, String label) {
      final isOn = selected == c;
      return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(c),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isOn
                    ? scheme.primary.withAlpha(theme.brightness == Brightness.dark ? 200 : 220)
                    : scheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOn ? scheme.primary : scheme.outline.withAlpha(100),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOn ? scheme.onPrimary : scheme.onSurface,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip(Currency.BIF, 'BIF'),
        const SizedBox(width: 10),
        chip(Currency.USD, 'USD'),
      ],
    );
  }
}
