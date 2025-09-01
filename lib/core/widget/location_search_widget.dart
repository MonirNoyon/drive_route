import 'package:car_routing_application/features/home/domain/entities/place_details.dart';
import 'package:car_routing_application/features/home/domain/entities/place_suggestions.dart';
import 'package:car_routing_application/features/home/domain/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocationSearchWidget extends ConsumerStatefulWidget {
  const LocationSearchWidget({
    super.key,
    required this.onSuggestedData,
    required this.prefixIcon,
    required this.hintText,

  });

  final Function(PlaceDetails? dd) onSuggestedData;
  final Icon prefixIcon;
  final String hintText;


  @override
  ConsumerState<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends ConsumerState<LocationSearchWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final _controller =  TextEditingController();

  List<PlaceSuggestion> _placeList = [];

  @override
  void initState() {
    super.initState();

  }

  _onChanged() {
      getSuggestion(_controller.text);
  }

  void getSuggestion(String query) async {
    _placeList = await ref.read(getPlaceSuggestionsProvider).call(
      query,
      sessionToken: 'uuid-1',
      countryComponent: 'country:bd',
    );
    // setState(() {});

    _removeOverlay();
    if (_placeList.isNotEmpty) {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 20,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(16, 60),
          child: Material(
            elevation: 4.0,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_placeList[index].description),
                  onTap: () async {
                    String? placeId = _placeList[index].placeId;
                    PlaceDetails? details = await ref.read(getPlaceDetailsProvider).call(placeId, sessionToken: 'uuid-1');
                    _controller.text = _placeList[index].description;
                    FocusNode().unfocus();
                    _removeOverlay();
                    _placeList = [];
                    widget.onSuggestedData(details);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        onChanged: (value)=>_onChanged(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              _controller.clear();
              _removeOverlay();
              _placeList = [];
              // setState(() {
              //   _placeList = [];
              // });
            },
          )
              : null,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }
}