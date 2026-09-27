import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/lead.dart';
import '../providers/leads_providers.dart';
import '../widgets/lead_card.dart';
import 'lead_detail_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const Color primaryColor = Color(0xFF5B5FEF);
  static const Color backgroundColor = Color(0xFFF7F8FC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leadsAsync = ref.watch(leadsStreamProvider);

    return DefaultTabController(
      length: LeadStatus.values.length,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: leadsAsync.when(
            loading: () => const _DashboardLoading(),
            error: (error, _) => _DashboardError(
              error: error.toString(),
              onRetry: () {
                ref.invalidate(leadsStreamProvider);
              },
            ),
            data: (leads) {
              final totalLeads = leads.length;

              final highPriorityLeads = leads
                  .where((lead) => lead.priority == LeadPriority.high)
                  .length;

              final mediumPriorityLeads = leads
                  .where((lead) => lead.priority == LeadPriority.medium)
                  .length;

              final lowPriorityLeads = leads
                  .where((lead) => lead.priority == LeadPriority.low)
                  .length;

              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, ref)
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideY(begin: -0.15, end: 0),

                            const SizedBox(height: 24),

                            Text(
                                  'Overview',
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.4,
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 100.ms)
                                .slideX(begin: -0.08, end: 0),

                            const SizedBox(height: 14),

                            _buildStats(
                              context,
                              totalLeads: totalLeads,
                              highPriorityLeads: highPriorityLeads,
                              mediumPriorityLeads: mediumPriorityLeads,
                              lowPriorityLeads: lowPriorityLeads,
                            ),

                            const SizedBox(height: 24),

                            _buildPipelineHeader(context),

                            const SizedBox(height: 14),

                            _buildPipelineChart(context, leads),

                            const SizedBox(height: 24),

                            Text(
                              'Lead Pipeline',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                            ),

                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _TabBarDelegate(
                        child: Container(
                          color: backgroundColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _buildTabBar(context),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: LeadStatus.values.map((status) {
                    final filtered = leads
                        .where((lead) => lead.status == status)
                        .toList();

                    if (filtered.isEmpty) {
                      return const _EmptyLeadsState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final lead = filtered[index];

                        return LeadCard(
                              lead: lead,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        LeadDetailScreen(lead: lead),
                                  ),
                                );
                              },
                            )
                            .animate()
                            .fadeIn(
                              delay: Duration(
                                milliseconds: 40 * index.clamp(0, 8),
                              ),
                              duration: 350.ms,
                            )
                            .slideY(
                              begin: 0.08,
                              end: 0,
                              delay: Duration(
                                milliseconds: 40 * index.clamp(0, 8),
                              ),
                            );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF4F46E5)],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.20),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.dashboard_rounded, color: Colors.white, size: 24),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good morning 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'NexyMark Dashboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        _HeaderIconButton(
          icon: Icons.logout_rounded,
          onPressed: () {
            ref.read(authControllerProvider.notifier).signOut();
          },
        ),
      ],
    );
  }

  Widget _buildStats(
    BuildContext context, {
    required int totalLeads,
    required int highPriorityLeads,
    required int mediumPriorityLeads,
    required int lowPriorityLeads,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          title: 'Total Leads',
          value: totalLeads,
          icon: Icons.people_alt_rounded,
          iconColor: const Color(0xFF5B5FEF),
          backgroundColor: const Color(0xFFEEEEFF),
          animationDelay: 100,
        ),
        _StatCard(
          title: 'High Priority',
          value: highPriorityLeads,
          icon: Icons.priority_high_rounded,
          iconColor: const Color(0xFFEF4444),
          backgroundColor: const Color(0xFFFFEEEE),
          animationDelay: 160,
        ),
        _StatCard(
          title: 'Medium Priority',
          value: mediumPriorityLeads,
          icon: Icons.remove_rounded,
          iconColor: const Color(0xFFF59E0B),
          backgroundColor: const Color(0xFFFFF7E8),
          animationDelay: 220,
        ),
        _StatCard(
          title: 'Low Priority',
          value: lowPriorityLeads,
          icon: Icons.keyboard_arrow_down_rounded,
          iconColor: const Color(0xFF10B981),
          backgroundColor: const Color(0xFFEAFBF5),
          animationDelay: 280,
        ),
      ],
    );
  }

  Widget _buildPipelineHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Pipeline Overview',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.4),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.insights_rounded, size: 16, color: primaryColor),
              SizedBox(width: 5),
              Text(
                'Live',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineChart(BuildContext context, List<Lead> leads) {
    final values = LeadStatus.values.map((status) {
      return leads.where((lead) => lead.status == status).length;
    }).toList();

    final maxValue = values.isEmpty
        ? 5.0
        : values.reduce((a, b) => a > b ? a : b).toDouble();

    final chartMax = maxValue == 0 ? 5.0 : maxValue + 1;

    return Container(
          height: 230,
          padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: BarChart(
            BarChartData(
              maxY: chartMax,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              groupsSpace: 18,
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey.shade100, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();

                      if (index < 0 || index >= LeadStatus.values.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _shortStatusLabel(LeadStatus.values[index].label),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: List.generate(LeadStatus.values.length, (index) {
                final value = values[index].toDouble();

                return BarChartGroupData(
                  x: index,
                  barsSpace: 0,
                  barRods: [
                    BarChartRodData(
                      toY: value,
                      width: 18,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(7),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
                      ),
                    ),
                  ],
                );
              }),
            ),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
          ),
        )
        .animate()
        .fadeIn(delay: 300.ms)
        .slideY(begin: 0.08, end: 0, delay: 300.ms);
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(11),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        padding: const EdgeInsets.all(4),
        tabs: LeadStatus.values.map((status) {
          return Tab(text: status.label);
        }).toList(),
      ),
    );
  }

  String _shortStatusLabel(String label) {
    if (label.length <= 8) {
      return label;
    }

    return label.substring(0, 8);
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Icon(icon, size: 21, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final int animationDelay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 21),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$value',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
        )
        .slideY(
          begin: 0.12,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
        );
  }
}

class _EmptyLeadsState extends StatelessWidget {
  const _EmptyLeadsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEFF),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 38,
                color: DashboardScreen.primaryColor,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No leads here yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 7),
            Text(
              'Add a new lead to start building your pipeline.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: DashboardScreen.primaryColor),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _DashboardError({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 50, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Unable to load leads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  double get minExtent => 56;

  @override
  double get maxExtent => 56;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
