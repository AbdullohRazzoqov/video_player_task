import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player_task/bloc/bloc/player_bloc_bloc.dart';

import 'video_play_screen.dart';

class VideoList extends StatefulWidget {
  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  bool isOnline = true;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isOnline = (result != ConnectivityResult.none);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Ilova'),
      ),
      body: BlocBuilder<PlayerBloc, PlayerState>(
        builder: (context, state) {
          if (state is LoadVideoState) {
            return ListView.builder(
              itemCount: state.videos.length,
              itemBuilder: (context, index) {
                final video = state.videos[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(video.title),
                        subtitle: Text(
                            video.isDownloaded ? 'Yuklab olingan' : 'Online'),
                        leading: Icon(Icons.video_library),
                        trailing: video.isDownloaded
                            ? IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  context
                                      .read<PlayerBloc>()
                                      .add(DeleteEvent(index: index));
                                },
                              )
                            : (isOnline
                                ? IconButton(
                                    icon: Icon(Icons.download),
                                    onPressed: () {
                                      context
                                          .read<PlayerBloc>()
                                          .add(DownloadEvent(index: index));
                                    },
                                  )
                                : null),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VideoPlayScreen(video: video, index: index),
                            ),
                          );
                        },
                      ),
                         if (video.downloadProgress > 0&&video.downloadProgress<100)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: (video.downloadProgress / 100),
                                backgroundColor: Colors.grey[400],
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${(video.downloadProgress).toStringAsFixed(1)}%',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return SizedBox();
        },
      ),
    );
  }
}
