import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character.dart';

class RickMortyApi {
  static const String baseUrl = 'https://rickandmortyapi.com/api';

  Future<Map<String, dynamic>> getCharacters({int page = 1}) async {
    final response =
        await http.get(Uri.parse('$baseUrl/character/?page=$page'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      final List<Character> characters =
          results.map((character) => Character.fromJson(character)).toList();

      return {
        'characters': characters,
        'info': data['info'],
      };
    } else {
      throw Exception('Failed to load characters');
    }
  }

  Future<Character> getCharacter(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/character/$id'));

    if (response.statusCode == 200) {
      return Character.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load character');
    }
  }
}
