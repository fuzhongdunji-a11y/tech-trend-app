import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'detail_page.dart';
import 'models.dart';

void main() {
  runApp(const TechTrendApp());
}

class TechTrendApp extends StatefulWidget {
  const TechTrendApp({super.key});

  @override
  State<TechTrendApp> createState() => _TechTrendAppState();
}

class _TechTrendAppState extends State<TechTrendApp> {
  Digest? _digest;
  Set<int> _bookmarks = <int>{};
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final raw = await rootBundle.loadString('assets/sample_digest.json');
      final digest =
          Digest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList('bookmarked_ids') ?? const <String>[];
      if (!mounted) return;
      setState(() {
        _digest = digest;
        _bookmarks = saved.map(int.tryParse).whereType<int>().toSet();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _toggleBookmark(int id) async {
    setState(() {
      if (_bookmarks.contains(id)) {
        _bookmarks.remove(id);
      } else {
        _bookmarks.add(id);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'bookmarked_ids', _bookmarks.map((e) => e.toString()).toList());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'テックトレンドまとめ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: _buildHome(context),
    );
  }

  Widget _buildHome(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('テックトレンドまとめ')),
        body: Center(child: Text('読み込みに失敗しました\n$_error')),
      );
    }
    final digest = _digest;
    if (digest == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return FeedPage(
      digest: digest,
      bookmarks: _bookmarks,
      onToggleBookmark: _toggleBookmark,
    );
  }
}

class FeedPage extends StatelessWidget {
  final Digest digest;
  final Set<int> bookmarks;
  final Future<void> Function(int id) onToggleBookmark;

  const FeedPage({
    super.key,
    required this.digest,
    required this.bookmarks,
    required this.onToggleBookmark,
  });

  List<Article> _bySource(String source) =>
      digest.articles.where((a) => a.source == source).toList();

  List<Article> get _rising {
    final list = digest.articles
        .where((a) => a.source == 'github' && a.growthRate != null)
        .toList()
      ..sort((a, b) => b.growthRate!.compareTo(a.growthRate!));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <(String, List<Article>)>[
      ('トップ', digest.articles),
      ('GitHub', _bySource('github')),
      ('Hugging Face', _bySource('huggingface')),
      ('Kaggle', _bySource('kaggle')),
      ('急上昇', _rising),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('テックトレンドまとめ'),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(digest.digestDate,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bookmarks),
              tooltip: '保存済み',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => BookmarksPage(
                    articles: digest.articles
                        .where((a) => bookmarks.contains(a.id))
                        .toList(),
                    bookmarks: bookmarks,
                    onToggleBookmark: onToggleBookmark,
                  ),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final t in tabs) Tab(text: t.$1)],
          ),
        ),
        body: TabBarView(
          children: [
            for (final t in tabs)
              ArticleList(
                articles: t.$2,
                bookmarks: bookmarks,
                onToggleBookmark: onToggleBookmark,
              ),
          ],
        ),
      ),
    );
  }
}

class BookmarksPage extends StatelessWidget {
  final List<Article> articles;
  final Set<int> bookmarks;
  final Future<void> Function(int id) onToggleBookmark;

  const BookmarksPage({
    super.key,
    required this.articles,
    required this.bookmarks,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('保存済み')),
      body: articles.isEmpty
          ? const Center(child: Text('ブックマークした記事はまだありません'))
          : ArticleList(
              articles: articles,
              bookmarks: bookmarks,
              onToggleBookmark: onToggleBookmark,
            ),
    );
  }
}

class ArticleList extends StatelessWidget {
  final List<Article> articles;
  final Set<int> bookmarks;
  final Future<void> Function(int id) onToggleBookmark;

  const ArticleList({
    super.key,
    required this.articles,
    required this.bookmarks,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return const Center(child: Text('記事がありません'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: articles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => ArticleCard(
        article: articles[i],
        bookmarked: bookmarks.contains(articles[i].id),
        onToggleBookmark: () => onToggleBookmark(articles[i].id),
      ),
    );
  }
}

class ArticleCard extends StatelessWidget {
  final Article article;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  const ArticleCard({
    super.key,
    required this.article,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ArticleDetailPage(
              article: article,
              bookmarked: bookmarked,
              onToggleBookmark: onToggleBookmark,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Chip(
                    label: Text(article.sourceLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(article.metricLabel),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (article.growthRate != null) ...[
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                          '急上昇 ${article.growthRate!.toStringAsFixed(1)}/日'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                        bookmarked ? Icons.bookmark : Icons.bookmark_border),
                    tooltip: 'ブックマーク',
                    onPressed: onToggleBookmark,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(article.headlineJa,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(article.summaryJa,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium),
              if (article.secondaryMetric.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(article.secondaryMetric,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
