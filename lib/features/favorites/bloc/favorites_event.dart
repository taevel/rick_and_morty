import 'package:equatable/equatable.dart';
import '../bloc/favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class RemoveFavorite extends FavoritesEvent {
  final int characterId;

  const RemoveFavorite(this.characterId);

  @override
  List<Object> get props => [characterId];
}

class SortFavorites extends FavoritesEvent {
  final SortOption sortOption;

  const SortFavorites(this.sortOption);

  @override
  List<Object> get props => [sortOption];
}
