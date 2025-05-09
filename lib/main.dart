import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player_task/bloc/bloc/player_bloc_bloc.dart';

import 'screens/video_list.dart';

void main() {
  runApp(MultiBlocProvider(
      providers: [BlocProvider(create: (context) => PlayerBloc())],
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: VideoList(),
    );
  }
}
