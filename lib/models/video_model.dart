
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

 
}
