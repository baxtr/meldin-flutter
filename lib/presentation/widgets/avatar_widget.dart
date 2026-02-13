import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/avatar_utils.dart';

class AvatarWidget extends StatelessWidget {
  final String name;
  final bool isAgent;
  final double size;

  const AvatarWidget({
    super.key,
    required this.name,
    required this.isAgent,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final url = getAvatarUrl(name, isAgent);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? const Color(0xFF252830) : const Color(0xFFF3F4F6),
        border: isAgent
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: ClipOval(
        child: SvgPicture.network(
          url,
          width: size,
          height: size,
          placeholderBuilder: (_) => _fallback(context),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    final color = Color(getAvatarColor(name));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.36,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
