import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPickerTile extends StatelessWidget {
  const PhotoPickerTile({
    super.key,
    required this.label,
    required this.subtitle,
    required this.imagePath,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onClear,
  });

  final String label;
  final String subtitle;
  final String? imagePath;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF64748B),
                ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              image: hasImage
                  ? DecorationImage(
                      image: FileImage(File(imagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: hasImage
                ? const SizedBox.shrink()
                : const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 56,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onPickFromCamera,
                icon: const Icon(Icons.photo_camera_outlined),
                label: const Text('Cámara'),
              ),
              OutlinedButton.icon(
                onPressed: onPickFromGallery,
                icon: const Icon(Icons.photo_library_outlined),
                label: const Text('Galería'),
              ),
              TextButton.icon(
                onPressed: hasImage ? onClear : null,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Quitar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
