import 'package:bmflutter/src/helpers/preferences/preferences_generator.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

Builder preferencesBuilder(BuilderOptions options) =>
    PartBuilder([PreferencesGenerator()], '.preferences.dart');
