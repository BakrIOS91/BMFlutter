import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/helpers/preferences/preferences_generator.dart';

/// Preferences builder
Builder preferencesBuilder(BuilderOptions options) =>
    PartBuilder([PreferencesGenerator()], '.pref.g.dart');
