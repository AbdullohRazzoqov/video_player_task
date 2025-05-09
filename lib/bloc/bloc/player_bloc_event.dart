part of 'player_bloc_bloc.dart';

@immutable
sealed class PlayerEvent {}

final class LoadVideosEvent extends PlayerEvent {}

final class DownloadEvent extends PlayerEvent {
  final int index;
  DownloadEvent({required this.index});
}

final class DeleteEvent extends PlayerEvent {
  final int index;
  DeleteEvent({required this.index});
}
