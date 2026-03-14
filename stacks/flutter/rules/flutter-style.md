# Flutter Style Rules

- Use `const` constructors on every widget that allows it -- this is the single biggest performance win
- Keep widgets under 50 lines in `build()` -- extract sub-widgets when they grow
- Use `StatelessWidget` by default; only use `StatefulWidget` when you need `initState`, `dispose`, or `AnimationController`
- Name files in `snake_case.dart` -- match the primary class name (e.g., `user_profile_screen.dart`)
- Use `dart format` (line length 80) on all files before committing
- Run `dart analyze` with zero warnings -- treat info-level lints as warnings
- Use `flutter_lints` or `very_good_analysis` for a strict lint ruleset
- Prefer Riverpod `ref.watch` in build, `ref.read` in callbacks -- never `ref.watch` inside callbacks
- Use `sealed class` or `freezed` for state and event types in Bloc/Riverpod notifiers
- Keep business logic out of widgets -- all logic belongs in providers, blocs, or use cases
- Use `part` files only for code generation (freezed, json_serializable) -- not for splitting widget files
- Avoid `dynamic` types -- always annotate return types on public methods and provider definitions
- Use trailing commas on all argument lists for consistent formatting by `dart format`
- Dispose controllers, streams, and animation controllers in `dispose()` -- or use Riverpod `ref.onDispose`
- Use `ListView.builder` or `SliverList` for lists over 20 items -- never put large lists inside `Column`
