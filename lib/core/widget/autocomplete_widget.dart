import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A strict autocomplete that only accepts values chosen from the suggestion list.
/// Typing is allowed for searching, but the final value is set ONLY after selection.
/// If the user leaves the field without selecting a valid option, the text is cleared.
class StrictAutocomplete<T extends Object> extends StatefulWidget {
  const StrictAutocomplete({
    super.key,
    required this.items,
    required this.displayStringForOption,
    this.onSelected,
    this.initialValue,
    this.filterFn,
    this.decoration,
    this.enabled = true,
    this.emptyStateBuilder,
    this.optionsMaxHeight = 240,
    this.debounce = const Duration(milliseconds: 0),
    this.validator,
    this.focusNode,
    this.textStyle,
    this.hintText,
    this.labelText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChange,
    this.controller, // if you want to read text externally
  });

  /// Full list of items.
  final List<T> items;

  /// How to display an option as text.
  final String Function(T) displayStringForOption;

  /// Called when an item is selected.
  final ValueChanged<T?>? onSelected;

  /// Initial value (must be present in [items] to show as text).
  final T? initialValue;

  /// Custom filter. Defaults to case-insensitive "contains" on display string.
  final bool Function(String text, T option)? filterFn;

  /// TextFormField decoration convenience.
  final InputDecoration? decoration;

  /// Enable/disable the whole field.
  final bool enabled;

  /// Widget to show when there are no matches.
  final WidgetBuilder? emptyStateBuilder;

  /// Max height for the dropdown list.
  final double optionsMaxHeight;

  /// Optional debounce while typing (0 = off).
  final Duration debounce;

  /// Optional validator (runs on the visible text).
  final String? Function(String?)? validator;
  final  Function(String?)? onChange;

  /// Provide a FocusNode if you need control.
  final FocusNode? focusNode;

  /// Optional text style for the field.
  final TextStyle? textStyle;

  final String? hintText;
  final String? labelText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Optional external controller to read the text. (Do NOT set it yourself.)
  /// The widget manages the content: it writes only on selection or when clearing.
  final TextEditingController? controller;

  @override
  State<StrictAutocomplete<T>> createState() => _StrictAutocompleteState<T>();
}

class _StrictAutocompleteState<T extends Object> extends State<StrictAutocomplete<T>> with WidgetsBindingObserver {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController();
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  T? _selected;
  String _lastQuery = '';
  DateTime _lastType = DateTime.fromMillisecondsSinceEpoch(0);
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (widget.initialValue != null) {
      _selected = widget.initialValue;
      _controller.text = widget.displayStringForOption(widget.initialValue as T);
    }

    // When focus is lost, enforce "selection-only".
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _enforceSelectionOnly();
      }
    });
    // Listen to controller changes to update the clear button visibility.
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = MediaQuery.of(context).viewInsets.bottom > 0;
    if (visible != _keyboardVisible) {
      _keyboardVisible = visible;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // This fires when the keyboard (IME) shows/hides.
    final bottomInset = WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
        ? WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom
        : 0.0;
    final visible = bottomInset > 0;
    if (visible != _keyboardVisible && mounted) {
      setState(() {
        _keyboardVisible = visible;
      });
    }
  }

  void _enforceSelectionOnly() {
    // If the visible text doesn't match the selected option, clear it.
    final text = _controller.text.trim();
    if (_selected == null ||
        text != widget.displayStringForOption(_selected as T)) {
      _selected = null;
      _controller.text = '';
      widget.onSelected?.call(null);
      setState(() {}); // update validator/UI if needed
    }
  }

  Iterable<T> _defaultFilter(String text, Iterable<T> options) {
    final q = text.toLowerCase();
    return options.where((o) =>
        widget.displayStringForOption(o).toLowerCase().contains(q));
  }


  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<T>(
      focusNode: _focusNode,
      textEditingController: _controller,
      displayStringForOption: widget.displayStringForOption,
      optionsBuilder: (TextEditingValue te) {
        if (!_focusNode.hasFocus || !_keyboardVisible) {
          return <T>[];
        }
        if (widget.debounce.inMilliseconds > 0) {
          final now = DateTime.now();
          final diff = now.difference(_lastType);
          _lastType = now;
          _lastQuery = te.text;
          if (diff < widget.debounce) {

          }
        }
        final opts = widget.items;
        if (te.text.isEmpty) {
          return opts;
        }
        final filter = widget.filterFn;
        return filter == null
            ? _defaultFilter(te.text, opts)
            : opts.where((o) => filter(te.text, o));
      },
      onSelected: (T option) {
        // Accept only via selection.
        _selected = option;
        final text = widget.displayStringForOption(option);
        // Ensure the field reflects the chosen value.
        _controller
          ..text = text
          ..selection =
          TextSelection.collapsed(offset: text.length);
        widget.onSelected?.call(option);
        setState(() {});
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          enabled: widget.enabled,
          validator: widget.validator,
          onChanged: widget.onChange,
          style: widget.textStyle ?? const TextStyle(
            color: Colors.white,
          ),
          onFieldSubmitted: (_) {
            _enforceSelectionOnly();
          },
          decoration: (widget.decoration ??
              const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ))
              .copyWith(
            hintText: widget.hintText,
            labelText: widget.labelText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon ??
                (_controller.text.isEmpty || !widget.enabled
                    ? null
                    : IconButton(
                        tooltip: 'Clear',
                        icon:  Icon(CupertinoIcons.clear_circled,color: Colors.red,size: 16,),
                        onPressed: () {
                          _selected = null;
                          _controller.clear();
                          widget.onSelected?.call(null);
                          setState(() {});
                        },
                      )),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final opts = options.toList();
        if (!_focusNode.hasFocus || !_keyboardVisible) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: EdgeInsets.only(top: 3),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: widget.optionsMaxHeight),
              child: opts.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: opts.length,
                separatorBuilder: (_, __) =>
                const Divider(height: 1),
                itemBuilder: (context, index) {
                  final option = opts[index];
                  final label = widget.displayStringForOption(option);
                  return InkWell(
                    onTap: () => onSelected(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // if (widget.emptyStateBuilder != null) {
    //   return widget.emptyStateBuilder!(context);
    // }
    return const SizedBox(
      height: 56,
      child: Center(
        child: Text('No matches'),
      ),
    );
  }
}