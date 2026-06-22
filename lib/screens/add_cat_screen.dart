import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:winnie_the_cat/l10n/app_localizations.dart';
import 'package:winnie_the_cat/models/cat_entry.dart';
import 'package:winnie_the_cat/providers/cat_provider.dart';

class AddCatScreen extends StatefulWidget {
  const AddCatScreen({super.key});

  @override
  State<AddCatScreen> createState() => _AddCatScreenState();
}

class _AddCatScreenState extends State<AddCatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _placeController = TextEditingController();
  final _noteController = TextEditingController();

  String? _imagePath;

  @override
  void dispose() {
    _nameController.dispose();
    _placeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<String> _copyImageToAppDirectory(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extension =
        p.extension(sourcePath).isEmpty ? ".jpg" : p.extension(sourcePath);
    final fileName = "cat_${DateTime.now().millisecondsSinceEpoch}$extension";
    final savedPath = p.join(appDir.path, fileName);

    final savedImage = await File(sourcePath).copy(savedPath);
    return savedImage.path;
  }

  Future<void> _showPhotoSourceSheet() async {
    final l10n = AppLocalizations.of(context)!;

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
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (file == null) return;

      final savedPath = await _copyImageToAppDirectory(file.path);

      if (!mounted) return;

      setState(() {
        _imagePath = savedPath;
      });
    } on PlatformException {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cameraError)),
      );
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    final cat = CatEntry(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      place: _placeController.text.trim(),
      note: _noteController.text.trim(),
      imagePath: _imagePath,
      lastSeen: DateTime.now(),
      fedToday: false,
      createdAt: DateTime.now(),
    );

    await context.read<CatProvider>().addCat(cat);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.addedSuccessfully)),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCat),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _showPhotoSourceSheet,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _imagePath != null && File(_imagePath!).existsSync()
                        ? Image.file(
                            File(_imagePath!),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.orange.shade100,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo_outlined,
                                    size: 36),
                                const SizedBox(height: 8),
                                Text(l10n.pickPhoto),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: l10n.name),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _placeController,
                  decoration: InputDecoration(labelText: l10n.place),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.placeRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: l10n.note,
                    hintText: l10n.optional,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    child: Text(l10n.save),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
