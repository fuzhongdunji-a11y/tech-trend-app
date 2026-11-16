class TermItem {
  final String term;
  final String explanation;
  const TermItem({required this.term, required this.explanation});

  factory TermItem.fromJson(Map<String, dynamic> j) => TermItem(
        term: j['term'] as String? ?? '',
        explanation: j['explanation'] as String? ?? '',
      );
}

class Article {
  final int id;
  final String source;
  final String title;
  final String headlineJa;
  final String summaryJa;
  final String detailJa;
  final String strengthsJa;
  final String usageJa;
  final List<String> usageIdeas;
  final List<TermItem> terms;
  final String url;
  final String metricLabel;
  final String secondaryMetric;
  final List<String> tags;
  final String? language;
  final double? growthRate;

  const Article({
    required this.id,
    required this.source,
    required this.title,
    required this.headlineJa,
    required this.summaryJa,
    required this.detailJa,
    required this.strengthsJa,
    required this.usageJa,
    required this.usageIdeas,
    required this.terms,
    required this.url,
    required this.metricLabel,
    required this.secondaryMetric,
    required this.tags,
    required this.language,
    required this.growthRate,
  });

  factory Article.fromJson(Map<String, dynamic> j) => Article(
        id: (j['id'] as num).toInt(),
        source: j['source'] as String? ?? '',
        title: j['title'] as String? ?? '',
        headlineJa: j['headlineJa'] as String? ?? '',
        summaryJa: j['summaryJa'] as String? ?? '',
        detailJa: j['detailJa'] as String? ?? '',
        strengthsJa: j['strengthsJa'] as String? ?? '',
        usageJa: j['usageJa'] as String? ?? '',
        usageIdeas: (j['usageIdeas'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        terms: (j['terms'] as List?)
                ?.map((e) => TermItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        url: j['url'] as String? ?? '',
        metricLabel: j['metricLabel'] as String? ?? '',
        secondaryMetric: j['secondaryMetric'] as String? ?? '',
        tags:
            (j['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        language: j['language'] as String?,
        growthRate: (j['growthRate'] as num?)?.toDouble(),
      );

  String get sourceLabel => switch (source) {
        'github' => 'GitHub',
        'huggingface' => 'Hugging Face',
        'kaggle' => 'Kaggle',
        _ => source,
      };
}

class Digest {
  final String digestDate;
  final List<Article> articles;
  const Digest({required this.digestDate, required this.articles});

  factory Digest.fromJson(Map<String, dynamic> j) => Digest(
        digestDate: j['digestDate'] as String? ?? '',
        articles: (j['articles'] as List?)
                ?.map((e) => Article.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );
}
