/// Enums and Constants for LDFlutter Network Layer
///
/// This file contains all the enumerations, constants, and error types used
/// throughout the LDFlutter core layer. It provides type-safe definitions
/// for HTTP methods, status codes, request types, error categories, and
/// multipart form data handling.
///
/// The enums are designed to be comprehensive and cover all common core
/// scenarios, from basic HTTP requests to complex file uploads and downloads.
/// Error handling is built into the enums with descriptive error messages
/// and proper categorization.
///
/// Usage:
/// ```dart
/// final method = HTTPMethod.post;
/// final status = HTTPStatusCode.from(200);
/// ```
library;

import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Represents different app environments for configuration management
///
/// This enum defines the various deployment environments that the app
/// can run in, allowing for environment-specific configurations and
/// behaviors. Each environment can have different API endpoints,
/// logging levels, and feature flags.
enum AppEnvironment {
  /// Development environment for local development and testing
  development,

  /// Testing environment for automated tests and QA
  testing,

  /// Staging environment for pre-production testing
  staging,

  /// Pre-production environment for final testing before release
  preProduction,

  /// Production environment for live users
  production,
}

extension AppEnvironmentEnv on AppEnvironment {
  static AppEnvironment fromString(String value) {
    switch (value.toLowerCase()) {
      case 'development':
      case 'dev':
        return AppEnvironment.development;

      case 'testing':
      case 'test':
        return AppEnvironment.testing;

      case 'staging':
        return AppEnvironment.staging;

      case 'preproduction':
      case 'pre_production':
      case 'pre-production':
      case 'preprod':
        return AppEnvironment.preProduction;

      case 'production':
      case 'prod':
        return AppEnvironment.production;

      default:
        return AppEnvironment.development;
    }
  }
}

/// Represents the type of core request protocol
///
/// This enum defines the supported core request types, allowing the
/// system to handle different API protocols with appropriate configurations.
enum RequestType {
  /// REST API requests using standard HTTP methods
  rest,

  /// SOAP API requests using XML-based messaging
  soap,
}

/// Represents HTTP request methods as defined in RFC 7231
///
/// This enum provides type-safe HTTP method definitions that can be
/// easily converted to strings for use in HTTP requests. It covers
/// all standard HTTP methods including the most commonly used ones.
enum HTTPMethod {
  /// GET method for retrieving data
  get,

  /// POST method for creating new resources
  post,

  /// PUT method for updating existing resources
  put,

  /// DELETE method for removing resources
  delete,

  /// PATCH method for partial updates
  patch,

  /// HEAD method for retrieving headers only
  head,

  /// OPTIONS method for CORS preflight requests
  options,

  /// TRACE method for debugging
  trace,

  /// CONNECT method for tunneling
  connect,
}

/// Extension to get the string value for each HTTP method
///
/// This extension provides a convenient way to convert HTTPMethod enum
/// values to their string representations for use in HTTP requests.
extension HTTPMethodExtension on HTTPMethod {
  /// Returns the uppercase string representation of the HTTP method
  ///
  /// Example: HTTPMethod.post.value returns "POST"
  String get value => name.toUpperCase();
}

/// Base class for multipart form data types
///
/// This sealed class serves as the base for different types of multipart
/// form data that can be sent in HTTP requests. It uses the sealed class
/// pattern to ensure type safety and exhaustive pattern matching.
sealed class MultipartFormData {
  const MultipartFormData();
}

/// Multipart form data for binary file uploads
///
/// This class represents binary data that can be uploaded as part
/// of a multipart form request. It includes the file data, filename,
/// and MIME type for proper handling by the server.
class MultipartFormDataData extends MultipartFormData {
  /// The binary data of the file
  final Uint8List data;

  /// The name of the file
  final String fileName;

  /// The MIME type of the file (e.g., 'image/jpeg', 'application/pdf')
  final String mimeType;

  /// Creates a new MultipartFormDataData instance
  ///
  /// Parameters:
  /// - [data]: The binary data of the file
  /// - [fileName]: The name of the file
  /// - [mimeType]: The MIME type of the file
  const MultipartFormDataData({
    required this.data,
    required this.fileName,
    required this.mimeType,
  });
}

/// Multipart form data for text field uploads
///
/// This class represents text data that can be sent as part of a
/// multipart form request. It can handle any dynamic value that
/// can be converted to a string.
class MultipartFormDataText extends MultipartFormData {
  /// The text value to be sent
  final dynamic value;

  /// Creates a new MultipartFormDataText instance
  ///
  /// Parameters:
  /// - [value]: The text value to be sent (will be converted to string)
  const MultipartFormDataText(this.value);
}

/// Represents different types of core request tasks
///
/// This enum defines the various types of core operations that can be
/// performed, from simple requests to complex file uploads and downloads.
/// Each task type has specific handling logic in the core layer.
enum RequestTaskType {
  /// Plain request with no additional data
  plain,

  /// Request with URL parameters
  parameters,

  /// Request with JSON-encoded body
  encodedBody,

  /// File upload request
  uploadFile,

  /// Multipart form data upload
  uploadMultipart,

  /// File download request
  download,

  /// Resumable file download with offset support
  downloadResumable,
}

/// Represents HTTP status code categories for response handling
///
/// This enum categorizes HTTP status codes into logical groups for
/// easier handling and error management. It provides a factory method
/// to convert numeric status codes to their appropriate categories.
enum HTTPStatusCode {
  /// 1xx Informational responses
  information,

