import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  bool _isAddingPhoto = false;
  int _heartBurstId = 0;

  String _text(BuildContext context, String en, String tr) {
    return Localizations.localeOf(context).languageCode == 'tr' ? tr : en;
  }

  Future<bool> _looksLikeCatPhoto(String sourcePath) async {
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.45),
    );

    try {
      final labels = await labeler.processImage(InputImage.fromFilePath(sourcePath));
      final values = labels.map((e) => e.label.toLowerCase()).toList();

      return values.any((label) =>
          label.contains('cat') ||
          label.contains('kitten') ||
          label.contains('pet') ||
          label.contains('animal') ||
          label.contains('mammal'));
    } catch (_) {
      return true;
    } finally {
      await labeler.close();
    }
  }

  Future<String> _copyImageToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final fileName = 'cat_${DateTime.now().millisecondsSinceEpoch}$extension';
    final savedPath = p.join(appDir.path, fileName);
    final savedImage = await File(sourcePath).copy(savedPath);
    return savedImage.path;
  }

  Future<String?> _adjustAndSaveImage(String sourcePath) async {
    final colorScheme = Theme.of(context).colorScheme;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: sourcePath,
      maxWidth: 1600,
      maxHeight: 1600,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Adjust Photo',
          toolbarColor: colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: colorScheme.primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: false,
          hideBottomControls: false,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Adjust Photo',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          resetButtonHidden: false,
          rotateButtonsHidden: false,
          aspectRatioPickerButtonHidden: false,
          aspectRatioLockEnabled: false,
          resetAspectRatioEnabled: true,
          aspectRatioPresets: const [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
      ],
    );

    if (croppedFile == null) return null;

    final isCat = await _looksLikeCatPhoto(croppedFile.path);
    if (!isCat) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              context,
              'No cat was detected in this photo. Please choose a cat photo.',
              'Bu fotoğrafta kedi algılanmadı. Lütfen kedi fotoğrafı seç.',
            ),
          ),
        ),
      );
      return null;
    }

    return _copyImageToAppDirectory(croppedFile.path);
  }

  Future<void> _showPhotoSourceSheet(CatEntry cat) async {
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.photoSource,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.takePhoto),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAndAddPhoto(ImageSource.camera, cat);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickAndAddPhoto(ImageSource.gallery, cat);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndAddPhoto(ImageSource source, CatEntry cat) async {
    final l10n = AppLocalizations.of(context);

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 95);
      if (file == null) return;
      if (!mounted) return;

      setState(() => _isAddingPhoto = true);

      final savedPath = await _adjustAndSaveImage(file.path);

      if (!mounted) return;

      if (savedPath != null) {
        await context.read<CatProvider>().addPhotoToCat(cat.id, savedPath);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _text(context, 'Photo added.', 'Fotoğraf eklendi.'),
            ),
          ),
        );
      }
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cameraError)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.cameraError)));
    } finally {
      if (mounted) setState(() => _isAddingPhoto = false);
    }
  }

  Future<void> _editNote(CatEntry cat) async {
    final controller = TextEditingController(text: cat.note);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_text(context, 'Edit Note', 'Notu Düzenle')),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: _text(context, 'Write a note...', 'Not yaz...'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(_text(context, 'Cancel', 'İptal')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
              child: Text(_text(context, 'Save', 'Kaydet')),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) return;

    await context.read<CatProvider>().updateNote(cat.id, result);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_text(context, 'Note updated.', 'Not güncellendi.'))),
    );
  }

  Future<void> _handleFeed(CatEntry cat) async {
    final l10n = AppLocalizations.of(context);

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
        setState(() => _showHearts = false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.fedToday)),
    );
  }

  Future<void> _shareCat(CatEntry cat) async {
    final l10n = AppLocalizations.of(context);

    final dateText = "${cat.lastSeen.day}.${cat.lastSeen.month}.${cat.lastSeen.year}";
    final noteText = cat.note.trim().isEmpty ? "" : "\n${l10n.note}: ${cat.note.trim()}";

    final text =
        "${cat.name}\n${l10n.place}: ${cat.place}\n${l10n.lastSeen}: $dateText$noteText\n\nMade with Winnie's Cat Diary";

    final validImages = cat.imagePaths
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .map((path) => XFile(path))
        .toList();

    if (validImages.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: validImages,
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(text: text),
      );
    }
  }

  Future<void> _confirmDelete(CatEntry cat) async {
    final l10n = AppLocalizations.of(context);

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

  Future<void> _confirmRemovePhoto(CatEntry cat, String imagePath) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(_text(context, 'Delete Photo', 'Fotoğrafı Sil')),
          content: Text(
            _text(
              context,
              'Remove this photo from the album?',
              'Bu fotoğraf albümden silinsin mi?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(_text(context, 'Cancel', 'İptal')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(_text(context, 'Delete', 'Sil')),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await context.read<CatProvider>().removePhotoFromCat(cat.id, imagePath);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_text(context, 'Photo deleted.', 'Fotoğraf silindi.'))),
    );
  }

  void _openPhotoViewer(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewerScreen(imagePath: imagePath),
      ),
    );
  }

  Widget _buildMainPhoto(CatEntry cat) {
    final imagePath = cat.imagePath;
    final hasImage = imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? GestureDetector(
                    onTap: () => _openPhotoViewer(imagePath),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  )
                : Container(
                    color: Colors.orange.shade100,
                    alignment: Alignment.center,
                    child: const Icon(Icons.pets, size: 52),
                  ),
            if (_showHearts) _HeartBurst(key: ValueKey(_heartBurstId)),
            if (_isAddingPhoto)
              Container(
                color: Colors.black.withValues(alpha: 0.18),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(CatEntry cat) {
    final validPaths = cat.imagePaths
        .where((path) => path.isNotEmpty && File(path).existsSync())
        .toList();

    if (validPaths.isEmpty) {
      return Text(
        _text(context, 'No photos yet.', 'Henüz fotoğraf yok.'),
        style: Theme.of(context).textTheme.bodyMedium,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: validPaths.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final path = validPaths[index];

        return GestureDetector(
          onTap: () => _openPhotoViewer(path),
          onLongPress: () => _confirmRemovePhoto(cat, path),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<CatProvider>();

    final cat = provider.cats.firstWhere(
      (e) => e.id == widget.catId,
      orElse: () => CatEntry(
        id: "",
        name: "",
        place: "",
        note: "",
        imagePaths: const [],
        lastSeen: DateTime.now(),
        fedToday: false,
        createdAt: DateTime.now(),
      ),
    );

    if (cat.id.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.catDetails)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.catDetails),
        actions: [
          IconButton(
            onPressed: () => _shareCat(cat),
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.share,
          ),
          IconButton(
            onPressed: () => _confirmDelete(cat),
            icon: const Icon(Icons.delete_outline),
            tooltip: l10n.delete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          _buildMainPhoto(cat),
          const SizedBox(height: 18),
          Text(
            cat.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text("${l10n.place}: ${cat.place}"),
          const SizedBox(height: 8),
          Text("${l10n.lastSeen}: ${cat.lastSeen.day}.${cat.lastSeen.month}.${cat.lastSeen.year}"),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.notes,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _editNote(cat),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(_text(context, 'Edit', 'Düzenle')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(cat.note.isEmpty ? "-" : cat.note),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _handleFeed(cat),
                  icon: const Icon(Icons.restaurant),
                  label: Text(l10n.feed),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await context.read<CatProvider>().markSeenToday(cat.id);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.markSeenToday)),
                    );
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text(l10n.markSeenToday),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _isAddingPhoto ? null : () => _showPhotoSourceSheet(cat),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_text(context, 'Add Photo to Album', 'Albüme Fotoğraf Ekle')),
          ),
          const SizedBox(height: 20),
          Text(
            _text(context, 'Album', 'Albüm'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              context,
              'Tap a photo to zoom. Long press to delete.',
              'Büyütmek için fotoğrafa dokun. Silmek için basılı tut.',
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          _buildPhotoGrid(cat),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(cat),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.deleteCat),
          ),
        ],
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final String imagePath;

  const _PhotoViewerScreen({
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.7,
          maxScale: 5,
          child: Image.file(File(imagePath)),
        ),
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
                style: TextStyle(fontSize: 22 + (index % 3) * 4),
              ),
            ),
          );
        }),
      ),
    );
  }
}
