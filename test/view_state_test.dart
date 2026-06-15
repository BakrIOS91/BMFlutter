import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/view_state.dart';

void main() {
  group('ViewState — non-error states', () {
    test('Loading.isError is false', () {
      expect(const Loading().isError, false);
    });

    test('OverlayLoading.isError is false', () {
      expect(const OverlayLoading().isError, false);
    });

    test('OverlayLoading.color is transparent', () {
      expect(const OverlayLoading().color, Colors.transparent);
    });

    test('Loaded.isError is false', () {
      expect(const Loaded().isError, false);
    });
  });

  group('ViewState — error states', () {
    test('NoNetwork.isError is true', () {
      expect(const NoNetwork().isError, true);
    });

    test('NoData.isError is true', () {
      expect(const NoData().isError, true);
    });

    test('ServerError.isError is true', () {
      expect(const ServerError().isError, true);
    });

    test('UnexpectedError.isError is true', () {
      expect(const UnexpectedError().isError, true);
    });

    test('Unauthorized.isError is true', () {
      expect(const Unauthorized().isError, true);
    });

    test('CustomErrorState.isError is true', () {
      expect(const CustomErrorState().isError, true);
    });

    test('SearchError.isError is true', () {
      expect(const SearchError().isError, true);
    });

    test('ForceUpdateError.isError is true', () {
      expect(const ForceUpdateError().isError, true);
    });

    test('JailBroken.isError is true', () {
      expect(const JailBroken().isError, true);
    });
  });

  group('ViewState — static constants', () {
    test('ViewState.loading is Loading', () {
      expect(ViewState.loading, isA<Loading>());
    });

    test('ViewState.overlayLoading is OverlayLoading', () {
      expect(ViewState.overlayLoading, isA<OverlayLoading>());
    });

    test('ViewState.loaded is Loaded', () {
      expect(ViewState.loaded, isA<Loaded>());
    });

    test('ViewState.noNetwork is NoNetwork', () {
      expect(ViewState.noNetwork, isA<NoNetwork>());
    });

    test('ViewState.noData is NoData', () {
      expect(ViewState.noData, isA<NoData>());
    });

    test('ViewState.serverError is ServerError', () {
      expect(ViewState.serverError, isA<ServerError>());
    });

    test('ViewState.unexpectedError is UnexpectedError', () {
      expect(ViewState.unexpectedError, isA<UnexpectedError>());
    });

    test('ViewState.unauthorized is Unauthorized', () {
      expect(ViewState.unauthorized, isA<Unauthorized>());
    });

    test('ViewState.forceUpdate is ForceUpdateError', () {
      expect(ViewState.forceUpdate, isA<ForceUpdateError>());
    });

    test('ViewState.jailBroken is JailBroken', () {
      expect(ViewState.jailBroken, isA<JailBroken>());
    });

    test('ViewState.searchError is SearchError', () {
      expect(ViewState.searchError, isA<SearchError>());
    });

    test('ViewState.customError is CustomErrorState', () {
      expect(ViewState.customError, isA<CustomErrorState>());
    });
  });

  group('ViewState — errorModel field', () {
    test('NoNetwork stores errorModel', () {
      const state = NoNetwork(errorModel: 'payload');
      expect(state.errorModel, 'payload');
    });

    test('NoData stores errorModel', () {
      const state = NoData(errorModel: 42);
      expect(state.errorModel, 42);
    });

    test('ServerError stores errorModel', () {
      const state = ServerError(errorModel: {'key': 'val'});
      expect(state.errorModel, {'key': 'val'});
    });

    test('UnexpectedError stores errorModel', () {
      const state = UnexpectedError(errorModel: true);
      expect(state.errorModel, true);
    });

    test('Unauthorized stores errorModel', () {
      const state = Unauthorized(errorModel: 'token');
      expect(state.errorModel, 'token');
    });

    test('SearchError stores errorModel', () {
      const state = SearchError(errorModel: 'query');
      expect(state.errorModel, 'query');
    });

    test('ForceUpdateError stores errorModel', () {
      const state = ForceUpdateError(errorModel: 1);
      expect(state.errorModel, 1);
    });

    test('JailBroken stores errorModel', () {
      const state = JailBroken(errorModel: 'device');
      expect(state.errorModel, 'device');
    });
  });

  group('ViewState — CustomErrorState fields', () {
    test('defaults all optional fields', () {
      const state = CustomErrorState();
      expect(state.title, '');
      expect(state.message, '');
      expect(state.image, '');
      expect(state.buttonText, '');
      expect(state.secondaryButtonText, '');
      expect(state.onPressed, isNull);
      expect(state.onSecondaryPressed, isNull);
      expect(state.errorModel, isNull);
    });

    test('stores all provided fields', () {
      void onPress() {}
      void onSecondary() {}
      final state = CustomErrorState(
        title: 'Error',
        message: 'Something went wrong',
        image: 'assets/error.png',
        buttonText: 'Retry',
        secondaryButtonText: 'Cancel',
        onPressed: onPress,
        onSecondaryPressed: onSecondary,
        errorModel: 'model',
      );
      expect(state.title, 'Error');
      expect(state.message, 'Something went wrong');
      expect(state.image, 'assets/error.png');
      expect(state.buttonText, 'Retry');
      expect(state.secondaryButtonText, 'Cancel');
      expect(state.onPressed, onPress);
      expect(state.onSecondaryPressed, onSecondary);
      expect(state.errorModel, 'model');
    });
  });
}
