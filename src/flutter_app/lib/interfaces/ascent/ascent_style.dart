enum AscentStyle { boulder, solo, lead, second, topRope, aid }

extension ToEmoji on AscentStyle {
  String toEmoji() {
    String emoji = "❓";
    switch (this) {
      case AscentStyle.boulder: emoji = "🪨"; break;
      case AscentStyle.solo: emoji = "🔥"; break;
      case AscentStyle.lead: emoji = "🥇"; break;
      case AscentStyle.second: emoji = "🥈"; break;
      case AscentStyle.topRope: emoji = "🥉"; break;
      case AscentStyle.aid: emoji = "🩹"; break;
    }
    return emoji;
  }
}