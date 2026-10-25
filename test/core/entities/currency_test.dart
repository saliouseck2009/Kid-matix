import 'package:flutter_test/flutter_test.dart';
import 'package:kid_matix/core/entities/currency.dart';

void main() {
  group('Currency', () {
    test('is the CFA franc by default, in the plural of the statements', () {
      // Assert
      expect(Currency.defaultCurrency, Currency.cfaFranc);
      expect(Currency.cfaFranc.code, 'XOF');
      expect(Currency.cfaFranc.unitName, 'francs');
    });
    test('is the same currency when it has the same code', () {
      // Arrange
      const Currency other = Currency(code: 'XOF', unitName: 'francs CFA');
      // Assert
      expect(other, Currency.cfaFranc);
      expect(other.hashCode, Currency.cfaFranc.hashCode);
      expect(
        const Currency(code: 'GMD', unitName: 'dalasis'),
        isNot(Currency.cfaFranc),
      );
      expect(Currency.cfaFranc.toString(), 'XOF');
    });
  });
}
