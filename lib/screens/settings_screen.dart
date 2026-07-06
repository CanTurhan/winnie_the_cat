import 'package:flutter/material.dart';
import 'package:winnie_the_cat/l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  final Locale currentLocale;
  final void Function(Locale locale) onChangeLocale;

  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onChangeLocale,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedLanguage =
        currentLocale.languageCode == 'tr' ? l10n.turkish : l10n.english;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _LanguageCard(
            title: l10n.appLanguage,
            description: l10n.chooseLanguage,
            currentLanguageLabel: l10n.currentLanguage,
            selectedLanguage: selectedLanguage,
            selectedCode: currentLocale.languageCode,
            onChanged: (languageCode) {
              onChangeLocale(Locale(languageCode));
            },
            englishLabel: l10n.english,
            turkishLabel: l10n.turkish,
          ),
          const SizedBox(height: 14),
          _ExpandableInfoCard(
            icon: Icons.privacy_tip_outlined,
            title: l10n.privacyTitle,
            lines: [
              l10n.privacyDescription,
              l10n.photoPrivacy,
              l10n.manualPlacePrivacy,
            ],
          ),
          const SizedBox(height: 14),
          _ExpandableInfoCard(
            icon: Icons.pets,
            title: l10n.aboutTitle,
            lines: [
              l10n.aboutDescription,
              "${l10n.version}: 1.0.1",
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String title;
  final String description;
  final String currentLanguageLabel;
  final String selectedLanguage;
  final String selectedCode;
  final String englishLabel;
  final String turkishLabel;
  final void Function(String languageCode) onChanged;

  const _LanguageCard({
    required this.title,
    required this.description,
    required this.currentLanguageLabel,
    required this.selectedLanguage,
    required this.selectedCode,
    required this.englishLabel,
    required this.turkishLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.language),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ]),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 12),
            Text(
              "$currentLanguageLabel: $selectedLanguage",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                selected: {selectedCode},
                showSelectedIcon: false,
                onSelectionChanged: (values) {
                  if (values.isEmpty) return;
                  onChanged(values.first);
                },
                segments: [
                  ButtonSegment<String>(
                    value: 'en',
                    icon: const Icon(Icons.flag_outlined),
                    label: Text(englishLabel),
                  ),
                  ButtonSegment<String>(
                    value: 'tr',
                    icon: const Icon(Icons.flag),
                    label: Text(turkishLabel),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandableInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> lines;

  const _ExpandableInfoCard({
    required this.icon,
    required this.title,
    required this.lines,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: lines
            .map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(line),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
