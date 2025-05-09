import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import '../../models/video_model.dart';
part 'player_bloc_event.dart';
part 'player_bloc_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc() : super(PlayerBlocInitial()) {
    List<Video> videos = [];

    on<LoadVideosEvent>((event, emit) async {
      List<Video> sampleVideos = [
        Video(
            id: '1',
            title: 'video 1',
            url:
                'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4'),
        Video(
            id: '2',
            title: 'video 2',
            url:
                'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8'),
        Video(
            id: '3',
            title: 'video 3',
            url:
                'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'),
      ];

      Directory appDir = await getApplicationDocumentsDirectory();
      final videoDir = Directory('${appDir.path}/videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

      for (var video in sampleVideos) {
        File videoFile = File('${videoDir.path}/${video.id}.mp4');
        if (await videoFile.exists()) {
          video.isDownloaded = true;
          video.localPath = videoFile.path;
        } else {
          File tempFile = File('${videoDir.path}/${video.id}.mp4.temp');
          if (await tempFile.exists()) {
            video.downloadProgress =
                await _calculateProgress(tempFile, video.url);
            video.isDownloaded = false;
            video.localPath = null;
          }
        }
      }

      videos = sampleVideos;
      emit(LoadVideoState(videos: videos));
    });

    on<DownloadEvent>((event, emit) async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final videoDir = Directory('${dir.path}/videos');
        if (!await videoDir.exists()) {
          await videoDir.create(recursive: true);
        }

        final tempPath = '${videoDir.path}/${videos[event.index].id}.mp4.temp';
        final finalPath = '${videoDir.path}/${videos[event.index].id}.mp4';
        final dio = Dio();

        File tempFile = File(tempPath);
        int startByte = 0;

        if (await tempFile.exists()) {
          startByte = await tempFile.length();
        }

        await dio.download(
          videos[event.index].url,
          tempPath,
          options: Options(
            headers: {
              if (startByte > 0) 'Range': 'bytes=$startByte-',
            },
          ),
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress =
                  ((received + startByte) / (total + startByte) * 100);
              videos[event.index].downloadProgress = progress;
              emit(LoadVideoState(videos: List.from(videos)));
            }
          },
        );

        await tempFile.rename(finalPath);

        videos[event.index].isDownloaded = true;
        videos[event.index].localPath = finalPath;
        emit(LoadVideoState(videos: List.from(videos)));
      } catch (e) {}
    });

    on<DeleteEvent>((event, emit) async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final videoDir = Directory('${dir.path}/videos');

        if (videos[event.index].localPath != null) {
          File file = File(videos[event.index].localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        File tempFile =
            File('${videoDir.path}/${videos[event.index].id}.mp4.temp');
        if (await tempFile.exists()) {
          await tempFile.delete();
        }

        videos[event.index].isDownloaded = false;
        videos[event.index].localPath = null;
        videos[event.index].downloadProgress = 0;
        emit(LoadVideoState(videos: List.from(videos)));
      } catch (e) {}
    });

    add(LoadVideosEvent());
  }

  Future<double> _calculateProgress(File tempFile, String url) async {
    try {
      final dio = Dio();
      Response response = await dio.head(url);
      int totalSize =
          int.parse(response.headers.value('content-length') ?? '0');
      if (totalSize > 0) {
        int downloadedSize = await tempFile.length();
        return (downloadedSize / totalSize * 100);
      }
    } catch (e) {
    }
    return 0.0;
  }
}
