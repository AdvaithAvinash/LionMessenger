import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/constants.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool showOnline;
  final bool isOnline;
  final Color? borderColor;
  final double borderWidth;

  const UserAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 44,
    this.showOnline = false,
    this.isOnline = false,
    this.borderColor,
    this.borderWidth = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: borderColor != null && borderWidth > 0
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _buildInitials(),
                    errorWidget: (_, __, ___) => _buildInitials(),
                  )
                : _buildInitials(),
          ),
        ),
        if (showOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: isOnline ? LionColors.online : LionColors.offline,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials(name);
    final color = _getAvatarColor(name);

    return Container(
      width: size,
      height: size,
      color: color,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF43E97B),
      const Color(0xFFFBBC04),
      const Color(0xFF4FC3F7),
      const Color(0xFFFF7043),
      const Color(0xFFAB47BC),
      const Color(0xFF26A69A),
    ];
    final index = name.isNotEmpty
        ? name.codeUnits.reduce((a, b) => a + b) % colors.length
        : 0;
    return colors[index];
  }
}

class GroupAvatar extends StatelessWidget {
  final List<String?> imageUrls;
  final List<String> names;
  final double size;

  const GroupAvatar({
    super.key,
    required this.imageUrls,
    required this.names,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final count = imageUrls.length.clamp(0, 4);
    if (count == 0) return const SizedBox.shrink();
    if (count == 1) {
      return UserAvatar(
        imageUrl: imageUrls[0],
        name: names.isNotEmpty ? names[0] : '',
        size: size,
      );
    }

    final halfSize = size * 0.65;
    final offset = size * 0.35;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: UserAvatar(
              imageUrl: imageUrls[0],
              name: names.isNotEmpty ? names[0] : '',
              size: halfSize,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: UserAvatar(
              imageUrl: imageUrls[1],
              name: names.length > 1 ? names[1] : '',
              size: halfSize,
            ),
          ),
        ],
      ),
    );
  }
}
