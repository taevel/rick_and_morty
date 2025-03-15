import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/rick_morty_api.dart';
import '../../../core/database/favorites_database.dart';
import '../../../core/models/character.dart';
import 'characters_event.dart';
import 'characters_state.dart';

class CharactersBloc extends Bloc<CharactersEvent, CharactersState> {
  final RickMortyApi api;
  final FavoritesDatabase favoritesDb;
  int currentPage = 1;
  bool hasMorePages = true;

  CharactersBloc({required this.api, required this.favoritesDb})
      : super(CharactersInitial()) {
    on<LoadCharacters>(_onLoadCharacters);
    on<LoadMoreCharacters>(_onLoadMoreCharacters);
    on<ToggleFavorite>(_onToggleFavorite);
    on<UpdateCharacterFavoriteStatus>(_onUpdateCharacterFavoriteStatus);
  }

  Future<void> _onLoadCharacters(
    LoadCharacters event,
    Emitter<CharactersState> emit,
  ) async {
    try {
      emit(CharactersLoading());
      currentPage = 1;

      final result = await api.getCharacters(page: currentPage);
      final List<Character> characters = result['characters'];
      final info = result['info'];

      hasMorePages = info['next'] != null;

      // Update favorite status
      final List<Character> updatedCharacters =
          await _updateFavoriteStatus(characters);

      emit(CharactersLoaded(
          characters: updatedCharacters, hasMorePages: hasMorePages));
    } catch (e) {
      emit(CharactersError(message: e.toString()));
    }
  }

  Future<void> _onLoadMoreCharacters(
    LoadMoreCharacters event,
    Emitter<CharactersState> emit,
  ) async {
    try {
      if (!hasMorePages || state is CharactersLoadingMore) return;

      if (state is CharactersLoaded) {
        final currentState = state as CharactersLoaded;
        emit(CharactersLoadingMore(
          characters: currentState.characters,
          hasMorePages: currentState.hasMorePages,
        ));

        currentPage++;
        final result = await api.getCharacters(page: currentPage);
        final List<Character> newCharacters = result['characters'];
        final info = result['info'];

        hasMorePages = info['next'] != null;

        // Update favorite status for new characters
        final List<Character> updatedNewCharacters =
            await _updateFavoriteStatus(newCharacters);

        final List<Character> allCharacters = List.from(currentState.characters)
          ..addAll(updatedNewCharacters);

        emit(CharactersLoaded(
            characters: allCharacters, hasMorePages: hasMorePages));
      }
    } catch (e) {
      // Keep existing characters in case of error
      if (state is CharactersLoaded) {
        final currentState = state as CharactersLoaded;
        emit(CharactersLoaded(
          characters: currentState.characters,
          hasMorePages: currentState.hasMorePages,
          error: e.toString(),
        ));
      } else {
        emit(CharactersError(message: e.toString()));
      }
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<CharactersState> emit,
  ) async {
    if (state is CharactersLoaded) {
      final currentState = state as CharactersLoaded;
      final Character character = event.character;
      final int index =
          currentState.characters.indexWhere((c) => c.id == character.id);

      if (index != -1) {
        final List<Character> updatedCharacters =
            List.from(currentState.characters);
        final updatedCharacter = updatedCharacters[index].copyWith(
          isFavorite: !updatedCharacters[index].isFavorite,
        );
        updatedCharacters[index] = updatedCharacter;

        if (updatedCharacter.isFavorite) {
          await favoritesDb.addFavorite(updatedCharacter);
        } else {
          await favoritesDb.removeFavorite(updatedCharacter.id);
        }

        emit(CharactersLoaded(
          characters: updatedCharacters,
          hasMorePages: currentState.hasMorePages,
        ));
      }
    }
  }

  Future<void> _onUpdateCharacterFavoriteStatus(
    UpdateCharacterFavoriteStatus event,
    Emitter<CharactersState> emit,
  ) async {
    if (state is CharactersLoaded) {
      final currentState = state as CharactersLoaded;
      final List<Character> updatedCharacters =
          List.from(currentState.characters);

      for (int i = 0; i < updatedCharacters.length; i++) {
        final character = updatedCharacters[i];
        final isFavorite = await favoritesDb.isFavorite(character.id);
        if (character.isFavorite != isFavorite) {
          updatedCharacters[i] = character.copyWith(isFavorite: isFavorite);
        }
      }

      emit(CharactersLoaded(
        characters: updatedCharacters,
        hasMorePages: currentState.hasMorePages,
      ));
    }
  }

  Future<List<Character>> _updateFavoriteStatus(
      List<Character> characters) async {
    final List<Character> updatedCharacters = List.from(characters);

    for (int i = 0; i < updatedCharacters.length; i++) {
      final character = updatedCharacters[i];
      final isFavorite = await favoritesDb.isFavorite(character.id);
      updatedCharacters[i] = character.copyWith(isFavorite: isFavorite);
    }

    return updatedCharacters;
  }
}
