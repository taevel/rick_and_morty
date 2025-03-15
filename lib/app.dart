import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'core/api/rick_morty_api.dart';
import 'core/database/favorites_database.dart';
import 'features/characters/bloc/characters_bloc.dart';
import 'features/favorites/bloc/favorites_bloc.dart';
import 'main_screen.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme provider
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        // API and Database
        Provider(create: (_) => RickMortyApi()),
        Provider(create: (_) => FavoritesDatabase.instance),

        // BLoCs
        BlocProvider(
          create: (context) => CharactersBloc(
            api: context.read<RickMortyApi>(),
            favoritesDb: context.read<FavoritesDatabase>(),
          ),
        ),
        BlocProvider(
          create: (context) => FavoritesBloc(
            favoritesDb: context.read<FavoritesDatabase>(),
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Rick and Morty',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}
