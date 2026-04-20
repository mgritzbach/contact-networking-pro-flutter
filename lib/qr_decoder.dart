import 'package:mobile_scanner/mobile_scanner.dart';

class QrDecoder {
  /// Decodes the first QR code found in [imagePath].
  /// Returns the decoded string, or null if no QR is found.
  static Future<String?> decodeFromPath(String imagePath) async {
    final controller = MobileScannerController(
      formats: [BarcodeFormat.qrCode],
    );
    try {
      final capture = await controller.analyzeImage(imagePath);
      return capture?.barcodes.firstOrNull?.rawValue;
    } catch (_) {
      return null;
    } finally {
      controller.dispose();
    }
  }
}
