/// Model for Video Lecture stored in Google Drive
class VideoLecture {
  final String? id;
  final String title;
  final String driveFileId;
  final String shareableLink;
  final double duration; // Duration in minutes
  final String? uploadedAt;

  VideoLecture({
    this.id,
    required this.title,
    required this.driveFileId,
    required this.shareableLink,
    this.duration = 0.0,
    this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'driveFileId': driveFileId,
    'shareableLink': shareableLink,
    'duration': duration,
    'uploadedAt': uploadedAt ?? DateTime.now().toIso8601String(),
  };

  factory VideoLecture.fromJson(Map<String, dynamic> json) => VideoLecture(
    id: json['id'],
    title: json['title'] ?? '',
    driveFileId: json['driveFileId'] ?? '',
    shareableLink: json['shareableLink'] ?? '',
    duration: (json['duration'] ?? 0).toDouble(),
    uploadedAt: json['uploadedAt'],
  );

  VideoLecture copyWith({
    String? id,
    String? title,
    String? driveFileId,
    String? shareableLink,
    double? duration,
    String? uploadedAt,
  }) {
    return VideoLecture(
      id: id ?? this.id,
      title: title ?? this.title,
      driveFileId: driveFileId ?? this.driveFileId,
      shareableLink: shareableLink ?? this.shareableLink,
      duration: duration ?? this.duration,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