  /// 2xx Success responses
  success,

  /// 3xx Redirection responses
  redirection,

  /// 404 Not Found (specific common error)
  notFound,

  /// 401 Unauthorized (specific common error)
  notAuthorize,

  /// 4xx Client error responses
  clientError,

  /// 5xx Server error responses
  serverError,

  /// Unknown or unhandled status codes
  unknown;

  /// Factory method to create HTTPStatusCode from numeric status code
  ///
  /// This method analyzes the numeric status code and returns the
  /// appropriate HTTPStatusCode category for easier handling.
  ///
  /// Parameters:
  /// - [code]: The numeric HTTP status code
  ///
  /// Returns the corresponding HTTPStatusCode category
  static HTTPStatusCode from(int code) {
    // 1xx Informational responses
    if (code >= 100 && code < 200) return HTTPStatusCode.information;

    // 2xx Success responses
    if (code >= 200 && code < 300) return HTTPStatusCode.success;

    // 3xx Redirection responses
    if (code >= 300 && code < 400) return HTTPStatusCode.redirection;

    // Specific common error codes
    if (code == 401) return HTTPStatusCode.notAuthorize;
    if (code == 404) return HTTPStatusCode.notFound;

    // 4xx Client error responses
    if (code >= 400 && code < 500) return HTTPStatusCode.clientError;

    // 5xx Server error responses
    if (code >= 500 && code < 600) return HTTPStatusCode.serverError;

    // Unknown status codes
    return HTTPStatusCode.unknown;
  }
}

/// Enum for supported locales with their string representations.
enum SupportedLocale {
  // Arabic
  ar("ar"),
  arAE("ar_AE"), // Arabic (United Arab Emirates)
  arBH("ar_BH"), // Arabic (Bahrain)
  arDZ("ar_DZ"), // Arabic (Algeria)
  arEG("ar_EG"), // Arabic (Egypt)
  arIQ("ar_IQ"), // Arabic (Iraq)
  arJO("ar_JO"), // Arabic (Jordan)
  arKW("ar_KW"), // Arabic (Kuwait)
  arLB("ar_LB"), // Arabic (Lebanon)
  arLY("ar_LY"), // Arabic (Libya)
  arMA("ar_MA"), // Arabic (Morocco)
  arOM("ar_OM"), // Arabic (Oman)
  arQA("ar_QA"), // Arabic (Qatar)
  arSA("ar_SA"), // Arabic (Saudi Arabia)
  arSD("ar_SD"), // Arabic (Sudan)
  arSY("ar_SY"), // Arabic (Syria)
  arTN("ar_TN"), // Arabic (Tunisia)
  arYE("ar_YE"), // Arabic (Yemen)

  // English
  en("en"),
  enAu("en_AU"), // English (Australia)
  enCa("en_CA"), // English (Canada)
  enGb("en_GB"), // English (United Kingdom)
  enUs("en_US"), // English (United States)

  // German
  de("de"),
  deDe("de_DE"), // German (Germany)
  deAt("de_AT"), // German (Austria)
  deCh("de_CH"), // German (Switzerland)

  // Spanish
  es("es"),
  esEs("es_ES"), // Spanish (Spain)
  esMx("es_MX"), // Spanish (Mexico)

  // French
  fr("fr"),
  frCa("fr_CA"), // French (Canada)
  frFr("fr_FR"), // French (France)

  // Other languages
  caEs("ca_ES"), // Catalan (Spain)
  csCz("cs_CZ"), // Czech (Czech Republic)
  daDk("da_DK"), // Danish (Denmark)
  elGr("el_GR"), // Greek (Greece)
  fiFi("fi_FI"), // Finnish (Finland)
  hiIn("hi_IN"), // Hindi (India)
  hrHr("hr_HR"), // Croatian (Croatia)
  huHu("hu_HU"), // Hungarian (Hungary)
  idId("id_ID"), // Indonesian (Indonesia)
  itIt("it_IT"), // Italian (Italy)
  jaJp("ja_JP"), // Japanese (Japan)
  koKr("ko_KR"), // Korean (South Korea)
  msMy("ms_MY"), // Malay (Malaysia)
  nbNo("nb_NO"), // Norwegian Bokmål (Norway)
  nlNl("nl_NL"), // Dutch (Netherlands)
  plPl("pl_PL"), // Polish (Poland)
  ptBr("pt_BR"), // Portuguese (Brazil)
  ptPt("pt_PT"), // Portuguese (Portugal)
  roRo("ro_RO"), // Romanian (Romania)
  ruRu("ru_RU"), // Russian (Russia)
  skSk("sk_SK"), // Slovak (Slovakia)
  svSe("sv_SE"), // Swedish (Sweden)
  thTh("th_TH"), // Thai (Thailand)
  trTr("tr_TR"), // Turkish (Turkey)
  ukUa("uk_UA"), // Ukrainian (Ukraine)
  viVn("vi_VN"), // Vietnamese (Vietnam)
  zhCn("zh_CN"), // Chinese (China)
  zhHk("zh_HK"), // Chinese (Hong Kong)
  zhTw("zh_TW"); // Chinese (Taiwan)
  // Chinese (Taiwan)

  const SupportedLocale(this.rawValue);
  final String rawValue;

  /// Returns the `Locale` object corresponding to the supported locale.
  Locale get locale {
    final parts = rawValue.split('_');
    if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}
