import 'di_enums.dart';
import 'package:meta/meta.dart';

/// Annotation for generating Riverpod providers
@immutable
class Provider {
  /// The interface or type the provider should expose
  final Type? asType;

  /// Which environments this provider should be active in
  final List<DIEnvironment>? env;

  /// The type of provider
  final ProviderType type;

  const Provider({this.asType, this.env, this.type = ProviderType.singleton});
}
