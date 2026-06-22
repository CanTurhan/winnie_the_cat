import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winnie_the_cat/l10n/app_localizations.dart';
import 'package:winnie_the_cat/models/cat_entry.dart';
import 'package:winnie_the_cat/providers/cat_provider.dart';
import 'package:winnie_the_cat/screens/add_cat_screen.dart';
import 'package:winnie_the_cat/screens/cat_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<CatProvider>();
    final cats = provider.cats;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCatScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text(l10n.addCat),
      ),
      body: cats.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pets, size: 72),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noCatsYet,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.noCatsSubtitle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: cats.length,
              itemBuilder: (context, index) {
                final cat = cats[index];
                return _CatCard(cat: cat);
              },
            ),
    );
  }
}

class _CatCard extends StatelessWidget {
  final CatEntry cat;

  const _CatCard({required this.cat});

  bool get _hasValidImage {
    if (cat.imagePath == null || cat.imagePath!.isEmpty) return false;
    return File(cat.imagePath!).existsSync();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CatDetailScreen(catId: cat.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _hasValidImage
                    ? Image.file(
                        File(cat.imagePath!),
                        width: 84,
                        height: 84,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 84,
                        height: 84,
                        color: Colors.orange.shade100,
                        child: const Icon(Icons.pets, size: 32),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text("${l10n.place}: ${cat.place}"),
                    const SizedBox(height: 4),
                    Text(
                      "${l10n.lastSeen}: ${cat.lastSeen.day}.${cat.lastSeen.month}.${cat.lastSeen.year}",
                    ),
                    if (cat.fedToday) ...[
                      const SizedBox(height: 6),
                      Text(
                        l10n.fedToday,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
