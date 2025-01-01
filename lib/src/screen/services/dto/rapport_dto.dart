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
  }) : assert(title.length >= 2, 'Le titre doit avoir au moins 2 caractères'),
       assert(content.length >= 10, 'Le contenu doit avoir au moins 10 caractères');

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      if (attachment != null) 'attachment': attachment,
      if (attachmentFilename != null) 'attachmentFilename': attachmentFilename,
    };
  }
} 