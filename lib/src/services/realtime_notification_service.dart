import 'package:logging/logging.dart';
import 'local_notification_service.dart';
import 'websocket_service.dart';

/// Service pour gérer les notifications en temps réel via WebSocket
class RealtimeNotificationService {
  static final RealtimeNotificationService _instance =
      RealtimeNotificationService._internal();
  final _logger = Logger('RealtimeNotificationService');
  final _webSocketService = WebSocketService();
  final _localNotificationService = LocalNotificationService();
  bool _isInitialized = false;

  factory RealtimeNotificationService() {
    return _instance;
  }

  RealtimeNotificationService._internal();

  /// Initialiser le service de notifications en temps réel
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Se connecter au WebSocket
      await _webSocketService.connect();

      // S'abonner aux événements de notifications
      _setupEventListeners();

      _isInitialized = true;
      _logger.info('RealtimeNotificationService initialized');
    } catch (e) {
      _logger.severe('Error initializing RealtimeNotificationService: $e');
    }
  }

  /// Configurer les écouteurs d'événements
  void _setupEventListeners() {
    // Événement créé
    _webSocketService.on('event.created', (event, data) {
      _handleEventCreated(data);
    });

    // Versement créé
    _webSocketService.on('deposit.created', (event, data) {
      _handleDepositCreated(data);
    });

    // Versement validé
    _webSocketService.on('deposit.validated', (event, data) {
      _handleDepositValidated(data);
    });

    // Demande de prêt créée
    _webSocketService.on('loan.created', (event, data) {
      _handleLoanCreated(data);
    });

    // Prêt approuvé
    _webSocketService.on('loan.approved', (event, data) {
      _handleLoanApproved(data);
    });

    // Prêt rejeté
    _webSocketService.on('loan.rejected', (event, data) {
      _handleLoanRejected(data);
    });

    // Membre ajouté
    _webSocketService.on('member.added', (event, data) {
      _handleMemberAdded(data);
    });

    // Rapport créé
    _webSocketService.on('rapport.created', (event, data) {
      _handleRapportCreated(data);
    });

    // Sanction créée
    _webSocketService.on('sanction.created', (event, data) {
      _handleSanctionCreated(data);
    });

    // Part ajoutée
    _webSocketService.on('part.added', (event, data) {
      _handlePartAdded(data);
    });

    // Rappel : versements manquants (fin de mois)
    _webSocketService.on('reminder.missing_deposits', (event, data) {
      _handleMissingDepositsReminder(data);
    });
  }

  /// Gérer la création d'un événement
  void _handleEventCreated(Map<String, dynamic> data) {
    try {
      final title = data['title'] as String? ?? 'Nouvel événement';
      final tontineName = data['tontineName'] as String? ?? '';

      _localNotificationService.showNotification(
        title: 'Nouvel événement',
        body: '$title${tontineName.isNotEmpty ? ' - $tontineName' : ''}',
        payload: '/event',
      );
      _logger.info('Notification sent for event created: $title');
    } catch (e) {
      _logger.severe('Error handling event created: $e');
    }
  }

  /// Gérer la création d'un versement
  void _handleDepositCreated(Map<String, dynamic> data) {
    try {
      final amount = data['amount'] as num? ?? 0;
      final currency = data['currency'] as String? ?? '';
      final memberName = data['memberName'] as String? ?? 'Un membre';
      final tontineName = data['tontineName'] as String?;

      final body = '$memberName a effectué un versement de $amount $currency';
      final summary = tontineName != null ? 'Tontine: $tontineName' : null;

      _localNotificationService.showBigTextNotification(
        title: 'Nouveau versement',
        body: body,
        summary: summary,
        payload: '/cashflow',
      );
      _logger.info('Notification sent for deposit created');
    } catch (e) {
      _logger.severe('Error handling deposit created: $e');
    }
  }

  /// Gérer la validation d'un versement
  void _handleDepositValidated(Map<String, dynamic> data) {
    try {
      final amount = data['amount'] as num? ?? 0;
      final currency = data['currency'] as String? ?? '';

      _localNotificationService.showNotification(
        title: 'Versement validé',
        body: 'Votre versement de $amount $currency a été validé',
        payload: '/cashflow',
      );
      _logger.info('Notification sent for deposit validated');
    } catch (e) {
      _logger.severe('Error handling deposit validated: $e');
    }
  }

  /// Gérer la création d'une demande de prêt
  void _handleLoanCreated(Map<String, dynamic> data) {
    try {
      final amount = data['amount'] as num? ?? 0;
      final currency = data['currency'] as String? ?? '';
      final memberName = data['memberName'] as String? ?? 'Un membre';
      final tontineName = data['tontineName'] as String?;

      final body = '$memberName a demandé un prêt de $amount $currency';
      final summary = tontineName != null ? 'Tontine: $tontineName' : null;

      _localNotificationService.showBigTextNotification(
        title: 'Nouvelle demande de prêt',
        body: body,
        summary: summary,
        payload: '/loan',
      );
      _logger.info('Notification sent for loan created');
    } catch (e) {
      _logger.severe('Error handling loan created: $e');
    }
  }

  /// Gérer l'approbation d'un prêt
  void _handleLoanApproved(Map<String, dynamic> data) {
    try {
      final amount = data['amount'] as num? ?? 0;
      final currency = data['currency'] as String? ?? '';

      _localNotificationService.showNotification(
        title: 'Prêt approuvé',
        body: 'Votre demande de prêt de $amount $currency a été approuvée',
        payload: '/loan',
      );
      _logger.info('Notification sent for loan approved');
    } catch (e) {
      _logger.severe('Error handling loan approved: $e');
    }
  }

  /// Gérer le rejet d'un prêt
  void _handleLoanRejected(Map<String, dynamic> data) {
    try {
      final amount = data['amount'] as num? ?? 0;
      final currency = data['currency'] as String? ?? '';
      final reason = data['reason'] as String?;

      _localNotificationService.showNotification(
        title: 'Prêt rejeté',
        body:
            'Votre demande de prêt de $amount $currency a été rejetée${reason != null ? ': $reason' : ''}',
        payload: '/loan',
      );
      _logger.info('Notification sent for loan rejected');
    } catch (e) {
      _logger.severe('Error handling loan rejected: $e');
    }
  }

  /// Gérer l'ajout d'un membre
  void _handleMemberAdded(Map<String, dynamic> data) {
    try {
      final memberName = data['memberName'] as String? ?? 'Un nouveau membre';
      final tontineName = data['tontineName'] as String? ?? '';

      _localNotificationService.showNotification(
        title: 'Nouveau membre',
        body:
            '$memberName a rejoint${tontineName.isNotEmpty ? ' $tontineName' : ' la tontine'}',
        payload: '/member',
      );
      _logger.info('Notification sent for member added');
    } catch (e) {
      _logger.severe('Error handling member added: $e');
    }
  }

  /// Gérer la création d'un rapport
  void _handleRapportCreated(Map<String, dynamic> data) {
    try {
      final title = data['title'] as String? ?? 'Nouveau rapport';

      _localNotificationService.showNotification(
        title: 'Nouveau rapport',
        body: 'Un nouveau rapport "$title" a été créé',
        payload: '/rapport',
      );
      _logger.info('Notification sent for rapport created');
    } catch (e) {
      _logger.severe('Error handling rapport created: $e');
    }
  }

  /// Gérer la création d'une sanction
  void _handleSanctionCreated(Map<String, dynamic> data) {
    try {
      final memberName = data['memberName'] as String? ?? 'Un membre';
      final reason = data['reason'] as String? ?? '';

      _localNotificationService.showNotification(
        title: 'Nouvelle sanction',
        body:
            'Une sanction a été appliquée à $memberName${reason.isNotEmpty ? ': $reason' : ''}',
        payload: '/tontine',
      );
      _logger.info('Notification sent for sanction created');
    } catch (e) {
      _logger.severe('Error handling sanction created: $e');
    }
  }

  /// Gérer l'ajout d'une part
  void _handlePartAdded(Map<String, dynamic> data) {
    try {
      final memberName = data['memberName'] as String? ?? 'Un membre';
      final order = data['order'] as int?;

      _localNotificationService.showNotification(
        title: 'Part ajoutée',
        body:
            'Une part${order != null ? ' (ordre $order)' : ''} a été assignée à $memberName',
        payload: '/tontine',
      );
      _logger.info('Notification sent for part added');
    } catch (e) {
      _logger.severe('Error handling part added: $e');
    }
  }

  /// Gérer le rappel de versements manquants (fin de mois)
  void _handleMissingDepositsReminder(Map<String, dynamic> data) {
    try {
      final tontineName = data['tontineName'] as String? ?? '';
      final beneficiaryName = data['beneficiaryName'] as String? ?? '';
      final missingCount = data['missingCount'] as int?;
      final message = data['message'] as String?;

      final title = 'Rappel de versement';
      final body = message ??
          [
            if (tontineName.isNotEmpty) 'Tontine: $tontineName',
            if (beneficiaryName.isNotEmpty)
              'Bénéficiaire: $beneficiaryName',
            if (missingCount != null) 'Membres en retard: $missingCount',
            'Merci de régulariser votre versement.',
          ].join('\n');

      _localNotificationService.showBigTextNotification(
        title: title,
        body: body,
        summary: tontineName.isNotEmpty ? tontineName : null,
        payload: '/cashflow',
      );
      _logger.info('Notification sent for missing deposits reminder');
    } catch (e) {
      _logger.severe('Error handling missing deposits reminder: $e');
    }
  }

  /// Déconnecter le service
  void disconnect() {
    _webSocketService.disconnect();
    _isInitialized = false;
    _logger.info('RealtimeNotificationService disconnected');
  }
}
