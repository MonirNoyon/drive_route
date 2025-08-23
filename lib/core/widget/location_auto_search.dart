
import 'dart:async';
import 'package:flutter/material.dart';

class GoogleSearchAutoComplete<T> extends StatefulWidget {
  const GoogleSearchAutoComplete({
    super.key,
    required this.places,
    required this.onSelected,
    this.onChange,
    this.controller,
    this.focusNode,
    this.hintText = 'Search',
    this.decoration,
    this.minSearchLength = 1,
    this.debounceMs = 200,
    this.maxListHeight = 280,
    this.itemBuilder,
    this.displayStringForOption,
    this.inputTextStyle,
    this.emptyBuilder,
    this.noResultsText = 'No results',
    this.caseSensitive = false,
    this.autofocus = false,
  });

  /// Source data
  final List<T> places;

  /// Callback when a user selects an item
  final ValueChanged<T> onSelected;

  /// Callback as the query changes
  final ValueChanged<String>? onChange;

  /// Optional text controller / focus node
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// UI config
  final String hintText;
  final InputDecoration? decoration;
  final TextStyle? inputTextStyle;
  final bool autofocus;

  /// Filtering config
  final int minSearchLength;
  final int debounceMs;
  final double maxListHeight;
  final bool caseSensitive;

  /// How to show each item (default = option.toString())
  final String Function(T option)? displayStringForOption;

  /// Optional custom row UI for items
  final Widget Function(BuildContext context, T option, String query)? itemBuilder;

  /// Optional custom "empty" widget
  final Widget Function(BuildContext context, String query)? emptyBuilder;
  final String noResultsText;

  @override
  State<GoogleSearchAutoComplete<T>> createState() => _GoogleSearchAutoCompleteState<T>();
}

class _GoogleSearchAutoCompleteState<T> extends State<GoogleSearchAutoComplete<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _debounce;

  List<T> _filtered = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        _recompute(); // show when focused, if there’s content
        _showOrUpdateOverlay();
      }
    });

    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant GoogleSearchAutoComplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If source list changes, recompute
    if (!identical(oldWidget.places, widget.places)) {
      _recompute();
      _showOrUpdateOverlay();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    widget.onChange?.call(text);

    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      _query = text;
      _recompute();
      _showOrUpdateOverlay();
    });
  }

  String _toDisplay(T o) {
    final f = widget.displayStringForOption;
    return (f != null ? f(o) : o.toString());
  }

  void _recompute() {
    final q = widget.caseSensitive ? _query : _query.toLowerCase();
    if (q.trim().length < widget.minSearchLength) {
      setState(() => _filtered = const []);
      return;
    }
    final list = widget.places;
    final results = <T>[];
    for (final item in list) {
      final s = _toDisplay(item);
      final hay = widget.caseSensitive ? s : s.toLowerCase();
      if (hay.contains(q)) results.add(item);
    }
    setState(() => _filtered = results);
  }

  void _showOrUpdateOverlay() {
    if (!_focusNode.hasFocus) return;

    if (_filtered.isEmpty && _query.trim().length < widget.minSearchLength) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry == null) {
      _overlayEntry = _buildOverlay();
      Overlay.of(context, rootOverlay: true)?.insert(_overlayEntry!);
    } else {
      _overlayEntry!.markNeedsBuild();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlay() {
    return OverlayEntry(
      builder: (context) {
        // Find the size of the input field, so we can align the overlay
        final box = context.findRenderObject() as RenderBox?;
        final size = box?.size ??
            (context.findAncestorRenderObjectOfType<RenderBox>()?.size ??
                const Size(300, 48));

        return Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _removeOverlay,
            child: Stack(
              children: [
                CompositedTransformFollower(
                  link: _layerLink,
                  showWhenUnlinked: false,
                  offset: Offset(0, size.height + 4),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(8),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.maxListHeight,
                        minWidth: size.width,
                        maxWidth: size.width,
                      ),
                      child: _buildList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList() {
    final q = _query.trim();
    if (q.isEmpty || q.length < widget.minSearchLength) {
      return widget.emptyBuilder?.call(context, q) ??
          const SizedBox.shrink();
    }

    if (_filtered.isEmpty) {
      return widget.emptyBuilder?.call(context, q) ??
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(widget.noResultsText),
          );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = _filtered[index];
        if (widget.itemBuilder != null) {
          return InkWell(
            onTap: () => _select(item),
            child: widget.itemBuilder!(context, item, _query),
          );
        }
        // Default simple row with highlighted match
        final text = _toDisplay(item);
        return InkWell(
          onTap: () => _select(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18),
                const SizedBox(width: 10),
                Expanded(child: _highlight(text, _query, caseSensitive: widget.caseSensitive)),
              ],
            ),
          ),
        );
      },
    );
  }

  void _select(T value) {
    // Fill the input with the chosen display text
    final text = _toDisplay(value);
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _removeOverlay();
    widget.onSelected(value);
  }

  // Simple highlight (bold) of the matched substring
  Widget _highlight(String source, String query, {required bool caseSensitive}) {
    if (query.isEmpty) return Text(source);
    final s = caseSensitive ? source : source.toLowerCase();
    final q = caseSensitive ? query : query.toLowerCase();
    final i = s.indexOf(q);
    if (i < 0) return Text(source);

    final pre = source.substring(0, i);
    final mid = source.substring(i, i + q.length);
    final post = source.substring(i + q.length);
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: pre),
          TextSpan(text: mid, style: const TextStyle(fontWeight: FontWeight.w700)),
          TextSpan(text: post),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        style: widget.inputTextStyle,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
        onTap: _showOrUpdateOverlay,
      ),
    );
  }
}