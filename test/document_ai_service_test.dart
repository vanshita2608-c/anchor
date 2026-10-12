import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:anchor/core/services/document_ai_service.dart';

void main() {
  group('DocumentAiService Tests', () {
    test('Simulate AI OCR extraction produces structured metadata', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
      final result = await DocumentAiService.instance.analyzeDocument(
        imageBytes: bytes,
      );

      expect(result.title, isNotEmpty);
      expect(result.category, equals('Financial & Legal'));
      expect(result.holderName, equals('Vanshita Shah'));
      expect(result.documentNumber, contains('POL-82910'));
      expect(result.tags, contains('Vault'));
    });
  });
}
