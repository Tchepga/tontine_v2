import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:logging/logging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../providers/models/auction.dart';
import 'dto/auction_dto.dart';
import 'middleware/interceptor_http.dart';
import 'member_service.dart';

class AuctionService {
  static final _logger = Logger('AuctionService');
  final client = ApiClient.client;
  final storage = GetStorage();
  final String urlApi = '${dotenv.env['API_URL']}/api';

  // Récupérer toutes les enchères d'une tontine
  Future<List<Auction>> getAuctions(int tontineId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/tontine/$tontineId/auctions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Auction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting auctions: $e');
      return [];
    }
  }

  // Récupérer une enchère spécifique
  Future<Auction?> getAuction(int auctionId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/auction/$auctionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Auction.fromJson(data);
      }
      return null;
    } catch (e) {
      _logger.severe('Error getting auction: $e');
      return null;
    }
  }

  // Créer une nouvelle enchère
  Future<Auction?> createAuction(CreateAuctionDto auctionDto) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.post(
        Uri.parse('$urlApi/auction'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(auctionDto.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return Auction.fromJson(data);
      }
      return null;
    } catch (e) {
      _logger.severe('Error creating auction: $e');
      return null;
    }
  }

  // Mettre à jour une enchère
  Future<Auction?> updateAuction(
      int auctionId, UpdateAuctionDto auctionDto) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.put(
        Uri.parse('$urlApi/auction/$auctionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(auctionDto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Auction.fromJson(data);
      }
      return null;
    } catch (e) {
      _logger.severe('Error updating auction: $e');
      return null;
    }
  }

  // Supprimer une enchère
  Future<bool> deleteAuction(int auctionId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.delete(
        Uri.parse('$urlApi/auction/$auctionId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      _logger.severe('Error deleting auction: $e');
      return false;
    }
  }

  // Placer une enchère
  Future<bool> placeBid(CreateAuctionBidDto bidDto) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.post(
        Uri.parse('$urlApi/auction/bid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bidDto.toJson()),
      );

      return response.statusCode == 201;
    } catch (e) {
      _logger.severe('Error placing bid: $e');
      return false;
    }
  }

  // Terminer une enchère (déclarer le gagnant)
  Future<Auction?> completeAuction(int auctionId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.patch(
        Uri.parse('$urlApi/auction/$auctionId/complete'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Auction.fromJson(data);
      }
      return null;
    } catch (e) {
      _logger.severe('Error completing auction: $e');
      return null;
    }
  }

  // Annuler une enchère
  Future<Auction?> cancelAuction(int auctionId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.patch(
        Uri.parse('$urlApi/auction/$auctionId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Auction.fromJson(data);
      }
      return null;
    } catch (e) {
      _logger.severe('Error cancelling auction: $e');
      return null;
    }
  }

  // Récupérer les enchères actives d'une tontine
  Future<List<Auction>> getActiveAuctions(int tontineId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/tontine/$tontineId/auctions/active'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Auction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting active auctions: $e');
      return [];
    }
  }

  // Récupérer les enchères d'un membre
  Future<List<Auction>> getMemberAuctions(int memberId) async {
    try {
      final token = storage.read(MemberService.KEY_TOKEN);
      final response = await client.get(
        Uri.parse('$urlApi/member/$memberId/auctions'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Auction.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      _logger.severe('Error getting member auctions: $e');
      return [];
    }
  }
}
