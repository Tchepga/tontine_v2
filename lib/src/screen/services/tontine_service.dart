import 'dart:convert';
import 'dart:io';
import 'package:get_storage/get_storage.dart';
import 'package:tontine_v2/src/screen/services/member_service.dart';
import '../../models/deposit.dart';
import '../../models/tontine.dart';
import '../../models/event.dart';
import '../../models/sanction.dart';
import '../../models/rapport_meeting.dart';
import 'dto/member_dto.dart';
import 'middleware/interceptor_http.dart';
import 'dto/tontine_dto.dart';
import 'dto/deposit_dto.dart';
import 'dto/rapport_dto.dart';
import 'dto/sanction_dto.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dto/event_dto.dart';
import 'package:path_provider/path_provider.dart';
class TontineService {
  static final _logger = Logger('TontineService');
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';

  // Tontine CRUD
  Future<List<Tontine>> getTontines() async {
    try {
      final memberData = await storage.read(MemberService.KEY_USER_INFO);
      final username = memberData?['user']['username'];
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client
          .get(Uri.parse('$urlApi/tontine/member/$username'), headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Tontine.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting tontines: $e');
      return [];
    }
  }

  Future<Tontine?> getTontine(int id) async {
    try {
      final response = await client.get(Uri.parse('$urlApi/tontine/$id'));
      if (response.statusCode == 200) {
        return Tontine.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting tontine: $e');
      return null;
    }
  }

  Future<Tontine> createTontine(CreateTontineDto tontineDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.post(
      Uri.parse('$urlApi/tontine'),
      body: jsonEncode(tontineDto.toJson()),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 201) {
      return Tontine.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create tontine');
  }

  Future<void> addMemberToTontine(
      int tontineId, CreateMemberDto memberDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final responseCreateMember = await client.post(
      Uri.parse('$urlApi/member'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'tontine-id': tontineId.toString(),
      },
      body: jsonEncode(memberDto.toJson()),
    );
    if (responseCreateMember.statusCode != 201) {
      throw Exception('Failed to add member to tontine during creation');
    }

    final memberId = jsonDecode(responseCreateMember.body)['id'];

    final responseAddMemberToTontine = await client.patch(
      Uri.parse('$urlApi/tontine/$tontineId/member'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'memberId': memberId}),
    );
    if (responseAddMemberToTontine.statusCode != 200) {
      throw Exception('Failed to add member to tontine');
    }
  }

  Future<Tontine> updateTontine(int id, CreateTontineDto tontineDto) async {
    final response = await client.patch(
      Uri.parse('$urlApi/tontine/$id'),
      body: jsonEncode(tontineDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update tontine');
    }
    return Tontine.fromJson(jsonDecode(response.body));
  }

  // Rapports
  Future<RapportMeeting?> createRapport(
      int tontineId,
      CreateMeetingRapportDto rapportDto) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final uri = Uri.parse('$urlApi/tontine/$tontineId/rapport');
      dynamic body = jsonEncode(rapportDto.toJson());

      if (rapportDto.attachment != null) {
        final encodedFile = base64Encode(rapportDto.attachment!);
        body = jsonEncode({
          'title': rapportDto.title,
          'content': rapportDto.content,
          'attachment': encodedFile,
          'attachmentFilename': rapportDto.attachmentFilename,
        });
      }

      final response = await client.post(uri,
          headers:  {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body);

      if (response.statusCode == 201) {
        return RapportMeeting.fromJson(jsonDecode(response.body));
      }else {
        _logger.severe('Error creating rapport: ${response.body}');
        return null;
      }
    } catch (e) {
      _logger.severe('Error creating rapport: $e');
      return null;
    }
  }

  Future<List<RapportMeeting>> getRapports(int tontineId) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client
        .get(Uri.parse('$urlApi/tontine/$tontineId/rapport'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RapportMeeting.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> updateRapport(
      int tontineId, CreateMeetingRapportDto rapportDto) async {
    final response = await client.patch(
      Uri.parse('$urlApi/tontine/$tontineId/rapport'),
      body: jsonEncode(rapportDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update rapport');
    }
  }

  // Sanctions
  Future<Sanction> createSanction(
      int tontineId, CreateSanctionDto sanctionDto) async {
    final response = await client.post(
      Uri.parse('$urlApi/tontine/$tontineId/sanction'),
      body: jsonEncode(sanctionDto.toJson()),
    );
    if (response.statusCode == 201) {
      return Sanction.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create sanction');
  }

  Future<List<Sanction>> getSanctions(int tontineId) async {
    final response =
        await client.get(Uri.parse('$urlApi/tontine/$tontineId/sanction'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Sanction.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> updateSanction(
      int tontineId, int sanctionId, CreateSanctionDto sanctionDto) async {
    final response = await client.patch(
      Uri.parse('$urlApi/tontine/$tontineId/sanction/$sanctionId'),
      body: jsonEncode(sanctionDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update sanction');
    }
  }

  // Events
  Future<Event> createEvent(int tontineId, CreateEventDto eventDto) async {
    final response = await client.post(
      Uri.parse('$urlApi/tontine/$tontineId/event'),
      body: jsonEncode(eventDto.toJson()),
    );
    if (response.statusCode == 201) {
      return Event.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to create event');
  }

  Future<List<Event>> getEvents(int tontineId) async {
    final response =
        await client.get(Uri.parse('$urlApi/tontine/$tontineId/event'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Event.fromJson(json)).toList();
    }
    return [];
  }

  Future<List<Deposit>> getDeposits(int tontineId) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client
        .get(Uri.parse('$urlApi/tontine/$tontineId/deposit'), headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Deposit.fromJson(json)).toList();
    }
    return [];
  }

  // Deposits
  Future<void> createDeposit(int tontineId, CreateDepositDto depositDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    try {
      final response = await client.post(
        Uri.parse('$urlApi/tontine/$tontineId/deposit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(depositDto.toJson()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to create deposit');
      }
    } catch (e) {
      _logger.severe('Error creating deposit: $e');
      throw Exception('Failed to create deposit');
    }
  }

  Future<void> updateDeposit(
      int tontineId, int depositId, CreateDepositDto depositDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/tontine/$tontineId/deposit/$depositId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(depositDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update deposit');
    }
  }

  Future<void> deleteDeposit(int tontineId, int depositId) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.delete(
      Uri.parse('$urlApi/tontine/$tontineId/deposit/$depositId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete deposit');
    }
  }

  Future<void> updateTontineConfig(
      int tontineId, CreateConfigTontineDto configDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/tontine/$tontineId/config'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(configDto.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update tontine config');
    }
  }

  Future<void> deleteRapport(int tontineId, int rapportId) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.delete(
      Uri.parse('$urlApi/tontine/$tontineId/rapport/$rapportId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete rapport');
    }
  }

  Future<File> downloadRapportAttachment(int tontineId, int rapportId) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.get(
      Uri.parse('$urlApi/tontine/$tontineId/rapport/$rapportId/attachment'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to download attachment');
    }

    try {
      // Récupérer le nom du fichier depuis les headers
      final disposition = response.headers['content-disposition'];
      final filename = disposition != null 
          ? disposition.split('filename=')[1].replaceAll('"', '')
          : 'downloaded_file';

      // Obtenir le répertoire de téléchargement
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$filename';

      // Écrire le fichier
      final file = File(filePath);
      file.writeAsBytes(response.bodyBytes);
      return file;
      
      // Ouvrir le fichier
      // await FileSaver.instance.saveFile(name: filename, bytes: response.bodyBytes);
    } catch (e) {
      _logger.severe('Error saving file: $e');
      rethrow;
    }
  }
}
