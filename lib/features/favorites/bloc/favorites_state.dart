import 'package:equatable/equatable.dart';
import '../../../core/models/character.dart';
import '../bloc/favorites_bloc.dart';

abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object> get props => [];
}

class FavoritesInitial extends FavoritesState {}

class FavoritesLoading extends FavoritesState {}

class FavoritesLoaded extends FavoritesState {
  final List<Character> favorites;
  final SortOption sortOption;
  final String? error;

  const FavoritesLoaded({
    required this.favorites,
    required this.sortOption,
    this.error,
  });

  @override
  List<Object> get props => [favorites, sortOption];
}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});

  @override
  List<Object> get props => [message];
}
