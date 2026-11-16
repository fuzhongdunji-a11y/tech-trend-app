import 'package:flutter_test/flutter_test.dart';
import 'package:tech_trend_app/models.dart';

void main() {
  test('Digest.fromJson parses articles and terms', () {
    final digest = Digest.fromJson({
      'digestDate': '2026-11-14',
      'articles': [
        {
          'id': 1,
          'source': 'github',
          'title': 'example/repo',
          'headlineJa': 'example/repo',
          'summaryJa': 'summary',
          'detailJa': 'detail',
          'strengthsJa': 'strengths',
          'usageJa': 'usage',
          'usageIdeas': ['idea'],
          'terms': [
            {'term': 'API', 'explanation': 'explanation'}
          ],
          'url': 'https://github.com/example/repo',
          'metricLabel': '★ 100',
          'secondaryMetric': 'フォーク 3',
          'tags': ['tag'],
          'language': 'Dart',
          'growthRate': 12.5,
        }
      ],
    });
    expect(digest.digestDate, '2026-11-14');
    expect(digest.articles, hasLength(1));
    expect(digest.articles.first.sourceLabel, 'GitHub');
    expect(digest.articles.first.terms.first.term, 'API');
    expect(digest.articles.first.growthRate, 12.5);
  });
}
