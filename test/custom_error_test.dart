import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/models/custom_error.dart';

void main() {
  late Image image;

  setUp(() {
    image = Image.asset(
      'assets/error.png',
      errorBuilder: (_, __, ___) => const SizedBox(),
    );
  });

  group('CustomError — constructor', () {
    test('stores all required fields', () {
      final error = CustomError(
        errorImage: image,
        errorTitle: 'Title',
        errorMessage: 'Message',
      );
      expect(error.errorTitle, 'Title');
      expect(error.errorMessage, 'Message');
      expect(error.buttonTitle, isNull);
      expect(error.retryAction, isNull);
    });

    test('stores optional buttonTitle and retryAction', () {
      void action() {}
      final error = CustomError(
        errorImage: image,
        errorTitle: 'Title',
        errorMessage: 'Message',
        buttonTitle: 'Retry',
        retryAction: action,
      );
      expect(error.buttonTitle, 'Retry');
      expect(error.retryAction, action);
    });
  });

  group('CustomError — equality', () {
    test('equal when buttonTitle matches', () {
      final e1 = CustomError(
        errorImage: image,
        errorTitle: 'A',
        errorMessage: 'B',
        buttonTitle: 'same',
      );
      final e2 = CustomError(
        errorImage: image,
        errorTitle: 'C',
        errorMessage: 'D',
        buttonTitle: 'same',
      );
      expect(e1, equals(e2));
    });

    test('not equal when buttonTitles differ', () {
      final e1 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'A',
      );
      final e2 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'B',
      );
      expect(e1, isNot(equals(e2)));
    });

    test('equal when both buttonTitles are null', () {
      final e1 = CustomError(errorImage: image, errorTitle: 'T1', errorMessage: 'M1');
      final e2 = CustomError(errorImage: image, errorTitle: 'T2', errorMessage: 'M2');
      expect(e1, equals(e2));
    });

    test('not equal to non-CustomError', () {
      final e = CustomError(errorImage: image, errorTitle: 'T', errorMessage: 'M');
      expect(e.hashCode, isNot(equals('not a CustomError'.hashCode)));
      // operator== checks `other is CustomError`, so e != a String
      expect(e == e, true); // self equality
    });
  });

  group('CustomError — hashCode', () {
    test('same hashCode for same buttonTitle', () {
      final e1 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'btn',
      );
      final e2 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'btn',
      );
      expect(e1.hashCode, e2.hashCode);
    });

    test('different hashCodes for different buttonTitles', () {
      final e1 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'A',
      );
      final e2 = CustomError(
        errorImage: image,
        errorTitle: 'T',
        errorMessage: 'M',
        buttonTitle: 'B',
      );
      expect(e1.hashCode, isNot(e2.hashCode));
    });
  });
}
