import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/loan.dart';
import 'middleware/interceptor_http.dart';
import 'dto/loan_dto.dart';
import 'member_service.dart';

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
        return data.map((json) => Loan.fromJson(json)).toList();
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
    if (response.statusCode != 201) {
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
    if (response.statusCode != 200) {
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

  Future<void> voteLoan(int id) async {
    final token = storage.read(MemberService.KEY_TOKEN);
    final response = await client.patch(
      Uri.parse('$urlApi/loan/$id/vote'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to vote for loan');
    }
  }
} 