import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/models/auction.dart';
import '../../providers/models/enum/system_type.dart';
import '../../providers/models/enum/auction_status.dart';
import '../../providers/models/enum/currency.dart';
import '../../widgets/responsive_padding.dart';
import '../../utils/responsive_helper.dart';
import '../../theme/app_theme.dart';
import '../../widgets/menu_widget.dart';
import 'create_auction_dialog.dart';
import 'auction_details_dialog.dart';

class AuctionView extends StatefulWidget {
  const AuctionView({super.key});
  static const routeName = '/auctions';

  @override
  State<AuctionView> createState() => _AuctionViewState();
}

class _AuctionViewState extends State<AuctionView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tontineProvider =
          Provider.of<TontineProvider>(context, listen: false);
      final currentTontine = tontineProvider.currentTontine;
      if (currentTontine != null) {
        tontineProvider.loadAuctions(currentTontine.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TontineProvider, AuthProvider>(
      builder: (context, tontineProvider, authProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final auctions = tontineProvider.auctions;
        final canCreateAuction = authProvider.canValidateDeposits();
        final isAuctionSystem =
            currentTontine?.config.systemType == SystemType.AUCTION;

        // Si ce n'est pas un système d'enchère, afficher un message
        if (!isAuctionSystem) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Enchères'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.gavel,
                    size: ResponsiveHelper.getAdaptiveIconSize(context, base: 64.0),
                    color: AppColors.textSecondary,
                  ),
                  ResponsiveSpacing(height: 16),
                  Text(
                    'Système d\'enchères non activé',
                    style: TextStyle(
                      fontSize: ResponsiveHelper.getAdaptiveValue(
                        context,
                        small: 16.0,
                        medium: 17.0,
                        large: 18.0,
                      ),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ResponsiveSpacing(height: 8),
                  Padding(
                    padding: ResponsiveHelper.getAdaptivePadding(context, horizontal: 16.0),
                    child: Text(
                      'Cette tontine utilise le système de parts.\nLes enchères ne sont pas disponibles.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: ResponsiveHelper.getAdaptiveValue(
                          context,
                          small: 12.0,
                          medium: 13.0,
                          large: 14.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: const MenuWidget(),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Enchères'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: ListView(
            padding: ResponsiveHelper.getAdaptivePadding(context, all: 16.0),
            children: [
              // Enchères actives
              if (auctions.where((a) => a.isActive).isNotEmpty) ...[
                _buildSectionTitle('Enchères en cours', Icons.gavel),
                const SizedBox(height: 12),
                ...auctions.where((a) => a.isActive).map((auction) =>
                    _buildAuctionCard(auction, tontineProvider, authProvider)),
                const SizedBox(height: 24),
              ],

              // Enchères terminées
              if (auctions.where((a) => a.isCompleted).isNotEmpty) ...[
                _buildSectionTitle('Enchères terminées', Icons.check_circle),
                const SizedBox(height: 12),
                ...auctions.where((a) => a.isCompleted).map((auction) =>
                    _buildAuctionCard(auction, tontineProvider, authProvider)),
                const SizedBox(height: 24),
              ],

              // Enchères annulées
              if (auctions.where((a) => a.isCancelled).isNotEmpty) ...[
                _buildSectionTitle('Enchères annulées', Icons.cancel),
                const SizedBox(height: 12),
                ...auctions.where((a) => a.isCancelled).map((auction) =>
                    _buildAuctionCard(auction, tontineProvider, authProvider)),
              ],

              // État vide
              if (auctions.isEmpty) _buildEmptyState(),
            ],
          ),
          floatingActionButton: canCreateAuction
              ? FloatingActionButton(
                  heroTag: 'auction_fab',
                  backgroundColor: AppColors.primary,
                  onPressed: () => _showCreateAuctionDialog(
                      context, tontineProvider, currentTontine!.id),
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          bottomNavigationBar: const MenuWidget(),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAuctionCard(Auction auction, TontineProvider tontineProvider,
      AuthProvider authProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withAlpha(30),
            ],
          ),
        ),
        child: InkWell(
          onTap: () => _showAuctionDetails(
              context, auction, tontineProvider, authProvider),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${auction.amount.toStringAsFixed(0)} ${auction.currency.displayName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(auction).withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getStatusColor(auction), width: 1),
                      ),
                      child: Text(
                        auction.status.displayName,
                        style: TextStyle(
                          color: _getStatusColor(auction),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (auction.description != null) ...[
                  Text(
                    auction.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Du ${DateFormat('dd/MM/yyyy').format(auction.startDate)} au ${DateFormat('dd/MM/yyyy').format(auction.endDate)}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${auction.bidCount} enchère${auction.bidCount > 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (auction.hasBids)
                      Text(
                        'Meilleure: ${auction.highestBid.toStringAsFixed(0)} ${auction.currency.displayName}',
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.surface,
              AppColors.surface.withAlpha(50),
            ],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.gavel,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune enchère',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Créez une nouvelle enchère pour commencer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(Auction auction) {
    switch (auction.status) {
      case AuctionStatus.ACTIVE:
        return AppColors.success;
      case AuctionStatus.COMPLETED:
        return AppColors.primary;
      case AuctionStatus.CANCELLED:
        return AppColors.error;
    }
  }

  void _showCreateAuctionDialog(
      BuildContext context, TontineProvider tontineProvider, int tontineId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CreateAuctionDialog(
          tontineId: tontineId,
          tontineProvider: tontineProvider,
        );
      },
    );
  }

  void _showAuctionDetails(BuildContext context, Auction auction,
      TontineProvider tontineProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AuctionDetailsDialog(
          auction: auction,
          tontineProvider: tontineProvider,
          authProvider: authProvider,
        );
      },
    );
  }
}
