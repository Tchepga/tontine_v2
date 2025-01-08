class CreateMeetingRapportDto {
  final String title;
  final String content;
  final dynamic attachment;
  final String? attachmentFilename;

  CreateMeetingRapportDto({
    required this.title,
    required this.content,
    this.attachment,
    this.attachmentFilename,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (attachment != null) 'attachment': attachment,
      if (attachmentFilename != null) 'attachmentFilename': attachmentFilename,
    };
  }
} 