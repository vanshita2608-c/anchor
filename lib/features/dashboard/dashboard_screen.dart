import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';
import '../search/search_screen.dart';
import '../emergency/emergency_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('ANCHOR', style: AnchorTypography.brandTitle.copyWith(fontSize: 22)),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined, color: AnchorColors.ceruleanTeal, size: 26),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            ),
            tooltip: 'AI Natural Language Search',
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded, color: AnchorColors.alertCoral, size: 26),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EmergencyScreen()),
            ),
            tooltip: 'Emergency Access',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Shah Family Vault', style: AnchorTypography.headlineMedium),
                    const SizedBox(height: 2),
                    Text('All family assets protected & encrypted', style: AnchorTypography.bodySmall),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AnchorColors.statusMintLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_rounded, size: 14, color: AnchorColors.statusMint),
                      const SizedBox(width: 4),
                      Text('ENCRYPTED', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Security Score Card (fl_chart Donut Gauge)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 84,
                      height: 84,
                      child: Stack(
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 0,
                              centerSpaceRadius: 30,
                              startDegreeOffset: 270,
                              sections: [
                                PieChartSectionData(
                                  color: AnchorColors.statusMint,
                                  value: 92,
                                  radius: 12,
                                  showTitle: false,
                                ),
                                PieChartSectionData(
                                  color: AnchorColors.borderSand,
                                  value: 8,
                                  radius: 12,
                                  showTitle: false,
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Text('92%', style: AnchorTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vault Security Score', style: AnchorTypography.titleLarge),
                          const SizedBox(height: 4),
                          Text('24 strong items • 2 weak passwords', style: AnchorTypography.bodySmall),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AnchorColors.statusMint),
                              const SizedBox(width: 4),
                              Text('Zero-Knowledge Verified', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.statusMint, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Expiring Soon Alert Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AnchorColors.warningAmberLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AnchorColors.warningAmber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_outlined, color: AnchorColors.warningAmber, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Car Insurance Expiring Soon', style: AnchorTypography.titleMedium.copyWith(color: AnchorColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text('Dad\'s Car Insurance Policy #8841 expires in 12 days.', style: AnchorTypography.bodySmall.copyWith(color: AnchorColors.textSecondary)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('View', style: AnchorTypography.buttonText.copyWith(color: AnchorColors.warningAmber, fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions Section
            Text('Quick Actions', style: AnchorTypography.headlineMedium),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.scanner_rounded,
                    label: 'Scan Doc',
                    color: AnchorColors.primaryNavy,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.key_rounded,
                    label: 'Add Password',
                    color: AnchorColors.ceruleanTeal,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionTile(
                    icon: Icons.auto_awesome,
                    label: 'AI Search',
                    color: AnchorColors.navySurface,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            // Recent Documents Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Family Documents', style: AnchorTypography.headlineMedium),
                TextButton(
                  onPressed: () {},
                  child: Text('See All', style: AnchorTypography.labelLarge.copyWith(color: AnchorColors.ceruleanTeal)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            _buildDocCard(
              title: "Dad's Passport",
              category: "Identity • Passport",
              owner: "Dad",
              daysLeft: "Expires in 8 mos",
              icon: Icons.card_membership_rounded,
            ),
            const SizedBox(height: 10),
            _buildDocCard(
              title: "HDFC Health Insurance Policy",
              category: "Insurance • Health",
              owner: "Shared (Family)",
              daysLeft: "Active",
              icon: Icons.health_and_safety_rounded,
            ),
            const SizedBox(height: 10),
            _buildDocCard(
              title: "Property Registry Papers",
              category: "Legal • Property",
              owner: "Mom & Dad",
              daysLeft: "Permanent",
              icon: Icons.home_work_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 26),
            const SizedBox(height: 6),
            Text(label, style: AnchorTypography.buttonText.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String category,
    required String owner,
    required String daysLeft,
    required IconData icon,
  }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AnchorColors.ceruleanTint,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AnchorColors.ceruleanTeal, size: 24),
        ),
        title: Text(title, style: AnchorTypography.titleMedium),
        subtitle: Text('$category • $owner', style: AnchorTypography.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AnchorColors.bgWarmCream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AnchorColors.borderSand),
          ),
          child: Text(daysLeft, style: AnchorTypography.bodySmall.copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
