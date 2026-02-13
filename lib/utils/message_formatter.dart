import '../data/models/message.dart';
import '../data/models/participant.dart';

String formatConversationForDownload({
  required String title,
  required List<Message> messages,
  required List<Participant> participants,
}) {
  final buffer = StringBuffer();
  buffer.writeln('Conversation: $title');
  buffer.writeln('Participants: ${participants.map((p) => p.name).join(", ")}');
  buffer.writeln('=' * 50);
  buffer.writeln();

  for (final msg in messages) {
    if (msg.isAnnouncement) continue;
    final time = DateTime.fromMillisecondsSinceEpoch(msg.timestamp);
    final ts =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
    buffer.writeln('[$ts] ${msg.senderName}: ${msg.content}');
  }

  return buffer.toString();
}
