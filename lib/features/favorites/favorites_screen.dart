import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/character.dart';
import '../characters/widgets/character_card.dart';
import 'bloc/favorites_bloc.dart';
import 'bloc/favorites_event.dart';
import 'bloc/favorites_state.dart';
import 'widgets/sort_dropdown.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FavoritesBloc>().add(LoadFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Characters'),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesInitial || state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritesLoaded) {
            return Column(
              children: [
                // Sort dropdown
                SortDropdown(
                  currentOption: state.sortOption,
                  onChanged: (option) {
                    context.read<FavoritesBloc>().add(SortFavorites(option));
                  },
                ),
                // Favorites list
                Expanded(
                  child: state.favorites.isEmpty
                      ? _buildEmptyState()
                      : _buildFavoritesList(state.favorites),
                ),
              ],
            );
          } else if (state is FavoritesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<FavoritesBloc>().add(LoadFavorites()),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No favorite characters yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              DefaultTabController.of(context).animateTo(0);
            },
            icon: const Icon(Icons.search),
            label: const Text('Browse Characters'),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<Character> favorites) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<FavoritesBloc>().add(LoadFavorites());
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          return CharacterCard(
            character: favorites[index],
            onFavoriteToggle: (character) {
              context.read<FavoritesBloc>().add(RemoveFavorite(character.id));
            },
            isInFavorites: true,
          );
        },
      ),
    );
  }
}
