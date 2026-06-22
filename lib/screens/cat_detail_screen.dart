import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:winnie_the_cat/l10n/app_localizations.dart';
import 'package:winnie_the_cat/models/cat_entry.dart';
import 'package:winnie_the_cat/providers/cat_provider.dart';

class CatDetailScreen extends StatefulWidget {
  final String catId;

  const CatDetailScreen({
    super.key,
    required this.catId,
  });

  @override
  State<CatDetailScreen> createState() => _CatDetailScreenState();
}

class _CatDetailScreenState extends State<CatDetailScreen> {
  bool _showHearts = false;
  int _heartBurstId = 0;

  Future<void> _handleFeed(BuildContext context, CatEntry cat) async {
    final l10n = AppLocalizations.of(context)!;

    await context.read<CatProvider>().feedCat(cat.id);

    if (!mounted) return;

    setState(() {
      _showHearts = true;
      _heartBurstId++;
    });

    final currentBurst = _heartBurstId;

    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      if (_heartBurstId == currentBurst) {
        setState(() {
          _showHearts = false;
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.fedToday)),
    );
  }

  Future<void> _shareCat(BuildContext context, CatEntry cat) async {
    final l10n = AppLocalizations.of(context)!;

    final dateText =
        "${cat.lastSeen.day}.${cat.lastSeen.month}.${cat.lastSeen.year}";

    final noteText =
        cat.note.trim().isEmpty ? "" : "\n${l10n.note}: ${cat.note.trim()}";

    final text =
        "${cat.name}\n${l10n.place}: ${cat.place}\n${l10n.lastSeen}: $dateText$noteText\n\nMade with Winnie The Cat";

    final hasImage = cat.imagePath != null &&
        cat.imagePath!.isNotEmpty &&
        File(cat.imagePath!).existsSync();

    if (hasImage) {
      await Share.shareXFiles(
        [XFile(cat.imagePath!)],
        text: text,
      );
    } else {
      await Share.share(text);
    }
  }

  Future<void> _confirmDelete(BuildContext context, CatEntry cat) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteCat),
          content: Text(l10n.deleteCatConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await context.read<CatProvider>().deleteCat(cat.id);

    if (!mounted) return;

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deletedSuccessfully)),
    );
  }

  Widget _buildPhoto(CatEntry cat) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 240,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            cat.imagePath != null && File(cat.imagePath!).existsSync()
                ? Image.file(
                    File(cat.imagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.orange.shade100,
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, size: 48),
                  ),
            if (_showHearts)
              _HeartBurst(
                key: ValueKey(_heartBurstId),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatProvider>();

    final cat = provider.cats.firstWhere(
      (e) => e.id == widget.catId,
      orElse: () => CatEntry(
        id: "",
        name: "",
        place: "",
        note: "",
        imagePath: null,
        lastSeen: DateTime.now(),
        fedToday: false,
        createdAt: DateTime.now(),
      ),
    );

    if (cat.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.catDetails)),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catDetails),
        actions: [
          IconButton(
            onPressed: () => _shareCat(context, cat),
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.share,
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, cat),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _buildPhoto(cat),
          const SizedBox(height: 20),
          Text(
            cat.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text("${l10n.place}: ${cat.place}"),
          const SizedBox(height: 8),
          Text(
            "${l10n.lastSeen}: ${cat.lastSeen.day}.${cat.lastSeen.month}.${cat.lastSeen.year}",
          ),
          const SizedBox(height: 8),
          Text("${l10n.notes}: ${cat.note.isEmpty ? "-" : cat.note}"),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _handleFeed(context, cat),
            icon: const Icon(Icons.restaurant),
            label: Text(l10n.feed),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await context.read<CatProvider>().markSeenToday(cat.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.markSeenToday)),
                );
              }
            },
            icon: const Icon(Icons.visibility),
            label: Text(l10n.markSeenToday),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, cat),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteCat),
          ),
        ],
      ),
    );
  }
}

class _HeartBurst extends StatelessWidget {
  const _HeartBurst({super.key});

  @override
  Widget build(BuildContext context) {
    const hearts = ["🧡", "🤍", "💛", "🧡", "🤍", "💛"];

    const alignments = [
      Alignment(-0.55, 0.15),
      Alignment(-0.25, -0.05),
      Alignment(0.05, 0.12),
      Alignment(0.35, -0.10),
      Alignment(0.58, 0.18),
      Alignment(-0.05, -0.35),
    ];

    return IgnorePointer(
      child: Stack(
        children: List.generate(hearts.length, (index) {
          return Align(
            alignment: alignments[index],
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 850 + (index * 80)),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: 1.0 - value,
                  child: Transform.translate(
                    offset: Offset(0, -70 * value),
                    child: Transform.scale(
                      scale: 0.8 + (0.35 * value),
                      child: child,
                    ),
                  ),
                );
              },
              child: Text(
                hearts[index],
                style: TextStyle(
                  fontSize: 22 + (index % 3) * 4,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
