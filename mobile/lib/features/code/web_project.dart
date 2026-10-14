import 'dart:convert';

/// Local learning document. It receives no tokens, keys, native bridges or cookies.
class WebProject {
  const WebProject({
    required this.html,
    required this.css,
    required this.javascript,
  });
  final String html, css, javascript;
  static const starter = WebProject(
    html:
        '<main><h1>မင်္ဂလာပါ!</h1><p>My first web page</p><button id="hello">Say hello</button><p id="message"></p></main>',
    css:
        'body { font-family: sans-serif; background: #080d1b; color: white; padding: 24px; }\nbutton { background: #775cff; color: white; border: 0; border-radius: 12px; padding: 14px; }',
    javascript:
        'document.querySelector("#hello").addEventListener("click", () => {\n  document.querySelector("#message").textContent = "Welcome to Myanmar Academy!";\n});',
  );
  static WebProject decode(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map ||
        json['version'] != 1 ||
        ['html', 'css', 'javascript'].any(
          (key) => json[key] is! String || (json[key] as String).length > 16000,
        )) {
      throw const FormatException('Unreadable web draft');
    }
    return WebProject(
      html: json['html'],
      css: json['css'],
      javascript: json['javascript'],
    );
  }

  String encode() => jsonEncode({
    'version': 1,
    'html': html,
    'css': css,
    'javascript': javascript,
  });

  String previewDocument() {
    if ([html, css, javascript].any((value) => value.length > 16000)) {
      throw const FormatException('Web draft is too large');
    }
    // Raw-text elements end at a literal closing tag even inside JS string quotes.
    // Escape closing raw-text tags without changing comparison operators.
    final safeJs = javascript.replaceAllMapped(
      RegExp(r'</script', caseSensitive: false),
      (match) => '<\\/${match[0]!.substring(2)}',
    );
    final safeCss = css.replaceAllMapped(
      RegExp(r'</style', caseSensitive: false),
      (match) => '<\\/${match[0]!.substring(2)}',
    );
    const policy =
        "default-src 'none'; script-src 'unsafe-inline'; style-src 'unsafe-inline'; img-src data:; font-src data:; connect-src 'none'; frame-src 'none'; child-src 'none'; object-src 'none'; base-uri 'none'; form-action 'none'";
    final child =
        '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="Content-Security-Policy" content="$policy"><style>$safeCss</style></head><body>$html<script>$safeJs</script></body></html>';
    final attribute = const HtmlEscape(HtmlEscapeMode.attribute).convert(child);
    // An opaque sandbox origin prevents access to the parent, storage and cookies.
    // No allow-same-origin, forms, popups, downloads or top-navigation permission.
    return '<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src \'none\'; frame-src about:; script-src \'unsafe-inline\'; style-src \'unsafe-inline\'; img-src data:; font-src data:; connect-src \'none\'; base-uri \'none\'; form-action \'none\'; object-src \'none\'"><style>html,body,iframe{margin:0;width:100%;height:100%;border:0;background:white}</style></head><body><iframe sandbox="allow-scripts" referrerpolicy="no-referrer" srcdoc="$attribute"></iframe></body></html>';
  }
}
