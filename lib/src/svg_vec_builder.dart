import 'dart:async';

import 'package:build/build.dart';
import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';

/// Compiles each `.svg` asset in a consuming app into a `<name>.svg.vec`
/// binary next to it — the same way `freezed`/`json_serializable` generate
/// `.g.dart` next to their source. Registered via build.yaml with
/// `auto_apply: dependents`, so any app depending on this package gets it
/// automatically; run `dart run build_runner build` (or `watch` to keep it
/// running in the background) in that app.
///
/// Rendering the `.svg.vec` output (instead of the raw `.svg`) skips
/// `flutter_svg`'s runtime XML parsing/tessellation — the source of visible
/// jank/memory spikes when many SVGs mount at once (e.g. list scrolling).
/// Load it with `SvgPicture(AssetBytesLoader('assets/icons/foo.svg.vec'))`
/// from `package:vector_graphics/vector_graphics.dart` /
/// `package:flutter_svg/flutter_svg.dart`.
///
/// The `.svg.vec` output is a generated build artifact — do not commit it;
/// add `**/*.svg.vec` to the consuming app's `.gitignore`.
class SvgVecBuilder implements Builder {
  const SvgVecBuilder();

  @override
  Map<String, List<String>> get buildExtensions => const {
        '.svg': ['.svg.vec'],
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    final xml = await buildStep.readAsString(buildStep.inputId);
    // The masking/clipping/overdraw optimizers need a native path-ops lib
    // that only the vector_graphics_compiler CLI wires up automatically;
    // skipping them keeps this builder dependency-free. They only shrink
    // the compiled output for edge cases (overlapping clips/masks) — never
    // affects correctness.
    final bytes = encodeSvg(
      xml: xml,
      debugName: buildStep.inputId.path,
      enableMaskingOptimizer: false,
      enableClippingOptimizer: false,
      enableOverdrawOptimizer: false,
    );
    await buildStep.writeAsBytes(buildStep.inputId.addExtension('.vec'), bytes);
  }
}

/// Builder factory — registered via build.yaml, not meant for direct import.
Builder svgVecBuilder(BuilderOptions options) => const SvgVecBuilder();
