String getAvatarUrl(String name, bool isAgent) {
  final seed = Uri.encodeComponent(name);
  if (isAgent) {
    const styles = ['bottts', 'avataaars', 'personas', 'lorelei', 'notionists'];
    final styleIndex =
        name.codeUnits.fold<int>(0, (acc, c) => acc + c) % styles.length;
    return 'https://api.dicebear.com/7.x/${styles[styleIndex]}/svg?seed=$seed';
  } else {
    return 'https://api.dicebear.com/7.x/initials/svg?seed=$seed';
  }
}

String getInitials(String name) {
  final parts = name.trim().split(' ');
  if (parts.length >= 2) {
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
  return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
}

const _avatarColors = [
  0xFF3B82F6, // blue
  0xFF8B5CF6, // purple
  0xFF22C55E, // green
  0xFFF97316, // orange
  0xFFEC4899, // pink
  0xFF6366F1, // indigo
  0xFF14B8A6, // teal
  0xFFEF4444, // red
];

int getAvatarColor(String name) {
  final index =
      name.codeUnits.fold<int>(0, (acc, c) => acc + c) % _avatarColors.length;
  return _avatarColors[index];
}
