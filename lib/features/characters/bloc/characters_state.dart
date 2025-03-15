import 'package:equatable/equatable.dart';
import '../../../core/models/character.dart';

abstract class CharactersState extends Equatable {
  const CharactersState();

  @override
  List<Object> get props => [];
}

class CharactersInitial extends CharactersState {}

class CharactersLoading extends CharactersState {}

class CharactersLoaded extends CharactersState {
  final List<Character> characters;
  final bool hasMorePages;
  final String? error;

  const CharactersLoaded({
    required this.characters,
    required this.hasMorePages,
    this.error,
  });

  @override
  List<Object> get props => [characters, hasMorePages];
}

class CharactersLoadingMore extends CharactersLoaded {
  const CharactersLoadingMore({
    required super.characters,
    required super.hasMorePages,
    super.error,
  });
}

class CharactersError extends CharactersState {
  final String message;

  const CharactersError({required this.message});

  @override
  List<Object> get props => [message];
}
