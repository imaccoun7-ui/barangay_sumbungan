import 'dart:io';

import 'package:flutter/material.dart';

/// Renders an image reference that may be either a local file path (offline
/// mode) or an HTTPS URL (Cloud Storage). Images returned by
/// [StorageService.upload] are URLs once the app is online.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.reference,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String reference;
  final double? width;
  final double? height;
  final BoxFit fit;

  bool get _isUrl =>
      reference.startsWith('http://') || reference.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (_isUrl) {
      return Image.network(
        reference,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (BuildContext context, Object error,
                StackTrace? stackTrace) =>
            const _ImagePlaceholder(message: 'Photo unavailable'),
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
      );
    }
    return Image.file(
      File(reference),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (BuildContext context, Object error,
              StackTrace? stackTrace) =>
          const _ImagePlaceholder(message: 'Photo unavailable'),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      child: Text(message, textAlign: TextAlign.center),
    );
  }
}
