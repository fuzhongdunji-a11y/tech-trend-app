import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';
import 'term_text.dart';

class ArticleDetailPage extends StatelessWidget {
  final Article article;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  const ArticleDetailPage({
    super.key,
    required this.article,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceLabel),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'ブックマーク',
            onPressed: onToggleBookmark,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(label: Text(article.metricLabel)),
              if (article.secondaryMetric.isNotEmpty)
                Chip(label: Text(article.secondaryMetric)),
              if (article.growthRate != null)
                Chip(
                    label: Text(
                        '急上昇 ${article.growthRate!.toStringAsFixed(1)}/日')),
              if (article.language != null)
                Chip(label: Text(article.language!)),
            ],
          ),
          const SizedBox(height: 12),
          Text(article.headlineJa,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(article.title,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          _Section(
              title: '要約', body: article.summaryJa, terms: article.terms),
          _Section(
              title: '詳しい説明',
              body: article.detailJa,
              terms: article.terms),
          _Section(
              title: 'なぜ優れているか',
              body: article.strengthsJa,
              terms: article.terms),
          _Section(
              title: '活用方法', body: article.usageJa, terms: article.terms),
          if (article.usageIdeas.isNotEmpty) ...[
            Text('活用アイデア',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            for (final idea in article.usageIdeas)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('・'),
                    Expanded(child: TermText(text: idea, terms: article.terms)),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
          if (article.tags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final tag in article.tags)
                  Chip(label: Text(tag), visualDensity: VisualDensity.compact),
              ],
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            icon: const Icon(Icons.open_in_new),
            label: const Text('元のページを開く'),
            onPressed: () async {
              final uri = Uri.tryParse(article.url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  final List<TermItem> terms;

  const _Section({required this.title, required this.body, required this.terms});

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TermText(text: body, terms: terms, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
