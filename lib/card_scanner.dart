import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'models.dart';

class CardScanner {
  static Future<ScanResult> scan(File imageFile) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final result     = await recognizer.processImage(inputImage);
      return _parse(result.text);
    } finally {
      recognizer.close();
    }
  }

  static final _emailRe    = RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
  static final _phoneRe    = RegExp(r'[+\d][\d\s\-().]{5,}\d');
  static final _linkedinRe = RegExp(r'linkedin\.com/in/([^\s/]+)', caseSensitive: false);
  static final _webRe      = RegExp(r'(https?://|www\.)\S+', caseSensitive: false);

  static ScanResult _parse(String raw) {
    final lines = raw.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    final email      = _emailRe.firstMatch(raw)?.group(0) ?? '';
    final linkedinM  = _linkedinRe.firstMatch(raw);
    final linkedinUrl = linkedinM != null
        ? 'https://www.linkedin.com/in/${linkedinM.group(1)}'
        : '';
    final website = _webRe.allMatches(raw)
        .map((m) => m.group(0)!)
        .firstWhere((u) => !u.toLowerCase().contains('linkedin'), orElse: () => '');

    final phones = _phoneRe.allMatches(raw)
        .map((m) => m.group(0)!.trim())
        .where((p) => p.replaceAll(RegExp(r'[^\d]'), '').length >= 6)
        .toSet()
        .toList();

    final metaLines = lines.where((line) =>
        !_emailRe.hasMatch(line) &&
        !_webRe.hasMatch(line) &&
        !_phoneRe.hasMatch(line) &&
        line.length > 1).toList();

    final draft = ContactDraft(
      fullName:    metaLines.isNotEmpty ? metaLines[0] : '',
      jobTitle:    metaLines.length > 1 ? metaLines[1] : '',
      company:     metaLines.length > 2 ? metaLines[2] : '',
      phoneMobile: phones.isNotEmpty ? phones[0] : '',
      phoneWork:   phones.length > 1  ? phones[1] : '',
      email:       email,
      website:     website,
      linkedinUrl: linkedinUrl,
    );

    return ScanResult(draft: draft, lines: lines);
  }
}
