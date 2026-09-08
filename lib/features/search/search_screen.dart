import 'package:flutter/material.dart';
import '../../core/theme/anchor_colors.dart';
import '../../core/theme/anchor_typography.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _queryController = TextEditingController();
  bool _isAnalyzing = false;
  String? _interpretedFilter;

  void _handleSearch(String query) {
    if (query.trim().isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _interpretedFilter = null;
    });

    // Gemini AI Query Parser simulation: Converts natural query into structured filter
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
        if (query.toLowerCase().contains('passport')) {
          _interpretedFilter = 'Category = Identity | Asset = Passport | Owner = Dad';
        } else if (query.toLowerCase().contains('expire')) {
          _interpretedFilter = 'Filter = Expiry Date < 30 Days';
        } else {
          _interpretedFilter = 'Query Tokens = "${query.trim()}"';
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AnchorColors.bgWarmCream,
      appBar: AppBar(
        title: Text('AI Search', style: AnchorTypography.headlineLarge),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _queryController,
              onSubmitted: _handleSearch,
              style: AnchorTypography.bodyLarge,
              decoration: InputDecoration(
                hintText: 'e.g. "When does Dad\'s car insurance expire?"',
                prefixIcon: const Icon(Icons.auto_awesome, color: AnchorColors.ceruleanTeal),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, color: AnchorColors.primaryNavy),
                  onPressed: () => _handleSearch(_queryController.text),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '🔒 Data Minimization: Gemini API only receives query keywords, never decrypted vault content.',
              style: AnchorTypography.bodySmall.copyWith(fontSize: 11, color: AnchorColors.statusMint),
            ),
            const SizedBox(height: 24),

            if (_isAnalyzing) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(color: AnchorColors.primaryNavy),
                ),
              ),
            ] else if (_interpretedFilter != null) ...[
              Card(
                color: AnchorColors.cardWhite,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: AnchorColors.ceruleanTeal),
                          const SizedBox(width: 8),
                          Text('AI Interpreted Search Filter', style: AnchorTypography.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AnchorColors.bgWarmCream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(_interpretedFilter!, style: AnchorTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            Text('Suggested Queries', style: AnchorTypography.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip("Mom's Passport"),
                _buildChip("Documents expiring this month"),
                _buildChip("Car Insurance policy"),
                _buildChip("Aadhaar card numbers"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return ActionChip(
      label: Text(text, style: AnchorTypography.bodySmall),
      backgroundColor: AnchorColors.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AnchorColors.borderSand),
      ),
      onPressed: () {
        _queryController.text = text;
        _handleSearch(text);
      },
    );
  }
}
