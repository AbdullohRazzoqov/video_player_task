
class Video {
  final String id;
  final String url;
  final String title;
  String? localPath;
  bool isDownloaded = false;
  double downloadProgress = 0;
  int downloadedBytes;
  int totalBytes;
  bool isDownloading;

  Video({
    required this.id,
    required this.url,
    required this.title,
    this.localPath,
    this.isDownloaded = false,
    this.downloadProgress = 0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.isDownloading = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'localPath': localPath,
      'isDownloaded': isDownloaded,
      'downloadProgress': downloadProgress,
      'downloadedBytes': downloadedBytes,
      'totalBytes': totalBytes,
      'isDownloading': isDownloading,
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      title: '',
      id: json['id'],
      url: json['url'],
      localPath: json['localPath'],
      isDownloaded: json['isDownloaded'] ?? false,
      downloadProgress: json['downloadProgress'] ?? 0.0,
      downloadedBytes: json['downloadedBytes'] ?? 0,
      totalBytes: json['totalBytes'] ?? 0,
      isDownloading: json['isDownloading'] ?? false,
    );
  }
}
