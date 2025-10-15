import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/models/auction.dart';
import '../../providers/models/enum/auction_status.dart';
import '../../theme/app_theme.dart';
import '../services/dto/auction_dto.dart';

class AuctionDetailsDialog extends StatefulWidget {
  final Auction auction;
  final TontineProvider tontineProvider;
  final AuthProvider authProvider;

  const AuctionDetailsDialog({
    super.key,
    required this.auction,
    required this.tontineProvider,
    required this.authProvider,
  });

  @override
  State<AuctionDetailsDialog> createState() => _AuctionDetailsDialogState();
}

class _AuctionDetailsDialogState extends State<AuctionDetailsDialog> {
  final _bidController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final canBid = widget.auction.canBid &&
        !widget.authProvider.isPresident() &&
        !widget.authProvider.isAccountManager();
    final canManage = widget.authProvider.canValidateDeposits();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.gavel,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.auction.amount.toStringAsFixed(0)} ${widget.auction.currency.name}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _getStatusColor(), width: 1),
                        ),
                        child: Text(
                          widget.auction.status.displayName,
                          style: TextStyle(
                            color: _getStatusColor(),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Contenu scrollable
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations de base
                    _buildInfoSection(),
                    const SizedBox(height: 24),

                    // Enchères
                    _buildBidsSection(),
                    const SizedBox(height: 24),

                    // Actions
                    if (canBid) _buildBidSection(),
                    if (canManage && widget.auction.isActive)
                      _buildManagementSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Montant',
            '${widget.auction.amount.toStringAsFixed(0)} ${widget.auction.currency.name}'),
        _buildInfoRow('Début',
            DateFormat('dd/MM/yyyy à HH:mm').format(widget.auction.startDate)),
        _buildInfoRow('Fin',
            DateFormat('dd/MM/yyyy à HH:mm').format(widget.auction.endDate)),
        _buildInfoRow('Créée par',
            '${widget.auction.createdBy.firstname} ${widget.auction.createdBy.lastname}'),
        if (widget.auction.description != null)
          _buildInfoRow('Description', widget.auction.description!),
        if (widget.auction.winner != null)
          _buildInfoRow('Gagnant',
              '${widget.auction.winner!.firstname} ${widget.auction.winner!.lastname}'),
        if (widget.auction.winningBid != null)
          _buildInfoRow('Enchère gagnante',
              '${widget.auction.winningBid!.toStringAsFixed(0)} ${widget.auction.currency.name}'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBidsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Enchères',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.auction.bidCount}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (widget.auction.bids.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'Aucune enchère pour le moment',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          ...widget.auction.bids.map((bid) => _buildBidCard(bid)),
      ],
    );
  }

  Widget _buildBidCard(AuctionBid bid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            bid.isWinning ? AppColors.success.withAlpha(20) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: bid.isWinning ? AppColors.success : AppColors.border,
          width: bid.isWinning ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${bid.bidder.firstname} ${bid.bidder.lastname}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: bid.isWinning
                        ? AppColors.success
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(bid.bidDate),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${bid.amount.toStringAsFixed(0)} ${widget.auction.currency.name}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                      bid.isWinning ? AppColors.success : AppColors.textPrimary,
                ),
              ),
              if (bid.isWinning)
                const Text(
                  'GAGNANT',
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Placer une enchère',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _bidController,
            decoration: InputDecoration(
              labelText: 'Montant de votre enchère',
              prefixIcon:
                  const Icon(Icons.monetization_on, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount <= 0) {
                return 'Montant invalide';
              }
              if (amount <= widget.auction.highestBid) {
                return 'L\'enchère doit être supérieure à ${widget.auction.highestBid.toStringAsFixed(0)}';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _placeBid,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Placer l\'enchère',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gestion de l\'enchère',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _completeAuction,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Terminer',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _cancelAuction,
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text('Annuler',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.auction.status) {
      case AuctionStatus.ACTIVE:
        return AppColors.success;
      case AuctionStatus.COMPLETED:
        return AppColors.primary;
      case AuctionStatus.CANCELLED:
        return AppColors.error;
    }
  }

  Future<void> _placeBid() async {
    if (_bidController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final bidDto = CreateAuctionBidDto(
        amount: double.parse(_bidController.text),
        auctionId: widget.auction.id,
        memberId: widget.authProvider.currentUser!.id!,
      );

      final success = await widget.tontineProvider.placeBid(bidDto);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enchère placée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        _bidController.clear();
        // Rafraîchir les détails de l'enchère
        // Note: Dans une vraie implémentation, on devrait recharger l'enchère depuis le serveur
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors du placement de l\'enchère'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _completeAuction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final auction =
          await widget.tontineProvider.completeAuction(widget.auction.id);

      if (!mounted) return;

      if (auction != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enchère terminée avec succès'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de la finalisation de l\'enchère'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelAuction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final auction =
          await widget.tontineProvider.cancelAuction(widget.auction.id);

      if (!mounted) return;

      if (auction != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enchère annulée'),
            backgroundColor: AppColors.warning,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'annulation de l\'enchère'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
