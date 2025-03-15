import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/favorites_database.dart';
import '../../../core/models/character.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

enum SortOption { name, status, species }

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesDatabase favoritesDb;
  SortOption currentSortOption = SortOption.name;

  FavoritesBloc({required this.favoritesDb}) : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<RemoveFavorite>(_onRemoveFavorite);
    on<SortFavorites>(_onSortFavorites);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      emit(FavoritesLoading());
      final favorites = await favoritesDb.getFavorites();
      final sortedFavorites = _sortFavorites(favorites, currentSortOption);
      emit(FavoritesLoaded(
          favorites: sortedFavorites, sortOption: currentSortOption));
    } catch (e) {
      emit(FavoritesError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFavorite(
    RemoveFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;

        // Remove from database
        await favoritesDb.removeFavorite(event.characterId);

        // Update state
        final updatedFavorites = currentState.favorites
            .where((character) => character.id != event.characterId)
            .toList();

        emit(FavoritesLoaded(
          favorites: updatedFavorites,
          sortOption: currentState.sortOption,
        ));
      }
    } catch (e) {
      // Keep existing favorites in case of error
      if (state is FavoritesLoaded) {
        final currentState = state as FavoritesLoaded;
        emit(FavoritesLoaded(
          favorites: currentState.favorites,
          sortOption: currentState.sortOption,
          error: e.toString(),
        ));
      } else {
        emit(FavoritesError(message: e.toString()));
      }
    }
  }

  void _onSortFavorites(
    SortFavorites event,
    Emitter<FavoritesState> emit,
  ) {
    if (state is FavoritesLoaded) {
      final currentState = state as FavoritesLoaded;
      currentSortOption = event.sortOption;

      final sortedFavorites = _sortFavorites(
        currentState.favorites,
        currentSortOption,
      );

      emit(FavoritesLoaded(
        favorites: sortedFavorites,
        sortOption: currentSortOption,
      ));
    }
  }

  List<Character> _sortFavorites(
      List<Character> favorites, SortOption sortOption) {
    final List<Character> sortedList = List.from(favorites);

    switch (sortOption) {
      case SortOption.name:
        sortedList.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.status:
        sortedList.sort((a, b) => a.status.compareTo(b.status));
        break;
      case SortOption.species:
        sortedList.sort((a, b) => a.species.compareTo(b.species));
        break;
    }

    return sortedList;
  }
}
