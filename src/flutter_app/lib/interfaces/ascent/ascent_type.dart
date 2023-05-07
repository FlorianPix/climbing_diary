enum AscentType { onSight, flash, redPoint, tick, bail }

extension ToEmoji on AscentType {
  String toEmoji(){
    String emoji = "❓";
    switch (this) {
      case AscentType.onSight:
        emoji = "👁️";
        break;
      case AscentType.flash:
        emoji = "⚡";
        break;
      case AscentType.redPoint:
        emoji = "🔴";
        break;
      case AscentType.tick:
        emoji = "✔️";
        break;
      case AscentType.bail:
        emoji = "❌";
        break;
    }
    return emoji;
  }
}