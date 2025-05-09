import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class VideoPlayScreen extends StatefulWidget {
  const VideoPlayScreen({super.key, required this.index, required this.video});
  final int index;
  final Video video;

  @override
  State<VideoPlayScreen> createState() => _VideoPlayScreenState();
}

class _VideoPlayScreenState extends State<VideoPlayScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  double _currentPosition = 0.0;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    initializeVideoPlayer();

    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> initializeVideoPlayer() async {
    if (widget.video.isDownloaded && widget.video.localPath != null) {
      _controller = VideoPlayerController.file(File(widget.video.localPath!));
    } else {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.video.url));
    }

    await _controller.initialize();

    _controller.addListener(() {
      if (mounted) {
        setState(() {
          _currentPosition = _controller.value.position.inMilliseconds /
              _controller.value.duration.inMilliseconds;
        });
      }
    });

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$minutes:$seconds";
    } else {
      return "$minutes:$seconds";
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      Future.delayed(Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.video.title),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Center(
            child: _isInitialized
                ? GestureDetector(
                    onTap: _toggleControls,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: _controller.value.aspectRatio,
                          child: VideoPlayer(_controller),
                        ),
                        if (_showControls)
                          Positioned(
                            bottom: 0,
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.5)),
                            ),
                          ),
                        if (_showControls)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final newPosition =
                                      _controller.value.position -
                                          Duration(seconds: 10);
                                  _controller.seekTo(newPosition);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 50.0,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        : _controller.play();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  final newPosition =
                                      _controller.value.position +
                                          Duration(seconds: 10);
                                  _controller.seekTo(newPosition);
                                },
                              ),
                            ],
                          ),
                        if (_showControls)
                          Positioned(
                            bottom: 0,
                            left: 12,
                            right: 0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      _formatDuration(
                                          _controller.value.position),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: _currentPosition.isNaN
                                            ? 0.0
                                            : _currentPosition,
                                        onChanged: (value) {
                                          final newPosition = Duration(
                                            milliseconds: (value *
                                                    _controller.value.duration
                                                        .inMilliseconds)
                                                .round(),
                                          );
                                          _controller.seekTo(newPosition);
                                        },
                                        activeColor: Colors.red,
                                        inactiveColor: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(
                                          _controller.value.duration),
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.fullscreen,
                                          color: Colors.white),
                                      onPressed: () {
                                        // SystemChrome.setEnabledSystemUIMode(
                                        //     SystemUiMode.edgeToEdge);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(
                        top: MediaQuery.sizeOf(context).height * .05),
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
