import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

class ApiService {
  static const String scheduleApiUrl = 'https://gamez.quest/api/v1/schedule/all';

  static Future<List<MatchModel>> fetchSchedule() async {
    try {
      final response = await http
          .get(
            Uri.parse(scheduleApiUrl),
            headers: {
              'Accept': 'application/json',
              'User-Agent': 'SportsStreamApp/1.0.0 (Android; Mobile)',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        List<dynamic> list = [];

        if (decoded is Map<String, dynamic> && decoded.containsKey('value')) {
          list = decoded['value'] as List<dynamic>;
        } else if (decoded is List) {
          list = decoded;
        }

        final matches = list
            .map((item) => MatchModel.fromJson(item as Map<String, dynamic>))
            .where((m) => m.hasStream)
            .toList();

        return matches;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load sports schedule: $e');
    }
  }

  /// Extracts sorted unique list of sports from matches
  static List<String> extractSports(List<MatchModel> matches) {
    final sportsSet = <String>{};
    for (final match in matches) {
      if (match.sport.isNotEmpty) {
        sportsSet.add(match.sport.toUpperCase());
      }
    }
    final list = sportsSet.toList()..sort();
    return ['ALL', ...list];
  }
}