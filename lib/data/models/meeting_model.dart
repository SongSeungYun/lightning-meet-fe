class Meeting {
  final int id;
  final String title;
  final String content;
  final String region;
  final String location;
  final String? keywords;
  final int maxParticipants;
  final int currentParticipants;
  final int hostId;
  final DateTime time;
  final DateTime createdAt;
  final DateTime updatedAt;

  Meeting({
    required this.id,
    required this.title,
    required this.content,
    required this.region,
    required this.location,
    this.keywords,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.hostId,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      region: json['region'],
      location: json['location'],
      keywords: json['keywords'],
      maxParticipants: json['maxParticipants'],
      currentParticipants: json['currentParticipants'],
      hostId: json['hostId'],
      time: DateTime.parse(json['time']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
