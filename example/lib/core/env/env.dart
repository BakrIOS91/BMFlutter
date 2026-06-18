import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'BASE_URL')
  static final String baseUrl = _Env.baseUrl;

  @EnviedField(varName: 'API_KEY')
  static final String apiKey = _Env.apiKey;

  @EnviedField(varName: 'API_PATH')
  static final String apiPath = _Env.apiPath;

  @EnviedField(varName: 'API_MAIN_PATH')
  static final String apiMainPath = _Env.apiMainPath;

  @EnviedField(varName: 'API_AUTH_MAIN_PATH')
  static final String apiAuthMainPath = _Env.apiAuthMainPath;

  @EnviedField(varName: 'API_RPC_PATH')
  static final String apiRPCPath = _Env.apiRPCPath;

  @EnviedField(varName: 'NOTIFICATION_PROJECT_ID')
  static final String notificationProjectId = _Env.notificationProjectId;

  @EnviedField(varName: 'NOTIFICATION_STORAGE_BUCKET')
  static final String notificationStorageBucket =
      _Env.notificationStorageBucket;

  @EnviedField(varName: 'NOTIFICATION_SENDER_ID')
  static final String notificationSenderId = _Env.notificationSenderId;

  @EnviedField(varName: 'ANDROID_NOTIFICATION_API_KEY')
  static final String androidNotificationApiKey =
      _Env.androidNotificationApiKey;

  @EnviedField(varName: 'ANDROID_NOTIFICATION_APP_ID')
  static final String androidNotificationAppId = _Env.androidNotificationAppId;

  @EnviedField(varName: 'IOS_NOTIFICATION_API_KEY')
  static final String iosNotificationApiKey = _Env.iosNotificationApiKey;

  @EnviedField(varName: 'IOS_NOTIFICATION_APP_ID')
  static final String iosNotificationAppId = _Env.iosNotificationAppId;

  @EnviedField(varName: 'IOS_NOTIFICATION_BUNDLE_ID')
  static final String iosNotificationBundleId = _Env.iosNotificationBundleId;
}
