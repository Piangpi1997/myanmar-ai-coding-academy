// Produce exactly the document used by the Android preview, without a web server.
import 'dart:io';
import '../mobile/lib/features/code/web_project.dart';

void main(List<String> args) {
  if (args.length != 1)
    throw ArgumentError('Provide a temporary output directory');
  final folder = Directory(args.single)..createSync(recursive: true);
  File(
    '${folder.path}/starter.html',
  ).writeAsStringSync(WebProject.starter.previewDocument());
  const attack = WebProject(
    html:
        '<h1 id="original">Restricted frame</h1><img src="https://example.invalid/image.png"><iframe src="https://example.invalid/frame"></iframe><form action="https://example.invalid/post"><input name="data"></form>',
    css: 'body { color: purple; }',
    javascript: '''
      window.securityResults = {};
      try { parent.document.body.innerHTML = "escaped"; window.securityResults.parent = false; }
      catch (_) { window.securityResults.parent = true; }
      try { localStorage.setItem("test", "value"); window.securityResults.storage = false; }
      catch (_) { window.securityResults.storage = true; }
      try { document.cookie = "token=unexpected"; window.securityResults.cookies = false; }
      catch (_) { window.securityResults.cookies = true; }
      window.securityResults.comparison = 1 < 2;
      window.securityResults.closing = "</SCRIPT>";
      fetch("https://example.invalid/api").then(() => window.securityResults.fetch = false)
        .catch(() => window.securityResults.fetch = true);
    ''',
  );
  File(
    '${folder.path}/restrictions.html',
  ).writeAsStringSync(attack.previewDocument());
  const error = WebProject(
    html: '<p>Error exercise</p>',
    css: '',
    javascript: 'throw new Error("academy-test-error");',
  );
  File('${folder.path}/error.html').writeAsStringSync(error.previewDocument());
  stdout.writeln('Exported 3 preview fixtures');
}
