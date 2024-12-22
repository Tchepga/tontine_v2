import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class AppService {
  final _logger = Logger('AppService');
  final String baseUrl = '${dotenv.env['API_URL']}/api';

  Future<bool> checkServerAvailability() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health')).timeout(
        const Duration(seconds: 5),
      );
      _logger.info('Server availability check response: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      _logger.severe('Error checking server availability: $e');
      return false;
    }
  }
}
