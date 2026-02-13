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

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
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
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        getInitials(name),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
