class Meeting {
  final int id;
  final String title;
  final String content;
  final String region;
  final int maxParticipants;
  final int currentParticipants;
  final int hostId;
  final DateTime eventAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.title,
    required this.content,
    required this.region,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.hostId,
    required this.eventAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      region: json['region'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      hostId: json['hostId'],
      eventAt: DateTime.parse(json['eventAt']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
