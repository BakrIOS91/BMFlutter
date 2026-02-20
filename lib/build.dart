import 'package:bmflutter/src/helpers/preferences/preferences_generator.dart';
import 'package:bmflutter/src/helpers/reducer/reducer_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Preferences builder
Builder preferencesBuilder(BuilderOptions options) =>
    PartBuilder([PreferencesGenerator()], '.preferences.g.dart');

/// Reducer builder
Builder reducerBuilder(BuilderOptions options) =>
    PartBuilder([ReducerGenerator()], '.reducer.g.dart');
