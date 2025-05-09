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
      for (var video in sampleVideos) {
        File file = File('${appDir.path}/videos/${video.id}.mp4');
        if (await file.exists()) {
          video.isDownloaded = true;
          video.localPath = file.path;
        }
      }
      videos = sampleVideos;
      emit(LoadVideoState(videos: videos));
    });
    //

    on<DownloadEvent>((event, emit) async {
      try {
        final dir = await getApplicationDocumentsDirectory();
        final videoDir = Directory('${dir.path}/videos');

        if (!await videoDir.exists()) {
          await videoDir.create(recursive: true);
        }

        final savePath = '${videoDir.path}/${videos[event.index].id}.mp4';

        final dio = Dio();

        await dio.download(
          videos[event.index].url,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              double progress = (received / total * 100);

              videos[event.index].downloadProgress = progress;
              emit(LoadVideoState(videos: videos));
            }
          },
        );

        videos[event.index].isDownloaded = true;
        videos[event.index].localPath = savePath;
        emit(LoadVideoState(videos: videos));
      } catch (e) {
        //error
      }

      emit(LoadVideoState(videos: videos));
    });
    on<DeleteEvent>((event, emit) async {
      try {
        if (videos[event.index].localPath != null) {
          File file = File(videos[event.index].localPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        videos[event.index].isDownloaded = false;
        videos[event.index].localPath = null;
        videos[event.index].downloadProgress = 0;

        emit(LoadVideoState(videos: videos));
      } catch (e) {
        //error
      }
    });

    add(LoadVideosEvent());
  }
}
