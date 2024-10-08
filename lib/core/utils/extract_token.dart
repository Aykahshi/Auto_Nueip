import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;

String extractToken(String html) {
  final Document document = parse(html);
  final Element? tag = document.querySelector('input[name="token"]');

  if (tag != null) {
    final String token = tag.attributes['value'] ?? '';
    return token;
  }

  return '';
}
