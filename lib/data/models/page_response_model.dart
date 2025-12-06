class PageResponse<T> {
  final List<T> content;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalElements;
  final bool last;

  PageResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory PageResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return PageResponse<T>(
      content: (json['content'] as List).map(fromJsonT).toList(),
      pageNumber: json['number'],
      pageSize: json['size'],
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      last: json['last'],
    );
  }
}
