part of 'player_bloc_bloc.dart';

@immutable
sealed class PlayerState {}

final class PlayerBlocInitial extends PlayerState {}

final class LoadVideoState extends PlayerState {
  final List<Video> videos;
  LoadVideoState({required this.videos});
}
