import 'package:flutter/material.dart';

/// Style helper (kalau di project kamu sudah ada Tw, hapus class ini dan import dari file kamu)
class Tw {
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;

  static const Radius rXl = Radius.circular(16);

  static const Color card = Color(0xFF141414); // neutral-900
  static const Color card2 = Color(0xFF1C1C1C); // neutral-800
  static const Color border = Color(0xFF3A3A3A);
  static const Color text = Color(0xFFEFEFEF);
  static const Color muted = Color(0xFF9CA3AF);
  static const Color blue = Color(0xFF2563EB);
  static const Color blue2 = Color(0xFF3B82F6);
}

/// Breakpoint helper (kalau sudah ada di project, pakai yang itu)
bool isLg(BuildContext c) => MediaQuery.sizeOf(c).width >= 1024;

/// Data hasil modal (seperti FormData threadForm)
class CreateThreadPayload {
  final String content;
  final String tags;
  final String imageUrl;

  CreateThreadPayload({
    required this.content,
    required this.tags,
    required this.imageUrl,
  });
}

/// Fungsi untuk membuka modal.
/// - Desktop: showDialog
/// - Mobile: showModalBottomSheet
Future<CreateThreadPayload?> showCreateThreadModal(BuildContext context) async {
  if (isLg(context)) {
    return showDialog<CreateThreadPayload>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => const _CreateThreadDialog(),
    );
  }

  return showModalBottomSheet<CreateThreadPayload>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (_) => const _CreateThreadBottomSheet(),
  );
}

/// ===============
/// Dialog (desktop)
/// ===============
class _CreateThreadDialog extends StatefulWidget {
  const _CreateThreadDialog();

  @override
  State<_CreateThreadDialog> createState() => _CreateThreadDialogState();
}

class _CreateThreadDialogState extends State<_CreateThreadDialog> {
  final contentController = TextEditingController();
  final tagsController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void dispose() {
    contentController.dispose();
    tagsController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void _submit() {
    final content = contentController.text.trim();
    final tags = tagsController.text.trim();
    final imageUrl = imageController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Content is required")),
      );
      return;
    }

    Navigator.of(context).pop(
      CreateThreadPayload(content: content, tags: tags, imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(Tw.s4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          decoration: BoxDecoration(
            color: Tw.card,
            borderRadius: const BorderRadius.all(Tw.rXl),
            border: Border.all(color: Tw.border.withOpacity(0.85)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _Header(
                title: "📝  Create a Post",
                onClose: () => Navigator.of(context).pop(),
              ),

              // Body (scrollable)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Tw.s5),
                  child: Column(
                    children: [
                      _TwTextArea(
                        controller: contentController,
                        hint: "What’s happening?",
                        minLines: 4,
                      ),
                      const SizedBox(height: Tw.s4),
                      _TwTextField(
                        controller: tagsController,
                        hint: "Add tags, e.g. football,ai,tech",
                      ),
                      const SizedBox(height: Tw.s4),
                      _TwTextField(
                        controller: imageController,
                        hint: "Paste an image URL (optional)",
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              _Footer(
                onCancel: () => Navigator.of(context).pop(),
                onPublish: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// =================
/// BottomSheet (mobile)
/// =================
class _CreateThreadBottomSheet extends StatefulWidget {
  const _CreateThreadBottomSheet();

  @override
  State<_CreateThreadBottomSheet> createState() => _CreateThreadBottomSheetState();
}

class _CreateThreadBottomSheetState extends State<_CreateThreadBottomSheet> {
  final contentController = TextEditingController();
  final tagsController = TextEditingController();
  final imageController = TextEditingController();

  @override
  void dispose() {
    contentController.dispose();
    tagsController.dispose();
    imageController.dispose();
    super.dispose();
  }

  void _submit() {
    final content = contentController.text.trim();
    final tags = tagsController.text.trim();
    final imageUrl = imageController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Content is required")),
      );
      return;
    }

    Navigator.of(context).pop(
      CreateThreadPayload(content: content, tags: tags, imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: Tw.card,
          borderRadius: const BorderRadius.vertical(top: Tw.rXl),
          border: Border.all(color: Tw.border.withOpacity(0.85)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(
                title: "📝  Create a Post",
                onClose: () => Navigator.of(context).pop(),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(Tw.s5),
                  child: Column(
                    children: [
                      _TwTextArea(
                        controller: contentController,
                        hint: "What’s happening?",
                        minLines: 4,
                      ),
                      const SizedBox(height: Tw.s4),
                      _TwTextField(
                        controller: tagsController,
                        hint: "Add tags, e.g. football,ai,tech",
                      ),
                      const SizedBox(height: Tw.s4),
                      _TwTextField(
                        controller: imageController,
                        hint: "Paste an image URL (optional)",
                        keyboardType: TextInputType.url,
                      ),
                    ],
                  ),
                ),
              ),
              _Footer(
                onCancel: () => Navigator.of(context).pop(),
                onPublish: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============
/// Shared UI parts
/// ===============
class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _Header({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s5, vertical: Tw.s4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Tw.border.withOpacity(0.85))),
      ),
      child: Row(
        children: [
          Text(title, style: const TextStyle(color: Tw.text, fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: Tw.muted),
            splashRadius: 18,
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onPublish;

  const _Footer({required this.onCancel, required this.onPublish});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Tw.s5, vertical: Tw.s4),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Tw.border.withOpacity(0.85))),
      ),
      child: Row(
        children: [
          TextButton(
            onPressed: onCancel,
            child: const Text("Cancel", style: TextStyle(color: Tw.muted)),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: onPublish,
            style: ElevatedButton.styleFrom(
              backgroundColor: Tw.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text("Publish", style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _TwTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _TwTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Tw.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Tw.muted.withOpacity(0.8)),
        filled: true,
        fillColor: Tw.card2,
        contentPadding: const EdgeInsets.symmetric(horizontal: Tw.s4, vertical: Tw.s4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Tw.border.withOpacity(0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Tw.blue2, width: 1.6),
        ),
      ),
    );
  }
}

class _TwTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;

  const _TwTextArea({
    required this.controller,
    required this.hint,
    required this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: 8,
      style: const TextStyle(color: Tw.text, height: 1.35),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Tw.muted.withOpacity(0.8)),
        filled: true,
        fillColor: Tw.card2,
        contentPadding: const EdgeInsets.symmetric(horizontal: Tw.s4, vertical: Tw.s4),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Tw.border.withOpacity(0.9)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Tw.blue2, width: 1.6),
        ),
      ),
    );
  }
}
