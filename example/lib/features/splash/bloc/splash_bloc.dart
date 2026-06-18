// Dart imports:
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_example/core/env/env.dart';
import 'package:flutter_example/core/firebase_services/notification_service_manager.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/app_targets.dart';
import 'package:flutter_example/services/client/common_client.dart';
import 'package:flutter_example/services/models/lookups/lookups_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter/core.dart';
import 'package:flutter_example/utilities/reusables/with_view_state.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

part 'splash_bloc.freezed.dart';
part 'splash_event.dart';
part 'splash_state.dart';

@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  late final AppLifecycleListener listener;
  late AppPreferences pref;
  late NotificationService notificationService;
  late CommonClient commonClient;

  SplashBloc({
    required this.pref,
    required this.notificationService,
    required this.commonClient,
  }) : super(SplashState.initial()) {
    on<SplashEvent>(_onEvent);
    listener = AppLifecycleListener(
      onResume: () {
        if (!isClosed) {
          add(const SplashEvent.requestNotification());
        }
      },
    );
  }

  Future<void> _onEvent(
    SplashEvent event,
    Emitter<SplashState> emit,
  ) async {
    event.map(
      started: (_) async {
        add(const SplashEvent.requestNotification());
        add(const SplashEvent.fetchLookups());
      },
      requestNotification: (_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        if (pref.notificationGranted) {
          await notificationService.checkNotificationStatus();
          await notificationService.setupTokenHandling();
        } else {
          await notificationService.init();
        }
      },
      checkJailBreak: (event) async {
        final SecurityCheckResult result =
            await DeviceSecurityHelper.checkDeviceSecurity(
          checkDebugging: appEnv == AppEnvironment.production ? true : false,
          checkEmulator: appEnv == AppEnvironment.production ? true : false,
          bundleId: Env.iosNotificationBundleId,
        );

        add(SplashEvent.jailbreakResponse(result));
      },
      jailbreakResponse: (event) {
        if (event.result.isSecure) {
          log("✅ Device is secure");
          emit(
            state.copyWith(
              viewState: ViewState.loaded,
              navigation: pref.isFreshInstalled
                  ? SplashNavigation.onboarding
                  : SplashNavigation.tab,
            ),
          );
        } else {
          log("❌ Device is NOT secure:");
          log(event.result.reason);
          emit(state.copyWith(viewState: ViewState.jailBroken));
        }
      },
      fetchLookups: (_) async {
        add(SplashEvent.lookupResponse(await commonClient.getLookups()));
      },
      lookupResponse: (event) {
        event.result.when(
          success: (response) {
            if (response != null) {
              pref.lookups = response;
            }

            emit(
              state.copyWith(
                navigation: pref.isFreshInstalled
                    ? SplashNavigation.onboarding
                    : SplashNavigation.tab,
              ),
            );
          },
          failure: (error) {
            emit(state.copyWith(viewState: WithViewState.failHandler(error)));
          },
        );
      },
    );
  }

  @override
  Future<void> close() {
    listener.dispose();
    return super.close();
  }
}
