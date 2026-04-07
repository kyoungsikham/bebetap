import 'dart:io';

import 'package:flutter/material.dart';

class BabyAvatarWidget extends StatelessWidget {
  const BabyAvatarWidget({
    super.key,
    this.photoUrl,
    this.localFile,
    this.gender,
    this.colorIndex,
    this.size = 72,
    this.showEditOverlay = false,
    this.onTap,
  });

  final String? photoUrl;
  final File? localFile;
  final String? gender;
  final int? colorIndex;
  final double size;
  final bool showEditOverlay;
  final VoidCallback? onTap;

  // 아기별 고유 색상 팔레트 (bg, icon, shadow)
  static const _palette = [
    (Color(0xFFD6E4FF), Color(0xFF6B8AFF), Color(0xFF6B8AFF)), // Blue
    (Color(0xFFFFD6DA), Color(0xFFFF6B8A), Color(0xFFFFB3BC)), // Pink
    (Color(0xFFD6F5E0), Color(0xFF4DBF6A), Color(0xFF4DBF6A)), // Green
    (Color(0xFFE8D6FF), Color(0xFF9B6BFF), Color(0xFF9B6BFF)), // Purple
    (Color(0xFFFFE4D6), Color(0xFFFF8A6B), Color(0xFFFF8A6B)), // Orange
    (Color(0xFFD6F5F0), Color(0xFF4DBFB5), Color(0xFF4DBFB5)), // Teal
    (Color(0xFFFFF3D6), Color(0xFFE8A020), Color(0xFFE8A020)), // Yellow
    (Color(0xFFFFD6F5), Color(0xFFFF6BD0), Color(0xFFFF6BD0)), // Magenta
  ];

  Color get _bgColor {
    if (colorIndex != null) return _palette[colorIndex! % _palette.length].$1;
    if (gender == 'male') return const Color(0xFFD6E4FF);
    return const Color(0xFFFFD6DA);
  }

  Color get _iconColor {
    if (colorIndex != null) return _palette[colorIndex! % _palette.length].$2;
    if (gender == 'male') return const Color(0xFF6B8AFF);
    return const Color(0xFFFF6B8A);
  }

  Color get _shadowColor {
    if (colorIndex != null) return _palette[colorIndex! % _palette.length].$3;
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
      return ClipOval(
        child: Image.file(localFile!, fit: BoxFit.cover, width: size, height: size),
      );
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, _, _) => _defaultIcon(),
        ),
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
