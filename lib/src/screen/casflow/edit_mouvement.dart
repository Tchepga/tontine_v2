import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/models/deposit.dart';
import '../../providers/models/enum/currency.dart';
import '../../providers/models/enum/deposit_reason.dart';
import '../../providers/models/enum/status_deposit.dart';
import '../../providers/models/enum/role.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tontine_provider.dart';
import '../../providers/models/member.dart';
import '../../theme/app_theme.dart';
import '../../utils/currency_utils.dart';
import '../../utils/money_utils.dart';
import '../../utils/submit_guard.dart';
import '../../utils/role_permissions.dart';
import '../services/dto/deposit_dto.dart';

enum _DepositTargetMode { myself, oneMember, severalMembers }

class EditMouvement extends StatefulWidget {
  final Deposit? deposit;

  const EditMouvement({super.key, this.deposit});

  @override
  State<EditMouvement> createState() => _EditMouvementState();
}

class _EditMouvementState extends State<EditMouvement> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memberSearchController = TextEditingController();
  final _submitGuard = SubmitGuard();

  Member? _selectedAuthor;
  final Set<int> _selectedMemberIds = {};
  DepositReason _selectedReason = DepositReason.VERSEMENT;
  _DepositTargetMode _targetMode = _DepositTargetMode.myself;
  String _memberQuery = '';
  bool _initialized = false;
  late DateTime _selectedDate;

  bool get _isEditing => widget.deposit != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = widget.deposit?.creationDate ??
        DateTime(now.year, now.month, now.day);
    if (widget.deposit != null) {
      _amountController.text = _formatAmountForInput(widget.deposit!.amount);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  String _formatAmountForInput(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }
    return amount.toString();
  }

  List<DepositReason> _getAvailableReasons(List<Role> roles) {
    if (canManageTreasury(roles)) return DepositReason.values.toList();
    return [DepositReason.VERSEMENT];
  }

  String _memberName(Member member) {
    final name =
        '${member.firstname ?? ''} ${member.lastname ?? ''}'.trim();
    if (name.isNotEmpty) return name;
    return member.user?.username ?? 'Membre #${member.id ?? '?'}';
  }

  String _initials(Member member) {
    final first = member.firstname?.trim();
    final last = member.lastname?.trim();
    if (first != null &&
        first.isNotEmpty &&
        last != null &&
        last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    final name = _memberName(member);
    return name.length >= 2 ? name.substring(0, 2).toUpperCase() : '?';
  }

  bool _hasPaidThisMonth(Member member, List<Deposit> deposits) {
    final now = DateTime.now();
    return deposits.any((d) {
      if (d.author?.id != member.id) return false;
      if (d.creationDate.year != now.year || d.creationDate.month != now.month) {
        return false;
      }
      final reason = depositReasonFromString(d.reasons ?? '');
      if (reason != DepositReason.VERSEMENT) return false;
      return d.status == StatusDeposit.VALIDATED ||
          d.status == StatusDeposit.PENDING;
    });
  }

  double? _suggestedAmountFor(
    Member? member,
    List<Deposit> deposits,
  ) {
    if (member?.id == null) return null;
    final versements = deposits
        .where((d) =>
            d.author?.id == member!.id &&
            depositReasonFromString(d.reasons ?? '') ==
                DepositReason.VERSEMENT &&
            d.status == StatusDeposit.VALIDATED)
        .toList()
      ..sort((a, b) => b.creationDate.compareTo(a.creationDate));
    if (versements.isEmpty) return null;
    return versements.first.amount;
  }

  List<double> _quickAmounts(Currency currency, double? suggested) {
    final defaults = switch (currency) {
      Currency.EUR => [50.0, 100.0, 150.0, 200.0],
      Currency.USD => [50.0, 100.0, 150.0, 200.0],
      Currency.FCFA => [10000.0, 25000.0, 50000.0, 100000.0],
    };
    final amounts = <double>{};
    if (suggested != null && suggested > 0) amounts.add(suggested);
    amounts.addAll(defaults);
    return amounts.toList()..sort();
  }

  void _ensureInitialized(
    AuthProvider auth,
    TontineProvider tontineProvider,
    List<Role> roles,
    bool canManage,
  ) {
    if (_initialized) return;
    _initialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final me = auth.currentUser;
      setState(() {
        if (_isEditing) {
          final available = _getAvailableReasons(roles);
          final fromDeposit =
              depositReasonFromString(widget.deposit!.reasons ?? '');
          _selectedReason = available.contains(fromDeposit)
              ? fromDeposit
              : available.first;
          _selectedAuthor = widget.deposit!.author;
          _targetMode = _DepositTargetMode.oneMember;
          return;
        }

        _selectedAuthor = me;
        _targetMode = _DepositTargetMode.myself;

        final suggested = _suggestedAmountFor(me, tontineProvider.deposits);
        if (suggested != null && _amountController.text.isEmpty) {
          _amountController.text = _formatAmountForInput(suggested);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, TontineProvider>(
      builder: (context, authProvider, tontineProvider, child) {
        final currentTontine = tontineProvider.currentTontine;
        final roles =
            tontineProvider.rolesInCurrentTontine(authProvider.currentUser?.id);
        final canManage = canManageTreasury(roles);
        final availableReasons = _getAvailableReasons(roles);
        final currency = currentTontine?.cashFlow.currency ?? Currency.EUR;
        final monthLabel = DateFormat('MM/yyyy').format(DateTime.now());

        _ensureInitialized(authProvider, tontineProvider, roles, canManage);

        final members = List<Member>.from(currentTontine?.members ?? [])
          ..sort((a, b) => _memberName(a).compareTo(_memberName(b)));

        final filteredMembers = members.where((m) {
          if (_memberQuery.trim().isEmpty) return true;
          final q = _memberQuery.toLowerCase();
          return _memberName(m).toLowerCase().contains(q) ||
              (m.user?.username?.toLowerCase().contains(q) ?? false);
        }).toList();

        final focusMember = _targetMode == _DepositTargetMode.myself
            ? authProvider.currentUser
            : _selectedAuthor;
        final suggested = _suggestedAmountFor(
          focusMember,
          tontineProvider.deposits,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_isEditing
                ? 'Modifier le mouvement'
                : (canManage && _selectedReason != DepositReason.VERSEMENT
                    ? 'Nouveau mouvement'
                    : 'Nouveau versement')),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MonthBanner(monthLabel: monthLabel),
                const SizedBox(height: 16),
                if (canManage && !_isEditing) ...[
                  _SectionCard(
                    title: 'Qui verse ?',
                    child: Column(
                      children: [
                        SegmentedButton<_DepositTargetMode>(
                          showSelectedIcon: false,
                          style: const ButtonStyle(
                            visualDensity: VisualDensity.compact,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: _DepositTargetMode.myself,
                              label: Text('Moi'),
                            ),
                            ButtonSegment(
                              value: _DepositTargetMode.oneMember,
                              label: Text('1 membre'),
                            ),
                            ButtonSegment(
                              value: _DepositTargetMode.severalMembers,
                              label: Text('Plusieurs'),
                            ),
                          ],
                          selected: {_targetMode},
                          onSelectionChanged: (value) {
                            setState(() {
                              _targetMode = value.first;
                              if (_targetMode == _DepositTargetMode.myself) {
                                _selectedAuthor = authProvider.currentUser;
                                _selectedMemberIds.clear();
                                final s = _suggestedAmountFor(
                                  authProvider.currentUser,
                                  tontineProvider.deposits,
                                );
                                if (s != null) {
                                  _amountController.text =
                                      _formatAmountForInput(s);
                                }
                              } else if (_targetMode ==
                                  _DepositTargetMode.oneMember) {
                                _selectedMemberIds.clear();
                              } else {
                                _selectedAuthor = null;
                              }
                            });
                          },
                        ),
                        if (_targetMode == _DepositTargetMode.myself) ...[
                          const SizedBox(height: 12),
                          _MemberTile(
                            member: authProvider.currentUser!,
                            name: _memberName(authProvider.currentUser!),
                            initials: _initials(authProvider.currentUser!),
                            selected: true,
                            paidThisMonth: _hasPaidThisMonth(
                              authProvider.currentUser!,
                              tontineProvider.deposits,
                            ),
                            onTap: null,
                          ),
                        ],
                        if (_targetMode == _DepositTargetMode.oneMember ||
                            _targetMode ==
                                _DepositTargetMode.severalMembers) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _memberSearchController,
                            decoration: InputDecoration(
                              labelText: 'Rechercher un membre',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (v) =>
                                setState(() => _memberQuery = v),
                          ),
                          const SizedBox(height: 8),
                          if (_targetMode ==
                              _DepositTargetMode.severalMembers)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Cochez les membres qui ont versé le même montant.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredMembers.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                final id = member.id;
                                final paid = _hasPaidThisMonth(
                                  member,
                                  tontineProvider.deposits,
                                );
                                final selected =
                                    _targetMode == _DepositTargetMode.oneMember
                                        ? _selectedAuthor?.id == id
                                        : id != null &&
                                            _selectedMemberIds.contains(id);
                                return _MemberTile(
                                  member: member,
                                  name: _memberName(member),
                                  initials: _initials(member),
                                  selected: selected,
                                  paidThisMonth: paid,
                                  multiSelect: _targetMode ==
                                      _DepositTargetMode.severalMembers,
                                  onTap: () {
                                    setState(() {
                                      if (_targetMode ==
                                          _DepositTargetMode.oneMember) {
                                        _selectedAuthor = member;
                                        final s = _suggestedAmountFor(
                                          member,
                                          tontineProvider.deposits,
                                        );
                                        if (s != null) {
                                          _amountController.text =
                                              _formatAmountForInput(s);
                                        }
                                      } else if (id != null) {
                                        if (_selectedMemberIds.contains(id)) {
                                          _selectedMemberIds.remove(id);
                                        } else {
                                          _selectedMemberIds.add(id);
                                        }
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  _SectionCard(
                    title: 'Bénéficiaire',
                    child: _MemberTile(
                      member: (_isEditing
                              ? _selectedAuthor
                              : authProvider.currentUser) ??
                          authProvider.currentUser!,
                      name: _memberName((_isEditing
                              ? _selectedAuthor
                              : authProvider.currentUser) ??
                          authProvider.currentUser!),
                      initials: _initials((_isEditing
                              ? _selectedAuthor
                              : authProvider.currentUser) ??
                          authProvider.currentUser!),
                      selected: true,
                      paidThisMonth: _hasPaidThisMonth(
                        (_isEditing
                                ? _selectedAuthor
                                : authProvider.currentUser) ??
                            authProvider.currentUser!,
                        tontineProvider.deposits,
                      ),
                      onTap: null,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'Montant',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Montant versé',
                          hintText: 'Ex. 10000',
                          prefixIcon: const Icon(Icons.payments_outlined),
                          suffixText: currency.displayName,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.,\s]'),
                          ),
                        ],
                        validator: MoneyUtils.validateAmountInput,
                      ),
                      if (suggested != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Dernière cotisation : ${CurrencyUtils.formatAmountForCard(suggested, currency)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _quickAmounts(currency, suggested)
                            .map((amount) {
                          final label = CurrencyUtils.formatAmountForCard(
                              amount, currency);
                          final selected =
                              _amountController.text.replaceAll(' ', '') ==
                                  _formatAmountForInput(amount);
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _amountController.text =
                                    _formatAmountForInput(amount);
                              });
                            },
                            selectedColor: AppColors.primary.withAlpha(30),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _pickDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date du versement',
                            prefixIcon: const Icon(Icons.event),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (canManage) ...[
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Type de mouvement',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableReasons.map((reason) {
                        final selected = _selectedReason == reason;
                        return ChoiceChip(
                          label: Text(reason.displayName),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selectedReason = reason);
                          },
                          selectedColor: AppColors.primary.withAlpha(30),
                          labelStyle: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _submitGuard.isBusy
                        ? null
                        : () => _handleSubmit(
                              context,
                              tontineProvider,
                              authProvider,
                              canManage,
                            ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _submitGuard.isBusy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(
                      _submitLabel(canManage),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  String _submitLabel(bool canManage) {
    if (_isEditing) return 'Enregistrer les modifications';
    if (canManage &&
        _targetMode == _DepositTargetMode.severalMembers &&
        _selectedMemberIds.length > 1) {
      return 'Enregistrer ${_selectedMemberIds.length} versements';
    }
    return 'Enregistrer le versement';
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      helpText: 'Date du versement',
      cancelText: 'Annuler',
      confirmText: 'OK',
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _handleSubmit(
    BuildContext context,
    TontineProvider tontineProvider,
    AuthProvider authProvider,
    bool canManage,
  ) async {
    await _submitGuard.run(() async {
      if (!(_formKey.currentState?.validate() ?? false)) return;

      final currentTontine = tontineProvider.currentTontine;
      if (currentTontine == null) return;

      final amount = MoneyUtils.parseToApiAmount(_amountController.text);
      if (amount == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Montant invalide'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final List<int> memberIds;
      if (_isEditing) {
        final id = _selectedAuthor?.id ?? widget.deposit?.author?.id;
        if (id == null) return;
        memberIds = [id];
      } else if (!canManage || _targetMode == _DepositTargetMode.myself) {
        final id = authProvider.currentUser?.id;
        if (id == null) return;
        memberIds = [id];
      } else if (_targetMode == _DepositTargetMode.oneMember) {
        final id = _selectedAuthor?.id;
        if (id == null) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sélectionnez un membre'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }
        memberIds = [id];
      } else {
        if (_selectedMemberIds.isEmpty) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sélectionnez au moins un membre'),
              backgroundColor: AppColors.warning,
            ),
          );
          return;
        }
        memberIds = _selectedMemberIds.toList();
      }

      try {
        if (_isEditing) {
          final depositDto = CreateDepositDto(
            amount: amount,
            currency: currentTontine.cashFlow.currency,
            memberId: memberIds.first,
            status: StatusDeposit.PENDING,
            cashFlowId: currentTontine.cashFlow.id,
            reasons: depositReasonToString(_selectedReason),
            creationDate: _selectedDate,
          );
          await tontineProvider.updateDeposit(
            currentTontine.id,
            widget.deposit!.id,
            depositDto,
          );
        } else {
          for (final memberId in memberIds) {
            final depositDto = CreateDepositDto(
              amount: amount,
              currency: currentTontine.cashFlow.currency,
              memberId: memberId,
              status: StatusDeposit.PENDING,
              cashFlowId: currentTontine.cashFlow.id,
              reasons: depositReasonToString(_selectedReason),
              creationDate: _selectedDate,
            );
            await tontineProvider.createDeposit(
              currentTontine.id,
              depositDto,
            );
          }
        }

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text(_isEditing
                ? 'Mouvement modifié avec succès'
                : memberIds.length > 1
                    ? '${memberIds.length} versements enregistrés'
                    : 'Versement enregistré avec succès'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });
  }
}

class _MonthBanner extends StatelessWidget {
  final String monthLabel;

  const _MonthBanner({required this.monthLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.info.withAlpha(12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.info.withAlpha(40)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month, color: AppColors.info),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cotisation du mois',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  monthLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;
  final String name;
  final String initials;
  final bool selected;
  final bool paidThisMonth;
  final bool multiSelect;
  final VoidCallback? onTap;

  const _MemberTile({
    required this.member,
    required this.name,
    required this.initials,
    required this.selected,
    required this.paidThisMonth,
    this.multiSelect = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withAlpha(12)
          : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withAlpha(80)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              if (multiSelect) ...[
                Icon(
                  selected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: selected ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 8),
              ],
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary.withAlpha(25),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (paidThisMonth)
                      Text(
                        'Déjà un versement ce mois-ci',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                  ],
                ),
              ),
              if (!multiSelect && selected)
                const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
