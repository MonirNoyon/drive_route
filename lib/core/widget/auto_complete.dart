import 'package:flutter/material.dart';

/// A very simple, professional autocomplete list for location suggestions.
/// - Pass an updated [items] list whenever the user types (e.g., from your API).
/// - [onChange] is fired on every text change.
/// - [onSelected] is fired when a suggestion is tapped.
///
/// Keep the parent in charge of fetching and passing [items].
class GoogleAutoCompLocSuggestion<T> extends StatelessWidget {
  const GoogleAutoCompLocSuggestion({
    super.key,
    required this.items,
    required this.onChange,
    required this.onSelected,
    this.controller,
    this.hintText = 'Search location',
    this.isLoading = false,
    this.emptyPlaceholder = 'No suggestions',
    this.maxListHeight = 240,
    this.decoration,
    this.leadingIcon,
  });

  /// Updated list of suggestions to show (parent supplies this).
  final List<T> items;

  /// Called on every text change.
  final ValueChanged<String> onChange;

  /// Called when user selects a suggestion.
  final ValueChanged<T> onSelected;

  /// Optional external controller (useful if you want to read/set text).
  final TextEditingController? controller;

  /// TextField hint.
  final String hintText;

  /// If true, shows a small progress indicator above the list.
  final bool isLoading;

  /// Message shown when [items] is empty and not loading.
  final String emptyPlaceholder;

  /// Max height for suggestions list.
  final double maxListHeight;

  /// Optional TextField decoration override.
  final InputDecoration? decoration;

  /// Optional leading icon inside the TextField.
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final textController = controller ?? TextEditingController();

    final inputDecoration = (decoration ??
        InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
          prefixIcon: leadingIcon ?? const Icon(Icons.search),
          isDense: true,
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.clear),
                onPressed: () {
                  textController.clear();
                  onChange('');
                },
              );
            },
          ),
        ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: textController,
          onChanged: onChange,
          textInputAction: TextInputAction.search,
          decoration: inputDecoration,
        ),
        const SizedBox(height: 8),
        if (isLoading) const LinearProgressIndicator(minHeight: 2),
        if (!isLoading)
          _SuggestionList<T>(
            items: items,
            onSelect: (value) {
              // If caller passed a controller, reflect the selected text.
              if (controller != null) {
                // controller!.text = value;
                controller!.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller!.text.length),
                );
              }
              onSelected(value);
            },
            emptyPlaceholder: emptyPlaceholder,
            maxListHeight: maxListHeight,
          ),
      ],
    );
  }
}

class _SuggestionList<T> extends StatelessWidget {
  const _SuggestionList({
    required this.items,
    required this.onSelect,
    required this.emptyPlaceholder,
    required this.maxListHeight,
  });

  final List<T> items;
  final ValueChanged<T> onSelect;
  final String emptyPlaceholder;
  final double maxListHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nothing to show
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          emptyPlaceholder,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
      );
    }

    // Suggestions
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxListHeight),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(6),
        clipBehavior: Clip.antiAlias,
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final text = items[index];
            return InkWell(
              onTap: () => onSelect(text),
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.place, size: 18),
                    const SizedBox(width: 8),
                    // Expanded(
                    //   child: Text(
                    //     text,
                    //     maxLines: 1,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: theme.textTheme.bodyMedium,
                    //   ),
                    // ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}