String formatRelativeTime(Duration difference) {
  if (difference.inDays > 0) {
    return '${difference.inDays} day(s)';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} hour(s)';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} minute(s)';
  } else {
    return 'Just now';
  }
}
