import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/helpers/preferences/preferences_generator.dart';
import 'src/helpers/river_pod/di/provider_generator.dart';
import 'src/helpers/river_pod/reducer/reducer_generator.dart';

/// Preferences builder
Builder preferencesBuilder(BuilderOptions options) =>
    PartBuilder([PreferencesGenerator()], '.preferences.g.dart');

/// Reducer builder
Builder reducerBuilder(BuilderOptions options) =>
    PartBuilder([ReducerGenerator()], '.reducer.g.dart');

/// Provider DI builder (your ProviderGenerator)
Builder providerBuilder(BuilderOptions options) =>
    PartBuilder([ProviderGenerator()], '.providers.g.dart');
