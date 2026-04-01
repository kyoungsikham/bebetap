import 'dart:io';

import 'package:flutter/material.dart';

class BabyAvatarWidget extends StatelessWidget {
  const BabyAvatarWidget({
    super.key,
    this.photoUrl,
    this.localFile,
    this.gender,
    this.size = 72,
    this.showEditOverlay = false,
    this.onTap,
  });

  final String? photoUrl;
  final File? localFile;
  final String? gender;
  final double size;
  final bool showEditOverlay;
  final VoidCallback? onTap;

  Color get _bgColor {
    if (gender == 'male') return const Color(0xFFD6E4FF);
    return const Color(0xFFFFD6DA);
  }

  Color get _iconColor {
    if (gender == 'male') return const Color(0xFF6B8AFF);
    return const Color(0xFFFF6B8A);
  }

  Color get _shadowColor {
    if (gender == 'male') return const Color(0xFF6B8AFF);
    return const Color(0xFFFFB3BC);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgColor,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _shadowColor.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildContent(),
          ),
          if (showEditOverlay)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B8A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: size * 0.16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (localFile != null) {
      return Image.file(localFile!, fit: BoxFit.cover);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultIcon(),
      );
    }
    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return Icon(
      Icons.child_care,
      color: _iconColor,
      size: size * 0.5,
    );
  }
}
