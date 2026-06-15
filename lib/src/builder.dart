import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'helpers/preferences/preferences_generator.dart';

/// Preferences builder — registered via build.yaml, not meant for direct import.
Builder preferencesBuilder(BuilderOptions options) =>
    PartBuilder([PreferencesGenerator()], '.pref.g.dart');
