import 'package:get_storage/get_storage.dart';
import '../screen/services/member_service.dart';

/// Service pour gérer le statut de lecture des notifications localement
/// Chaque utilisateur a son propre statut de lecture stocké en local
class LocalReadStatusService {
  final _storage = GetStorage();
  static const String _keyPrefix = 'read_notifications';

  /// Génère la clé de stockage unique pour un utilisateur et une tontine
  String _getStorageKey(int memberId, int tontineId) {
    return '${_keyPrefix}_${memberId}_$tontineId';
  }

  /// Récupère l'ID du membre connecté depuis le stockage
  Future<int?> _getCurrentMemberId() async {
    final userInfo = await _storage.read(MemberService.KEY_USER_INFO);
    if (userInfo != null && userInfo is Map<String, dynamic>) {
      return userInfo['id'] as int?;
    }
    return null;
  }

  /// Récupère la liste des IDs des notifications lues pour un utilisateur et une tontine
  Future<List<int>> getReadNotificationIds(int tontineId) async {
    final memberId = await _getCurrentMemberId();
    if (memberId == null) return [];

    final key = _getStorageKey(memberId, tontineId);
    final data = _storage.read<List<dynamic>>(key);
    if (data == null) return [];

    return data.map((e) => e as int).toList();
  }

  /// Vérifie si une notification est lue
  Future<bool> isRead(int notificationId, int tontineId) async {
    final readIds = await getReadNotificationIds(tontineId);
    return readIds.contains(notificationId);
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(int notificationId, int tontineId) async {
    final memberId = await _getCurrentMemberId();
    if (memberId == null) return;

    final key = _getStorageKey(memberId, tontineId);
    final readIds = await getReadNotificationIds(tontineId);

    if (!readIds.contains(notificationId)) {
      readIds.add(notificationId);
      await _storage.write(key, readIds);
    }
  }

  /// Marque plusieurs notifications comme lues
  Future<void> markAllAsRead(List<int> notificationIds, int tontineId) async {
    final memberId = await _getCurrentMemberId();
    if (memberId == null) return;

    final key = _getStorageKey(memberId, tontineId);
    final readIds = await getReadNotificationIds(tontineId);

    for (final id in notificationIds) {
      if (!readIds.contains(id)) {
        readIds.add(id);
      }
    }
    await _storage.write(key, readIds);
  }

  /// Nettoie les anciennes notifications lues (garde uniquement celles qui existent encore)
  Future<void> cleanupOldReadIds(
      List<int> existingNotificationIds, int tontineId) async {
    final memberId = await _getCurrentMemberId();
    if (memberId == null) return;

    final key = _getStorageKey(memberId, tontineId);
    final readIds = await getReadNotificationIds(tontineId);

    // Garder uniquement les IDs qui existent encore dans les notifications
    final cleanedIds =
        readIds.where((id) => existingNotificationIds.contains(id)).toList();
    await _storage.write(key, cleanedIds);
  }
}

