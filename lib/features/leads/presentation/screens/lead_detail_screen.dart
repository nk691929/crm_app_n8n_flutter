import 'package:crm_app/features/leads/domain/entities/interaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:crm_app/core/error/result.dart';

import '../../domain/entities/lead.dart';
import '../providers/leads_providers.dart';

import 'package:crm_app/core/error/failures.dart';

import '../../domain/entities/lead_note.dart';
import '../../../../core/theme/app_theme.dart';

class LeadDetailScreen extends ConsumerStatefulWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  @override
  ConsumerState<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends ConsumerState<LeadDetailScreen> {
  late LeadStatus _status;
  late LeadPriority _priority;
  ColorScheme get _colors => Theme.of(context).colorScheme;

  final _noteController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _status = widget.lead.status;
    _priority = widget.lead.priority;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(LeadStatus? newStatus) async {
    if (newStatus == null || newStatus == _status) return;

    final previous = _status;
    setState(() => _status = newStatus);

    final result = await ref
        .read(leadsControllerProvider)
        .updateStatus(lead: widget.lead, newStatus: newStatus);
    if (!mounted) return;

    if (result case Err(:final failure)) {
      setState(() => _status = previous);
      _showMessage(failure.message);
    }
  }

  Future<void> _updatePriority(LeadPriority? newPriority) async {
    if (newPriority == null || newPriority == _priority) return;

    final previous = _priority;
    setState(() => _priority = newPriority);

    final result = await ref
        .read(leadsControllerProvider)
        .updatePriority(leadId: widget.lead.id, priority: newPriority);

    if (!mounted) return;

    if (result case Err(:final failure)) {
      setState(() => _priority = previous);
      _showMessage(failure.message);
    }
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSaving = true);

    final result = await ref
        .read(leadsControllerProvider)
        .addNote(leadId: widget.lead.id, note: text);

    if (!mounted) return;
    setState(() => _isSaving = false);

    switch (result) {
      case Success():
        _noteController.clear();
        ref.invalidate(leadNotesProvider(widget.lead.id));
        _showMessage('Note added successfully');
      case Err(:final failure):
        _showMessage(failure.message);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not yet';

    return DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());
  }

  Color _statusColor(LeadStatus status) {
    switch (status) {
      case LeadStatus.newLead:
        return StatusColors.newLead;
      case LeadStatus.contacted:
        return StatusColors.contacted;
      case LeadStatus.qualified:
        return StatusColors.qualified;
      case LeadStatus.won:
        return StatusColors.won;
      case LeadStatus.lost:
        return StatusColors.lost;
    }
  }

  Color _priorityColor(LeadPriority priority) {
    switch (priority) {
      case LeadPriority.high:
        return PriorityColors.high;
      case LeadPriority.medium:
        return PriorityColors.medium;
      case LeadPriority.low:
        return PriorityColors.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),

        title: const Text(
          'Lead Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            _buildHeroCard(lead),

            const SizedBox(height: 20),

            _sectionTitle('Lead Status', 'Keep the pipeline up to date'),

            const SizedBox(height: 12),

            _buildStatusSelector(),

            const SizedBox(height: 24),

            _sectionTitle('Contact Information', 'How you can reach this lead'),

            const SizedBox(height: 12),

            _buildContactCard(lead),

            const SizedBox(height: 24),

            _sectionTitle(
              'Lead Information',
              'Important details about this opportunity',
            ),

            const SizedBox(height: 12),

            _buildInformationCard(lead),

            const SizedBox(height: 24),

            _sectionTitle('Priority', 'How important is this lead?'),

            const SizedBox(height: 12),

            _buildPrioritySelector(),

            const SizedBox(height: 24),

            _sectionTitle('Activity', 'Lead history and follow-up information'),

            const SizedBox(height: 12),

            _buildTimelineCard(lead),

            if (lead.message != null && lead.message!.trim().isNotEmpty) ...[
              const SizedBox(height: 24),

              _sectionTitle(
                'Original Message',
                'What the lead initially requested',
              ),

              const SizedBox(height: 12),

              _buildMessageCard(lead.message!),
            ],

            const SizedBox(height: 24),

            _sectionTitle('Activity Log', 'Automatic record of changes'),
            const SizedBox(height: 12),
            _buildInteractionLog(),
            const SizedBox(height: 24),

            _sectionTitle('Notes', 'Everything logged for this lead'),
            const SizedBox(height: 12),
            _buildNotesHistory(),
            const SizedBox(height: 24),

            _sectionTitle(
              'Add Note',
              'Keep useful information for future follow-ups',
            ),

            const SizedBox(height: 12),

            _buildNoteComposer(),

            const SizedBox(height: 20),

            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _isSaving ? null : _addNote,
                icon: _isSaving
                    ? SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _colors.surface,
                        ),
                      )
                    : const Icon(Icons.add_rounded),
                label: Text(
                  _isSaving ? 'Saving...' : 'Save Note',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(Lead lead) {
    final priorityColor = _priorityColor(_priority);
    final statusColor = _statusColor(_status);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_colors.primary, _colors.primaryContainer],
        ),
        boxShadow: [
          BoxShadow(
            color: _colors.shadow.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colors.surface.withValues(alpha: 0.10),
                  border: Border.all(
                    color: _colors.surface.withValues(alpha: 0.15),
                  ),
                ),
                child: Center(
                  child: Text(
                    _initials(lead.name),
                    style: TextStyle(
                      color: _colors.onPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _colors.onPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      lead.serviceInterested ?? 'Service not specified',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _colors.surface.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              _heroBadge(
                icon: Icons.circle,
                label: _status.label,
                color: statusColor,
              ),

              const SizedBox(width: 8),

              _heroBadge(
                icon: Icons.flag_rounded,
                label: _priority.label,
                color: priorityColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _colors.surface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _colors.surface.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),

          const SizedBox(width: 7),

          Text(
            label,
            style: TextStyle(
              color: _colors.surface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _colors.outlineVariant),
      ),
      child: Column(
        children: LeadStatus.values.map((status) {
          final selected = status == _status;
          final color = _statusColor(status);

          return GestureDetector(
            onTap: () => _updateStatus(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? _colors.onSurface
                            : _colors.onSurfaceVariant,
                      ),
                    ),
                  ),

                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 20, color: color),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard(Lead lead) {
    return _card(
      child: Column(
        children: [
          _contactItem(
            icon: Icons.phone_rounded,
            title: 'Phone',
            value: lead.phone,
          ),

          _cardDivider(),

          _contactItem(
            icon: Icons.email_rounded,
            title: 'Email',
            value: lead.email ?? 'Not provided',
          ),
        ],
      ),
    );
  }

  Widget _contactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: _colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 20, color: _colors.onSurfaceVariant),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: _colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(Lead lead) {
    return _card(
      child: Column(
        children: [
          _detailItem(
            icon: Icons.design_services_rounded,
            label: 'Service',
            value: lead.serviceInterested ?? 'Not specified',
          ),

          _cardDivider(),

          _detailItem(
            icon: Icons.payments_rounded,
            label: 'Budget',
            value: lead.budget ?? 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 19, color: _colors.onSurfaceVariant),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            label,
            style: TextStyle(color: _colors.onSurfaceVariant, fontSize: 13),
          ),
        ),

        const SizedBox(width: 12),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _colors.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: LeadPriority.values.map((priority) {
        final selected = priority == _priority;
        final color = _priorityColor(priority);

        return Expanded(
          child: GestureDetector(
            onTap: () => _updatePriority(priority),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: EdgeInsets.only(
                right: priority == LeadPriority.low ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
              decoration: BoxDecoration(
                color: selected
                    ? color.withValues(alpha: 0.10)
                    : _colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? color.withValues(alpha: 0.45)
                      : _colors.outlineVariant,
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    priority == LeadPriority.high
                        ? Icons.keyboard_double_arrow_up_rounded
                        : priority == LeadPriority.medium
                        ? Icons.drag_handle_rounded
                        : Icons.keyboard_double_arrow_down_rounded,
                    color: color,
                    size: 22,
                  ),

                  const SizedBox(height: 7),

                  Text(
                    priority.label,
                    style: TextStyle(
                      color: selected ? color : _colors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInteractionLog() {
    final interactionsAsync = ref.watch(
      leadInteractionsProvider(widget.lead.id),
    );

    return interactionsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _card(child: Text(failureMessage(error))),
      data: (result) => switch (result) {
        Err(:final failure) => _card(child: Text(failure.message)),
        Success(:final value) when value.isEmpty => _card(
          child: Text(
            'No activity logged yet.',
            style: TextStyle(color: _colors.onSurfaceVariant),
          ),
        ),
        Success(:final value) => _card(
          child: Column(
            children: [
              for (var i = 0; i < value.length; i++) ...[
                _interactionItem(value[i]),
                if (i != value.length - 1) _cardDivider(),
              ],
            ],
          ),
        ),
      },
    );
  }

  Widget _interactionItem(Interaction interaction) {
    final icon = interaction.direction == InteractionDirection.outbound
        ? Icons.send_rounded
        : Icons.swap_horiz_rounded;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: _colors.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                interaction.message,
                style: TextStyle(fontSize: 14, color: _colors.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(interaction.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: _colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard(Lead lead) {
    return _card(
      child: Column(
        children: [
          _timelineItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Lead created',
            value: _formatDate(lead.createdAt),
            color: const Color(0xFF6366F1),
            isLast: false,
          ),

          _timelineItem(
            icon: Icons.phone_in_talk_rounded,
            title: 'Last contacted',
            value: _formatDate(lead.lastContactedAt),
            color: const Color(0xFF0EA5E9),
            isLast: false,
          ),

          _timelineItem(
            icon: Icons.event_available_rounded,
            title: 'Next follow-up',
            value: _formatDate(lead.nextFollowUpAt),
            color: const Color(0xFF10B981),
            isLast: false,
          ),

          _timelineItem(
            icon: Icons.repeat_rounded,
            title: 'Follow-ups sent',
            value: '${lead.followUpCount}',
            color: const Color(0xFFF59E0B),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 36,
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 17, color: color),
              ),

              if (!isLast)
                Container(width: 1, height: 34, color: _colors.outlineVariant),
            ],
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: _colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: _colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageCard(String message) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              size: 20,
              color: _colors.onSurfaceVariant,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                height: 1.5,
                fontSize: 14,
                color: _colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteComposer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: _colors.shadow.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Write something important about this lead...',
          hintStyle: TextStyle(color: _colors.onSurfaceVariant, fontSize: 14),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4, right: 8, bottom: 65),
            child: Icon(Icons.edit_note_rounded, color: _colors.onSurfaceVariant),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: _colors.onSurface,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: _colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _colors.outlineVariant),
      ),
      child: child,
    );
  }

  Widget _cardDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Divider(height: 1, color: _colors.outlineVariant),
    );
  }

  Widget _buildNotesHistory() {
    final notesAsync = ref.watch(leadNotesProvider(widget.lead.id));

    return notesAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _notesError(failureMessage(error)),
      data: (result) => switch (result) {
        Err(:final failure) => _notesError(failure.message),
        Success(:final value) => _notesList(value),
      },
    );
  }

  Widget _notesError(String message) {
    return _card(
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: _colors.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(leadNotesProvider(widget.lead.id)),
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _notesList(List<LeadNote> notes) {
    if (notes.isEmpty) {
      return _card(
        child: Text(
          'No notes yet. Add the first one below.',
          style: TextStyle(color: _colors.onSurfaceVariant),
        ),
      );
    }

    return _card(
      child: Column(
        children: [
          for (var i = 0; i < notes.length; i++) ...[
            _noteItem(notes[i]),
            if (i != notes.length - 1) _cardDivider(),
          ],
        ],
      ),
    );
  }

  Widget _noteItem(LeadNote note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          note.text,
          style: TextStyle(
            height: 1.5,
            fontSize: 14,
            color: _colors.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(note.createdAt),
          style: TextStyle(
            fontSize: 11,
            color: _colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty) return '?';

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first.substring(0, 1)}'
            '${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}
