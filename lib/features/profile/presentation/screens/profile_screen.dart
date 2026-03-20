import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        children: [
          // Avatar section
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: ext.balanceGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Utilisateur', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'ayawe@app.local',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: ext.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Settings section
          Text(
            'PARAMÈTRES',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: FontAwesomeIcons.moon,
            title: 'Mode sombre',
            trailing: Switch.adaptive(
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: theme.colorScheme.primary,
            ),
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.bell,
            title: 'Notifications',
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.language,
            title: 'Langue',
            subtitle: 'Français',
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.coins,
            title: 'Devise',
            subtitle: 'BIF',
            trailing: const Icon(Icons.chevron_right_rounded),
          ),

          const SizedBox(height: 24),
          Text(
            'DONNÉES',
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              color: ext.textTertiary,
            ),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: FontAwesomeIcons.fileExport,
            title: 'Exporter les données',
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          _SettingsTile(
            icon: FontAwesomeIcons.shieldHalved,
            title: 'Confidentialité',
            trailing: const Icon(Icons.chevron_right_rounded),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'Ayawe v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ext.textTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = context.appTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ext.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        subtitle: subtitle != null
            ? Text(subtitle!, style: theme.textTheme.bodySmall)
            : null,
        trailing: trailing,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
