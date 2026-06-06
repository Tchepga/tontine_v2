import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/models/loan.dart';
import '../../providers/models/loan_repayment.dart';
import 'middleware/interceptor_http.dart';
import 'dto/loan_dto.dart';
import 'dto/loan_repayment_dto.dart';
import 'member_service.dart';
import '../../services/websocket_service.dart';

class LoanService {
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';
  final _logger = Logger('LoanService');

  Future<List<Loan>> getLoans(int tontineId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/loan?tontineId=$tontineId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          // Injecter le tontineId depuis la requête si absent de la réponse
          map['tontineId'] ??= tontineId;
          return Loan.fromJson(map);
        }).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting loans: $e');
      return [];
    }
  }

  Future<Loan?> getLoan(int id) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/loan/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return Loan.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting loan: $e');
      return null;
    }
  }

  Future<void> createLoan(CreateLoanDto loanDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.post(
      Uri.parse('$urlApi/loan'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(loanDto.toJson()),
    );
    if (response.statusCode == 201) {
      final loanData = jsonDecode(response.body);
      
      // Émettre un événement WebSocket pour notifier les autres utilisateurs
      try {
        final wsService = WebSocketService();
        if (wsService.isConnected) {
          wsService.emit('loan.created', {
            'loanId': loanData['id'],
            'amount': loanDto.amount,
            'currency': loanDto.currency,
            'tontineId': loanDto.tontineId,
            'memberName': loanData['member']?['user']?['username'] ?? 'Un membre',
          });
        }
      } catch (e) {
        _logger.warning('Error emitting WebSocket event: $e');
      }
    } else {
      throw Exception('Failed to create loan');
    }
  }

  Future<void> updateLoan(int id, UpdateLoanDto loanDto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/loan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(loanDto.toJson()),
    );
    if (response.statusCode == 200) {
      final loanData = jsonDecode(response.body);
      
      // Émettre un événement WebSocket pour notifier les autres utilisateurs
      try {
        final wsService = WebSocketService();
        if (wsService.isConnected) {
          final status = loanData['status'] as String?;
          if (status == 'APPROVED') {
            wsService.emit('loan.approved', {
              'loanId': id,
              'amount': loanData['amount'],
              'currency': loanData['currency'],
            });
          } else if (status == 'REJECTED') {
            wsService.emit('loan.rejected', {
              'loanId': id,
              'amount': loanData['amount'],
              'currency': loanData['currency'],
              'reason': loanData['rejectionReason'],
            });
          }
        }
      } catch (e) {
        _logger.warning('Error emitting WebSocket event: $e');
      }
    } else {
      throw Exception('Failed to update loan');
    }
  }

  Future<void> deleteLoan(int id) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.delete(
      Uri.parse('$urlApi/loan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete loan');
    }
  }

  /// Vote pour un prêt.
  /// Le serveur identifie le votant via le JWT.
  Future<void> voteLoan(int loanId, {required int tontineId}) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/loan/$loanId/vote'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'tontine-id': '$tontineId',
      },
      body: jsonEncode({}),
    );
    if (response.statusCode != 200) {
      _throwFromBody(response.body, 'Failed to vote for loan');
    }
  }

  /// Approbation via PATCH /:id avec { status: 'APPROVED' }.
  Future<void> approveLoan(int loanId, {required int tontineId}) async {
    await _patchStatus(loanId, 'APPROVED', tontineId: tontineId);
  }

  /// Annulation via PATCH /:id avec { status: 'CANCELLED' }.
  Future<void> cancelLoan(int loanId, {required int tontineId}) async {
    await _patchStatus(loanId, 'CANCELLED', tontineId: tontineId);
  }

  /// Rejet via PATCH /:id avec { status: 'REJECTED', rejectionReason }.
  Future<void> rejectLoan(int loanId, String reason,
      {required int tontineId}) async {
    await _patchStatus(loanId, 'REJECTED',
        rejectionReason: reason, tontineId: tontineId);
  }

  /// Met à jour le statut d'un prêt via PATCH /:id.
  /// Envoie le header 'tontine-id' requis par le RolesGuard backend pour
  /// distinguer l'ID du prêt (params.id) de l'ID de la tontine.
  Future<void> _patchStatus(int loanId, String status,
      {String? rejectionReason, required int tontineId}) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    if (token == null || token.toString().trim().isEmpty) {
      _logger.severe(
          '_patchStatus: token absent dans storage — reconnexion requise');
      throw Exception('Session expirée. Veuillez vous reconnecter.');
    }

    final tokenStr = token.toString();
    _logger.info(
        '_patchStatus: token="${tokenStr.substring(0, tokenStr.length.clamp(0, 20))}..." tontineId=$tontineId');

    final body = <String, dynamic>{'status': status};
    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      body['rejectionReason'] = rejectionReason;
    }
    _logger.info('PATCH /loan/$loanId tontineId=$tontineId body=$body');

    final response = await client.patch(
      Uri.parse('$urlApi/loan/$loanId'),
      headers: {
        'Authorization': 'Bearer $tokenStr',
        'Content-Type': 'application/json',
        // Requis par RolesGuard : params.id = loan ID ≠ tontine ID
        'tontine-id': '$tontineId',
      },
      body: jsonEncode(body),
    );

    _logger.info(
        'PATCH /loan/$loanId → ${response.statusCode} body=${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');

    if (response.statusCode == 401) {
      throw Exception(
          'Session expirée ou token invalide. Veuillez vous reconnecter.');
    }
    if (response.statusCode == 403) {
      throw Exception(
          'Action non autorisée : vous n\'avez pas les droits pour modifier ce prêt.');
    }
    if (response.statusCode != 200) {
      _throwFromBody(
          response.body, 'Échec de la mise à jour du statut vers $status');
    }
  }

  void _throwFromBody(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        throw Exception(decoded['message'].toString());
      }
    } catch (e) {
      if (e is Exception) rethrow;
    }
    throw Exception(fallback);
  }

  /// Récupère tous les remboursements d'un prêt.
  Future<List<LoanRepayment>> getRepayments(int loanId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/loan/$loanId/repayments'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => LoanRepayment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting repayments: $e');
      return [];
    }
  }

  /// Enregistre un remboursement (principal + intérêts).
  Future<LoanRepayment> recordRepayment(
      int loanId, CreateLoanRepaymentDto dto) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.post(
      Uri.parse('$urlApi/loan/$loanId/repayments'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(dto.toJson()),
    );
    if (response.statusCode == 201) {
      return LoanRepayment.fromJson(jsonDecode(response.body));
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Failed to record repayment');
  }
}
