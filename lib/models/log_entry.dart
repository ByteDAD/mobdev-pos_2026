class LogEntry {
  const LogEntry({
    required this.id,
    required this.title,
    required this.detail,
    required this.user,
    required this.timestamp,
  });

  final int id;
  final String title;
  final String detail;
  final String user;
  final DateTime timestamp;
}
