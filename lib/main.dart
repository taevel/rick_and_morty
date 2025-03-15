import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rick_morty/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const RickAndMortyApp());
}
